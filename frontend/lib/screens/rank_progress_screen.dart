import 'package:flutter/material.dart';

class RankProgressScreen extends StatelessWidget {
  final String currentRank;
  final int points;

  const RankProgressScreen({
    super.key,
    required this.currentRank,
    required this.points,
  });

  static const List<Map<String, dynamic>> _rankLadder = [
    {'name': 'Explorer', 'points': 0, 'icon': Icons.explore_rounded},
    {'name': 'Wanderer', 'points': 500, 'icon': Icons.directions_walk_rounded},
    {'name': 'Pathfinder', 'points': 1500, 'icon': Icons.map_rounded},
    {'name': 'Adventurer', 'points': 3000, 'icon': Icons.terrain_rounded},
    {'name': 'Globetrotter', 'points': 6000, 'icon': Icons.public_rounded},
    {'name': 'World Traveler', 'points': 10000, 'icon': Icons.flight_takeoff_rounded},
    {'name': 'Travel Legend', 'points': 20000, 'icon': Icons.workspace_premium_rounded},
  ];

  int _getNextThreshold() {
    if (points < 500) return 500;
    if (points < 1500) return 1500;
    if (points < 3000) return 3000;
    if (points < 6000) return 6000;
    if (points < 10000) return 10000;
    if (points < 20000) return 20000;
    return 20000; // maxed out
  }

  String _getNextRankName() {
    if (points < 500) return 'Wanderer';
    if (points < 1500) return 'Pathfinder';
    if (points < 3000) return 'Adventurer';
    if (points < 6000) return 'Globetrotter';
    if (points < 10000) return 'World Traveler';
    if (points < 20000) return 'Travel Legend';
    return 'Max Rank';
  }

  double _calculateProgress(int nextThreshold) {
    int currentFloor = 0;
    if (points >= 10000 && points < 20000) {
      currentFloor = 10000;
    } else if (points >= 6000 && points < 10000) {
      currentFloor = 6000;
    } else if (points >= 3000 && points < 6000) {
      currentFloor = 3000;
    } else if (points >= 1500 && points < 3000) {
      currentFloor = 1500;
    } else if (points >= 500 && points < 1500) {
      currentFloor = 500;
    } else {
      currentFloor = 0;
    }

    final double denominator = (nextThreshold - currentFloor).toDouble();
    return (points >= 20000 || denominator <= 0)
        ? 1.0
        : ((points - currentFloor) / denominator).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextThreshold = _getNextThreshold();
    final progress = _calculateProgress(nextThreshold);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Rank Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeroSection(progress, nextThreshold),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Rank Ladder',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _rankLadder.length,
              itemBuilder: (context, index) {
                final rank = _rankLadder[index];
                final isCurrent = rank['name'] == currentRank;
                final isPassed = points >= (rank['points'] as int);

                return _buildRankTile(theme, rank, isCurrent, isPassed);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(double progress, int nextThreshold) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade300, Colors.amber.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, size: 64, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            currentRank,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$points Travel Points',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.4),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (points < 20000)
            Text(
              '${nextThreshold - points} pts to ${_getNextRankName()}',
              style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
            )
          else
            const Text(
              'Maximum Rank Reached!',
              style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildRankTile(ThemeData theme, Map<String, dynamic> rank, bool isCurrent, bool isPassed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrent 
            ? Colors.amber.shade100 
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isPassed ? Colors.amber : theme.colorScheme.surface,
          child: Icon(
            rank['icon'], 
            color: isPassed ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          rank['name'],
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
            fontSize: 18,
            color: isCurrent ? Colors.amber.shade900 : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${rank['points']} pts',
          style: TextStyle(
            color: isCurrent ? Colors.amber.shade800 : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: isCurrent
            ? const Icon(Icons.check_circle_rounded, color: Colors.amber, size: 28)
            : (isPassed ? const Icon(Icons.check_rounded, color: Colors.green) : null),
      ),
    );
  }
}
