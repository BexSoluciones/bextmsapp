import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
//utils
import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/user/navigation/index.dart';
import '../../../presentation/views/user/notes/index.dart';
import '../../../presentation/views/user/navigation/features/store_editor.dart';
import '../../../presentation/views/user/navigation/features/import_store.dart';
import '../../../presentation/views/user/navigation/features/download_region.dart';

Map<String, RouteType> navigationRoutes = {
  AppRoutes.navigation: (context, settings) =>
      NavigationView(workcode: settings.arguments as String),
  AppRoutes.notes: (context, settings) =>
      NotesView(position: settings.arguments as LatLng),
  AppRoutes.editStore: (context, settings) => const StoreEditorPopup(
        existingStoreName: null,
        isStoreInUse: false,
      ),
  AppRoutes.importStore: (context, setting) => const ImportStorePopup(),
  AppRoutes.recovery: (context, settings) =>
      NotesView(position: settings.arguments as LatLng),
  AppRoutes.downloader: (context, settings) =>
      DownloadRegionPopup(region: settings.arguments as BaseRegion),
};
