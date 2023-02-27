import 'package:flutter/material.dart';

import '../components/global.dart';
import '../screens/description_detail_screen.dart';
import '../screens/job_detail_screen.dart';
import '../screens/job_listing_screen.dart';
import '../screens/work_notes_screen.dart';

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
  static const String jobDetailPath = '/job';
  static const String descriptionDetailPath = '/job/descriptionDetail';
  static const String workNotesPath = '/job/workNotes';
  // static const String itemMaterialsPath = '/job/item/materials';
  // static const String itemPhotosPath = '/job/item/photos';

  Route onGenerateRoute(RouteSettings settings) {
    //final GlobalKey<ScaffoldState> key = settings.arguments as GlobalKey<ScaffoldState>;
    switch (settings.name) {
      case jobListingPath:
        return MaterialPageRoute(
            builder: (_) => JobListingScreen()
        );
      case AppRouter.jobDetailPath:
        return MaterialPageRoute(
            builder:  (context) {
              JobIDs args = settings.arguments as JobIDs;
              return JobDetailScreen(
                  args.companyId,
                  args.jobId
              );
            },
        );
      case AppRouter.descriptionDetailPath:
        return MaterialPageRoute(
          builder:  (context) {
            JobIDs args = settings.arguments as JobIDs;
            return DescriptionDetailScreen(
                args.companyId,
                args.jobId
            );
          },
         );
      case AppRouter.workNotesPath:
        return MaterialPageRoute(
          builder:  (context) {
            JobIDs args = settings.arguments as JobIDs;
            return WorkNotesScreen(
                args.companyId,
                args.jobId
            );
          },
        );
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