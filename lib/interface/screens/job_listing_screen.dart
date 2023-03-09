import 'package:flutter/material.dart';
import 'package:ttsbuiltmobile/data/repositories/simpro_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ttsbuiltmobile/logic/blocs/job_listing_bloc.dart';
import 'package:ttsbuiltmobile/logic/blocs/processing_progress_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/connection_available.dart';
import 'package:ttsbuiltmobile/logic/states/job_listing_state.dart';
import '../../logic/blocs/simpro_connection_bloc.dart';
import '../../logic/blocs/user_bloc.dart';
import '../../logic/states/simpro_connection_state.dart';
import '../../logic/states/user_state.dart';
import '../components/global.dart';
import '../router/app_router.dart';

class JobListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProcessingProgressBloc>(
            create: (BuildContext context) {
          ProcessingProgressBloc bloc = ProcessingProgressBloc();
          return bloc;
        }, child: BlocBuilder<SimproConnectionBloc, SimproConnectionState>(
                builder: (context, connectionState) {
          SimproRepository simproRepository =
              RepositoryProvider.of<SimproRepository>(context);
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
          UserBloc userBloc = BlocProvider.of<UserBloc>(context);

          return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
            if (userState.name != "n/a") {
              simproRepository.refreshJobListing(context);
            }
            return SafeArea(
                child: Scaffold(
                    body: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(
                              width: borderWidth, color: borderColor),
                        ),
                        width: size.width - 2 * borderWidth,
                        height: size.height - 2 * borderWidth,
                        child: Column(children: <Widget>[
                          getUserHeader(size, userState),
                          BlocBuilder<ProcessingProgressBloc,
                                  ProcessingProgressState>(
                              builder: (context, progressState) {
                            bool visible = false;
                            double progressValue = 1;
                            if (progressState.numberToProcess > 0 &&
                                progressState.numberToProcess !=
                                    progressState.numberProcessed) {
                              visible = true;
                              progressValue = progressState.numberProcessed /
                                  progressState.numberToProcess;
                            }
                            if (visible) {
                              return LinearProgressIndicator(
                                value: progressValue,
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          }),
                          BlocBuilder<JobListingBloc, JobListingState>(
                              builder: (context, jobListingState) {
                            List<Widget> jobListing = [];
                            Map<String, dynamic> jobs = jobListingState.jobs;
                            int count = 0;
                            for (String jobId in jobs.keys) {
                              if (jobId == "last-job-listing-date") continue;
                              Color backgroundColor = c3;
                              if (count.isEven) backgroundColor = c4;
                              Map<String, dynamic> job = jobs[jobId];
                              List<Widget> jobDetailsColumnContents = [];
                              List<dynamic> timelines = job["timelines"];
                              String scheduledTime = "n/a";
                              for (Map<String, dynamic> timeline in timelines) {
                                if (timeline.containsKey("Type") &&
                                    timeline["Type"] == "Schedule") {
                                  if (timeline["Staff"]["ID"] ==
                                      userBloc.state.id) {
                                    scheduledTime = timeline["Message"]
                                        .replaceAll("Attend site from",
                                            timeline["Date"].substring(0, 10));
                                  }
                                }
                              }
                              String site = "n/a";
                              if (job.containsKey("details") &&
                                  job["details"].containsKey("Site"))
                                site = job["details"]["Site"]["Name"];
                              var item = null;
                              if (job.containsKey("schedule-item-listing") && job["schedule-item-listing"].length > 0) {
                                item = job["schedule-item-listing"][0];
                                if(item.runtimeType != "String"){
                                  item = item["schedule-reference-item"]["Code"] + ": " + item["schedule-reference-item"]["Task"];
                                }
                              }else{
                                continue;
                              }

                              jobDetailsColumnContents.add(Container(
                                  width: size.width - 30,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 2, color: c2),
                                  ),
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.of(context)
                                          .pushNamed(
                                          AppRouter.jobDetailPath,
                                          arguments: JobIDs(0, job["ID"])
                                      );
                                      },
                                      child: Card(
                                    color: backgroundColor,
                                    child: new Padding(
                                      padding: new EdgeInsets.all(7.0),
                                      child: new Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(scheduledTime,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  backgroundColor:
                                                      backgroundColor)),
                                          Text(site,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  backgroundColor:
                                                      backgroundColor)),
                                          Text(item,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  backgroundColor:
                                                      backgroundColor))
                                        ],
                                      ),
                                    ),
                                  ))));
                              jobListing.add(
                                  Column(children: jobDetailsColumnContents));
                              jobListing.add(SizedBox(height: 5));
                              count++;
                            }
                            //return Text("in bloc", style: TextStyle(color: Colors.white));
                            return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 2, color: c2),
                                ),
                                padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
                                constraints: BoxConstraints(
                                  maxWidth: size.width - 30,
                                  maxHeight: size.height - 153,
                                ),
                                child: SingleChildScrollView(
                                    child:Column(children: jobListing)
                                )
                            );
                          }),
                        ]))));
          });
        }));
  }
}
