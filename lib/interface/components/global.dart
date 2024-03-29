import 'package:flutter/material.dart';

import '../../logic/states/user_state.dart';
import '../router/app_router.dart';

Color c1 = Color.fromRGBO(220, 126, 34, 1.0);
Color c1_slightly_darker = Color.fromRGBO(147, 88, 31, 1.0);
Color c1_darker = Color.fromRGBO(176, 102, 28, 0);
Color c2 = Color.fromRGBO(220, 163, 34, 1);
Color c3 = Color.fromRGBO(38, 62, 149, 1);
Color c3_light = Color.fromRGBO(244, 231, 255, 1);
Color c4 = Color.fromRGBO(24, 115, 136, 1);

class JobIDs{
  final int companyId;
  final int jobId;
  JobIDs(this.companyId, this.jobId);
}

class WorkNoteID{
  final int companyId;
  final int jobId;
  final int workNoteId;
  final int iteration;
  WorkNoteID(this.companyId, this.jobId, this.workNoteId, this.iteration);
}

class WorkNoteAttachment{
  final int companyId;
  final int jobId;
  final int workNoteId;
  final int iteration;
  final String imagePath;
  WorkNoteAttachment(this.companyId, this.jobId, this.workNoteId, this.iteration, this.imagePath);
}

Widget _getHeader(Size size, String text, BuildContext context){
  return Padding(
      padding: new EdgeInsets.all(6.0),
      child: Container(
          decoration: BoxDecoration(
              color: c4,
              border: Border.all(
                color: c3,
              ),
              borderRadius:
              BorderRadius.all(Radius.circular(1))),
          width: size.width - 31,
          child: Padding(
              padding: new EdgeInsets.all(4.0),
              child: Row(children: <Widget>[
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          AppRouter.jobListingPath);
                    },
                    child:Image.asset(
                    'assets/images/territory-trade-services-icon.png', height: 30)),
                Spacer(),
                Container(
                    width: size.width - 120,
                    child: SingleChildScrollView(
                        scrollDirection:
                        Axis.horizontal,
                        child: Text(
                            text,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25)))),
                Spacer(),
              ]))));
}

Widget getUserHeader(Size size, UserState userState, BuildContext context){
  return _getHeader(size, userState.name, context);
}

Widget getJobHeader(Size size, String jobName, BuildContext context){
  return _getHeader(size, jobName, context);
}


Widget getJobDetailHeader(Size size, String text, BuildContext context, JobIDs jobIDs){
  return Padding(
      padding: new EdgeInsets.all(6.0),
      child: Container(
          decoration: BoxDecoration(
              color: c4,
              border: Border.all(
                color: c3,
              ),
              borderRadius:
              BorderRadius.all(Radius.circular(1))),
          width: size.width - 31,
          child: Padding(
              padding: new EdgeInsets.all(4.0),
              child: Row(children: <Widget>[
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          AppRouter.jobDetailPath,
                      arguments: jobIDs);
                    },
                    child:Image.asset(
                        'assets/images/territory-trade-services-icon.png', height: 30)),
                Spacer(),
                Container(
                    width: size.width - 120,
                    child: SingleChildScrollView(
                        scrollDirection:
                        Axis.horizontal,
                        child: Text(
                            text,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25)))),
                Spacer(),
              ]))));
}

TextStyle defaultTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 18
);

enum AttachmentPhase{
  before,
  after
}

extension ParseToString on AttachmentPhase {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
