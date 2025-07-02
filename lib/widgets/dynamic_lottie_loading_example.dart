import 'package:flutter/material.dart';
import 'dynamic_lottie_loading.dart';

/// 动态颜色Lottie加载组件使用示例
class DynamicLottieLoadingExample extends StatefulWidget {
  const DynamicLottieLoadingExample({super.key});

  @override
  State<DynamicLottieLoadingExample> createState() => _DynamicLottieLoadingExampleState();
}

class _DynamicLottieLoadingExampleState extends State<DynamicLottieLoadingExample> {
  Color _selectedColor = Colors.blue;
  double _selectedSpeed = 0.6;
  Duration _selectedDuration = const Duration(milliseconds: 1000);
  bool _useDuration = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态颜色Lottie加载组件示例'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本使用示例
            _buildSection(
              title: '1. 基本使用（自动使用主题色 + 优化的速度）',
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('小型 (慢)', style: TextStyle(fontSize: 12)),
                      SizedBox(height: 8),
                      DotLoading(),
                      Text('speed: 0.5', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('中型 (标准)', style: TextStyle(fontSize: 12)),
                      SizedBox(height: 8),
                      MediumLoading(),
                      Text('speed: 0.6', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('大型 (较快)', style: TextStyle(fontSize: 12)),
                      SizedBox(height: 8),
                      LargeLoading(),
                      Text('speed: 0.7', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 速度控制示例
            _buildSection(
              title: '2. 动画速度控制',
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text('很慢 (0.3x)', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          DynamicLottieLoading(speed: 0.3, width: 50, height: 16),
                        ],
                      ),
                      Column(
                        children: [
                          Text('慢 (0.5x)', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          DynamicLottieLoading(speed: 0.5, width: 50, height: 16),
                        ],
                      ),
                      Column(
                        children: [
                          Text('标准 (1.0x)', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          DynamicLottieLoading(speed: 1.0, width: 50, height: 16),
                        ],
                      ),
                      Column(
                        children: [
                          Text('快 (1.5x)', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          DynamicLottieLoading(speed: 1.5, width: 50, height: 16),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 动态速度控制器
                  Column(
                    children: [
                      const Text('动态速度控制:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DynamicLottieLoading(
                        color: _selectedColor,
                        speed: _selectedSpeed,
                        width: 80,
                        height: 28,
                      ),
                      const SizedBox(height: 10),
                      Text('当前速度: ${_selectedSpeed.toStringAsFixed(1)}x'),
                      Slider(
                        value: _selectedSpeed,
                        min: 0.1,
                        max: 2.0,
                        divisions: 19,
                        label: '${_selectedSpeed.toStringAsFixed(1)}x',
                        onChanged: (value) => setState(() => _selectedSpeed = value),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 自定义时长示例
            _buildSection(
              title: '3. 自定义动画时长',
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text('0.5秒', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          DynamicLottieLoading(
                            duration: Duration(milliseconds: 500),
                            width: 50,
                            height: 16,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('1秒', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          DynamicLottieLoading(
                            duration: Duration(milliseconds: 1000),
                            width: 50,
                            height: 16,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('2秒', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          DynamicLottieLoading(
                            duration: Duration(milliseconds: 2000),
                            width: 50,
                            height: 16,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('3秒', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          DynamicLottieLoading(
                            duration: Duration(milliseconds: 3000),
                            width: 50,
                            height: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 动态时长控制器
                  Column(
                    children: [
                      const Text('动态时长控制:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DynamicLottieLoading(
                        color: _selectedColor,
                        duration: _selectedDuration,
                        width: 80,
                        height: 28,
                      ),
                      const SizedBox(height: 10),
                      Text('当前时长: ${_selectedDuration.inMilliseconds}ms'),
                      Slider(
                        value: _selectedDuration.inMilliseconds.toDouble(),
                        min: 200,
                        max: 3000,
                        divisions: 28,
                        label: '${_selectedDuration.inMilliseconds}ms',
                        onChanged: (value) => setState(() => _selectedDuration = Duration(milliseconds: value.round())),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 自定义颜色示例
            _buildSection(
              title: '4. 自定义颜色',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildColorExample('红色', Colors.red),
                      _buildColorExample('绿色', Colors.green),
                      _buildColorExample('橙色', Colors.orange),
                      _buildColorExample('紫色', Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 动态颜色选择器
                  Column(
                    children: [
                      const Text('动态颜色控制:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DynamicLottieLoading(
                        color: _selectedColor,
                        speed: _selectedSpeed,
                        width: 80,
                        height: 28,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          Colors.red,
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.purple,
                          Colors.teal,
                          Colors.pink,
                          Colors.indigo,
                        ]
                            .map((color) => GestureDetector(
                                  onTap: () => setState(() => _selectedColor = color),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: _selectedColor == color ? Border.all(color: Colors.black, width: 2) : null,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 使用场景示例
            _buildSection(
              title: '5. 实际使用场景',
              child: Column(
                children: [
                  _buildUsageExample(
                    '聊天加载（慢速，轻柔）',
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('AI正在思考'),
                          SizedBox(width: 8),
                          DotLoading(), // speed: 0.5，很慢很轻柔
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUsageExample(
                    '页面加载（标准速度）',
                    const Center(
                      child: Column(
                        children: [
                          MediumLoading(), // speed: 0.6，标准速度
                          SizedBox(height: 8),
                          Text('加载中...', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUsageExample(
                    '重要操作（较快速度）',
                    ElevatedButton(
                      onPressed: null,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DynamicLottieLoading(
                            width: 16,
                            height: 6,
                            color: Colors.white,
                            speed: 0.8, // 稍快一些，表示紧急感
                          ),
                          SizedBox(width: 8),
                          Text('处理中...'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUsageExample(
                    '缓慢的背景任务（超慢速）',
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('同步中', style: TextStyle(color: Colors.grey)),
                          SizedBox(width: 8),
                          DynamicLottieLoading(
                            width: 30,
                            height: 10,
                            speed: 0.3, // 很慢，不打扰用户
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 代码示例
            _buildSection(
              title: '6. 代码使用示例',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '''// 基本使用（自动使用主题色 + 优化速度）
const DotLoading()     // 慢速 (0.5x)
const MediumLoading()  // 标准 (0.6x) 
const LargeLoading()   // 较快 (0.7x)

// 自定义速度
const DynamicLottieLoading(speed: 0.3)  // 很慢
const DynamicLottieLoading(speed: 1.5)  // 快速

// 自定义时长（精确控制）
const DynamicLottieLoading(
  duration: Duration(milliseconds: 1500),
)

// 综合自定义
const DynamicLottieLoading(
  color: Colors.blue,
  speed: 0.8,
  width: 80,
  height: 28,
)

// 在聊天中使用（轻柔缓慢）
Row(
  children: [
    Text('AI正在回复'),
    SizedBox(width: 8),
    DotLoading(), // 自带慢速效果
  ],
)

// 重要加载提示（稍快）
Column(
  children: [
    LargeLoading(), // 自带较快效果
    Text('正在处理重要数据...'),
  ],
)''',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildColorExample(String label, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        DynamicLottieLoading(
          color: color,
          width: 50,
          height: 16,
          speed: 0.6, // 使用标准速度展示颜色
        ),
      ],
    );
  }

  Widget _buildUsageExample(String title, Widget example) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        example,
      ],
    );
  }
}
