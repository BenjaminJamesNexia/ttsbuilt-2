import 'package:flutter/cupertino.dart';
import 'package:ttsbuiltmobile/logic/states/job_listing_state.dart';
import 'package:bloc/bloc.dart';

import '../states/job_listing_event.dart';

class JobListingBloc extends Bloc<JobListingEvent, JobListingState>{
  JobListingBloc(): super(JobListingState({})){
    on<LoadJobListing>(_loadJobListing);
    on<AddToJobListing>(_addToJobListing);
    on<RemoveFromJobListing>(_removeFromJobListing);
    on<UpdateListedJobs>(_updateJobListing);
  }
  void _loadJobListing(LoadJobListing event, Emitter<JobListingState> emit){
    emit(event.getState());
  }
  void _addToJobListing(AddToJobListing event, Emitter<JobListingState> emit){
    int sedf = 0;
  }
  void _removeFromJobListing(RemoveFromJobListing event, Emitter<JobListingState> emit){
    int sedf = 0;
  }

  //The event state here contains just the things to update, so apply that to the current state and then emit it
  void _updateJobListing(UpdateListedJobs event, Emitter<JobListingState> emit){
    Map<String, dynamic> currentState = this.state.jobs;
    Map<String, dynamic> stateUpdates = event.getState().jobs;
    bool updated = false;
    for(String jobId in stateUpdates.keys){
      var thisJob = stateUpdates[jobId];
      for(String fieldToUpdate in thisJob.keys){
        //The details field will have sub-fields, whereas other fields will not
        if(fieldToUpdate == "details"){
          for(String detailField in thisJob["details"].keys){
            currentState[jobId]["details"][detailField] = stateUpdates[jobId]["details"][detailField];
            updated = true;
          }
        }else{
          currentState[jobId][fieldToUpdate] = stateUpdates[jobId][fieldToUpdate];
          updated = true;
        }
      }
    }
    JobListingState newState = JobListingState(currentState);
    if(updated) emit(newState);
  }

}
