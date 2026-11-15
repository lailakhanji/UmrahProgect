import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:umrahapp/views/smart_assistance/smart_assistant_bloc/smart_assistance_bloc.dart';
import 'package:umrahapp/views/smart_assistance/smart_assistant_bloc/smart_assistance_event.dart';
import 'package:umrahapp/views/smart_assistance/smart_assistant_bloc/smart_assistance_state.dart';

import 'data/chat_message_model.dart';
import 'data/smart_assistant_api_service.dart';

class SmartAssistantScreen extends StatefulWidget {
  const SmartAssistantScreen({super.key});

  @override
  State<SmartAssistantScreen> createState() => _SmartAssistantScreenState();
}

class _SmartAssistantScreenState extends State<SmartAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  late final SmartAssistantBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = SmartAssistantBloc(apiService: SmartAssistantApiService());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _bloc.close();

    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();

    if (message.isEmpty) return;

    _messageController.clear();

    _bloc.add(SendMessageEvent(message));

    Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
  }

  void _sendQuickQuestion(String question) {
    _messageController.text = question;
    _sendMessage();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xffF8FFFB),
          body: SafeArea(
            child: BlocConsumer<SmartAssistantBloc, SmartAssistantState>(
              listener: (context, state) {
                if (state is SmartAssistantLoaded) {
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    _scrollToBottom,
                  );
                }

                if (state is SmartAssistantError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                final messages = _getMessages(state);

                final isLoading = state is SmartAssistantLoading;

                return Column(
                  children: [
                    _buildAppBar(),

                    Expanded(
                      child: messages.isEmpty
                          ? _buildWelcomeContent(isLoading)
                          : _buildChatContent(messages, isLoading),
                    ),

                    _buildMessageInput(isLoading),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<ChatMessageModel> _getMessages(SmartAssistantState state) {
    if (state is SmartAssistantInitial) {
      return state.messages;
    }

    if (state is SmartAssistantLoading) {
      return state.messages;
    }

    if (state is SmartAssistantLoaded) {
      return state.messages;
    }

    if (state is SmartAssistantError) {
      return state.messages;
    }

    return [];
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
              color: Color(0xff222222),
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'المساعد الذكي',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff186442),
                ),
              ),
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildWelcomeContent(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Image.asset('assets/images/chat_image.png'),

          const SizedBox(height: 20),

          const Text(
            'كيف أستطيع مساعدتك؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff222222),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'اطرح أسئلة حول العمرة وسأجيبك عليها',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xff999999)),
          ),

          const SizedBox(height: 25),

          Align(
            alignment: Alignment.centerRight,
            child: const Text(
              'أسئلة شائعة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff222222),
              ),
            ),
          ),

          const SizedBox(height: 10),

          _buildQuestionButton('ماهي محظورات الإحرام؟'),

          _buildQuestionButton('هل الحلق أفضل أم التقصير؟'),
          _buildQuestionButton('هل يجب تقبيل الحجر الأسود؟'),
          _buildQuestionButton('ماهي أهم نصيحة للمعتمر؟'),
        ],
      ),
    );
  }

  Widget _buildQuestionButton(String question) {
    return InkWell(
      onTap: () => _sendQuickQuestion(question),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 36,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffDDDDDD)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset('assets/icons/message.svg'),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent(List<ChatMessageModel> messages, bool isLoading) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= messages.length) {
          return const _TypingIndicator();
        }

        final message = messages[index];

        return _buildMessage(message);
      },
    );
  }

  Widget _buildMessage(ChatMessageModel message) {
    final isUser = message.type == ChatMessageType.user;

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xffDDF5E9) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 3),
            bottomRight: Radius.circular(isUser ? 3 : 14),
          ),
          border: Border.all(
            color: isUser ? const Color(0xffC8EAD8) : const Color(0xffE4E4E4),
          ),
        ),
        child: isUser
            ? Text(
                message.message,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xff222222),
                ),
              )
            : MarkdownBody(
                data: message.message.replaceAll(RegExp(r'_{3,}|-{3,}'), ''),
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: Color(0xff333333),
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff186442),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMessageInput(bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      color: const Color(0xffF8FFFB),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // حقل الكتابة
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, maxHeight: 120),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffDCEFE5), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1216),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                enabled: !isLoading,
                minLines: 1,
                maxLines: 4,
                textDirection: TextDirection.rtl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!isLoading) {
                    _sendMessage();
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'اطرح سؤالك...',
                  hintStyle: TextStyle(fontSize: 12, color: Color(0xffAAAAAA)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 7),

          // زر الإرسال
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: InkWell(
              onTap: isLoading ? null : _sendMessage,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  color: Color(0xff186442),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/send.svg',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = (_controller.value - delay) % 1.0;

        double opacity;

        if (value < 0.5) {
          opacity = 0.3 + (value * 1.4);
        } else {
          opacity = 1.0 - ((value - 0.5) * 1.4);
        }

        opacity = opacity.clamp(0.3, 1.0);

        return Opacity(
          opacity: opacity,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xff186442),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffE4E4E4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0.0),
            const SizedBox(width: 5),
            _buildDot(0.2),
            const SizedBox(width: 5),
            _buildDot(0.4),
          ],
        ),
      ),
    );
  }
}
