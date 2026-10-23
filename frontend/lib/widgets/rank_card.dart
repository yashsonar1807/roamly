import 'package:flutter/material.dart';
import '../screens/rank_progress_screen.dart';

class RankCard extends StatelessWidget {
  final String rank;
  final int points;

  const RankCard({
    super.key,
    required this.rank,
    required this.points,
  });

  int getNextThreshold() {
    if (points < 500) return 500;
    if (points < 1500) return 1500;
    if (points < 3000) return 3000;
    if (points < 6000) return 6000;
    if (points < 10000) return 10000;
    if (points < 20000) return 20000;
    return 20000; // maxed out
  }

  String getNextRankName() {
    if (points < 500) return 'Wanderer';
    if (points < 1500) return 'Pathfinder';
    if (points < 3000) return 'Adventurer';
    if (points < 6000) return 'Globetrotter';
    if (points < 10000) return 'World Traveler';
    if (points < 20000) return 'Travel Legend';
    return 'Max Rank';
  }

  @override
  Widget build(BuildContext context) {
    final nextThreshold = getNextThreshold();
    
    // To make progress bar visually accurate for the current level tier,
    // we should calculate progress relative to the tier span.
    // e.g. if I have 700 pts (Wanderer is 500, Pathfinder is 1500),
    // Progress should be (700-500) / (1500-500)
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
    final double progress = (points >= 20000 || denominator <= 0)
        ? 1.0
        : ((points - currentFloor) / denominator).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RankProgressScreen(
              currentRank: rank,
              points: points,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade200, Colors.amber.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 8),
                  Text(
                    rank,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$points pts',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.4),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Rank',
                style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
              ),
              if (points < 20000)
                Text(
                  '${nextThreshold - points} pts to ${getNextRankName()}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w800),
                )
              else
                const Text(
                  'Maximum Rank Reached!',
                  style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w800),
                ),
            ],
          ),
        ],
      ),
    ));
  }
}
