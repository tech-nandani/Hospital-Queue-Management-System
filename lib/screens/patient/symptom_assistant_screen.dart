import 'package:flutter/material.dart';

import '../../services/symptom_assistant_service.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_context_panel.dart';
import 'widgets/chat_empty_state.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_typing_indicator.dart';

class SymptomAssistantScreen extends StatefulWidget {
  final ValueChanged<String>? onBookAppointment;

  const SymptomAssistantScreen({
    super.key,
    this.onBookAppointment,
  });

  @override
  State<SymptomAssistantScreen> createState() => _SymptomAssistantScreenState();
}

class _SymptomAssistantScreenState extends State<SymptomAssistantScreen> {
  final SymptomAssistantService _service = SymptomAssistantService.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  bool _showContextPanel = true;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (!mounted) return;
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(String text) {
    _service.sendMessage(text);
    _scrollToBottom();
  }

  void _handleNewChat() {
    _service.createNewSession();
  }

  void _handleClearChat() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.cleaning_services_rounded, color: Color(0xFF1D72FE)),
            SizedBox(width: 10),
            Text(
              'Clear conversation?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: const Text(
          'This will clear the messages in your active conversation. Your health records and account data remain unaffected.',
          style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B), height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _service.clearCurrentSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideDesktop = screenWidth >= 1150;
    final messages = _service.currentMessages;
    final isThinking = _service.isThinking;

    return Row(
      children: [
        // Main Chat Area
        Expanded(
          child: Column(
            children: [
              // Header
              _buildChatHeader(isWideDesktop),

              // Chat Message Stream or Empty State
              Expanded(
                child: messages.isEmpty && !isThinking
                    ? ChatEmptyState(
                        onSelectPrompt: (prompt) {
                          _handleSendMessage(prompt);
                        },
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                        itemCount: messages.length + (isThinking ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < messages.length) {
                            final msg = messages[index];
                            return ChatMessageBubble(
                              message: msg,
                              onBookAppointment: widget.onBookAppointment,
                              onSelectFollowUp: (followUp) {
                                _handleSendMessage(followUp);
                              },
                              onRetry: () {
                                _service.retryLastMessage();
                              },
                            );
                          } else {
                            return const ChatTypingIndicator();
                          }
                        },
                      ),
              ),

              // Sticky Bottom Composer
              ChatComposer(
                controller: _inputController,
                isThinking: isThinking,
                onSend: _handleSendMessage,
              ),
            ],
          ),
        ),

        // Optional Context Panel on wide desktop
        if (isWideDesktop && _showContextPanel)
          ChatContextPanel(
            onClose: () => setState(() => _showContextPanel = false),
          ),
      ],
    );
  }

  Widget _buildChatHeader(bool isWideDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDF2F7), width: 1),
        ),
      ),
      child: Row(
        children: [
          // CareFlow AI Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D72FE), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'AI Care Assistant',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: Color(0xFF10B981),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Online',
                            style: TextStyle(
                              color: Color(0xFF047857),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Your healthcare guidance companion',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          OutlinedButton.icon(
            onPressed: _handleNewChat,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text(
              'New Chat',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1D72FE),
              side: const BorderSide(color: Color(0xFFDCE7F5)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // More Options Menu
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) {
              if (value == 'new_chat') {
                _handleNewChat();
              } else if (value == 'clear') {
                _handleClearChat();
              } else if (value == 'toggle_guide') {
                setState(() => _showContextPanel = !_showContextPanel);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_chat',
                child: Row(
                  children: [
                    Icon(Icons.add_comment_outlined,
                        size: 18, color: Color(0xFF1D72FE)),
                    SizedBox(width: 10),
                    Text('Start new chat', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services_outlined,
                        size: 18, color: Color(0xFF64748B)),
                    SizedBox(width: 10),
                    Text('Clear conversation', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              if (isWideDesktop)
                PopupMenuItem(
                  value: 'toggle_guide',
                  child: Row(
                    children: [
                      Icon(
                        _showContextPanel
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _showContextPanel
                            ? 'Hide Care Guide'
                            : 'Show Care Guide',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
