import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ttsbuiltmobile/data/repositories/simpro_repository.dart';

import 'interface/router/app_router.dart';
import 'logic/blocs/simpro_connection_bloc.dart';
import 'logic/blocs/user_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(BlocApp());
  });
}

class BlocApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();
  @override
  Widget build(BuildContext context) {
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
    child: MaterialApp(
      navigatorKey: SimproRepository.contextKey,
      title: 'TTS Simpro Data Capture',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: _appRouter.onGenerateRoute,
      initialRoute: AppRouter.jobListingPath
    )));
  }
}