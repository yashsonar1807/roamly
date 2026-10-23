import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';

class UploadPostScreen extends StatefulWidget {
  const UploadPostScreen({super.key});

  @override
  State<UploadPostScreen> createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;
  Uint8List? _selectedBytes;
  bool _isVideo = false;

  Future<void> _pickMedia(bool isVideo) async {
    final XFile? pickedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedFile = pickedFile;
        _selectedBytes = bytes;
        _isVideo = isVideo;
      });
    }
  }

  void _removeMedia() {
    setState(() {
      _selectedFile = null;
      _selectedBytes = null;
    });
  }

  Future<void> _uploadPost() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image or video')),
      );
      return;
    }

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated. Please log in.')),
      );
      return;
    }

    final bytes = _selectedBytes ?? await _selectedFile!.readAsBytes();
    
    await postProvider.createPost(
      token: authProvider.accessToken!,
      caption: _captionController.text,
      location: _locationController.text,
      fileBytes: bytes.toList(),
      fileName: _selectedFile!.name,
      onSuccess: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post uploaded successfully')),
        );
        Navigator.pop(context);
      },
      onError: (err) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err)),
        );
      },
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: postProvider.isLoading ? null : _uploadPost,
            child: const Text('Share', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: postProvider.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(value: postProvider.uploadProgress),
                  const SizedBox(height: 16),
                  Text('${(postProvider.uploadProgress * 100).toStringAsFixed(0)}% Uploaded'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedFile != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: _isVideo || _selectedBytes == null
                                ? null
                                : DecorationImage(
                                    image: MemoryImage(_selectedBytes!),
                                    fit: BoxFit.cover,
                                  ),
                            color: Colors.grey[200],
                          ),
                          child: _isVideo
                              ? const Center(
                                  child: Icon(Icons.video_library, size: 50, color: Colors.grey),
                                )
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.black54),
                            onPressed: _removeMedia,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickMedia(false),
                            icon: const Icon(Icons.image),
                            label: const Text('Photo'),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickMedia(true),
                            icon: const Icon(Icons.videocam),
                            label: const Text('Video'),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _captionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write a caption...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[900] 
                        : Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Add location',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[900] 
                        : Colors.grey[100],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
