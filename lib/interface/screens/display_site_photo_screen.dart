import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/job_listing_bloc.dart';
import '../components/global.dart';
import '../router/app_router.dart';

// A widget that displays the picture taken by the user.
class DisplaySitePhotoScreen extends StatelessWidget {
  final WorkNoteAttachment attachment;
  DisplaySitePhotoScreen(this.attachment);
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    JobListingBloc jlb = BlocProvider.of<JobListingBloc>(context);
    Map<String, dynamic> thisJob = jlb.state.jobs[attachment.jobId.toString()];
    return Scaffold(
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
        body: SafeArea(
            child: Scaffold(
                body: Container(
                    color: Colors.black,
                    width: size.width,
                    child: Column(children: [
                      getJobHeader(size, thisJob["details"]["Site"]["Name"]),
                      Container(
                          child: Text(
                              "Attach photo to ",
                              style: defaultTextStyle)),
                      SizedBox(height: 5),
                      Expanded(child: Image.file(File(attachment.imagePath))),
                      SizedBox(height: 5),
                      Container(
                          height: 30,
                          width: size.width - 30,
                          child: Row(
                              children:[
                                Expanded(child:GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          AppRouter.itemAttachmentPath,
                                          arguments: WorkNoteID(0, attachment.jobId, attachment.workNoteId, attachment.iteration));
                                    },
                                    child: Container(
                                        margin: EdgeInsets.fromLTRB(2, 1, 1, 2),
                                        decoration: BoxDecoration(
                                          color: c4,
                                          border: Border.all(width: 2, color: c2),
                                        ),
                                        child: Center(
                                            child: Text("Before",
                                                style: defaultTextStyle))))),
                                SizedBox(width: 3),
                                Expanded(child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          AppRouter.spotlessScheduleItemSelectionScreen,
                                          arguments: WorkNoteID(0, attachment.jobId, attachment.workNoteId, attachment.iteration));
                                    },
                                    child:Container(
                                        margin: EdgeInsets.fromLTRB(1, 1, 2, 2),
                                        decoration: BoxDecoration(
                                          color: c4,
                                          border: Border.all(width: 2, color: c2),
                                        ),
                                        width: -8 + (size.width - 2) / 2,
                                        child: Center(
                                            child: Text("After",
                                                style: defaultTextStyle)))))
                              ]
                          ))
                    ])))));
  }
}
