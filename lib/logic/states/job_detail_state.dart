import 'package:ttsbuiltmobile/logic/states/job_listing_state.dart';
import 'package:ttsbuiltmobile/logic/states/job_summary_state.dart';

class JobDetailState{
  JobSummaryState _summaryState;
  JobDetailState(this._summaryState){

  }


}

class JobDetailEvent{
  JobDetailState _state;
  JobDetailEvent(this._state);
  JobDetailState get state => _state;
}