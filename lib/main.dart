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
//
//
// import 'package:flutter/material.dart';
// import 'package:oauth2_client/access_token_response.dart';
// import 'package:oauth2_client/oauth2_helper.dart';
// import 'package:http/http.dart' as http;
// import 'package:ttsbuiltmobile/simpro_oauth2_client.dart';
// import 'dart:convert';
// import 'dart:io';
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() async{
//     SimproOAuth2Client client = SimproOAuth2Client(
//         redirectUri: 'com.nexiaem.ttsbuiltmobile://oauth2redirect',
//         customUriScheme: 'com.nexiaem.ttsbuiltmobile'
//     );
//     OAuth2Helper oauth2Helper = OAuth2Helper(client,
//         grantType: OAuth2Helper.AUTHORIZATION_CODE,
//         clientId: '216db2b119c178035694d36ee1b90b',
//         clientSecret: 'ac0f1b5725'
//     );
//
//     Map<String, String> headers = {};
//     headers["Accept"] = "*/*";
//     int startTime =  DateTime.now().millisecondsSinceEpoch;
//     http.Response resp = await oauth2Helper.get('https://territorytrade.simprosuite.com/api/v1.0/currentUser/', headers: headers);
//     Map<String, dynamic> currentUser = jsonDecode(resp.body);
//     AccessTokenResponse? accessTokenResponse = await oauth2Helper.getToken();
//     String? accessToken = accessTokenResponse?.accessToken;
//     resp = await oauth2Helper.get('https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/?Status.ID=!in(70,12,67,13,142,11)', headers: headers);
//     List<dynamic> jobsListing = jsonDecode(resp.body);
//     for(dynamic job in jobsListing){
//       int cycleTime =  DateTime.now().millisecondsSinceEpoch - startTime;
//       if(cycleTime < 100){
//         int timeToPause = 100 - cycleTime;
//         await new Future.delayed(Duration(milliseconds: timeToPause));
//       }
//       int id = job["ID"];
//       String link = "https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/" + id.toString() + "/timelines/";
//       resp = await oauth2Helper.get(link, headers: headers);
//
//       List<dynamic> timelines = jsonDecode(resp.body);
//
//       startTime = DateTime.now().millisecondsSinceEpoch;
//
//       String description = job["Description"];
//       link = "https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/" + id.toString();
//       resp = await oauth2Helper.get(link, headers: headers);
//       Map<String, dynamic> jobDetails = jsonDecode(resp.body);
//       String notes = jobDetails["Notes"];
//       Map<String, dynamic> responseTimes = jobDetails["ResponseTime"];
//       Map<String, dynamic> site = jobDetails["site"];
//       List<dynamic> detailsNotesArray = [];
//       int startingDivLength = 30;
//       int startPos = startingDivLength;
//       String iterationNote = notes;
//       if(iterationNote.startsWith("<div")){
//         while(iterationNote.startsWith("<div")){
//           int endPos = startPos + iterationNote.substring(startPos).indexOf("</div");
//           String thisNote = iterationNote.substring(startPos, endPos);
//           detailsNotesArray.add(thisNote);
//           iterationNote = iterationNote.substring(endPos + 6);
//         }
//       }else{
//         detailsNotesArray.add(iterationNote);
//       }
//     }
//
//
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
