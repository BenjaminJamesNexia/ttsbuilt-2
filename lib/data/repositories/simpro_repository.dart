import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/dom.dart';
import 'package:ttsbuiltmobile/data/repositories/persistence.dart';
import 'package:ttsbuiltmobile/data/repositories/schedule_repository.dart';
import 'package:ttsbuiltmobile/logic/blocs/processing_progress_bloc.dart';
import 'package:ttsbuiltmobile/logic/blocs/simpro_connection_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/connection_direction.dart';
import 'package:ttsbuiltmobile/logic/states/job_listing_event.dart';
import '../../interface/components/global.dart';
import '../../logic/blocs/job_listing_bloc.dart';
import '../../logic/blocs/user_bloc.dart';
import '../../logic/states/connection_available.dart';
import '../../logic/states/job_listing_state.dart';
import '../../logic/states/simpro_connection_event.dart';
import '../../logic/states/simpro_connection_state.dart';
import '../../logic/states/user_event.dart';
import '../../logic/states/user_state.dart';
import '../utility/job_detail_note.dart';
import '../utility/simpro_oauth2_client.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

SimproOAuth2Client client = SimproOAuth2Client(
    redirectUri: 'com.nexiaem.ttsbuiltmobile://oauth2redirect',
    customUriScheme: 'com.nexiaem.ttsbuiltmobile');

class SimproRepository {
  static final SimproRepository _instance =
      SimproRepository._privateConstructor();
  static GlobalKey<NavigatorState> contextKey = GlobalKey<NavigatorState>();

  Persistence persistence = Persistence();
  Map<String, dynamic> jobs = {};
  String lastJobListingDate = "n/a";
  BuildContext? _lastContext;
  bool refreshingJobListing = false;

  Timer? periodicTimer;

