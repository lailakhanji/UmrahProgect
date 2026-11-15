import 'package:equatable/equatable.dart';

abstract class SmartAssistantEvent extends Equatable {
  const SmartAssistantEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends SmartAssistantEvent {
  final String message;

  const SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}