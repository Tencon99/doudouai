import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// 动态颜色控制的 Lottie 加载动画组件
///
/// 支持自定义颜色、尺寸、适配方式和动画时间
/// 如果不指定颜色，会自动使用当前主题的primary color
class DynamicLottieLoading extends StatefulWidget {
  /// 自定义颜色，如果为null则使用主题primary color
  final Color? color;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 适配方式
  final BoxFit? fit;

  /// 是否重复播放
  final bool repeat;

  /// 是否反向播放
  final bool reverse;

  /// 动画播放速度 (1.0 = 正常速度, 0.5 = 一半速度, 2.0 = 两倍速度)
  final double speed;

  /// 自定义动画时长，如果设置了此参数，speed参数将被忽略
  final Duration? duration;

  const DynamicLottieLoading({
    super.key,
    this.color,
    this.width = 60,
    this.height = 20,
    this.fit,
    this.repeat = true,
    this.reverse = false,
    this.speed = 0.6, // 默认比原速度慢40%，更舒缓
    this.duration,
  });

  @override
  State<DynamicLottieLoading> createState() => _DynamicLottieLoadingState();
}

class _DynamicLottieLoadingState extends State<DynamicLottieLoading> with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    // 计算动画时长
    Duration animationDuration;
    if (widget.duration != null) {
      animationDuration = widget.duration!;
    } else {
      // 原始动画大约是 40 frames，60fps，所以大约 667ms
      // 根据speed参数调整时长
      const baseDuration = Duration(milliseconds: 667);
      animationDuration = Duration(
        milliseconds: (baseDuration.inMilliseconds / widget.speed).round(),
      );
    }

    _controller = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    if (widget.repeat) {
      _controller!.repeat(reverse: widget.reverse);
    } else {
      _controller!.forward();
    }
  }

  @override
  void didUpdateWidget(DynamicLottieLoading oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果动画相关参数发生变化，重新创建controller
    if (widget.duration != oldWidget.duration ||
        widget.speed != oldWidget.speed ||
        widget.repeat != oldWidget.repeat ||
        widget.reverse != oldWidget.reverse) {
      _controller?.dispose();
      _createController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 如果没有指定颜色，使用主题的primary color
    final dotColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return Lottie.asset(
      'assets/lottie/dot_loading.json',
      delegates: LottieDelegates(
        values: [
          // 为所有三个点设置相同的颜色
          ValueDelegate.color(
            const ['Shape Layer 1', 'Ellipse 1', 'Fill 1'],
            value: dotColor,
          ),
          ValueDelegate.color(
            const ['Shape Layer 2', 'Ellipse 1', 'Fill 1'],
            value: dotColor,
          ),
          ValueDelegate.color(
            const ['Shape Layer 3', 'Ellipse 1', 'Fill 1'],
            value: dotColor,
          ),
        ],
      ),
      controller: _controller,
      width: widget.width,
      height: widget.height,
      fit: widget.fit ?? BoxFit.contain,
    );
  }
}

/// 小型的点状加载动画 - 最慢最轻柔
class DotLoading extends DynamicLottieLoading {
  const DotLoading({
    super.key,
    super.color,
    super.speed = 0.5, // 最慢的动画，适合小巧的提示
    super.duration,
  }) : super(
          width: 28,
          height: 7,
        );
}

/// 中等大小的加载动画 - 标准速度
class MediumLoading extends DynamicLottieLoading {
  const MediumLoading({
    super.key,
    super.color,
    super.speed = 0.6, // 标准速度
    super.duration,
  }) : super(
          width: 40,
          height: 12,
        );
}

/// 大型的加载动画 - 稍快一些
class LargeLoading extends DynamicLottieLoading {
  const LargeLoading({
    super.key,
    super.color,
    super.speed = 0.7, // 稍快的动画，适合重要的加载提示
    super.duration,
  }) : super(
          width: 60,
          height: 20,
        );
}