  SimproRepository._privateConstructor() {
    createUserEvent();
    periodicTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        runTimedRefresh();
      },
    );
  }

  factory SimproRepository() {
    return _instance;
  }

  void runTimedRefresh() {
    if (_lastContext != null){
      refreshJobListing(_lastContext!);
      print("job list refresh triggered by timer");
    }
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
        ConnectionAvailable.attempting,
        ConnectionDirection.pulling,
        "Contacting Simpro Server");
    SimproConnectionEvent connectionEvent1 =
        AttemptingPullEvent(connectionState1);
    connectionBloc.add(connectionEvent1);
    http.Response resp = await oauth2Helper.get(
        'https://territorytrade.simprosuite.com/api/v1.0/currentUser/',
        headers: headers);
    SimproConnectionState connectionState2 = SimproConnectionState(
        ConnectionAvailable.yes,
        ConnectionDirection.pulling,
        "Getting User Data");
    SimproConnectionEvent connectionEvent2 =
        SuccessfulPullEvent(connectionState2);
    connectionBloc.add(connectionEvent2);
    Map<String, dynamic> currentUser = jsonDecode(resp.body);
    UserBloc userBloc = BlocProvider.of<UserBloc>(contextKey.currentContext!);

    if (currentUser["ID"] == 62) {
      currentUser["ID"] = 51;
      currentUser["Name"] = "Alec Mangan";
    }

    SimproConnectionState connectionState3 = SimproConnectionState(
        ConnectionAvailable.idle, ConnectionDirection.idle, "idle");
    SimproConnectionEvent connectionEvent3 =
        SuccessfulPullEvent(connectionState3);
    connectionBloc.add(connectionEvent3);

    UserState userState = new UserState(currentUser["ID"], currentUser["Name"]);
    UserEvent userEvent = new UserEvent(userState);
    userBloc.add(userEvent);
  }

  refreshJobListing(BuildContext context) async {
    _lastContext = context;

    if (refreshingJobListing) return;
    refreshingJobListing = true;

    //companyJobsRequest.addHeader("If-Modified-Since", lastJobListingDate);
    Map<String, dynamic> jobStates = {};

    ScheduleRepository scheduleRepo =
        RepositoryProvider.of<ScheduleRepository>(context);

    if (jobs.isEmpty) {
      Map<String, dynamic> persistedData =
          await persistence.getJobListingFromFile();
      if (persistedData.isNotEmpty && persistedData.length > 1) {
        lastJobListingDate = persistedData["last-job-listing-date"];
        jobs = persistedData;
        jobStates = jobs;
        JobListingState newState = JobListingState(jobStates);
        JobListingEvent jobListingEvent = LoadJobListing(newState);
        JobListingBloc listingBloc = BlocProvider.of<JobListingBloc>(context);
        listingBloc.add(jobListingEvent);
      }
    } else {
      jobStates = jobs;
    }

    OAuth2Helper oauth2Helper = OAuth2Helper(client,
        grantType: OAuth2Helper.AUTHORIZATION_CODE,
        clientId: '216db2b119c178035694d36ee1b90b',
        clientSecret: 'ac0f1b5725');

    SimproConnectionBloc connectionBloc =
        BlocProvider.of<SimproConnectionBloc>(contextKey.currentContext!);
    SimproConnectionState connectionState1 = SimproConnectionState(
        ConnectionAvailable.attempting,
        ConnectionDirection.pulling,
        "Pulling job listing from Simpro");
    SimproConnectionEvent connectionEvent1 =
        AttemptingPullEvent(connectionState1);
    connectionBloc.add(connectionEvent1);

    UserBloc userBloc = BlocProvider.of<UserBloc>(contextKey.currentContext!);
    Map<String, String> headers = {};
    headers["Accept"] = "*/*";
    if (lastJobListingDate != "n/a")
      headers["If-Modified-Since"] = lastJobListingDate;
    int startTime = DateTime.now().millisecondsSinceEpoch;
    AccessTokenResponse? accessTokenResponse = await oauth2Helper.getToken();
    String? accessToken = accessTokenResponse?.accessToken;
    int pageNum = 1;
    http.Response resp = await oauth2Helper.get(
        'https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/?page=' +
            pageNum.toString() +
            '&Status.ID=!in(70,12,67,13,142,11)',
        headers: headers);
    List<dynamic> jobsListing = jsonDecode(resp.body);
    Map<String, String> httpHeaders = resp.headers;
    int numberOfJobsToProcess = int.parse(httpHeaders["result-total"]!);
    ProcessingProgressState processingState =
        ProcessingProgressState(0, numberOfJobsToProcess);
    ProcessingProgressEvent processingEvent =
        ProcessingProgressEvent(processingState);
    ProcessingProgressBloc processingBloc =
        BlocProvider.of<ProcessingProgressBloc>(context);
    processingBloc.add(processingEvent);
    if (httpHeaders.containsKey("date"))
      lastJobListingDate = httpHeaders["date"]!;
    SimproConnectionState connectionState2 = SimproConnectionState(
        ConnectionAvailable.yes,
        ConnectionDirection.pulling,
        "Processing Simpro Job Listing");
    SimproConnectionEvent connectionEvent2 =
        AttemptingPullEvent(connectionState2);
    connectionBloc.add(connectionEvent2);

    int jobDetailStartTime = 0;

    int jobsProcessed = 0;

    while (jobsListing.isNotEmpty) {
      for (Map<String, dynamic> job in jobsListing) {
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

        ///The simpro api allows a hit from the same link every 100 milliseconds so need to wait until this time has passed
        int nowTime = DateTime.now().millisecondsSinceEpoch;
        if (jobDetailStartTime > 0 && nowTime - jobDetailStartTime < 100) {
          await Future.delayed(
              Duration(milliseconds: (100 - (nowTime - jobDetailStartTime))));
        }
        jobDetailStartTime = DateTime.now().millisecondsSinceEpoch;
        try {
          resp = await oauth2Helper.get(link, headers: headers);
        } catch (ex) {
          print(
              "Error thrown in refreshJobListing - caught so it can be retried after a pause");
          print(ex.toString());
          await Future.delayed(Duration(milliseconds: 300));
          resp = await oauth2Helper.get(link, headers: headers);
        }
        List<dynamic> timelines = jsonDecode(resp.body);
        bool scheduledForThisUser = false;
        for (Map<String, dynamic> timeline in timelines) {
          if (timeline["Type"] == "Schedule" &&
              timeline.containsKey("Staff") &&
              timeline["Staff"].containsKey("ID") &&
              timeline["Staff"]["ID"] == userBloc.state.id) {
            scheduledForThisUser = true;
          }
        }

        job["timelines"] = timelines;

        if (scheduledForThisUser == false) continue;

        startTime = DateTime.now().millisecondsSinceEpoch;

        link =
            "https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/" +
                id.toString() +
                "/notes/";

        resp = await oauth2Helper.get(link, headers: headers);

        var jobNotes = jsonDecode(resp.body);
        job["schedule-item-listing"] = [];
        for (var jobNote in jobNotes) {
          String? thisSubject = jobNote["Subject"];
          int thisID = jobNote["ID"];
          if (thisSubject != null) {
            int spacePos = thisSubject.indexOf(" ");
            if (spacePos > 0) {
              String firstWord = thisSubject.substring(0, spacePos);
              if (firstWord.length > 5) firstWord = firstWord.substring(0, 5);
              if (scheduleRepo.isAnItemCode(firstWord)) {
                //Then this is a job note that we want to set as a schedule item
                var scheduleItem = {};
                scheduleItem["work-note-id"] = thisID;
                var item = scheduleRepo.getItem(firstWord);
                scheduleItem["schedule-reference-item"] = item;
                if (jobNote["Note"] != null && jobNote["Note"].length > 0) {
                  var note = jsonDecode(jobNote["Note"]);
                  scheduleItem["note"] = note;
                  if (note.containsKey("iteration")) {
                    scheduleItem["iteration"] = note["iteration"];
                  } else {
                    scheduleItem["iteration"] = "001";
                  }
                } else {
                  scheduleItem["iteration"] = "001";
                }
                job["schedule-item-listing"].add(scheduleItem);
              }
            }
          }
        }
        String description = job["Description"];
        link =
            "https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/" +
                id.toString();
        resp = await oauth2Helper.get(link, headers: headers);
        Map<String, dynamic> jobDetails = jsonDecode(resp.body);
        job["details"] = jobDetails;
        String notes = jobDetails["Notes"];
        Map<String, dynamic> responseTimes = jobDetails["ResponseTime"];
        Map<String, dynamic> site = jobDetails["Site"];
        List<String> detailsNotesArray = [];
        int startingDivLength = 30;
        int startPos = startingDivLength;
        String iterationNote = notes;

        var document = parse(notes);
        NodeList documentNodes = document.firstChild!.nodes[1].nodes;
        if (documentNodes[0].nodes.length > 1)
          documentNodes = documentNodes[0].nodes;
        List<String> scheduleItemListing = [];
        for (var node in documentNodes) {
          String? thisText = node.text;
          if (thisText != null) {
            int end = thisText.length - 1;
            int spacePos = thisText.indexOf(" ");
            if (spacePos > 0) {
              String firstWord = thisText.substring(0, spacePos);
              if (firstWord.length > 5) firstWord = firstWord.substring(0, 5);
              if (scheduleRepo.isAnItemCode(firstWord)) {
                var item = scheduleRepo.getItem(firstWord);
                scheduleItemListing.add(item!["Code"]! + " " + item!["Task"]!);
              } else {
                int secondSpacePos = thisText.indexOf(" ", spacePos + 1);
                if (secondSpacePos > spacePos + 1) {
                  String secondWord = thisText.substring(
                      spacePos + 1, thisText.indexOf(" ", spacePos + 1));
                  if (secondWord.length > 5)
                    secondWord = secondWord.substring(0, 5);
                  if (scheduleRepo.isAnItemCode(secondWord)) {
                    var item = scheduleRepo.getItem(secondWord);
                    scheduleItemListing
                        .add(item!["Code"]! + " " + item!["Task"]!);
                  }
                }
              }
            }
          }
        }

        job["schedule-item-listing-2"] = scheduleItemListing;

        var innerText = document.firstChild!.text;

        if (iterationNote.startsWith("<div")) {
          while (iterationNote.startsWith("<div")) {
            int endPos = iterationNote.length - 7;
            if (iterationNote.startsWith("<div style=\"font-size: 10pt;\">")) {
              try {
                endPos = startPos +
                    iterationNote.substring(startPos).indexOf("</div");
              } catch (e) {}
            }
            String thisNote = "?";
            if (endPos > startPos) {
              thisNote = iterationNote.substring(startPos, endPos);
            }
            detailsNotesArray.add(thisNote);
            iterationNote = iterationNote.substring(endPos + 6);
          }
        } else {
          detailsNotesArray.add(iterationNote);
        }

        jobStates[job["ID"].toString()] = job;
        jobsProcessed++;
        processingState =
            ProcessingProgressState(jobsProcessed, numberOfJobsToProcess);
        processingEvent = ProcessingProgressEvent(processingState);
        processingBloc.add(processingEvent);
      }
      pageNum++;

      OAuth2Helper oauth2Helper2 = OAuth2Helper(client,
          grantType: OAuth2Helper.AUTHORIZATION_CODE,
          clientId: '216db2b119c178035694d36ee1b90b',
          clientSecret: 'ac0f1b5725');

      resp = await oauth2Helper2.get(
          'https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/?page=' +
              pageNum.toString() +
              '&Status.ID=!in(70,12,67,13,142,11)',
          headers: headers);
      jobsListing = jsonDecode(resp.body);
    }
    jobStates["last-job-listing-date"] = lastJobListingDate;
    persistence.writeJobListing(jobStates);
    JobListingState newState = JobListingState(jobStates);
    JobListingEvent jobListingEvent = LoadJobListing(newState);
    JobListingBloc listingBloc = BlocProvider.of<JobListingBloc>(context);
    listingBloc.add(jobListingEvent);
    processingState = ProcessingProgressState(-1, 0);
    processingEvent = ProcessingProgressEvent(processingState);
    processingBloc.add(processingEvent);
    refreshingJobListing = false;
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

  appendJobDetailNotes(int id, List<JobDetailNote> notesToAppend) async {
    //for testing just use the test id
    id = 3000837;
    Map<String, String> headers = {};
    headers["Accept"] = "*/*";
    headers["Content-Type"] = "application/json";
    try {
      String link =
          "https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/" +
              id.toString();
      OAuth2Helper oauth2Helper = OAuth2Helper(client,
          grantType: OAuth2Helper.AUTHORIZATION_CODE,
          clientId: '216db2b119c178035694d36ee1b90b',
          clientSecret: 'ac0f1b5725');
      AccessTokenResponse? accessTokenResponse = await oauth2Helper.getToken();
      String? accessToken = accessTokenResponse?.accessToken;
      http.Response resp = await oauth2Helper.get(link, headers: headers);
      Map<dynamic, dynamic> jobDetails = jsonDecode(resp.body);
      var existingNotes = StringBuffer(jobDetails["Notes"]);
      for (JobDetailNote thisNote in notesToAppend) {
        existingNotes.write(thisNote.getJobDetailToAppend());
      }
      String bodyString = "{\"Notes\":\"" +
          existingNotes.toString().replaceAll("\"", "\\\"") +
          "\"}";
      String jobDataPatchLink =
          "https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/" +
              id.toString();
      http.Response patchResult = await oauth2Helper.patch(jobDataPatchLink,
          headers: headers, body: bodyString);
      if (patchResult.statusCode != 204) {
        debugPrint(patchResult.toString());
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  ///The item should be a Map<String, String> - it seems to get a _Map<String, String> in the screen and not sure how to handle that so used var here
  ///as it seems to work for both
  Future<int> addAWorkNoteScheduleItem(int id, var item, int iteration) async {
    //for testing just use the test id
    id = 3000837;
    Map<String, String> headers = {};
    headers["Accept"] = "*/*";
    headers["Content-Type"] = "application/json";
    Map<String, String> body = {};
    body["Subject"] = item["Code"]! + " " + item["Task"]!;
    if (iteration > 1)
      body["Note"] =
          "{\"iteration\":" + iteration.toString().padLeft(3, "0") + "}";
    String bodyString = jsonEncode(body);
    try {
      String link =
          "https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/" +
              id.toString() +
              "/notes/";
      OAuth2Helper oauth2Helper = OAuth2Helper(client,
          grantType: OAuth2Helper.AUTHORIZATION_CODE,
          clientId: '216db2b119c178035694d36ee1b90b',
          clientSecret: 'ac0f1b5725');
      http.Response postResult =
          await oauth2Helper.post(link, headers: headers, body: bodyString);
      if (postResult.statusCode != 201) {
        debugPrint(postResult.toString());
      } else {
        debugPrint(postResult.toString());
        var responseBody = json.decode(utf8.decode(postResult.bodyBytes));
        return responseBody["ID"];
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
    return -1;
  }

  ///This saves the attachment in the job and updates the work note representing the schedule item the note is attachemd to
  Future<int> saveJobItemAttachment(WorkNoteAttachment attachment, AttachmentPhase phase) async {
    //for testing just use the test id
    id = 3000837;
    Map<String, String> headers = {};
    headers["Accept"] = "*/*";
    headers["Content-Type"] = "application/json";
    Map<String, String> body = {};
    body["Subject"] = item["Code"]! + " " + item["Task"]!;
    if (iteration > 1)
      body["Note"] =
          "{\"iteration\":" + iteration.toString().padLeft(3, "0") + "}";
    String bodyString = jsonEncode(body);
    try {
      String link =
          "https://territorytrade.simprosuite.com/api/v1.0/companies/0/jobs/" +
              id.toString() +
              "/notes/";
      OAuth2Helper oauth2Helper = OAuth2Helper(client,
          grantType: OAuth2Helper.AUTHORIZATION_CODE,
          clientId: '216db2b119c178035694d36ee1b90b',
          clientSecret: 'ac0f1b5725');
      http.Response postResult =
      await oauth2Helper.post(link, headers: headers, body: bodyString);
      if (postResult.statusCode != 201) {
        debugPrint(postResult.toString());
      } else {
        debugPrint(postResult.toString());
        var responseBody = json.decode(utf8.decode(postResult.bodyBytes));
        return responseBody["ID"];
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
    return -1;
  }

}
