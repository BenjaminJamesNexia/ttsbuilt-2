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

import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;

class JobDetailScreen extends StatelessWidget {
  final int companyId;
  final int jobId;

  final int headerHeight = 165;

  JobDetailScreen(this.companyId, this.jobId);

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
                    Map<String,dynamic> thisJob = jobListingState.jobs[jobId.toString()];
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
                                          decoration: BoxDecoration(
                                              color: c2,
                                              border: Border.all(
                                                color: c2,
                                              ),
                                              borderRadius:
                                              BorderRadius.all(Radius.circular(5))),
                                          width: size.width - 39,
                                          child: Padding(
                                              padding: new EdgeInsets.all(4.0),
                                              child: Row(children: <Widget>[
                                                Image.asset(
                                                    'assets/images/territory-trade-services-icon.png'),
                                                Spacer(),
                                                Padding(
                                                    padding: new EdgeInsets.all(7.0),
                                                    child: Container(
                                                        constraints: BoxConstraints(
                                                          maxWidth: size.width - 130,
                                                        ),
                                                        child: SingleChildScrollView(
                                                        scrollDirection: Axis.horizontal,
                                                        child: Text(thisJob["details"]["Site"]["Name"],
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 30))))),
                                                Spacer(),
                                              ])))),
                                  Container(
                                      constraints: BoxConstraints(
                                        maxHeight: (size.height - headerHeight)/3,
                                        minWidth: size.width - 30,
                                        maxWidth: size.width - 30,
                                      ),
                                      child: SingleChildScrollView(child:GestureDetector(
                                          onTap: (){
                                            Navigator.of(context)
                                                .pushNamed(
                                                AppRouter.descriptionDetailPath,
                                                arguments: JobIDs(0, thisJob["ID"])
                                            );
                                          },
                                          child: Card(
                                            color: c3,
                                            child: new Padding(
                                              padding: new EdgeInsets.all(7.0),
                                              child: Html(
                                                  data: thisJob["Description"],
                                                  style: {
                                                    "div": Style(
                                                        color: Colors.white,
                                                        fontSize: FontSize(18)
                                                    )
                                                  }
                                              )
                                            ),
                                          )))),
                                  SizedBox(
                                    height: 5
                                  ),
                                  Container(
                                      constraints: BoxConstraints(
                                        maxHeight: (size.height - headerHeight)/3,
                                        minWidth: size.width - 30,
                                        maxWidth: size.width - 30,
                                      ),
                                      child: SingleChildScrollView(child:GestureDetector(
                                          onTap: (){
                                            Navigator.of(context)
                                                .pushNamed(
                                                AppRouter.workNotesPath,
                                                arguments: JobIDs(0, thisJob["ID"])
                                            );
                                          },
                                          child: Card(
                                            color: c4,
                                            child: new Padding(
                                                padding: new EdgeInsets.all(7.0),
                                                child: Html(
                                                    data: thisJob["details"]["Notes"],
                                                    style: {
                                                      "div": Style(
                                                      color: Colors.white,
                                                        fontSize: FontSize(18)
                                                      )
                                                    }

                                                )
                                                )
                                            ),
                                      ))),
                                  SizedBox(
                                      height: 5
                                  ),
                                  Container(
                                      constraints: BoxConstraints(
                                        maxHeight: (size.height - headerHeight)/3,
                                        minWidth: size.width - 30,
                                        maxWidth: size.width - 30,
                                      ),
                                      child: SingleChildScrollView(child:GestureDetector(
                                        onTap: (){
                                          Navigator.of(context)
                                              .pushNamed(
                                              AppRouter.workNotesPath,
                                              arguments: JobIDs(0, thisJob["ID"])
                                          );
                                        },
                                        child: Card(
                                            color: c4,
                                            child: new Padding(
                                                padding: new EdgeInsets.all(7.0),
                                                child: Html(
                                                    data: thisJob["details"]["Notes"],
                                                    style: {
                                                      "div": Style(
                                                          color: Colors.white,
                                                          fontSize: FontSize(18)
                                                      )
                                                    }

                                                )
                                            )
                                        ),
                                      )))
                                ]))));
                  }
                  );
            });
  }
}