

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umrahapp/views/smart_assistance/smart_assistant_bloc/smart_assistance_event.dart';
import 'package:umrahapp/views/smart_assistance/smart_assistant_bloc/smart_assistance_state.dart';

import '../data/chat_message_model.dart';
import '../data/smart_assistant_api_service.dart';

class SmartAssistantBloc
    extends Bloc<SmartAssistantEvent, SmartAssistantState> {
  final SmartAssistantApiService apiService;

  final List<ChatMessageModel> _messages = [];

  SmartAssistantBloc({
    required this.apiService,
  }) : super(const SmartAssistantInitial()) {
    on<SendMessageEvent>(_sendMessage);
  }

  Future<void> _sendMessage(
      SendMessageEvent event,
      Emitter<SmartAssistantState> emit,
      ) async {
    final message = event.message.trim();

    if (message.isEmpty) return;

    // إضافة رسالة المستخدم
    _messages.add(
      ChatMessageModel(
        message: message,
        type: ChatMessageType.user,
      ),
    );

    emit(
      SmartAssistantLoading(
        List.from(_messages),
      ),
    );

    try {
      final response = await apiService.sendMessage(message);

      // إضافة رد المساعد
      _messages.add(
        ChatMessageModel(
          message: response,
          type: ChatMessageType.assistant,
        ),
      );

      emit(
        SmartAssistantLoaded(
          List.from(_messages),
        ),
      );
    } catch (e) {
      emit(
        SmartAssistantError(
          messages: List.from(_messages),
          message: e.toString().replaceFirst(
            'Exception: ',
            '',
          ),
        ),
      );
    }
  }
}