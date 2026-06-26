import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/custom_text_field.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  int _currentImageIndex = 0;
  bool _isSaved = false;

  // Mock traveler reviews generator based on destination name
  late final List<Map<String, String>> _mockReviews;

  @override
  void initState() {
    super.initState();
    final name = widget.destination['name'] ?? 'Destination';
    _mockReviews = [
      {
        'author': 'Aarav Mehta',
        'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150',
        'rating': '5.0',
        'comment': 'Absolutely breathtaking! Visited $name last week and it was a magical experience. Highly recommend early mornings.',
        'date': '2 days ago',
      },
      {
        'author': 'Diya Sen',
        'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150',
        'rating': '4.8',
        'comment': 'Stunning architecture and great atmosphere. There are plenty of guides around, but make sure to capture the views from the east side!',
        'date': '1 week ago',
      },
    ];
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved 
            ? 'Saved ${widget.destination['name']} to Bookmarks!' 
            : 'Removed ${widget.destination['name']} from Bookmarks.'),
        backgroundColor: _isSaved ? Colors.green : Colors.grey[850],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareDestination() {
    final shareUrl = 'https://roamly.com/destinations/${widget.destination['_id'] ?? 'explore'}';
    Clipboard.setData(ClipboardData(text: shareUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share link for ${widget.destination['name']} copied to clipboard!'),
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

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: 'My Trip to ${widget.destination['name']}');
    final destController = TextEditingController(text: '${widget.destination['name']}, ${widget.destination['city']}');
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
                    'Pre-fill travel logs for ${widget.destination['name']} in MongoDB.',
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
                                        content: Text('Trip logged successfully! Go to Trips tab to view.'),
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
                              icon: const Icon(Icons.cloud_upload_rounded),
                              label: const Text('Confirm & Log to MongoDB'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dest = widget.destination;

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
                          (dest['rating'] ?? '4.8').toString(),
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
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star_rounded,
                                  color: index < (dest['rating'] ?? 4.8).floor() ? Colors.amber : Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Based on ${142 + (dest['name'] ?? '').length} certified explorer reviews',
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
                        // Stylized Map Drawing Grid
                        CustomPaint(
                          painter: MapPainter(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                        ),
                        // Target Map Marker with Ripple Rings
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
                                  'Lat: ${dest['latitude'] ?? 0.0}, Lng: ${dest['longitude'] ?? 0.0}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Open In Google Maps Button
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
              Text(
                'Explorer Reviews',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mockReviews.length,
                itemBuilder: (context, index) {
                  final review = _mockReviews[index];
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
                                backgroundImage: NetworkImage(review['avatar']!),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review['author']!,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      review['date']!,
                                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      review['rating']!,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review['comment']!,
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

    // Draw some stylized diagonal roads / lines
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.7, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(0, size.height * 0.5), paint);
    
    // Draw a curvy blue-like river line
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
