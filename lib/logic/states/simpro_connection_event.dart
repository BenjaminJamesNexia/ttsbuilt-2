import 'package:ttsbuiltmobile/logic/states/simpro_connection_state.dart';

abstract class SimproConnectionEvent{
  SimproConnectionState _state;
  SimproConnectionEvent(this._state);
  SimproConnectionState get state => _state;
}

class AttemptingPullEvent extends SimproConnectionEvent{
  AttemptingPullEvent(super._state);
}

class AttemptingPushEvent extends SimproConnectionEvent{
  AttemptingPushEvent(super._state);
}

class SuccessfulPullEvent extends SimproConnectionEvent{
  SuccessfulPullEvent(super._state);
}

class SuccessfulPushEvent extends SimproConnectionEvent{
  SuccessfulPushEvent(super._state);
}

class UnsuccessfulPullEvent extends SimproConnectionEvent{
  UnsuccessfulPullEvent(super._state);
}

class UnsuccessfulPushEvent extends SimproConnectionEvent{
  UnsuccessfulPushEvent(super._state);
}

class UpdateListedJobs extends SimproConnectionEvent{
  UpdateListedJobs(super._state);
}