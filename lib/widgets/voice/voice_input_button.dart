import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:doudouai/utils/platform.dart';
import 'package:doudouai/services/voice_service.dart';
import 'package:doudouai/widgets/voice/voice_wave_widget.dart';
import 'package:doudouai/widgets/ink_icon.dart';
import 'package:doudouai/generated/app_localizations.dart';

class VoiceInputButton extends StatefulWidget {
  final bool disabled;
  final ValueChanged<String>? onVoiceResult;
  final VoidCallback? onVoiceStart;
  final VoidCallback? onVoiceEnd;

  const VoiceInputButton({
    super.key,
    this.disabled = false,
    this.onVoiceResult,
    this.onVoiceStart,
    this.onVoiceEnd,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _showWaveform = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化脉冲动画
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _initializeVoiceService();
    _voiceService.addListener(_onVoiceServiceChange);
  }

  Future<void> _initializeVoiceService() async {
    _isInitialized = await _voiceService.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  void _onVoiceServiceChange() {
    if (mounted) {
      setState(() {
        _isRecording = _voiceService.isRecording;
      });
    }
  }

  Future<void> _startRecording() async {
    if (widget.disabled || !_isInitialized || _isRecording) return;

    widget.onVoiceStart?.call();

    await _voiceService.startListening();
    setState(() {
      _showWaveform = true;
    });
    _pulseController.repeat(reverse: true);
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    _pulseController.stop();
    _pulseController.reset();

    final result = await _voiceService.stopListening();

    setState(() {
      _showWaveform = false;
    });

    widget.onVoiceEnd?.call();

    if (result.isNotEmpty) {
      widget.onVoiceResult?.call(result);
    }
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording) return;

    _pulseController.stop();
    _pulseController.reset();

    await _voiceService.cancelListening();

    setState(() {
      _showWaveform = false;
    });

    widget.onVoiceEnd?.call();
  }

  @override
  void dispose() {
    _voiceService.removeListener(_onVoiceServiceChange);
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildVoiceWaveformDialog() {
    return Dialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.listening,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // 语音波形显示
            VoiceWaveWidget(
              isRecording: _isRecording,
              amplitudes: _voiceService.currentAmplitudes,
              waveColor: Colors.white,
            ),

            const SizedBox(height: 10),

            // 实时识别文本
            if (_voiceService.currentWords.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _voiceService.currentWords,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),

            // 控制按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 取消按钮
                Material(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: _cancelRecording,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // 停止按钮
                Material(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: _stopRecording,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.stop,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return InkIcon(
        icon: CupertinoIcons.mic_off,
        disabled: true,
        tooltip: AppLocalizations.of(context)!.voiceNotAvailable,
      );
    }

    if (_showWaveform) {
      return _buildVoiceWaveformDialog();
    }

    if (kIsMobile) {
      // 移动端：长按触发
      return GestureDetector(
        onLongPressStart: (_) => _startRecording(),
        onLongPressEnd: (_) => _stopRecording(),
        onLongPressCancel: () => _cancelRecording(),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isRecording ? _pulseAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _isRecording ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
                  color: _isRecording ? Colors.red : Theme.of(context).iconTheme.color,
                  size: 20,
                ),
              ),
            );
          },
        ),
      );
    } else {
      // 桌面端：点击触发
      return InkIcon(
        icon: _isRecording ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
        onTap: widget.disabled
            ? null
            : () async {
                if (_isRecording) {
                  await _stopRecording();
                } else {
                  await _startRecording();
                }
              },
        disabled: widget.disabled,
        tooltip: _isRecording ? AppLocalizations.of(context)!.stopVoice : AppLocalizations.of(context)!.startVoice,
      );
    }
  }
}
