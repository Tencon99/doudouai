import 'package:flutter/material.dart';
import 'dart:math' as math;

class VoiceWaveWidget extends StatefulWidget {
  final bool isRecording;
  final List<double> amplitudes;
  final Color waveColor;
  final int waveCount;
  final double minHeight;
  final double maxHeight;
  final double waveWidth;

  const VoiceWaveWidget({
    super.key,
    required this.isRecording,
    this.amplitudes = const [],
    this.waveColor = Colors.white,
    this.waveCount = 40,
    this.minHeight = 12.0,
    this.maxHeight = 58.0,
    this.waveWidth = 6.0,
  });

  @override
  State<VoiceWaveWidget> createState() => _VoiceWaveWidgetState();
}

class _VoiceWaveWidgetState extends State<VoiceWaveWidget> with TickerProviderStateMixin {
  List<double> _waveHeights = [];
  bool _hasAudioInput = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // 初始化波形高度为最小值
    _waveHeights = List.generate(widget.waveCount, (index) => widget.minHeight);

    // 创建动画控制器用于平滑过渡
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(VoiceWaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRecording && widget.amplitudes.isNotEmpty) {
      // 检测是否有真实的音频输入
      _hasAudioInput = widget.amplitudes.any((amplitude) => amplitude > 0.01);
      _updateAmplitudes(widget.amplitudes);
    } else if (!widget.isRecording) {
      // 停止录音时重置为静态状态
      _resetToStatic();
    } else if (widget.isRecording && widget.amplitudes.isEmpty) {
      // 录音中但没有振幅数据，显示等待状态
      _showWaitingState();
    }
  }

  void _updateAmplitudes(List<double> amplitudes) {
    if (!widget.isRecording || amplitudes.isEmpty) return;

    // 确保振幅数据长度匹配波形数量
    List<double> processedAmplitudes = List.from(amplitudes);

    // 如果振幅数据长度不够，进行插值
    if (processedAmplitudes.length < widget.waveCount) {
      final ratio = widget.waveCount / processedAmplitudes.length;
      final newAmplitudes = <double>[];

      for (int i = 0; i < widget.waveCount; i++) {
        final sourceIndex = (i / ratio).floor();
        final nextIndex = ((i / ratio).floor() + 1).clamp(0, processedAmplitudes.length - 1);
        final t = (i / ratio) - sourceIndex;

        // 线性插值
        final currentAmp = processedAmplitudes[sourceIndex.clamp(0, processedAmplitudes.length - 1)];
        final nextAmp = processedAmplitudes[nextIndex];
        final interpolatedAmp = currentAmp + (nextAmp - currentAmp) * t;

        newAmplitudes.add(interpolatedAmp);
      }
      processedAmplitudes = newAmplitudes;
    } else if (processedAmplitudes.length > widget.waveCount) {
      // 如果振幅数据过多，进行降采样
      final step = processedAmplitudes.length / widget.waveCount;
      final newAmplitudes = <double>[];

      for (int i = 0; i < widget.waveCount; i++) {
        final index = (i * step).floor().clamp(0, processedAmplitudes.length - 1);
        newAmplitudes.add(processedAmplitudes[index]);
      }
      processedAmplitudes = newAmplitudes;
    }

    // 更新波形高度
    for (int i = 0; i < widget.waveCount && i < processedAmplitudes.length; i++) {
      double amplitude = processedAmplitudes[i].clamp(0.0, 1.0);

      // 应用平滑曲线来获得更自然的视觉效果
      amplitude = _applySmoothCurve(amplitude);

      // 计算实际高度
      final targetHeight = widget.minHeight + (widget.maxHeight - widget.minHeight) * amplitude;
      _waveHeights[i] = targetHeight;
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// 应用平滑曲线
  double _applySmoothCurve(double amplitude) {
    // 使用平方根函数来增强低振幅的可见性
    return math.sqrt(amplitude);
  }

  void _showWaitingState() {
    // 录音中但没有数据时，显示微小的脉动
    for (int i = 0; i < widget.waveCount; i++) {
      final phase = DateTime.now().millisecondsSinceEpoch / 1000.0 + i * 0.1;
      final pulse = (math.sin(phase * 2) + 1) / 2; // 0到1之间的脉动
      _waveHeights[i] = widget.minHeight + (widget.minHeight * 0.3 * pulse);
    }

    _hasAudioInput = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _resetToStatic() {
    // 重置所有波形到最小高度（静态状态）
    _waveHeights = List.generate(widget.waveCount, (index) => widget.minHeight);
    _hasAudioInput = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.maxHeight + 20,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.waveCount, (index) {
              double height = _waveHeights[index];

              // 为边缘的波形添加渐变效果
              double opacity = 1.0;
              if (index < 3) {
                opacity = (index + 1) / 4.0;
              } else if (index >= widget.waveCount - 3) {
                opacity = (widget.waveCount - index) / 4.0;
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                width: widget.waveWidth,
                height: height,
                decoration: BoxDecoration(
                  color: widget.waveColor.withOpacity(opacity * 0.9),
                  borderRadius: BorderRadius.circular(widget.waveWidth / 2),
                  boxShadow: widget.isRecording && _hasAudioInput
                      ? [
                          BoxShadow(
                            color: widget.waveColor.withOpacity(0.3),
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
