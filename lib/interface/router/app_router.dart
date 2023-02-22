import 'package:flutter/material.dart';

import '../screens/job_listing_screen.dart';

enum Pages{
  jobListing,
  jobDetail,
  descriptionDetail,
  workNotes,
  itemMaterials,
  itemPhotos
}

class AppRouter {
  static const String jobListingPath = '/jobListing';
  // static const String jobDetailsPath = '/job';
  // static const String descriptionDetailPath = '/job/descriptionDetail';
  // static const String workNotesPath = '/job/workNotes';
  // static const String itemMaterialsPath = '/job/itemMaterials';
  // static const String itemPhotosPath = '/job/itemPhotos';

  Route onGenerateRoute(RouteSettings settings) {
    //final GlobalKey<ScaffoldState> key = settings.arguments as GlobalKey<ScaffoldState>;
    switch (settings.name) {
      case jobListingPath:
        return MaterialPageRoute(
            builder: (_) => JobListingScreen()
        );
      // case AppRouter.jobDetailsPath:
      //   return MaterialPageRoute(
      //       builder: (_) => JobDetailScreen()
      //   );
      // case AppRouter.descriptionDetailPath:
      //   return MaterialPageRoute(
      //       builder: (_) => DescriptionDetailScreen()
      //   );
      // case AppRouter.workNotesPath:
      //   return MaterialPageRoute(
      //       builder: (_) => WorkNotesScreen()
      //   );
      // case AppRouter.itemMaterialsPath:
      //   return MaterialPageRoute(
      //       builder: (_) => ItemMaterialsScreen()
      //   );
      // case AppRouter.itemPhotosPath:
      //   return MaterialPageRoute(
      //       builder: (_) => ItemPhotosScreen()
      //   );
      default:
        return MaterialPageRoute(
            builder: (_) => JobListingScreen()
        );
    }
  }
}