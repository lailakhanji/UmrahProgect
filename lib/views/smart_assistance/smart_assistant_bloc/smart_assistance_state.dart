import 'package:equatable/equatable.dart';

import '../data/chat_message_model.dart';


abstract class SmartAssistantState extends Equatable {
  const SmartAssistantState();

  @override
  List<Object?> get props => [];
}

class SmartAssistantInitial extends SmartAssistantState {
  final List<ChatMessageModel> messages;

  const SmartAssistantInitial({
    this.messages = const [],
  });

  @override
  List<Object?> get props => [messages];
}

class SmartAssistantLoading extends SmartAssistantState {
  final List<ChatMessageModel> messages;

  const SmartAssistantLoading(this.messages);

  @override
  List<Object?> get props => [messages];
}

class SmartAssistantLoaded extends SmartAssistantState {
  final List<ChatMessageModel> messages;

  const SmartAssistantLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class SmartAssistantError extends SmartAssistantState {
  final List<ChatMessageModel> messages;
  final String message;

  const SmartAssistantError({
    required this.messages,
    required this.message,
  });

  @override
  List<Object?> get props => [messages, message];
}