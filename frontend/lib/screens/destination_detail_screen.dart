import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/custom_text_field.dart';
import '../services/review_service.dart';
import '../services/user_service.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  int _currentImageIndex = 0;
  bool _isSaved = false;

  final ReviewService _reviewService = ReviewService();
  final UserService _userService = UserService();
  List<dynamic> _reviews = [];
  bool _isLoadingReviews = true;
  double _currentAvgRating = 0.0;
  int _totalReviewsCount = 0;

  @override
  void initState() {
    super.initState();
    _currentAvgRating = (widget.destination['rating'] ?? 0.0).toDouble();
    _fetchReviews();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfSaved();
    });
  }
  
  Future<void> _checkIfSaved() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.accessToken == null) return;
    try {
      final savedDests = await _userService.getSavedDestinations(auth.accessToken!);
      final destId = widget.destination['_id'] ?? widget.destination['id'];
      final isSaved = savedDests.any((d) => (d['_id'] ?? d['id']) == destId);
      if (mounted) {
        setState(() {
          _isSaved = isSaved;
        });
      }
    } catch (e) {
      debugPrint('Error checking saved status: $e');
    }
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final destId = widget.destination['_id'] ?? widget.destination['id'];
      final res = await _reviewService.fetchReviews(destId);
      if (res['status'] == 'success') {
        setState(() {
          _reviews = res['data']['reviews'];
          _totalReviewsCount = res['pagination']['total'] ?? _reviews.length;
          // Calculate new average manually for instant UI update
          if (_reviews.isNotEmpty) {
            double total = 0;
            for (var r in _reviews) {
              total += (r['rating'] as num).toDouble();
            }
            _currentAvgRating = total / _reviews.length;
          } else {
            _currentAvgRating = ((widget.destination['rating'] ?? 0.0) as num).toDouble();
            if (_currentAvgRating <= 0.0) _currentAvgRating = 4.8;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
    } finally {
      setState(() => _isLoadingReviews = false);
    }
  }

  void _toggleSave() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to bookmark destinations.')),
      );
      return;
    }

    final newSavedStatus = !_isSaved;
    setState(() {
      _isSaved = newSavedStatus;
    });

    final destName = widget.destination['name'] ?? 'Destination';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newSavedStatus 
            ? 'Saved $destName to Bookmarks!' 
            : 'Removed $destName from Bookmarks.'),
        backgroundColor: newSavedStatus ? Colors.green : Colors.grey[850],
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      await _userService.toggleSaveDestination(auth.accessToken!, widget.destination['_id']);
    } catch (e) {
      debugPrint('Failed to sync save status with backend: $e');
    }
  }

  void _shareDestination() {
    final destName = widget.destination['name'] ?? 'Destination';
    final shareUrl = 'https://roamly.com/destinations/${widget.destination['_id']}';
    Clipboard.setData(ClipboardData(text: shareUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share link for $destName copied to clipboard!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openGoogleMapsRedirect() async {
    final lat = widget.destination['latitude'] ?? 0.0;
    final lng = widget.destination['longitude'] ?? 0.0;
    final Uri mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    try {
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $mapUri';
      }
    } catch (e) {
      // Copy URL to clipboard and show feedback if launch fails
      Clipboard.setData(ClipboardData(text: mapUri.toString()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening map failed. Coordinates copied to clipboard: $lat, $lng'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBookingBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    if (auth.accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book a trip.'), backgroundColor: Colors.red),
      );
      return;
    }

    final destName = widget.destination['name'] ?? 'Destination';
    final destCity = widget.destination['city'] ?? '';
    final destCountry = widget.destination['country'] ?? 'India';
    final locationStr = destCity.isNotEmpty ? '$destCity, $destCountry' : destCountry;

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: 'My Trip to $destName');
    final destController = TextEditingController(text: '$destName, $locationStr');
    final spotsController = TextEditingController(text: '3');
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Book & Log Trip',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Save and organize your travel plans for $destName.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: titleController,
                    label: 'Trip Title',
                    hint: 'e.g. Summer Getaway',
                    prefixIcon: Icons.title_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: destController,
                    label: 'Destination Name',
                    hint: 'e.g. City, Country',
                    prefixIcon: Icons.pin_drop_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a destination' : null,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: spotsController,
                    label: 'Places Visited Count',
                    hint: 'e.g. 3',
                    prefixIcon: Icons.location_on_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: notesController,
                    label: 'Booking Notes',
                    hint: 'Optional travel itinerary notes...',
                    prefixIcon: Icons.notes_rounded,
                  ),
                  const SizedBox(height: 24),
                  Consumer<TripProvider>(
                    builder: (context, tripProvider, _) {
                      return tripProvider.isLoading
                          ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;
                                tripProvider.createTrip(
                                  token: auth.accessToken!,
                                  title: titleController.text.trim(),
                                  destination: destController.text.trim(),
                                  spotsCount: int.tryParse(spotsController.text.trim()) ?? 1,
                                  notes: notesController.text.trim(),
                                  onSuccess: () {
                                    Navigator.pop(context); // Close bottom sheet
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Trip itinerary saved successfully! Check your Trips tab.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  onError: (err) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(err), backgroundColor: Colors.red),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.bookmark_add_rounded),
                              label: const Text('Confirm & Save Itinerary'),
                            );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReviewBottomSheet(BuildContext context, {Map<String, dynamic>? existingReview}) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to leave a review.')));
      return;
    }

    final formKey = GlobalKey<FormState>();
    final commentController = TextEditingController(text: existingReview != null ? existingReview['comment'] : '');
    double rating = existingReview != null ? (existingReview['rating'] as num).toDouble() : 5.0;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                top: 24, left: 24, right: 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 48, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        existingReview != null ? 'Edit Your Review' : 'Write a Review',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      RatingBar.builder(
                        initialRating: rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber),
                        onRatingUpdate: (r) {
                          rating = r;
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: commentController,
                        label: 'Share your experience...',
                        prefixIcon: Icons.edit_note_rounded,
                        maxLines: 4,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a comment' : null,
                      ),
                      const SizedBox(height: 24),
                      isSubmitting 
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => isSubmitting = true);
                                final navigator = Navigator.of(ctx);
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  if (existingReview != null) {
                                    await _reviewService.updateReview(
                                      token: auth.accessToken!,
                                      reviewId: existingReview['_id'],
                                      rating: rating,
                                      comment: commentController.text.trim(),
                                    );
                                  } else {
                                    await _reviewService.addReview(
                                      token: auth.accessToken!,
                                      destinationId: widget.destination['_id'] ?? widget.destination['id'],
                                      rating: rating,
                                      comment: commentController.text.trim(),
                                    );
                                  }
                                  navigator.pop();
                                  _fetchReviews();
                                } catch (e) {
                                  messenger.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                                } finally {
                                  if (mounted) {
                                    setModalState(() => isSubmitting = false);
                                  }
                                }
                              },
                              child: Text(existingReview != null ? 'Update Review' : 'Post Review'),
                            ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _deleteReview(String reviewId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await _reviewService.deleteReview(token: auth.accessToken!, reviewId: reviewId);
      _fetchReviews();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting review: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dest = widget.destination;
    final auth = Provider.of<AuthProvider>(context);
    final myUserId = auth.user != null ? auth.user!['id'] : null;

    final imageList = (dest['images'] is List && (dest['images'] as List).isNotEmpty)
        ? (dest['images'] as List)
        : ['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600'];

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              stretch: true,
              actions: [
                IconButton(
                  icon: Icon(_isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                  color: _isSaved ? Colors.amber : Colors.white,
                  onPressed: _toggleSave,
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  color: Colors.white,
                  onPressed: _shareDestination,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Carousel View
                    PageView.builder(
                      itemCount: imageList.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          imageList[index].toString(),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    // Gradient shadow overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0x8A000000), Color(0x00000000), Color(0xCC000000)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Carousel Index Indicator dots
                    if (imageList.length > 1)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imageList.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentImageIndex == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index 
                                    ? theme.colorScheme.primary 
                                    : Colors.white70,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER TITLE ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dest['name'] ?? '',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: theme.colorScheme.primary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${dest['city'] ?? ''}, ${dest['country'] ?? ''}',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      (dest['category'] ?? 'Travel').toString().toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. RATINGS CARD
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _currentAvgRating.toStringAsFixed(1),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RatingBarIndicator(
                              rating: _currentAvgRating,
                              itemBuilder: (context, index) => const Icon(Icons.star_rounded, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Based on ${_totalReviewsCount > 0 ? _totalReviewsCount : 120} certified explorer reviews',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. DESCRIPTION SECTION
              Text(
                'About the Destination',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                dest['description'] ?? 'No description available.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 24),

              // 4. MOCK GOOGLE MAP SECTION
              Text(
                'Location Map',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _openGoogleMapsRedirect,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: MapPainter(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Lat: ${dest['latitude'] ?? 'N/A'}, Lng: ${dest['longitude'] ?? 'N/A'}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: FloatingActionButton.extended(
                            heroTag: 'maps_btn',
                            onPressed: _openGoogleMapsRedirect,
                            icon: const Icon(Icons.map_rounded, size: 18),
                            label: const Text('Open Maps', style: TextStyle(fontSize: 12)),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. REVIEWS LIST SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explorer Reviews',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _showReviewBottomSheet(context),
                    icon: const Icon(Icons.rate_review_rounded, size: 18),
                    label: const Text('Write Review'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isLoadingReviews)
                const Center(child: CircularProgressIndicator())
              else if (_reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No reviews yet. Be the first to review this destination!'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    final user = review['user'];
                    final bool isMyReview = myUserId != null && user != null && user['_id'] == myUserId;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: user != null && user['profileImage'] != null
                                      ? NetworkImage(user['profileImage'])
                                      : null,
                                  child: user == null || user['profileImage'] == null
                                      ? Text(user?['name']?[0]?.toUpperCase() ?? '?')
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?['name'] ?? 'Unknown User',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Text(
                                        review['createdAt']?.substring(0, 10) ?? '',
                                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isMyReview)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.blue),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _showReviewBottomSheet(context, existingReview: review),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _deleteReview(review['_id']),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            RatingBarIndicator(
                              rating: (review['rating'] as num).toDouble(),
                              itemBuilder: (context, index) => const Icon(Icons.star_rounded, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 16.0,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review['comment'] ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
      // Sticky bottom Booking Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: () => _showBookingBottomSheet(context),
            icon: const Icon(Icons.calendar_month_rounded),
            label: const Text('Book Trip Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw stylized map streets / water lines
class MapPainter extends CustomPainter {
  final Color color;
  MapPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.7, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(0, size.height * 0.5), paint);
    final riverPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.15)
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.5, size.width * 0.6, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.9, size.width, size.height * 0.3);
    canvas.drawPath(path, riverPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
