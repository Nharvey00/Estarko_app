import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get mapboxAccessToken =>
      (dotenv.isInitialized ? dotenv.env['MAPBOX_ACCESS_TOKEN'] : null) ?? '';
  static String get cloudinaryCloudName =>
      (dotenv.isInitialized ? dotenv.env['CLOUDINARY_CLOUD_NAME'] : null) ??
      'gyv0xeph';
  static const double defaultPadding = 24.0;
}
