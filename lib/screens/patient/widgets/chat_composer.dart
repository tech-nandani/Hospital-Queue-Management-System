import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatComposer extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool isThinking;
  final TextEditingController? controller;

  const ChatComposer({
    super.key,
    required this.onSend,
    this.isThinking = false,
    this.controller,
  });

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_updateCanSend);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCanSend);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _updateCanSend() {
    final canSend = _controller.text.trim().isNotEmpty && !widget.isThinking;
    if (canSend != _canSend) {
      setState(() => _canSend = canSend);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isThinking) return;

    _controller.clear();
    widget.onSend(text);
    _focusNode.requestFocus();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      _handleSend();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCanSend =
        _controller.text.trim().isNotEmpty && !widget.isThinking;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 140),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? const Color(0xFF1D72FE)
                      : const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Focus(
                      focusNode: _focusNode,
                      onKeyEvent: _handleKeyEvent,
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          height: 1.4,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Describe your symptoms or ask a health-related question...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                            height: 1.4,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: effectiveCanSend
                            ? const Color(0xFF1D72FE)
                            : const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                        boxShadow: effectiveCanSend
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF1D72FE).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_upward_rounded,
                          size: 20,
                        ),
                        color: effectiveCanSend
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                        onPressed: effectiveCanSend ? _handleSend : null,
                        tooltip: 'Send message',
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'AI guidance only — not a diagnosis. In emergencies, call 108 or 112.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF64748B).withValues(alpha: 0.85),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
