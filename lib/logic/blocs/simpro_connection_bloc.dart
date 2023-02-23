import 'package:ttsbuiltmobile/logic/states/job_listing_state.dart';
import 'package:bloc/bloc.dart';

import '../states/connection_available.dart';
import '../states/connection_direction.dart';
import '../states/simpro_connection_event.dart';
import '../states/simpro_connection_state.dart';

class SimproConnectionBloc extends Bloc<SimproConnectionEvent, SimproConnectionState>{
  SimproConnectionBloc(): super(SimproConnectionState(ConnectionAvailable.idle, ConnectionDirection.idle, "idle")){
    on<SuccessfulPullEvent>(_updateConnectionState);
    on<SuccessfulPushEvent>(_updateConnectionState);
    on<AttemptingPullEvent>(_updateConnectionState);
    on<AttemptingPushEvent>(_updateConnectionState);
    on<UnsuccessfulPullEvent>(_updateConnectionState);
    on<UnsuccessfulPushEvent>(_updateConnectionState);
    on<UpdateListedJobs>(_updateConnectionState);
  }
  void _updateConnectionState(SimproConnectionEvent event, Emitter<SimproConnectionState> emit){
  }
}