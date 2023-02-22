import 'job_listing_state.dart';

abstract class JobListingEvent{
  JobListingState _state;
  JobListingEvent(this._state);
  JobListingState getState(){
    return _state;
  }
}

class LoadJobListing extends JobListingEvent{
  LoadJobListing(super._state);
}

class AddToJobListing extends JobListingEvent{
  AddToJobListing(super._state);
}

class RemoveFromJobListing extends JobListingEvent{
  RemoveFromJobListing(super._state);
}

class UpdateListedJobs extends JobListingEvent{
  UpdateListedJobs(super._state);
}