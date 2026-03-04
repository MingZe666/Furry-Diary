import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProPurchasePage extends StatefulWidget {
  const ProPurchasePage({super.key});

  @override
  State<ProPurchasePage> createState() => _ProPurchasePageState();
}

class _ProPurchasePageState extends State<ProPurchasePage> {
  // 0: 连续包月, 1: 连续包年
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('升级 Pro 会员',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header icon
            Icon(
              Icons.stars_rounded,
              size: 100,
              color: Colors.amber.shade400,
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),

            // Title
            const Text(
              '解锁所有高级特权',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                '记录爱宠的点点滴滴，不再受限。立即升级获得更加完善的管理体验。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 40),

            // Features list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildFeatureItem(
                    icon: Icons.pets,
                    title: '无限制宠物数量',
                    description: '想添加多少只毛孩子都可以，管理无忧。',
                    delay: 400,
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    icon: Icons.monitor_heart,
                    title: '无限健康日志',
                    description: '打破免费版 10 条记录上限，完整掌握健康走势。',
                    delay: 500,
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    icon: Icons.cloud_sync,
                    title: '数据多端同步',
                    description: '您的宠物数据云端备份，无论何地皆可访问。',
                    delay: 600,
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    icon: Icons.insights,
                    title: '专属健康报表',
                    description: '自动生成图表及统计报告，健康状态一目了然。',
                    delay: 700,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Pricing Cards Mock
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildPriceCard(
                      context: context,
                      title: '连续包月',
                      price: '￥5',
                      period: '/ 月',
                      isSelected: _selectedIndex == 0,
                      onTap: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPriceCard(
                      context: context,
                      title: '连续包年',
                      price: '￥50',
                      period: '/ 年',
                      isSelected: _selectedIndex == 1,
                      tag: '立省10元',
                      onTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
            ),

            const SizedBox(height: 32),

            // Purchase Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    // 模拟支付逻辑
                    _mockPurchase(context);
                  },
                  child: const Text('立即开通',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ).animate().scale(delay: 1000.ms, curve: Curves.easeOutBack),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // mock restore
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已尝试恢复购买状态')),
                );
              },
              child: Text('恢复购买',
                  style: TextStyle(color: theme.colorScheme.primary)),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.amber.shade700, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildPriceCard({
    required BuildContext context,
    required String title,
    required String price,
    required String period,
    required bool isSelected,
    required VoidCallback onTap,
    String? tag,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(price,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary)),
                    Text(period, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          if (tag != null)
            Positioned(
              top: -10,
              right: 0,
              left: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _mockPurchase(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('支付确认'),
        content: const Text('这是功能演示节点，在此进行内购或支付接入完成订阅流程。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('内购流程尚未完全接入，当前为模拟完成。')),
              );
            },
            child: const Text('确认支付'),
          ),
        ],
      ),
    );
  }
}
