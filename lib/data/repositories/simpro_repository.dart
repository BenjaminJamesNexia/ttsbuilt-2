import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ttsbuiltmobile/logic/blocs/simpro_connection_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/connection_direction.dart';
import '../../logic/blocs/user_bloc.dart';
import '../../logic/states/connection_available.dart';
import '../../logic/states/simpro_connection_event.dart';
import '../../logic/states/simpro_connection_state.dart';
import '../../logic/states/user_event.dart';
import '../../logic/states/user_state.dart';
import '../utility/simpro_oauth2_client.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:http/http.dart' as http;

SimproOAuth2Client client = SimproOAuth2Client(
    redirectUri: 'com.nexiaem.ttsbuiltmobile://oauth2redirect',
    customUriScheme: 'com.nexiaem.ttsbuiltmobile');

class SimproRepository {
  static final SimproRepository _instance =
      SimproRepository._privateConstructor();
  static GlobalKey<NavigatorState> contextKey = GlobalKey<NavigatorState>();

  SimproRepository._privateConstructor() {
    createUserEvent();
  }

  factory SimproRepository() {
    return _instance;
  }

  createUserEvent() async {
    OAuth2Helper oauth2Helper = OAuth2Helper(client,
        grantType: OAuth2Helper.AUTHORIZATION_CODE,
        clientId: '216db2b119c178035694d36ee1b90b',
        clientSecret: 'ac0f1b5725');

    Map<String, String> headers = {};
    headers["Accept"] = "*/*";
    int startTime = DateTime.now().millisecondsSinceEpoch;
    SimproConnectionBloc connectionBloc =
        BlocProvider.of<SimproConnectionBloc>(contextKey.currentContext!);
    SimproConnectionState connectionState1 = SimproConnectionState(
        ConnectionAvailable.attempting, ConnectionDirection.pulling);
    SimproConnectionEvent connectionEvent1 =
        AttemptingPullEvent(connectionState1);
    connectionBloc.add(connectionEvent1);
    http.Response resp = await oauth2Helper.get(
        'https://territorytrade.simprosuite.com/api/v1.0/currentUser/',
        headers: headers);
    SimproConnectionState connectionState2 = SimproConnectionState(
        ConnectionAvailable.yes, ConnectionDirection.pulling);
    SimproConnectionEvent connectionEvent2 =
        SuccessfulPullEvent(connectionState2);
    connectionBloc.add(connectionEvent2);
    Map<String, dynamic> currentUser = jsonDecode(resp.body);
    UserBloc userBloc = BlocProvider.of<UserBloc>(contextKey.currentContext!);
    UserState userState = new UserState(currentUser["ID"], currentUser["Name"]);
    UserEvent userEvent = new UserEvent(userState);
    userBloc.add(userEvent);
  }

  refreshJobListing() async {
    OAuth2Helper oauth2Helper = OAuth2Helper(client,
        grantType: OAuth2Helper.AUTHORIZATION_CODE,
        clientId: '216db2b119c178035694d36ee1b90b',
        clientSecret: 'ac0f1b5725');

    UserBloc userBloc = BlocProvider.of<UserBloc>(contextKey.currentContext!);
    Map<String, String> headers = {};
    headers["Accept"] = "*/*";
    int startTime = DateTime.now().millisecondsSinceEpoch;
    AccessTokenResponse? accessTokenResponse = await oauth2Helper.getToken();
    String? accessToken = accessTokenResponse?.accessToken;
    http.Response resp = await oauth2Helper.get(
        'https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/?Status.ID=!in(70,12,67,13,142,11)',
        headers: headers);
    List<dynamic> jobsListing = jsonDecode(resp.body);
    for (dynamic job in jobsListing) {
      int cycleTime = DateTime.now().millisecondsSinceEpoch - startTime;
      if (cycleTime < 100) {
        int timeToPause = 100 - cycleTime;
        await new Future.delayed(Duration(milliseconds: timeToPause));
      }
      int id = job["ID"];
      String link =
          "https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/" +
              id.toString() +
              "/timelines/";
      resp = await oauth2Helper.get(link, headers: headers);
      List<dynamic> timelines = jsonDecode(resp.body);
      bool scheduledForThisUser = false;
      for (dynamic timeline in timelines) {
        if (timeline["Type"] == "Schedule" &&
            timeline["Staff"]["ID"] == userBloc.state.id) {
          scheduledForThisUser = true;
        }
      }

      if (scheduledForThisUser == false) continue;

      startTime = DateTime.now().millisecondsSinceEpoch;

      String description = job["Description"];
      link =
          "https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/" +
              id.toString();
      resp = await oauth2Helper.get(link, headers: headers);
      Map<String, dynamic> jobDetails = jsonDecode(resp.body);
      String notes = jobDetails["Notes"];
      Map<String, dynamic> responseTimes = jobDetails["ResponseTime"];
      Map<String, dynamic> site = jobDetails["site"];
      List<dynamic> detailsNotesArray = [];
      int startingDivLength = 30;
      int startPos = startingDivLength;
      String iterationNote = notes;
      if (iterationNote.startsWith("<div")) {
        while (iterationNote.startsWith("<div")) {
          int endPos =
              startPos + iterationNote.substring(startPos).indexOf("</div");
          String thisNote = iterationNote.substring(startPos, endPos);
          detailsNotesArray.add(thisNote);
          iterationNote = iterationNote.substring(endPos + 6);
        }
      } else {
        detailsNotesArray.add(iterationNote);
      }
    }
  }

  refreshJobDetails(int jobId) async {
    Map<String, String> headers = {};
    headers["Accept"] = "*/*";
    int startTime = DateTime.now().millisecondsSinceEpoch;

    OAuth2Helper oauth2Helper = OAuth2Helper(client,
        grantType: OAuth2Helper.AUTHORIZATION_CODE,
        clientId: '216db2b119c178035694d36ee1b90b',
        clientSecret: 'ac0f1b5725');

    AccessTokenResponse? accessTokenResponse = await oauth2Helper.getToken();
    String? accessToken = accessTokenResponse?.accessToken;

    String link =
        "https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/" +
            jobId.toString();

    http.Response resp = await oauth2Helper.get(link, headers: headers);
    Map<String, dynamic> jobDetails = jsonDecode(resp.body);
    String notes = jobDetails["Notes"];
    Map<String, dynamic> responseTimes = jobDetails["ResponseTime"];
    Map<String, dynamic> site = jobDetails["site"];
    List<dynamic> detailsNotesArray = [];
    int startingDivLength = 30;
    int startPos = startingDivLength;
    String iterationNote = notes;
    if (iterationNote.startsWith("<div")) {
      while (iterationNote.startsWith("<div")) {
        int endPos =
            startPos + iterationNote.substring(startPos).indexOf("</div");
        String thisNote = iterationNote.substring(startPos, endPos);
        detailsNotesArray.add(thisNote);
        iterationNote = iterationNote.substring(endPos + 6);
      }
    } else {
      detailsNotesArray.add(iterationNote);
    }
  }
}
