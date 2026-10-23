import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/colors.dart';

class StoryViewerDialog extends StatefulWidget {
  final List<dynamic> stories;
  final int initialIndex;

  const StoryViewerDialog({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  static void show(BuildContext context, List<dynamic> stories, int initialIndex) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => StoryViewerDialog(
        stories: stories,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  State<StoryViewerDialog> createState() => _StoryViewerDialogState();
}

class _StoryViewerDialogState extends State<StoryViewerDialog> with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _progressController;
  bool _isLiked = false;

  // Curated vivid travel photography backdrops for demo stories
  final List<Map<String, String>> _sampleStoryScenes = [
    {
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1200',
      'location': 'Amalfi Coast, Italy',
      'caption': 'Golden hour magic over the Mediterranean cliffs 🌅 Pure serenity.',
    },
    {
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=1200',
      'location': 'Yosemite Valley, USA',
      'caption': 'Crisp morning air and mist rising over El Capitan 🌲⛰️',
    },
    {
      'image': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=1200',
      'location': 'Kyoto, Japan',
      'caption': 'Lost in ancient bamboo groves and quiet temple gardens 🎋⛩️',
    },
    {
      'image': 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=1200',
      'location': 'Dubai Marina, UAE',
      'caption': 'Skylines reflecting into the night waters. The future is here! ✨',
    },
    {
      'image': 'https://images.unsplash.com/photo-1533105079780-92b9be482077?q=80&w=1200',
      'location': 'Santorini, Greece',
      'caption': 'Endless Aegean blues and whitewashed rooftops 🇬🇷🌊',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _isLiked = false;
        _progressController.reset();
        _progressController.forward();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isLiked = false;
        _progressController.reset();
        _progressController.forward();
      });
    } else {
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) return const SizedBox.shrink();

    final story = widget.stories[_currentIndex];
    final userName = story['userName'] ?? 'Traveler';
    final userAvatar = story['userAvatar'] ?? 'https://ui-avatars.com/api/?name=$userName&background=0EA5E9&color=fff';
    
    // Choose story scene
    final sceneIndex = _currentIndex % _sampleStoryScenes.length;
    final scene = _sampleStoryScenes[sceneIndex];
    final storyImage = story['mediaUrl'] ?? scene['image']!;
    final location = story['location'] ?? scene['location']!;
    final caption = story['caption'] ?? scene['caption']!;

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: isDesktop
          ? const EdgeInsets.symmetric(horizontal: 40, vertical: 24)
          : EdgeInsets.zero,
      child: Center(
        child: Container(
          width: isDesktop ? 440 : double.infinity,
          height: isDesktop ? 740 : double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isDesktop ? 24 : 0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isDesktop ? 24 : 0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. STORY BACKGROUND PHOTO
                CachedNetworkImage(
                  imageUrl: storyImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFF0F172A),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  errorWidget: (context, url, err) => Container(
                    color: const Color(0xFF0F172A),
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
                    ),
                  ),
                ),

                // 2. GRADIENT OVERLAYS (FOR CRISP READABILITY)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.22, 0.65, 1.0],
                    ),
                  ),
                ),

                // 3. TAP ZONES (LEFT / RIGHT TO NAVIGATE)
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _previousStory,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _nextStory,
                      ),
                    ),
                  ],
                ),

                // 4. TOP PROGRESS BARS & USER HEADER
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Progress Indicators Row
                          Row(
                            children: List.generate(widget.stories.length, (idx) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: Container(
                                      height: 3.5,
                                      color: Colors.white.withValues(alpha: 0.3),
                                      child: idx < _currentIndex
                                          ? Container(color: Colors.white)
                                          : idx == _currentIndex
                                              ? AnimatedBuilder(
                                                  animation: _progressController,
                                                  builder: (context, child) {
                                                    return FractionallySizedBox(
                                                      alignment: Alignment.centerLeft,
                                                      widthFactor: _progressController.value,
                                                      child: Container(color: Colors.white),
                                                    );
                                                  },
                                                )
                                              : const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),

                          // User info and close button
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.storyGradient,
                                ),
                                child: CircleAvatar(
                                  radius: 19,
                                  backgroundImage: CachedNetworkImageProvider(userAvatar),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          userName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Explorer',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      'Active Today • Live Story',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 5. BOTTOM STORY DETAILS & QUICK REACTIONS
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Location Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.place_rounded, color: AppColors.accentOrange, size: 15),
                                const SizedBox(width: 5),
                                Text(
                                  location,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Story Caption
                          Text(
                            caption,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Quick Reaction Bar
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                  ),
                                  child: const Text(
                                    'Reply to traveler...',
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isLiked = !_isLiked;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_isLiked ? 'Loved this story! ❤️' : 'Removed reaction'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isLiked ? Colors.red.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: _isLiked ? Colors.red : Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: _isLiked ? Colors.red : Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Desktop Next/Prev Arrow Helpers
                if (isDesktop) ...[
                  if (_currentIndex > 0)
                    Positioned(
                      left: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.4),
                          ),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: _previousStory,
                        ),
                      ),
                    ),
                  if (_currentIndex < widget.stories.length - 1)
                    Positioned(
                      right: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.4),
                          ),
                          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                          onPressed: _nextStory,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
