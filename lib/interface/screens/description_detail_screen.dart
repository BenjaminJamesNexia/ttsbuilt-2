import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ttsbuiltmobile/logic/blocs/simpro_connection_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/simpro_connection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/blocs/job_listing_bloc.dart';
import '../../logic/blocs/processing_progress_bloc.dart';
import '../../logic/states/connection_available.dart';
import '../../logic/states/job_listing_state.dart';
import '../components/global.dart';
import '../router/app_router.dart';

class DescriptionDetailScreen extends StatelessWidget {
  final int companyId;
  final int jobId;

  DescriptionDetailScreen(this.companyId, this.jobId);

  @override
  Widget build(BuildContext context) {
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
                          width: size.width - 30,
                          height: size.height - 152,
                          color: c3,
                          child: SingleChildScrollView(
                            child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Html(
                                    data: thisJob["Description"]
                                        .replaceAll("#333333", "#ffffff"),
                                    style: {
                                      "div": Style(
                                          color: Colors.white,
                                          fontSize: FontSize(18))
                                    })),
                          ))
                    ]))));
      });
    });
  }
}
