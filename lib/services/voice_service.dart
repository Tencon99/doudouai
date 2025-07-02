import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class VoiceService extends ChangeNotifier {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final AudioRecorder _audioRecorder = AudioRecorder();
  final SpeechToText _speechToText = SpeechToText();

  bool _isRecording = false;
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';
  String _currentWords = '';
  List<double> _currentAmplitudes = [];
  Timer? _amplitudeTimer;

  // 音频流相关
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  List<double> _audioBuffer = [];
  static const int _bufferSize = 1024; // 音频缓冲区大小
  static const int _sampleRate = 16000; // 采样率
  static const int _amplitudeCount = 45; // 波形数量（用户要求40-50个）

  // 音频检测相关
  bool _isDetectingAudio = false;
  double _lastSpeechTime = 0;
  double _silenceThreshold = 0.02; // 静音阈值

  // 平台支持检测
  bool get _isPlatformSupported {
    if (kIsWeb) return true;
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) return true;
    return false; // Windows, Linux 等不支持的平台
  }

  // Getters
  bool get isRecording => _isRecording;
  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;
  bool get isPlatformSupported => _isPlatformSupported;
  String get lastWords => _lastWords;
  String get currentWords => _currentWords;
  List<double> get currentAmplitudes => List.from(_currentAmplitudes);

  /// 初始化语音服务
  Future<bool> initialize() async {
    try {
      if (_speechEnabled) return true;

      // 检查麦克风权限
      final micPermission = await Permission.microphone.request();
      if (micPermission != PermissionStatus.granted) {
        debugPrint('麦克风权限被拒绝');
        return false;
      }

      if (_isPlatformSupported) {
        // 支持的平台：初始化语音识别
        try {
          _speechEnabled = await _speechToText.initialize(
            onStatus: _onSpeechStatus,
            onError: _onSpeechError,
          );
          debugPrint('语音识别初始化成功: $_speechEnabled');
        } catch (e) {
          debugPrint('语音识别初始化失败: $e');
          _speechEnabled = false;
        }
      } else {
        // 不支持的平台：只提供录音功能
        _speechEnabled = false;
        debugPrint('当前平台不支持语音识别，仅提供录音和波形显示功能');
      }

      // 初始化振幅数组
      _currentAmplitudes = List.filled(_amplitudeCount, 0.0);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('语音服务初始化失败: $e');
      return false;
    }
  }

  /// 开始录音和语音识别
  Future<void> startListening() async {
    if (_isRecording) return;

    try {
      // 检查录音权限
      if (!await _audioRecorder.hasPermission()) {
        debugPrint('没有录音权限');
        return;
      }

      // 开始录音流
      final audioStream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits, // 使用PCM16位编码以便处理原始音频数据
          bitRate: 128000,
          sampleRate: _sampleRate,
          numChannels: 1, // 单声道
        ),
      );

      debugPrint('开始录音流，采样率: $_sampleRate');
      _isRecording = true;
      _isDetectingAudio = false;
      _lastSpeechTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

      // 监听音频流数据
      _audioStreamSubscription = audioStream.listen(
        _onAudioData,
        onError: (error) {
          debugPrint('音频流错误: $error');
          _stopAudioStream();
        },
        onDone: () {
          debugPrint('音频流结束');
          _stopAudioStream();
        },
      );

      // 如果平台支持，开始语音识别
      if (_isPlatformSupported && _speechEnabled) {
        try {
          await _speechToText.listen(
            onResult: _onSpeechResult,
            listenFor: const Duration(minutes: 5),
            pauseFor: const Duration(seconds: 3),
            cancelOnError: false,
            partialResults: true,
          );
          _isListening = true;
        } catch (e) {
          debugPrint('启动语音识别失败: $e');
        }
      } else {
        // 不支持的平台：模拟监听状态
        _isListening = true;
        _currentWords = _isPlatformSupported ? '' : '当前平台不支持语音识别';
      }

      notifyListeners();
    } catch (e) {
      debugPrint('开始录音失败: $e');
    }
  }

  /// 处理音频流数据
  void _onAudioData(Uint8List audioData) {
    if (!_isRecording) return;

    // 将字节数据转换为16位PCM样本
    final samples = <double>[];
    for (int i = 0; i < audioData.length - 1; i += 2) {
      // 组合两个字节为一个16位样本（小端序）
      final sample = (audioData[i + 1] << 8) | audioData[i];
      // 转换为有符号16位整数
      final signedSample = sample > 32767 ? sample - 65536 : sample;
      // 归一化到 -1.0 到 1.0 范围
      samples.add(signedSample / 32768.0);
    }

    if (samples.isEmpty) return;

    // 更新音频缓冲区
    _audioBuffer.addAll(samples);

    // 保持缓冲区大小
    if (_audioBuffer.length > _bufferSize * 2) {
      _audioBuffer = _audioBuffer.sublist(_audioBuffer.length - _bufferSize);
    }

    // 计算振幅并更新波形
    _calculateAmplitudesFromAudio();
  }

  /// 从音频数据计算振幅
  void _calculateAmplitudesFromAudio() {
    if (_audioBuffer.isEmpty || !_isRecording) return;

    final chunkSize = math.max(1, _audioBuffer.length ~/ _amplitudeCount);
    final newAmplitudes = <double>[];

    for (int i = 0; i < _amplitudeCount; i++) {
      final startIdx = i * chunkSize;
      final endIdx = math.min(startIdx + chunkSize, _audioBuffer.length);

      if (startIdx >= _audioBuffer.length) {
        newAmplitudes.add(0.0);
        continue;
      }

      // 计算RMS (Root Mean Square) 作为振幅
      double sum = 0.0;
      int count = 0;
      for (int j = startIdx; j < endIdx; j++) {
        sum += _audioBuffer[j] * _audioBuffer[j];
        count++;
      }

      final rms = count > 0 ? math.sqrt(sum / count) : 0.0;

      // 应用对数缩放以获得更好的视觉效果
      final amplitude = math.min(1.0, rms * 10.0); // 放大10倍并限制最大值
      newAmplitudes.add(amplitude);
    }

    // 检测是否有音频活动
    final maxAmplitude = newAmplitudes.reduce(math.max);
    final hasAudioActivity = maxAmplitude > _silenceThreshold;

    if (hasAudioActivity) {
      _lastSpeechTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      _isDetectingAudio = true;
    }

    // 更新振幅数据
    _currentAmplitudes = newAmplitudes;
    notifyListeners();
  }

  /// 停止音频流
  void _stopAudioStream() {
    _audioStreamSubscription?.cancel();
    _audioStreamSubscription = null;
    _audioBuffer.clear();
  }

  /// 停止录音和语音识别
  Future<String> stopListening() async {
    if (!_isRecording) return '';

    try {
      // 停止录音流
      await _audioRecorder.stop();
      _stopAudioStream();
      _isRecording = false;

      // 停止语音识别
      if (_isPlatformSupported && _isListening && _speechEnabled) {
        await _speechToText.stop();
      }
      _isListening = false;

      // 重置波形到静止状态
      _currentAmplitudes = List.filled(_amplitudeCount, 0.0);
      _isDetectingAudio = false;

      // 对于不支持的平台，提供友好的提示
      if (!_isPlatformSupported) {
        _lastWords = '录音已完成，但当前平台不支持语音转文字';
        _currentWords = _lastWords;
      } else if (_speechEnabled) {
        _lastWords = _currentWords;
      } else {
        _lastWords = '语音识别不可用';
        _currentWords = _lastWords;
      }

      notifyListeners();
      return _lastWords;
    } catch (e) {
      debugPrint('停止录音失败: $e');
      _isRecording = false;
      _isListening = false;
      _stopAudioStream();
      _currentAmplitudes = List.filled(_amplitudeCount, 0.0);
      notifyListeners();
      return '';
    }
  }

  /// 取消录音
  Future<void> cancelListening() async {
    if (!_isRecording) return;

    try {
      await _audioRecorder.stop();
      _stopAudioStream();
      _isRecording = false;

      if (_isPlatformSupported && _isListening && _speechEnabled) {
        await _speechToText.cancel();
      }
      _isListening = false;

      _currentAmplitudes = List.filled(_amplitudeCount, 0.0);
      _currentWords = '';
      _isDetectingAudio = false;
      notifyListeners();
    } catch (e) {
      debugPrint('取消录音失败: $e');
    }
  }

  /// 开始音频检测（现在已不需要，因为使用实时音频流）
  void _startAudioDetection() {
    // 保留此方法以保持向后兼容，但现在使用实时音频流数据
  }

  /// 停止音频检测
  void _stopAudioDetection() {
    _amplitudeTimer?.cancel();
    _currentAmplitudes = List.filled(_amplitudeCount, 0.0);
    _isDetectingAudio = false;
    notifyListeners();
  }

  /// 检测音频活动（保留用于兼容性）
  void _detectAudioActivity() {
    // 现在由 _calculateAmplitudesFromAudio 处理
  }

  /// 更新音频振幅数据（保留用于兼容性）
  void _updateAmplitudes(bool hasAudioActivity) {
    // 现在由 _calculateAmplitudesFromAudio 处理
  }

  /// 语音识别结果回调
  void _onSpeechResult(result) {
    _currentWords = result.recognizedWords;
    notifyListeners();
  }

  /// 语音识别状态回调
  void _onSpeechStatus(String status) {
    debugPrint('语音识别状态: $status');
    if (status == 'listening') {
      _isListening = true;
    } else if (status == 'notListening') {
      _isListening = false;
    }
    notifyListeners();
  }

  /// 语音识别错误回调
  void _onSpeechError(error) {
    debugPrint('语音识别错误: $error');
    _isListening = false;
    notifyListeners();
  }

  /// 检查语音识别是否可用
  Future<bool> checkSpeechAvailability() async {
    if (!_isPlatformSupported) return false;

    if (!_speechEnabled) {
      _speechEnabled = await _speechToText.initialize();
    }
    return _speechEnabled;
  }

  /// 获取平台信息
  String getPlatformInfo() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// 获取功能状态描述
  String getFeatureStatus() {
    if (!_isPlatformSupported) {
      return '当前平台 (${getPlatformInfo()}) 支持录音和波形显示，但不支持语音转文字';
    }

    if (_speechEnabled) {
      return '语音识别功能正常可用';
    } else {
      return '语音识别功能不可用，请检查权限设置';
    }
  }

  /// 清理资源
  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    _stopAudioStream();
    _audioRecorder.dispose();
    super.dispose();
  }
}
