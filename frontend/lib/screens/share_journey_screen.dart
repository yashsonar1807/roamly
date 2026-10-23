import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../config/api_config.dart';

class ShareJourneyScreen extends StatefulWidget {
  final Map<String, dynamic> trip;

  const ShareJourneyScreen({super.key, required this.trip});

  @override
  State<ShareJourneyScreen> createState() => _ShareJourneyScreenState();
}

class _ShareJourneyScreenState extends State<ShareJourneyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _itineraryController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedPhotos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: '${widget.trip['title']} Journey');
    if (widget.trip['budget'] != null) {
      _budgetController.text = widget.trip['budget'].toString();
    }
  }

  Future<void> _pickPhotos() async {
    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(picked);
      });
    }
  }

  Future<void> _submitJourney() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.accessToken == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/journeys');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${authProvider.accessToken}'
        ..fields['trip'] = widget.trip['_id']
        ..fields['title'] = _titleController.text
        ..fields['description'] = _descriptionController.text
        ..fields['budget'] = _budgetController.text
        ..fields['duration'] = _durationController.text
        ..fields['itinerary'] = _itineraryController.text
        ..fields['destinationName'] = widget.trip['destination'] ?? 'Unknown';

      for (var photo in _selectedPhotos) {
        if (kIsWeb) {
          final bytes = await photo.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes('photos', bytes, filename: photo.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('photos', photo.path));
        }
      }

      final response = await request.send();
      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journey Shared successfully!')));
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to share journey');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Journey'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Journey Title', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _budgetController,
                            decoration: const InputDecoration(labelText: 'Budget', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _durationController,
                            decoration: const InputDecoration(labelText: 'Duration (e.g. 5 days)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _itineraryController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Itinerary / Highlights', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickPhotos,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Add Photos'),
                    ),
                    if (_selectedPhotos.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedPhotos.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  kIsWeb
                                      ? Image.network(_selectedPhotos[index].path, width: 100, height: 100, fit: BoxFit.cover)
                                      : Image.file(File(_selectedPhotos[index].path), width: 100, height: 100, fit: BoxFit.cover),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _selectedPhotos.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: _submitJourney,
                      child: const Text('Publish Journey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
