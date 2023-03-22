import 'package:flutter/material.dart';
import 'package:ttsbuiltmobile/logic/blocs/simpro_connection_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/simpro_connection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/blocs/job_listing_bloc.dart';
import '../../logic/states/connection_available.dart';
import '../../logic/states/job_listing_state.dart';
import '../components/global.dart';
import '../router/app_router.dart';

class ItemListingScreen extends StatelessWidget {
  final int companyId;
  final int jobId;
  final double borderWidth = 4;
  ItemListingScreen(this.companyId, this.jobId);

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
        int rootSpotlessScheduleId = -1;
        List<Widget> scheduleItems = [];
        if (thisJob.containsKey("schedule-item-listing")) {
          //For each item, materials and photos can be listed
          //Notes will have a subject starting with an item code,
          // and where this is the case the notes will be a json string with properties
          // attachments and
          // materials
          // each containing an array of items input by the technician

          for (var item in thisJob["schedule-item-listing"]) {
            // for(int i = 0; i < 33; i++) {
              scheduleItems.add(getItemListing(item, size, context, jobId));
              if(rootSpotlessScheduleId == -1) rootSpotlessScheduleId = item["work-note-id"];
              scheduleItems.add(SizedBox(height: 8));
            // }
          }

          if(scheduleItems.isEmpty){
            if(thisJob.containsKey("schedule-item-listing-2") && thisJob["schedule-item-listing-2"].isNotEmpty){
              String firstItem = thisJob["schedule-item-listing-2"][0];
              int spacePos = firstItem.indexOf(" ");
              if (spacePos > 0) {
                String firstWord = firstItem.substring(0, spacePos);
                if (firstWord.length > 5) firstWord = firstWord.substring(0, 5);

              }
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
                      getJobDetailHeader(size, thisJob["details"]["Site"]["Name"], context, JobIDs(companyId, jobId)),
                      SizedBox(height: 8),
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: c2),
                          ),
                          padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
                          constraints: BoxConstraints(
                            maxWidth: size.width - 30,
                            maxHeight: size.height - 208,
                          ),
                          child: SingleChildScrollView(
                              child:Column(children: scheduleItems)
                          )
                      ),
                Container(
                  margin: EdgeInsets.fromLTRB(9, 12, 9, 12),
                    decoration: BoxDecoration(
                      border: Border.all(width: 6, color: c2),
                    ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          AppRouter.spotlessScheduleItemSelectionScreen,
                          arguments: WorkNoteID(0, thisJob["ID"], rootSpotlessScheduleId, 1));
                    },
                    child:Container(
                      height: 30,
                      color: c3,
                      child: Center(
                          child: Text(
                              "Add Spotless Schedule Item Link",
                              style: TextStyle(color: Colors.white, fontSize: 20)))),
                ))
                    ]))));
      });
    });
  }

  Widget getItemListing(var item, Size size, BuildContext context, int jobId){
    if(item.containsKey("iteration") == false) item["iteration"] = "001";
    List<Widget> attachments = [];
    if(item.containsKey("note") && item["note"].containsKey("attachments")){
      for(var attachment in item["note"]["attachments"]){
        attachments.add(SingleChildScrollView(child: Text(attachment["file-name"],
            style: TextStyle(color: Colors.white)), scrollDirection: Axis.horizontal,));
      }
    }
    return Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: c1_slightly_darker),
        ),

        child: Column(children: [
          Container(
              width: size.width - 2 * borderWidth,
              height: 23,
              color: c3,
              child: Center(
                  child: Text(
                      item["schedule-reference-item"]["Code"] +
                          ": " +
                          item["schedule-reference-item"]["Task"],
                      style: defaultTextStyle))),
          Row(
              children:const [
                Expanded(child:Center(child:Text("Attachments",
                    style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline)))),
                Expanded(child:Center(child: Text("Materials",
                    style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline)))),
              ]
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              constraints: BoxConstraints(
                                maxHeight: (size.height / 8) - 40,
                              ),
                              child: SingleChildScrollView(
                                  child: Column(children: attachments))),

                        ])),
                SizedBox(width: 3),
                Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [])))
              ]),
          Container(
              height: 23,
              child: Row(
              children:[
                Expanded(child:GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          AppRouter.itemAttachmentPath,
                          arguments: WorkNoteID(0, jobId, item["work-note-id"], int.parse(item["iteration"])));
                    },
                    child: Container(
                        margin: EdgeInsets.fromLTRB(2, 1, 1, 2),
                    decoration: BoxDecoration(
                      color: c4,
                      border: Border.all(width: 2, color: c2),
                    ),
                    child: Center(
                        child: Text("Click to add attachment",
                            style: TextStyle(color: Colors.white)))))),
                SizedBox(width: 3),
                Expanded(child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          AppRouter.spotlessScheduleItemSelectionScreen,
                          arguments: WorkNoteID(0, jobId, item["work-note-id"], item["iteration"]));
                    },
                    child:Container(
                        margin: EdgeInsets.fromLTRB(1, 1, 2, 2),
                        decoration: BoxDecoration(
                          color: c4,
                          border: Border.all(width: 2, color: c2),
                        ),
                    width: -8 + (size.width - 2) / 2,
                    child: Center(
                        child: Text("Click to add materials",
                            style: TextStyle(color: Colors.white))))))
              ]
          ))
        ]));
  }


}
