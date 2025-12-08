import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';

class LandmarkFormScreen extends StatefulWidget {
  final Landmark? landmark; // null for create mode, non-null for edit mode

  const LandmarkFormScreen({super.key, this.landmark});

  @override
  State<LandmarkFormScreen> createState() => _LandmarkFormScreenState();
}

class _LandmarkFormScreenState extends State<LandmarkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  bool get isEditMode => widget.landmark != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _titleController.text = widget.landmark!.title;
      _latController.text = widget.landmark!.lat.toString();
      _lonController.text = widget.landmark!.lon.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lonController.text = position.longitude.toStringAsFixed(6);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location detected successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: 800,
        minHeight: 600,
        quality: 85,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file; // Return original if compression fails
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Compress the image before storing
        File originalFile = File(pickedFile.path);
        File? compressedFile = await _compressImage(originalFile);
        
        setState(() {
          _imageFile = compressedFile ?? originalFile;
        });
        
        if (mounted && compressedFile != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image compressed and ready')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final landmark = Landmark(
        id: isEditMode ? widget.landmark!.id : '',
        title: _titleController.text.trim(),
        lat: double.parse(_latController.text.trim()),
        lon: double.parse(_lonController.text.trim()),
        imageUrl: isEditMode ? widget.landmark!.imageUrl : '',
      );

      debugPrint('FORM_SUBMIT - isEditMode: $isEditMode, Landmark ID: ${landmark.id}, Title: ${landmark.title}');

      if (isEditMode) {
        // Edit mode - use updateLandmark
        final success = await ApiService().updateLandmark(landmark, _imageFile);
        
        if (mounted) {
          if (success) {
            Navigator.pop(context, true); // Return true to indicate success
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update landmark'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Create mode - image is optional
        final success = await ApiService().createLandmark(landmark, _imageFile);
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Landmark added successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Reset form for next entry
            _titleController.clear();
            _latController.clear();
            _lonController.clear();
            setState(() {
              _imageFile = null;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to create landmark'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Landmark' : 'Add Landmark'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image preview/picker
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : isEditMode && widget.landmark!.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.landmark!.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            ),
                          )
                        : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to ${_imageFile != null || (isEditMode && widget.landmark!.imageUrl.isNotEmpty) ? 'change' : 'select'} image',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 24),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // GPS Location Button (only in create mode)
            if (!isEditMode)
              OutlinedButton.icon(
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_isGettingLocation ? 'Getting Location...' : 'Use Current Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            if (!isEditMode) const SizedBox(height: 16),

            // Latitude field
            TextFormField(
              controller: _latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
                hintText: 'e.g., 23.8103',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter latitude';
                }
                final lat = double.tryParse(value.trim());
                if (lat == null) {
                  return 'Please enter a valid number';
                }
                if (lat < -90 || lat > 90) {
                  return 'Latitude must be between -90 and 90';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Longitude field
            TextFormField(
              controller: _lonController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
                hintText: 'e.g., 90.4125',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter longitude';
                }
                final lon = double.tryParse(value.trim());
                if (lon == null) {
                  return 'Please enter a valid number';
                }
                if (lon < -180 || lon > 180) {
                  return 'Longitude must be between -180 and 180';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isEditMode ? 'Update Landmark' : 'Create Landmark',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'Select Image',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
