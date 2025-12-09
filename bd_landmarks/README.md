# BD Landmarks

A Flutter mobile application for discovering, documenting, and managing landmarks across Bangladesh. Users can view landmarks on an interactive map, maintain a comprehensive list of records, and add new landmarks with photos and GPS coordinates.

## Features

# Interactive Map View
- Visualize all landmarks on a real-time interactive map using OpenStreetMap
- Tap markers to view landmark details in a bottom sheet
- Centered on Bangladesh (23.6850°N, 90.3563°E)
- Red location pins for easy identification

# Records Management
- Browse all landmarks in a scrollable list view
- View landmark details including title, coordinates, and images
- Edit existing landmark information
- Delete landmarks with confirmation dialog
- Real-time updates after modifications

# Add New Landmarks
- Create new landmark entries with custom titles
- Capture or upload photos using device camera/gallery
- Automatic image compression for optimal performance
- Auto-detect current GPS location with one tap
- Manual coordinate entry supported
- Form validation for data integrity

# User Interface
- Material 3 design with dark theme
- Green color scheme optimized for Bangladesh theme
- Bottom navigation for easy screen switching
- Responsive layouts for various screen sizes
- Loading states and error handling

# Technology Stack

- **Framework**: Flutter SDK 3.9.2+
- **HTTP Client**: Dio (5.4.0)
- **Mapping**: Flutter Map (7.0.2) with Latlong2 (0.9.0)
- **Location**: Geolocator (13.0.2)
- **Media**: Image Picker (1.0.7), Flutter Image Compress (2.3.0)
- **Storage**: Path Provider (2.1.1)
- **Backend API**: `https://labs.anontech.info/cse489/t3/api.php`

# Setup Instructions

# Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile deployment)
- Active internet connection (for map tiles and API)

# Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/nerdyomi/CSE489_lab_mid.git
   cd bd_landmarks
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Platform-Specific Configuration

#### Android
- Minimum SDK: 21
- Target SDK: 34
- Permissions required: Location, Camera, Storage
- Configure `android/app/src/main/AndroidManifest.xml` for location permissions

#### iOS
- Minimum deployment target: iOS 12.0
- Update `ios/Runner/Info.plist` with:
  - `NSLocationWhenInUseUsageDescription`
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`

## API Integration

The app connects to a remote API for landmark data persistence:

**Base URL**: `https://labs.anontech.info/cse489/t3/api.php`

**Endpoints**:
- `GET /api.php` - Fetch all landmarks
- `POST /api.php` - Create new landmark (multipart/form-data)
- `PUT /api.php?id={id}` - Update existing landmark
- `DELETE /api.php?id={id}` - Delete landmark

**Data Format**:
```json
{
  "id": "string",
  "title": "string",
  "lat": "number",
  "lon": "number",
  "image": "string (URL or relative path)"
}
```

## Known Limitations

### Current Issues
1. **Network Dependency**: Requires constant internet connection for:
   - Map tiles loading (OpenStreetMap)
   - API communication
   - Image uploads
   - No offline mode or caching implemented

2. **Image Handling**:
   - Large images may take time to upload on slow connections
   - No image preview before compression
   - Limited error feedback for failed uploads
   - No support for multiple images per landmark

3. **Location Services**:
   - GPS accuracy depends on device capabilities
   - Manual coordinate entry requires user knowledge of lat/lon format

4. **Data Validation**:
   - Limited validation on coordinate ranges 
   - No duplicate detection
   - No character limits on title field
   - Missing validation for image file types/sizes

5. **User Experience**:
   - No search or filter functionality
   - No sorting options for records list
   - No pagination for large datasets

6. **Platform Support**:
   - Optimized for mobile (Android/iOS)

7. **Performance**:
   - All landmarks loaded at once
   - No image caching for repeated views
   - Map may lag with 1000+ markers

8. **Security**:
   - API endpoint not authenticated
   - No user account system
   - All data publicly accessible
   - No input sanitization


## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # Root widget with navigation
├── models/
│   └── landmark.dart                  # Landmark data model
├── screens/
│   ├── overview_map_screen.dart       # Map view
│   ├── records_list_screen.dart       # List view
│   └── landmark_form_screen.dart      # Create/Edit form
├── services/
│   └── api_service.dart               # API communication
└── widgets/
    ├── landmark_card.dart             # List item widget
    └── landmark_bottom_sheet.dart     # Map marker detail sheet
```

## Contributing

This project was created as part of CSE489 coursework. For issues or improvements, please contact nabid.hasan.omi@g.bracu.ac.bd

## License

This project is developed for educational purposes as part of the CSE489 course curriculum.
