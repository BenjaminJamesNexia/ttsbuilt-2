import 'user_state.dart';

class UserEvent{
  UserState _state;
  UserEvent(this._state);
  UserState get state => _state;
}