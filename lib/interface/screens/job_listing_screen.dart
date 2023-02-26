import 'package:flutter/material.dart';
import 'package:ttsbuiltmobile/data/repositories/simpro_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ttsbuiltmobile/logic/blocs/job_listing_bloc.dart';
import 'package:ttsbuiltmobile/logic/blocs/processing_progress_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/connection_available.dart';
import 'package:ttsbuiltmobile/logic/states/job_listing_state.dart';
import '../../logic/blocs/simpro_connection_bloc.dart';
import '../../logic/blocs/user_bloc.dart';
import '../../logic/states/job_state.dart';
import '../../logic/states/simpro_connection_state.dart';
import '../../logic/states/user_state.dart';
import '../components/global.dart';

class JobListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<SimproRepository>(
        lazy: true,
        create: (context) => SimproRepository(),
        child: BlocProvider<ProcessingProgressBloc>(
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
                              Padding(
                                  padding: new EdgeInsets.all(6.0),
                              child: Container(
                                  color: c2,
                                  width: size.width - 40,
                                  child:Padding(
                                      padding: new EdgeInsets.all(4.0),
                                    child: Row(
                                  children: <Widget>[
                                Image.asset(
                                    'assets/images/territory-trade-services-icon.png'),
                                Padding(
                                    padding: new EdgeInsets.all(7.0),
                                    child:Text(userState.name,
                                    style:
                                        const TextStyle(color: Colors.white, fontSize: 30))),
                              ])))),
                              BlocBuilder<ProcessingProgressBloc,
                                      ProcessingProgressState>(
                                  builder: (context, progressState) {
                                bool visible = false;
                                double progressValue = 1;
                                if (progressState.numberToProcess > 0 &&
                                    progressState.numberToProcess !=
                                        progressState.numberProcessed) {
                                  visible = true;
                                  progressValue =
                                      progressState.numberProcessed /
                                          progressState.numberToProcess;
                                }
                                if (visible) {
                                  return Text(progressState.numberProcessed.toString() + " job out of " + progressState.numberToProcess.toString(), style: TextStyle(color:Colors.white));
                                } else {
                                  return SizedBox.shrink();
                                }
                              }),
                              BlocBuilder<JobListingBloc, JobListingState>(
                                  builder: (context, jobListingState) {
                                List<Widget> jobListing = [];
                                Map<String, dynamic> jobs =
                                    jobListingState.jobs;
                                int count = 0;
                                for (String jobId in jobs.keys) {
                                  if(jobId == "last-job-listing-date") continue;
                                  Color backgroundColor = c3;
                                  if(count.isEven) backgroundColor = c4;
                                  Map<String, dynamic> job = jobs[jobId];
                                  List<Widget> jobDetailsColumnContents = [];
                                  List<dynamic> timelines = job["timelines"];
                                  String scheduledTime = "n/a";
                                  for(Map<String, dynamic> timeline in timelines){
                                    if(timeline.containsKey("Type") && timeline["Type"] == "Schedule"){
                                      if(timeline["Staff"]["ID"] == userBloc.state.id){
                                        scheduledTime = timeline["Message"];
                                      }
                                    }
                                  }
                                  String site = "n/a";
                                  if(job.containsKey("details") && job["details"].containsKey("Site")) site = job["details"]["Site"]["Name"];
                                  String item = "n/a";
                                  if(job.containsKey("schedule-items-listing")){
                                    item = job["schedule-items-listing"][0];
                                  }

                                  jobDetailsColumnContents.add(
                                    Container(
                                      width: size.width - 30,
                                      child: Card(
                                    color: backgroundColor,
                                    child: new Padding(
                                      padding: new EdgeInsets.all(7.0),
                                      child: new Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(scheduledTime, style: TextStyle(color: Colors.white, backgroundColor: backgroundColor)),
                                          Text(site, style: TextStyle(color: Colors.white, backgroundColor: backgroundColor)),
                                          Text(item, style: TextStyle(color: Colors.white, backgroundColor: backgroundColor))
                                        ],
                                      ),
                                    ),
                                  ))
                                  );
                                  jobListing.add(Column(children: jobDetailsColumnContents));
                                  count++;
                                }
                                //return Text("in bloc", style: TextStyle(color: Colors.white));
                                return Expanded(child:ListView( children: jobListing, scrollDirection: Axis.vertical,));
                              }),
                            ]))));
              });
            })));
  }
}
