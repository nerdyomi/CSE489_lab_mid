import 'package:flutter/material.dart';
import '../models/landmark.dart';
import '../screens/landmark_form_screen.dart';
import '../services/api_service.dart';

class LandmarkBottomSheet extends StatelessWidget {
  final Landmark landmark;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LandmarkBottomSheet({
    super.key,
    required this.landmark,
    this.onEdit,
    this.onDelete,
  });

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Landmark'),
        content: Text('Are you sure you want to delete "${landmark.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Get the root scaffold context before popping
      final rootContext = context;
      
      try {
        await ApiService().deleteLandmark(landmark.id);
        
        // Close bottom sheet after successful delete
        if (rootContext.mounted) {
          Navigator.pop(rootContext);
          
          // Show success message using root context
          ScaffoldMessenger.of(rootContext).showSnackBar(
            SnackBar(
              content: Text('${landmark.title} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Trigger refresh callback
          if (onDelete != null) {
            Future.microtask(() => onDelete!());
          }
        }
      } catch (e) {
        if (rootContext.mounted) {
          showDialog(
            context: rootContext,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to delete landmark: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            landmark.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          // Image preview
          if (landmark.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                landmark.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          
          // Coordinates
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Lat: ${landmark.lat.toStringAsFixed(6)}, Lon: ${landmark.lon.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _handleDelete(context),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LandmarkFormScreen(landmark: landmark),
                    ),
                  );
                  if (result == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Landmark updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    if (onEdit != null) {
                      onEdit!();
                    }
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
