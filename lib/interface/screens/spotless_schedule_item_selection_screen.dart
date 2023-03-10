import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ttsbuiltmobile/data/repositories/simpro_repository.dart';
import 'package:ttsbuiltmobile/interface/screens/work_notes_screen.dart';
import 'package:ttsbuiltmobile/logic/blocs/simpro_connection_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/simpro_connection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/schedule_repository.dart';
import '../../logic/blocs/job_listing_bloc.dart';
import '../../logic/blocs/processing_progress_bloc.dart';
import '../../logic/blocs/schedule_filter_bloc.dart';
import '../../logic/states/connection_available.dart';
import '../../logic/states/job_listing_event.dart';
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
        List<Widget> linkedScheduleItems = [];
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
            if (itemCount > 0) linkedScheduleItems.add(SizedBox(height: 8));
            linkedScheduleItems.add(GestureDetector(
              child: _getItemListing(item, size),
              onTap: () => _selectLinkedScheduleItem(item, scheduleRepo, context),
            ));
            itemCount++;
            // }
          }
          if (linkedScheduleItems.isEmpty) {
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
                  linkedScheduleItems.add(_getItemListing(item, size));
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
                      getJobHeader(size, thisJob),
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
                                      Container(
                                          width: 100,
                                          child: Text(
                                          filter, style: defaultTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold))),
                                      Expanded(
                                          flex: 2,
                                          child: Text(filters[filter]!,
                                          style: defaultTextStyle)),
                                      Align(child: GestureDetector(
                                        child:Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          onTap: () => _removeFilter(filter, filters[filter]!, context, scheduleRepo),
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
                                          width: size.width - 110,
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
                          if(a.containsKey("Category") && b.containsKey("Category")) {
                            int compareCategory =
                            a["Category"]!.compareTo(b["Category"]!);
                            if (compareCategory != 0) return compareCategory;
                          }else{
                            int sdf = 0;
                          }
                          if(a.containsKey("Subsection") && b.containsKey("Subsection")) {
                            int compareSubsection =
                            a["Subsection"]!.compareTo(b["Subsection"]!);
                            if (compareSubsection != 0)
                              return compareSubsection;
                          }else{
                            int sdf = 0;
                          }
                          return a["Code"]!.compareTo(b["Code"]!);
                        });
                        bool firstAdded = true;
                        for (var scheduleItem in itemsToDisplay) {
                          if(firstAdded){
                            firstAdded = false;
                          }else{
                            widgetsToList.add(SizedBox(height: 10));
                          }
                          Widget widgetToAdd = _getItemListing(scheduleItem, size);
                          widgetsToList.add(GestureDetector(
                            child: widgetToAdd,
                            onTap: () => _selectScheduleItem(scheduleItem, thisJob, context),
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
                                      height: 100,
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
                            color: c1_darker,
                            child: Center(
                                child: Text("Linked Spotless Schedule Items",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)))),
                      ),
                      Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 2.0, color: c2),
                              left: BorderSide(width: 2.0, color: c2),
                              right: BorderSide(width: 2.0, color: c2),
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
                          width: size.width - 30,
                          height: -40 + size.height / 4,
                          child: SingleChildScrollView(
                              child: Column(children: linkedScheduleItems))),
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

  void _selectScheduleItem(var item, Map<String, dynamic> thisJob, BuildContext context) async {
    //Get the current job, add tihs item to the schedule items list and send to the job listing bloc as an event
    if(item.containsKey("schedule-reference-item")) item = item["schedule-reference-item"];
    SimproRepository simproRepo = RepositoryProvider.of<SimproRepository>(context);
    int id = await  simproRepo.addAWorkNoteScheduleItem(jobId, item);
    var scheduleItem = {};
    scheduleItem["work-note-id"] = id;
    scheduleItem["schedule-reference-item"] = item;
    thisJob["schedule-item-listing"].add(scheduleItem);

    Map<String, dynamic> jobUpdateSkeleton = {};
    jobUpdateSkeleton[jobId.toString()] = {};
    jobUpdateSkeleton[jobId.toString()]["schedule-item-listing"] = thisJob["schedule-item-listing"];
    JobListingState updateState = JobListingState(jobUpdateSkeleton);
    UpdateListedJobs updateEvent = UpdateListedJobs(updateState);
    JobListingBloc listingBloc = BlocProvider.of<JobListingBloc>(context);
    listingBloc.add(updateEvent);
  }

  void _selectLinkedScheduleItem(var item, ScheduleRepository scheduleRepo, BuildContext context) {
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
  
  
  void _removeFilter(String filterName, String filterValue, BuildContext context, ScheduleRepository scheduleRepo){
    ScheduleFilterBloc bloc = BlocProvider.of<ScheduleFilterBloc>(context);
    ScheduleFilterState filterState = bloc.state;
    Map<String, String> filters = filterState.filtersApplied;
    List<Map<String, String>> results = filterState.filterResults;
    bool filterRemoved = false;
    for(String filter in filters.keys){
      if(filter == filterName && filters[filter] == filterValue){
        filters.remove(filter);
        filterRemoved = true;
        break;
      }
    }
    if(filterRemoved){
      String? category = null;
      String? subsection = null;
      String? task = null;
      if(filters.containsKey("Category")) category = filters["Category"];
      if(filters.containsKey("Subsection")) subsection = filters["Subsection"];
      if(filters.containsKey("Task")) task = filters["Task"];
      List<Map<String, String>> filterResults = applyFilter(task, category, subsection, scheduleRepo);
      ScheduleFilterState state = ScheduleFilterState(filterResults, filters);
      ScheduleFilterEvent event = ScheduleFilterEvent(state);
      bloc.add(event);
    }
  }

  Widget _getItemListing(item, Size size) {
    if(item.containsKey("schedule-reference-item")) item = item["schedule-reference-item"];
    return Container(
        child: Column(children: [
      Container(
          width: size.width - 2 * borderWidth,
          height: 30,
          padding: EdgeInsets.fromLTRB(3, 0, 1, 0),
          color: c3,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child:Center(
              child: Text(
                  item["Code"] +
                      ": " +
                      item["Task"],
                  style: defaultTextStyle)))),
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
