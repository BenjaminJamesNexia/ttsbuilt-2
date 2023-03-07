import 'package:flutter/material.dart';
import 'package:ttsbuiltmobile/logic/blocs/simpro_connection_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/simpro_connection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/blocs/job_listing_bloc.dart';
import '../../logic/blocs/processing_progress_bloc.dart';
import '../../logic/states/connection_available.dart';
import '../../logic/states/job_listing_state.dart';
import '../components/global.dart';
import '../router/app_router.dart';

class SpotlessScheduleItemSelectionScreen extends StatelessWidget {
  final int companyId;
  final int jobId;
  final int workNoteId;
  final double borderWidth = 4;
  SpotlessScheduleItemSelectionScreen(this.companyId, this.jobId, this.workNoteId);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimproConnectionBloc, SimproConnectionState>(
        builder: (context, connectionState) {
          final Size size = MediaQuery.of(context).size;
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
                List<Widget> scheduleItems = [];
                if (thisJob.containsKey("schedule-items-listing")) {
                  //For each item, materials and photos can be listed
                  //Notes will have a subject starting with an item code,
                  // and where this is the case the notes will be a json string with properties
                  // attachments and
                  // materials
                  // each containing an array of items input by the technician
                  for (var item in thisJob["schedule-items-listing"]) {
                    for(int i = 0; i < 33; i++) {
                      scheduleItems.add(getItemListing(item, size));
                      scheduleItems.add(SizedBox(height: 8));
                    }
                  }
                } else {
                  if (thisJob.containsKey("schedule-item-listing-2")) {}
                }
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
                              Padding(
                                  padding: new EdgeInsets.all(6.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: c2,
                                          border: Border.all(
                                            color: c2,
                                          ),
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                      child: Padding(
                                          padding: new EdgeInsets.all(4.0),
                                          child: Row(children: <Widget>[
                                            Image.asset(
                                                'assets/images/territory-trade-services-icon.png'),
                                            Spacer(),
                                            Padding(
                                                padding: new EdgeInsets.all(7.0),
                                                child: Text(
                                                    thisJob["details"]["Site"]["Name"],
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 30))),
                                            Spacer(),
                                          ])))),

                              SizedBox(height: 8),
                              Container(
                                margin: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(width: 2.0, color: c2),
                                    left: BorderSide(width: 2.0, color: c2),
                                    right: BorderSide(width: 2.0, color: c2),
                                  )
                                ),
                                child: Container(
                                    height: 26,
                                    color: c3,
                                    child: Center(
                                        child: Text(
                                            "Linked Spotless Schedule Items",
                                            style: TextStyle(color: Colors.white, fontSize: 20)))),
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 2, color: c2),
                                  ),
                                  padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
                                  constraints: BoxConstraints(
                                    maxWidth: size.width - 30,
                                    maxHeight: size.height/4,
                                  ),
                                  child: SingleChildScrollView(
                                      child:Column(children: scheduleItems)
                                  )
                              ),
                            ]))));
              });
        });
  }

  Widget getItemListing(item, Size size){
    return Container(
        child: Column(children: [
          Container(
              width: size.width - 2 * borderWidth,
              height: 20,
              color: c3,
              child: Center(
                  child: Text(
                      item["schedule-reference-item"]["Code"] +
                          ": " +
                          item["schedule-reference-item"]["Task"],
                      style: TextStyle(color: Colors.white)))),
        ]));
  }
}
