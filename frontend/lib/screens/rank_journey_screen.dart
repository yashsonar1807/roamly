import 'package:flutter/material.dart';

class RankJourneyScreen extends StatelessWidget {
  const RankJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ranks = [
      {'name': 'Novice', 'tp': '0 - 1,000 TP', 'icon': Icons.star_border, 'color': Colors.grey},
      {'name': 'Explorer', 'tp': '1,000 - 5,000 TP', 'icon': Icons.star_half, 'color': Colors.blue},
      {'name': 'Adventurer', 'tp': '5,000 - 10,000 TP', 'icon': Icons.star, 'color': Colors.purple},
      {'name': 'World Traveler', 'tp': '10,000+ TP', 'icon': Icons.stars, 'color': Colors.amber},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rank Journey'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: ranks.length,
        itemBuilder: (context, index) {
          final isUnlocked = index <= 1; // Dummy check
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUnlocked ? ranks[index]['color'] as Color : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ranks[index]['icon'] as IconData,
                      color: isUnlocked ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      size: 32,
                    ),
                  ),
                  if (index != ranks.length - 1)
                    Container(
                      width: 2,
                      height: 50,
                      color: isUnlocked ? ranks[index]['color'] as Color : theme.colorScheme.outline,
                    ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ranks[index]['name'] as String,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: isUnlocked ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ranks[index]['tp'] as String,
                        style: TextStyle(
                          color: isUnlocked ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
