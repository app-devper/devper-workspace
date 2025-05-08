// Project imports:
import 'package:pos/domain/model/receive/receive.dart';

abstract class ReceivesState {}

class LoadingState extends ReceivesState {}

class ListReceiveState extends ReceivesState {
  final List<Receive> data;
  final double totalCost;

  ListReceiveState({
    required this.data,
    required this.totalCost,
  });
}

class ErrorState extends ReceivesState {
  final String message;

  ErrorState({required this.message});
}
