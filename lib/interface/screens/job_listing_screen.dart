import 'package:flutter/material.dart';
import 'package:ttsbuiltmobile/data/repositories/simpro_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ttsbuiltmobile/logic/blocs/job_listing_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/connection_available.dart';
import 'package:ttsbuiltmobile/logic/states/job_listing_state.dart';
import 'package:ttsbuiltmobile/logic/states/job_summary_state.dart';

import '../../logic/blocs/simpro_connection_bloc.dart';
import '../../logic/blocs/user_bloc.dart';
import '../../logic/states/simpro_connection_state.dart';
import '../../logic/states/user_state.dart';

class JobListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<SimproRepository>(
        lazy: true,
        create: (context) => SimproRepository(),
        child: BlocProvider<JobListingBloc>(create: (BuildContext context) {
          JobListingBloc bloc = JobListingBloc();
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
            if(userState.name != "n/a") {
              simproRepository.refreshJobListing();
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
                          Row(children: <Widget>[
                            Image.asset(
                                'assets/images/territory-trade-services-icon.png'),
                            Text(userState.name),
                          ]),
                          BlocBuilder<JobListingBloc, JobListingState>(
                              builder: (context, jobListingState) {
                            List<Widget> jobListing = [];
                            List<JobSummaryState> jobs = jobListingState.jobs;
                            for (JobSummaryState job in jobs) {}
                            return Column(children: jobListing);
                          }),
                        ]))));
          });
        })));
  }
}
