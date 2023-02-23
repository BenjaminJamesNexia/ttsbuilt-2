import 'package:bloc/bloc.dart';

class ProcessingProgressState{
  final int numberToProcess;
  final int numberProcessed;
  ProcessingProgressState(this.numberProcessed, this.numberToProcess);
}

class ProcessingProgressEvent{
  ProcessingProgressState _state;
  ProcessingProgressEvent(this._state);
}

class ProcessingProgressBloc extends Bloc<ProcessingProgressEvent, ProcessingProgressState>{
  ProcessingProgressBloc(): super(ProcessingProgressState(0,-1)){
    on<ProcessingProgressEvent>(_updateListenersWithProgress);
  }
  void _updateListenersWithProgress(ProcessingProgressEvent event, Emitter<ProcessingProgressState> emit){
    if(state.numberToProcess == -1 && event._state.numberToProcess > 0){
      emit(event._state);
    }else{
      if(event._state.numberToProcess != state.numberToProcess){
        emit(event._state);
      }else if(event._state.numberProcessed != state.numberProcessed){
        emit(event._state);
      }
    }
  }

}