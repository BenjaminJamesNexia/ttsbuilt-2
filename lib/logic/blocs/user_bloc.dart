import 'package:ttsbuiltmobile/logic/states/job_listing_state.dart';
import 'package:bloc/bloc.dart';

import '../states/job_listing_event.dart';
import '../states/user_event.dart';
import '../states/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserState(-1, "n/a")) {
    on<UserEvent>(_updateUserState);
  }

  void _updateUserState(UserEvent event, Emitter<UserState> emit) {
    emit(event.state);
  }
}