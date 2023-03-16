import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ttsbuiltmobile/data/repositories/schedule_repository.dart';
import 'package:ttsbuiltmobile/data/repositories/simpro_repository.dart';

import 'data/repositories/camera_repository.dart';
import 'interface/router/app_router.dart';
import 'logic/blocs/job_listing_bloc.dart';
import 'logic/blocs/simpro_connection_bloc.dart';
import 'logic/blocs/user_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(BlocApp());
  });
}

class BlocApp extends StatelessWidget with WidgetsBindingObserver{
  final AppRouter _appRouter = AppRouter();
  bool _beingObserved = false;
  BuildContext? lastContext;
  @override
  Widget build(BuildContext context) {

    if(_beingObserved == false){
      WidgetsBinding.instance.addObserver(this);
      _beingObserved = true;
    }
    return BlocProvider<SimproConnectionBloc>(
        create: (BuildContext context) {
          SimproConnectionBloc bloc = SimproConnectionBloc();
          return bloc;
        },
        child: BlocProvider<UserBloc>(
            create: (BuildContext context) {
              UserBloc bloc = UserBloc();
              return bloc;
            },
            child: RepositoryProvider<SimproRepository>(
                lazy: true,
                create: (context) => SimproRepository(),
                child: RepositoryProvider<ScheduleRepository>(
                    create: (BuildContext context) {
                      ScheduleRepository scheduleRepository =
                          ScheduleRepository();
                      return scheduleRepository;
                    },
                    child: RepositoryProvider<CameraRepository>(
                        lazy: false,
                        create: (BuildContext context) {
                          CameraRepository cameraRepository =
                              CameraRepository();
                          return cameraRepository;
                        },
                        child: BlocProvider<JobListingBloc>(
                            create: (BuildContext context) {
                              lastContext = context;
                              JobListingBloc bloc = JobListingBloc();
                              return bloc;
                            },
                            child: MaterialApp(
                                navigatorKey: SimproRepository.contextKey,
                                title: 'TTS Simpro Data Capture',
                                theme: ThemeData(
                                  primarySwatch: Colors.blue,
                                  visualDensity:
                                      VisualDensity.adaptivePlatformDensity,
                                ),
                                onGenerateRoute: _appRouter.onGenerateRoute,
                                initialRoute: AppRouter.jobListingPath)))))));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state.index == 1){
      if(lastContext != null) {
        CameraRepository cameraRepository = RepositoryProvider.of<CameraRepository>(lastContext!);
        cameraRepository.dispose();
      }
    }else if (state.index == 0){
      if(lastContext != null) {
        CameraRepository cameraRepository = RepositoryProvider.of<CameraRepository>(lastContext!);
        cameraRepository.initialiseCameras();
      }
    }
    // if(lastContext != null) {
    //   CameraRepository cameraRepository = RepositoryProvider.of<CameraRepository>(lastContext!);
    //   cameraRepository.dispose();
    //   _beingObserved = false;
    //   WidgetsBinding.instance.removeObserver(this);
      print("test did change lifecycle state to " + state.name + "," + state.index.toString());
    // }
  }

}
