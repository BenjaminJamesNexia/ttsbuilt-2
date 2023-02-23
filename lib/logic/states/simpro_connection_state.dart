import 'connection_direction.dart';
import 'connection_available.dart';

class SimproConnectionState{
  ConnectionAvailable available;
  ConnectionDirection direction;
  String message;
  SimproConnectionState(this.available, this.direction, this.message);
}