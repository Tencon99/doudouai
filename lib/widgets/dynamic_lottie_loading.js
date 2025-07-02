import React, { useEffect, useState } from 'react';
import Lottie from 'react-lottie';
import { useTheme } from '@material-ui/core/styles'; // 使用Material-UI获取主题

// 动态颜色控制的 Lottie 加载动画组件
const DynamicLottieLoading = ({
  color,
  width = 60,
  height = 20,
  fit = 'contain',
  repeat = true,
  reverse = false,
  speed = 0.6, // 默认比原速度慢40%，更舒缓
  duration,
}) => {
  const theme = useTheme();
  const [animationData, setAnimationData] = useState(null);

  useEffect(() => {
    // 动态获取Lottie动画数据
    import('../assets/lottie/dot_loading.json').then((data) => {
      setAnimationData(data.default);
    });
  }, []);

  // 如果没有指定颜色，使用主题的primary color
  const dotColor = color || theme.palette.primary.main;

  const options = {
    animationData: animationData,
    loop: repeat,
    autoplay: true, // 开始播放
    rendererSettings: {
      preserveAspectRatio: fit,
      className: 'lottie-animation',
    },
    speed: speed,
  };

  const style = {
    width: `${width}px`,
    height: `${height}px`,
  };

  return (
    <div style={style}>
      {animationData && (
        <Lottie
          options={options}
          isClickToPauseDisabled
          eventListeners={[
            {
              eventName: 'enterFrame',
              callback: (e) => {
                if (e.currentTime >= duration) {
                  e.target.stop();
                }
              },
            },
          ]}
        />
      )}
    </div>
  );
};

// 小型的点状加载动画 - 最慢最轻柔
const DotLoading = ({ color, speed = 0.5, duration }) => (
  <DynamicLottieLoading
    color={color}
    speed={speed}
    duration={duration}
    width={28}
    height={7}
  />
);

// 中等大小的加载动画 - 标准速度
const MediumLoading = ({ color, speed = 0.6, duration }) => (
  <DynamicLottieLoading
    color={color}
    speed={speed}
    duration={duration}
    width={40}
    height={12}
  />
);

// 大型的加载动画 - 稍快一些
const LargeLoading = ({ color, speed = 0.7, duration }) => (
  <DynamicLottieLoading
    color={color}
    speed={speed}
    duration={duration}
    width={60}
    height={20}
  />
);

export { DotLoading, MediumLoading, LargeLoading };
