import 'package:flutter/material.dart';
import 'package:ttsbuiltmobile/interface/screens/work_notes_screen.dart';
import 'package:ttsbuiltmobile/logic/blocs/simpro_connection_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/simpro_connection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/schedule_repository.dart';
import '../../logic/blocs/job_listing_bloc.dart';
import '../../logic/blocs/processing_progress_bloc.dart';
import '../../logic/blocs/schedule_filter_bloc.dart';
import '../../logic/states/connection_available.dart';
import '../../logic/states/job_listing_state.dart';
import '../components/global.dart';
import '../router/app_router.dart';

class SpotlessScheduleItemSelectionScreen extends StatelessWidget {
  final int companyId;
  final int jobId;
  final int workNoteId;
  final double borderWidth = 4;
  SpotlessScheduleItemSelectionScreen(
      this.companyId, this.jobId, this.workNoteId);
  TextEditingController? textController;
  @override
  Widget build(BuildContext context) {
    textController = TextEditingController();
    ScheduleRepository scheduleRepo =
        RepositoryProvider.of<ScheduleRepository>(context);
    return BlocProvider<ScheduleFilterBloc>(create: (BuildContext context) {
      ScheduleFilterBloc bloc = ScheduleFilterBloc(context);
      return bloc;
    }, child: BlocBuilder<SimproConnectionBloc, SimproConnectionState>(
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
        if (thisJob.containsKey("schedule-item-listing")) {
          //For each item, materials and photos can be listed
          //Notes will have a subject starting with an item code,
          // and where this is the case the notes will be a json string with properties
          // attachments and
          // materials
          // each containing an array of items input by the technician
          int itemCount = 0;
          for (var item in thisJob["schedule-item-listing"]) {
            // for(int i = 0; i < 33; i++) {
            if (itemCount > 0) scheduleItems.add(SizedBox(height: 8));
            scheduleItems.add(GestureDetector(
              child: _getItemListing(item, size),
              onTap: () => _selectScheduleItem(item, scheduleRepo, context),
            ));
            itemCount++;
            // }
          }
          if (scheduleItems.isEmpty) {
            if (thisJob.containsKey("schedule-item-listing-2") &&
                thisJob["schedule-item-listing-2"].isNotEmpty) {
              String firstItem = thisJob["schedule-item-listing-2"][0];
              if (firstItem.indexOf(" ") > 0) {
                String firstWord = thisJob["schedule-item-listing-2"][0]
                    .substring(
                        0, thisJob["schedule-item-listing-2"][0].indexOf(" "));
                if (firstWord.length > 5) firstWord = firstWord.substring(0, 5);
                var scheduleItem = scheduleRepo.getItem(firstWord);
                if (scheduleItem != null) {
                  var item = {};
                  item["schedule-reference-item"] = scheduleItem;
                  scheduleItems.add(_getItemListing(item, size));
                }
              }
            }
          }
        } else {
          if (thisJob.containsKey("schedule-item-listing-2")) {}
        }
        return SafeArea(
            child: Scaffold(
                resizeToAvoidBottomInset: false,
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
                                        child: Container(
                                            constraints: BoxConstraints(
                                              maxWidth: size.width - 130,
                                            ),
                                            child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Text(
                                                    thisJob["details"]["Site"]
                                                        ["Name"],
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 30))))),
                                    Spacer(),
                                  ])))),
                      SizedBox(height: 8),
                      BlocBuilder<ScheduleFilterBloc, ScheduleFilterState>(
                          builder: (context, filterState) {
                            textController!.addListener(() => _processFilterText(context));
                            Map<String, String> filters = filterState.filtersApplied;
                            List<Widget> filtersApplied = [];
                            bool firstFilterAdded = true;
                            for(String filter in filters.keys){
                              if(filter == "Task"){
                                textController!.text = filters["Task"]!;
                              }else {
                                if(firstFilterAdded){
                                  firstFilterAdded = false;
                                }else{
                                  filtersApplied.add(SizedBox(height: 3));
                                }

                                filtersApplied.add(
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                          filter, style: defaultTextStyle)),
                                      Expanded(
                                          flex: 2,
                                          child: Text(filters[filter]!,
                                          style: defaultTextStyle)),
                                      Align(child: Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.white,
                                            size: 16
                                          )
                                      )
                                    ]
                                ));
                              }
                            }
                            filtersApplied.add(SizedBox(height: 3));
                            filtersApplied.add(
                                Row(
                                    children: [
                                      Text(
                                          "Task", style: defaultTextStyle),
                                      SizedBox(width: 17),
                                      Container(
                                          color: Colors.grey[900],
                                          height: 20,
                                          width: size.width - 103,
                                          child: TextField(
                                        controller: textController,
                                        style: defaultTextStyle,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          border: OutlineInputBorder(),
                                        ),
                                      )),
                                    ]
                                )
                                  );
                            List<Widget> widgetsToList = [];
                        List<Map<String, String>> itemsToDisplay =
                            filterState.filterResults;
                        itemsToDisplay.sort((a, b) {
                          int compareCategory =
                              a["Category"]!.compareTo(b["Category"]!);
                          if (compareCategory != 0) return compareCategory;
                          int compareSubsection =
                              a["Subsection"]!.compareTo(b["Subsection"]!);
                          if (compareSubsection != 0) return compareSubsection;
                          return a["Code"]!.compareTo(b["Code"]!);
                        });
                        bool firstAdded = true;
                        for (var scheduleItem in itemsToDisplay) {
                          if(firstAdded){
                            firstAdded = false;
                          }else{
                            widgetsToList.add(SizedBox(height: 4));
                          }
                          Widget widgetToAdd = _getItemListing(scheduleItem, size);
                          widgetsToList.add(GestureDetector(
                            child: widgetToAdd,
                            onTap: () => _selectScheduleItem(scheduleItem, scheduleRepo, context),
                          ));
                        }
                        return Column(
                                children:[
                                  Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 2, color: c2),
                                      ),
                                      padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
                                      width: size.width - 30,
                                      height: 90,
                                      child: SingleChildScrollView(
                                          child: Column(children: filtersApplied))),
                                  SizedBox(height: 7),
                                  Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: c2),
                            ),
                            padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
                            width: size.width - 30,
                            height: 42 + size.height/3,
                            child: SingleChildScrollView(
                                child: Column(children: widgetsToList)))]);
                      }),
                      SizedBox(height: 7),
                      Container(
                        margin: EdgeInsets.fromLTRB(7, 0, 7, 0),
                        decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 2.0, color: c2),
                              left: BorderSide(width: 2.0, color: c2),
                              right: BorderSide(width: 2.0, color: c2),
                            )),
                        child: Container(
                            height: 26,
                            color: c3,
                            child: Center(
                                child: Text("Linked Spotless Schedule Items",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)))),
                      ),
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: c2),
                          ),
                          padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
                          width: size.width - 30,
                          height: -10 + size.height / 4,
                          child: SingleChildScrollView(
                              child: Column(children: scheduleItems))),
                    ]))));
      });
    }));
  }

  void _processFilterText(BuildContext context) {
    ScheduleRepository scheduleRepo =
    RepositoryProvider.of<ScheduleRepository>(context);
    ScheduleFilterBloc scheduleFilter = RepositoryProvider.of<ScheduleFilterBloc>(context);
    ScheduleFilterState filterState = scheduleFilter.state;
    String? category = null;
    String? subsection = null;
    if(filterState.filtersApplied != null && filterState.filtersApplied.containsKey("Category")) category = filterState.filtersApplied["Category"];
    if(filterState.filtersApplied != null && filterState.filtersApplied.containsKey("Subsection")) subsection = filterState.filtersApplied["Subsection"];
    String filterText = textController!.text;
    List<Map<String, String>> filterResults = applyFilter(filterText, category, subsection, scheduleRepo);
    Map<String, String> filtersApplied = {};
    if(category != null) filtersApplied["Category"] = category;
    if(subsection != null) filtersApplied["Subsection"] = subsection;
    ScheduleFilterState state = ScheduleFilterState(filterResults, filtersApplied);
    ScheduleFilterEvent event = ScheduleFilterEvent(state);
    ScheduleFilterBloc bloc = BlocProvider.of<ScheduleFilterBloc>(context);
    bloc.add(event);
  }

  void _selectScheduleItem(var item, ScheduleRepository scheduleRepo, BuildContext context) {
    if(item.containsKey("schedule-reference-item")){
      String category = item["schedule-reference-item"]["Category"];
      String subsection = item["schedule-reference-item"]["Subsection"];
      List<Map<String, String>> filterResults = applyFilter(null, category, subsection, scheduleRepo);
      Map<String, String> filtersApplied = {};
      filtersApplied["Category"] = category;
      filtersApplied["Subsection"] = subsection;
      ScheduleFilterState state = ScheduleFilterState(filterResults, filtersApplied);
      ScheduleFilterEvent event = ScheduleFilterEvent(state);
      ScheduleFilterBloc bloc = BlocProvider.of<ScheduleFilterBloc>(context);
      bloc.add(event);
    }
  }

  Widget _getItemListing(item, Size size) {
    if(item.containsKey("schedule-reference-item")) item = item["schedule-reference-item"];
    return Container(
        child: Column(children: [
      Container(
          width: size.width - 2 * borderWidth,
          height: 20,
          color: c3,
          child: Center(
              child: Text(
                  item["Code"] +
                      ": " +
                      item["Task"],
                  style: TextStyle(color: Colors.white)))),
    ]));
  }

  //Filters are by text, by
  List<Map<String, String>> applyFilter(String? searchText, String? category,
      String? subsection, ScheduleRepository scheduleRepo) {
    List<Map<String, String>> selectableItems = [];

    if (subsection != null) {
      selectableItems = scheduleRepo.getSubsectionList(subsection)!;
    } else if (category != null) {
      selectableItems = scheduleRepo.getCategoryList(category)!;
    } else {
      selectableItems = scheduleRepo.scheduleItemList();
    }

    if (searchText != null) {
      List<Map<String, String>> retval = [];
      for (Map<String, String> item in selectableItems) {
        if (item.containsKey("Task") &&
            item["Task"]!.toLowerCase().contains(searchText)) {
          retval.add(item);
        }
      }
      return retval;
    }
    return selectableItems;
  }

}
