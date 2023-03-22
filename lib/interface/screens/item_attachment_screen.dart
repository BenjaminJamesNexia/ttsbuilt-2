import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ttsbuiltmobile/data/repositories/camera_repository.dart';
import 'package:ttsbuiltmobile/logic/blocs/simpro_connection_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/simpro_connection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/blocs/job_listing_bloc.dart';
import '../../logic/states/connection_available.dart';
import '../../logic/states/job_listing_state.dart';
import '../components/global.dart';
import '../router/app_router.dart';

class ItemAttachmentScreen extends StatelessWidget {
  final WorkNoteID workNoteID;

  final double borderWidth = 4;
  ItemAttachmentScreen(this.workNoteID);
  @override
  Widget build(BuildContext context) {
    CameraRepository cameraRepo = RepositoryProvider.of<CameraRepository>(
        context);
    final Size size = MediaQuery
        .of(context)
        .size;
    return BlocBuilder<JobListingBloc, JobListingState>(
        builder: (context, jobListingState)  {
          Map<String, dynamic> thisJob =
          jobListingState.jobs[workNoteID.jobId.toString()];
          int rootSpotlessScheduleId = -1;
          List<Widget> scheduleItems = [];
          var thisItem = {};
          if (thisJob.containsKey("schedule-item-listing")) {
            for (var item in thisJob["schedule-item-listing"]) {
              if (item["work-note-id"] == workNoteID.workNoteId) {}
            }
          }
          return SafeArea(
              child: Scaffold(
                body: Container(
                    color: Colors.black,
                    width: size.width,
                    child: Column(children: [
                      getJobDetailHeader(size, thisJob["details"]["Site"]["Name"], context, JobIDs(workNoteID.companyId, workNoteID.jobId)),
                      Text(
                          workNoteID.companyId.toString() +
                              " " +
                              workNoteID.jobId.toString() +
                              " " +
                              workNoteID.workNoteId.toString() +
                              " " +
                              workNoteID.iteration.toString(),
                          style: defaultTextStyle),
                      SizedBox(height: 10),
                      Expanded(
                          child:FutureBuilder<CameraController?>(
                            future: cameraRepo.getController(),
                            builder: (context, AsyncSnapshot<CameraController?> snapshot){
                              if(snapshot.hasData){
                                return CameraPreview(snapshot.data!);
                              }else {
                                return CircularProgressIndicator();
                              }
                            }
                          )
                      )
                    ])),
                floatingActionButton: FloatingActionButton(
                  // Provide an onPressed callback.
                  onPressed: () async {
                    // Take the Picture in a try / catch block. If anything goes wrong,
                    // catch the error.
                    try {
                      // Ensure that the camera is initialized.
                      CameraController? controller = await cameraRepo.getController()!;

                      // Attempt to take a picture and get the file `image`
                      // where it was saved.
                      final image = await controller!.takePicture();

                      if (context.mounted == false) return;

                      // If the picture was taken, display it on a new screen.
                      await Navigator.of(context).pushNamed(
                          AppRouter.displaySitePhoto,
                          arguments: WorkNoteAttachment(
                              workNoteID.companyId, workNoteID.jobId,
                              workNoteID.workNoteId, workNoteID.iteration,
                              image.path)
                      );
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      print(e);
                    }
                  },
                  child: const Icon(Icons.camera_alt),
                ),
              ));
        });
  }
}
