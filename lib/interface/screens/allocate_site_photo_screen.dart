import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ttsbuiltmobile/data/repositories/simpro_repository.dart';
import '../../logic/blocs/job_listing_bloc.dart';
import '../components/global.dart';
import '../router/app_router.dart';

// A widget that displays the picture taken by the user.
class AllocateSitePhotoScreen extends StatelessWidget {
  final WorkNoteAttachment attachment;
  AllocateSitePhotoScreen(this.attachment);
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    JobListingBloc jlb = BlocProvider.of<JobListingBloc>(context);
    Map<String, dynamic> thisJob = jlb.state.jobs[attachment.jobId.toString()];
    List<dynamic> scheduleItems = thisJob["schedule-item-listing"];
    Map<String, dynamic>? thisItem;
    String attachmentNote = "Attach to ";
    for(int i = 0; i < scheduleItems.length; i++){
      var maybeThisItem = scheduleItems[i];
      if(maybeThisItem.containsKey("work-note-id") && maybeThisItem["work-note-id"] == attachment.workNoteId && maybeThisItem["iteration"] == attachment.iteration){
        thisItem = maybeThisItem;
        attachmentNote = "Attach to " + thisItem!["schedule-reference-item"]["Code"] + " " + thisItem!["schedule-reference-item"]["Task"];
        if(thisItem["iteration"] > 1) attachmentNote = attachmentNote + "(" + thisItem["iteration"].toString() + ")";
        break;
      }
    }

    return Scaffold(
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
        body: SafeArea(
            child: Scaffold(
                body: Container(
                    color: Colors.black,
                    width: size.width,
                    child: Column(children: [
                      getJobDetailHeader(size, thisJob["details"]["Site"]["Name"], context, JobIDs(attachment.companyId, attachment.jobId)),
                      Expanded(child: Image.file(File(attachment.imagePath))),
                      SizedBox(height: 5),
                      Container(
                          child: Text(
                              attachmentNote,
                              style: defaultTextStyle)),
                      SizedBox(height: 5),
                      Container(
                          height: 30,
                          width: size.width - 30,
                          child: Row(
                              children:[
                                Expanded(child:GestureDetector(
                                    onTap: () {
                                      SimproRepository simproRepo = RepositoryProvider.of<SimproRepository>(context);
                                      simproRepo.saveJobItemAttachment(attachment, AttachmentPhase.before, context);
                                      Navigator.of(context).pushNamed(
                                          AppRouter.itemListingPath,
                                          arguments: JobIDs(attachment.companyId, attachment.jobId));
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
                                      SimproRepository simproRepo = RepositoryProvider.of<SimproRepository>(context);
                                      simproRepo.saveJobItemAttachment(attachment, AttachmentPhase.after, context);
                                      Navigator.of(context).pushNamed(
                                          AppRouter.itemListingPath,
                                          arguments: JobIDs(attachment.companyId, attachment.jobId));
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
