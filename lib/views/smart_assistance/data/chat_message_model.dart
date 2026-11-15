enum ChatMessageType {
  user,
  assistant,
}

class ChatMessageModel {
  final String message;
  final ChatMessageType type;

  ChatMessageModel({
    required this.message,
    required this.type,
  });
}