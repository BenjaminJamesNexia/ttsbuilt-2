import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class ScheduleFilterState{
  final List<Map<String, String>> filterResults;
  final Map<String, String> filtersApplied;
  ScheduleFilterState(this.filterResults, this.filtersApplied);
}

class ScheduleFilterEvent{
  ScheduleFilterState _state;
  ScheduleFilterEvent(this._state);
  ScheduleFilterState getState(){
    return _state;
  }
}

class ScheduleFilterBloc extends Bloc<ScheduleFilterEvent, ScheduleFilterState>{
  ScheduleFilterBloc(BuildContext context): super(ScheduleFilterState([],{})){
    on<ScheduleFilterEvent>(_updateListeners);
  }
  void _updateListeners(ScheduleFilterEvent event, Emitter<ScheduleFilterState> emit){
    if(event._state.filterResults.isNotEmpty){
      ScheduleFilterState stateToEmit = event._state;
      emit(stateToEmit);
    }
  }
}