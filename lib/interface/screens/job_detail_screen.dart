import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ttsbuiltmobile/data/repositories/schedule_repository.dart';
import 'package:ttsbuiltmobile/logic/blocs/simpro_connection_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/simpro_connection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/blocs/job_listing_bloc.dart';
import '../../logic/blocs/processing_progress_bloc.dart';
import '../../logic/states/connection_available.dart';
import '../../logic/states/job_listing_state.dart';
import '../components/global.dart';
import '../router/app_router.dart';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

class JobDetailScreen extends StatelessWidget {
  final int companyId;
  final int jobId;

  final int headerHeight = 175;

  JobDetailScreen(this.companyId, this.jobId);

  @override
  Widget build(BuildContext context) {
    ScheduleRepository scheduleRepo =
        RepositoryProvider.of<ScheduleRepository>(context);
    return BlocBuilder<SimproConnectionBloc, SimproConnectionState>(
        builder: (context, connectionState) {
      final Size size = MediaQuery.of(context).size;
      double borderWidth = 4;
      Color borderColor;
      switch (connectionState.available) {
        case ConnectionAvailable.attempting:
          {
            borderColor = Colors.amber;
          }
          break;
        case ConnectionAvailable.idle:
          {
            borderColor = Colors.grey;
          }
          break;
        case ConnectionAvailable.yes:
          {
            borderColor = Colors.lightGreenAccent;
          }
          break;
        case ConnectionAvailable.no:
          {
            borderColor = Colors.red;
          }
      }
      return BlocBuilder<JobListingBloc, JobListingState>(
          builder: (context, jobListingState) {
        Map<String, dynamic> thisJob = jobListingState.jobs[jobId.toString()];
        List<Widget> scheduleItemsList = [];
        scheduleItemsList.add(Container(
            width: size.width - 30,
            height: 22,
            color: c3,
            child: Padding(
                    padding: new EdgeInsets.fromLTRB(7, 3, 3, 3),
                    child: Text("Spotless Scheduled Items", style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold))
                )
            ));
        for (String item in thisJob["schedule-item-listing-2"]) {
          int firstSpacePos = item.indexOf(" ");
          if (firstSpacePos == -1) continue;
          String firstWord = item.substring(0, firstSpacePos);
          if(firstWord.length > 5) firstWord = firstWord.substring(0,5);
          if (scheduleRepo.isAnItemCode(firstWord) == false) continue;
          scheduleItemsList.add(
              Container(
                width: size.width - 30,
                child: new Padding(
                      padding: new EdgeInsets.fromLTRB(10, 3, 3, 0),
                      child: Text(item, style: const TextStyle(
                        color: Colors.white, fontSize: 18))
                    )
              )
          );
        }
        scheduleItemsList.add(SizedBox(height:7));
        Html descriptionHTML = Html(
            data: thisJob["Description"],
            style: {
              "div": Style(
                  color: Colors.white,
                  fontSize: FontSize(18))
            });
        Html workNotesHTML = Html(
            data: thisJob["details"]["Notes"],
            style: {
              "div": Style(
                  color: Colors.white,
                  fontSize: FontSize(18))
            });
        return SafeArea(
            child: Scaffold(
                body: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border:
                          Border.all(width: borderWidth, color: borderColor),
                    ),
                    width: size.width - 2 * borderWidth,
                    height: size.height - 2 * borderWidth,
                    child: Column(children: <Widget>[
                      getJobHeader(size, thisJob),
                      Container(
                          decoration: BoxDecoration(
                            color: c3,
                            border: Border.all(width: 2, color: c2),
                          ),
                          height: 1.5 * (size.height - headerHeight) / 3,
                          width: size.width - 30,
                          child: SingleChildScrollView(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        AppRouter.descriptionDetailPath,
                                        arguments: JobIDs(0, thisJob["ID"]));
                                  },
                                  child: Padding(
                                        padding: new EdgeInsets.all(7.0),
                                        child: descriptionHTML
                                    ),
                                  ))),
                      SizedBox(height: 7),
                      Container(

                          decoration: BoxDecoration(
                            color: c4,
                            border: Border.all(width: 2, color: c2),
                          ),
                          height: 1 * (size.height - headerHeight) / 3,
                          width: size.width - 30,
                          child: SingleChildScrollView(
                              child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  AppRouter.workNotesPath,
                                  arguments: JobIDs(0, thisJob["ID"]));
                            },
                            child: Padding(
                                    padding: new EdgeInsets.all(7.0),
                                    child: workNotesHTML)),
                          )),
                      SizedBox(height: 7),

                      Container(
                          decoration: BoxDecoration(
                            color: c3,
                            border: Border.all(width: 2, color: c2),
                          ),
                          height: 10 + 0.5 * (size.height - headerHeight) / 3,
                          width: size.width - 30,
                          child: SingleChildScrollView(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        AppRouter.itemListingPath,
                                        arguments: JobIDs(0, thisJob["ID"]));
                                  },
                                  child: Column(
                                      children: scheduleItemsList
                                  )
                              ))),


                    ]))));
      });
    });
  }
}
