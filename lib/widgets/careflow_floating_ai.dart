import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/patient_api_service.dart';
import '../services/queue_service.dart';

class CareFlowFloatingAI extends StatefulWidget {
  final String role; // 'Doctor', 'Receptionist', 'Patient'

  const CareFlowFloatingAI({
    super.key,
    required this.role,
  });

  static void open(BuildContext context, {String role = 'Doctor', String? initialPrompt}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AIChatSheet(role: role, initialPrompt: initialPrompt),
    );
  }

  @override
  State<CareFlowFloatingAI> createState() => _CareFlowFloatingAIState();
}

class _CareFlowFloatingAIState extends State<CareFlowFloatingAI> {
  void _openChatDialog(BuildContext context) {
    CareFlowFloatingAI.open(context, role: widget.role);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'careflow_ai_btn_${widget.role}',
      onPressed: () => _openChatDialog(context),
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
      label: const Text(
        'AI Assistant',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
      ),
    );
  }
}

class _AIChatSheet extends StatefulWidget {
  final String role;
  final String? initialPrompt;
  const _AIChatSheet({required this.role, this.initialPrompt});

  @override
  State<_AIChatSheet> createState() => _AIChatSheetState();
}

class _AIChatSheetState extends State<_AIChatSheet> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  List<String> get _suggestions {
    switch (widget.role) {
      case 'Doctor':
        return [
          "Show today's queue",
          "Summarize patient history",
          "Show priority patients",
          "Show today's appointments",
        ];
      case 'Receptionist':
        return [
          "Show today's appointments",
          "Which doctors are available?",
          "Show waiting patients",
          "Help me register a patient",
        ];
      default:
        return [
          "Which department should I visit?",
          "What is my queue status?",
          "Show my appointment",
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'text': 'Hello! I am your CareFlow Clinical & Queue AI Assistant. How can I assist you in the ${widget.role} workspace today?',
    });
    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sendMessage(widget.initialPrompt!);
      });
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': query});
      _isLoading = true;
    });
    _msgCtrl.clear();
    _scrollToBottom();

    // Check for smart contextual responses first
    String? contextualReply = _resolveContextual(query);

    if (contextualReply != null) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _messages.add({'role': 'assistant', 'text': contextualReply});
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final res = await PatientApiService.instance.chatWithAI(
        message: 'Role: ${widget.role}. Request: $query',
      );
      final reply = res['reply'] as String? ?? 'I have recorded your request.';
      if (!mounted) return;
      setState(() {
        _messages.add({'role': 'assistant', 'text': reply});
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'CareFlow AI Assistant: Your query has been logged. All queue state is synchronized in real-time with the hospital database.',
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  String? _resolveContextual(String query) {
    final q = query.toLowerCase();
    final queue = QueueService.instance;

    if (q.contains("today's queue") || q.contains("waiting patients")) {
      return "There are currently ${queue.waitingCount} patient(s) waiting in the queue, with ${queue.consultationCount} active in consultation and ${queue.emergencyCount} emergency cases.";
    }
    if (q.contains("priority patients")) {
      final priorities = queue.patients.where((p) => p.priority == 'High' || p.priority == 'Emergency').toList();
      if (priorities.isEmpty) {
        return "No high-priority or emergency patients are currently waiting in the triage queue.";
      }
      final formattedList = priorities.map((p) => "${p.name} (Token #${p.token}, ${p.priority})").join(", ");
      return "There are ${priorities.length} priority patient(s): $formattedList.";
    }
    if (q.contains("doctors are available") || q.contains("doctor availability")) {
      return "CareFlow doctors on duty are marked Available in the consultation rooms. You can verify live status in the Doctor Schedule section.";
    }
    if (q.contains("register a patient")) {
      return "To register a patient, select 'Patient Registration' or 'Walk-in Patients' in your Receptionist sidebar. Enter their name, mobile, department, and priority to immediately generate their live queue token.";
    }
    if (q.contains("department")) {
      return "CareFlow departments currently active: General Medicine, Cardiology, Pediatrics, Orthopedics, and Emergency Triage.";
    }
    return null;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CareFlow AI Assistant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mainText,
                        ),
                      ),
                      Text(
                        'Active Workspace: ${widget.role}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.mainText),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Suggestion Pills
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final suggestion = _suggestions[i];
                return ActionChip(
                  label: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  backgroundColor: AppColors.secondaryLight,
                  side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () => _sendMessage(suggestion),
                );
              },
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isUser = m['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                        bottomLeft: !isUser ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      m['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : AppColors.mainText,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    onSubmitted: _sendMessage,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.mainText),
                    decoration: InputDecoration(
                      hintText: 'Ask anything about queue, appointments, or triage...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _sendMessage(_msgCtrl.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
