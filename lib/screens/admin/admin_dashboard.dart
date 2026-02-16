import 'package:flutter/material.dart';
import '../../widgets/navigation/admin_stats_card.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine crossAxisCount based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    // Assuming side nav takes ~80px or more.
    final availableWidth = screenWidth - 100;
    final crossAxisCount = availableWidth > 1200
        ? 4
        : availableWidth > 800
        ? 3
        : availableWidth > 600
        ? 2
        : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              StatsCard(
                title: 'Total Users',
                value: '12,345',
                icon: Icons.people,
                color: Color(0xFF6200EE),
                trend: 5.2,
              ),
              StatsCard(
                title: 'Active Attractions',
                value: '84',
                icon: Icons.place,
                color: Color(0xFF03DAC6),
                trend: 1.8,
              ),
              StatsCard(
                title: 'Pending Reviews',
                value: '23',
                icon: Icons.rate_review,
                color: Colors.orange,
                trend: -0.5,
              ),
              StatsCard(
                title: 'Total Revenue',
                value: '\$45.2k',
                icon: Icons.attach_money,
                color: Colors.green,
                trend: 12.0,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: ListView.separated(
              itemCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) =>
                  const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
                    ),
                  ),
                  title: Text('User ${index + 1} posted a review'),
                  subtitle: Text('${index * 5 + 2} minutes ago'),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
