import 'package:ttsbuiltmobile/logic/states/job_listing_state.dart';
import 'package:bloc/bloc.dart';

import '../states/job_listing_event.dart';

class JobListingBloc extends Bloc<JobListingEvent, JobListingState>{
  JobListingBloc(): super(JobListingState([])){
    on<LoadJobListing>(_loadJobListing);
    on<AddToJobListing>(_addToJobListing);
    on<RemoveFromJobListing>(_removeFromJobListing);
    on<UpdateListedJobs>(_updateJobListing);
  }
  void _loadJobListing(LoadJobListing event, Emitter<JobListingState> emit){
  }
  void _addToJobListing(AddToJobListing event, Emitter<JobListingState> emit){
  }
  void _removeFromJobListing(RemoveFromJobListing event, Emitter<JobListingState> emit){
  }
  void _updateJobListing(UpdateListedJobs event, Emitter<JobListingState> emit){
  }
}
