import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/colors.dart';
import '../utils/animations.dart';

class TravelCirclesScreen extends StatelessWidget {
  const TravelCirclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Travel Circles',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          BounceScale(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Circle coming soon!')),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.add_circle_outline_rounded, size: 28),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: 4,
        itemBuilder: (context, index) {
          final titles = ['Digital Nomads Bali', 'Euro Backpackers', 'Himalayan Hikers', 'Foodies in Japan'];
          final members = ['12K Members', '45K Members', '8K Members', '22K Members'];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 24.0),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: CachedNetworkImage(
                      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80', // Placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.storyGradient,
                        ),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundImage: CachedNetworkImageProvider(
                            'https://ui-avatars.com/api/?name=Circle&background=random&format=png',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titles[index], 
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              members[index], 
                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      BounceScale(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Join',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
