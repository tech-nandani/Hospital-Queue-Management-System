import 'package:flutter/material.dart';

import '../../../services/symptom_assistant_service.dart';
import 'department_recommendation_card.dart';
import 'urgent_care_card.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String>? onBookAppointment;
  final ValueChanged<String>? onSelectFollowUp;
  final VoidCallback? onRetry;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onBookAppointment,
    this.onSelectFollowUp,
    this.onRetry,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    if (isUser) {
      return _buildUserBubble(context);
    } else {
      return _buildAIBubble(context);
    }
  }

  Widget _buildUserBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: Text(
              _formatTime(message.timestamp),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 560),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1D72FE),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D72FE).withValues(alpha: 0.24),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIBubble(BuildContext context) {
    final isEmergency = message.isEmergency;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(top: 2, right: 12),
            decoration: BoxDecoration(
              gradient: isEmergency
                  ? const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF1D72FE), Color(0xFF06B6D4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isEmergency
                      ? const Color(0xFFE11D48).withValues(alpha: 0.25)
                      : const Color(0xFF06B6D4).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isEmergency ? Icons.emergency_rounded : Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),

          // Message Content Container
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 640),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isEmergency ? const Color(0xFFFFF1F2) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(
                  color: isEmergency
                      ? const Color(0xFFFECDD3)
                      : (message.isError
                          ? const Color(0xFFFECDD3)
                          : const Color(0xFFE2E8F0)),
                  width: isEmergency ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isEmergency
                        ? const Color(0xFFE11D48).withValues(alpha: 0.08)
                        : const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: isEmergency ? 16 : 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header tag & timestamp
                  Row(
                    children: [
                      if (isEmergency) ...[
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Color(0xFFE11D48),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'URGENT MEDICAL ATTENTION',
                          style: TextStyle(
                            color: Color(0xFFBE123C),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'CareFlow AI',
                          style: TextStyle(
                            color: message.isError
                                ? const Color(0xFFE11D48)
                                : const Color(0xFF1E293B),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(message.timestamp),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Main Text
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isEmergency
                          ? const Color(0xFF4C0519)
                          : (message.isError
                              ? const Color(0xFF9F1239)
                              : const Color(0xFF334155)),
                      fontSize: 14.5,
                      height: 1.5,
                      fontWeight: isEmergency ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),

                  // Bullet Points if any
                  if (message.bulletPoints.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...message.bulletPoints.map((bp) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6, right: 8),
                              child: Icon(
                                isEmergency
                                    ? Icons.warning_amber_rounded
                                    : Icons.circle,
                                size: isEmergency ? 13 : 5,
                                color: isEmergency
                                    ? const Color(0xFFE11D48)
                                    : const Color(0xFF1D72FE),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                bp,
                                style: TextStyle(
                                  color: isEmergency
                                      ? const Color(0xFF881337)
                                      : const Color(0xFF475569),
                                  fontSize: 13.5,
                                  height: 1.45,
                                  fontWeight: isEmergency
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Emergency card if urgent (Call 108 / 112 Actions, NO Book Appointment)
                  if (isEmergency) ...[
                    const SizedBox(height: 8),
                    const UrgentCareCard(),
                  ],

                  // Department recommendation card (Only when NOT an emergency)
                  if (message.recommendation != null && !isEmergency) ...[
                    const SizedBox(height: 8),
                    DepartmentRecommendationCard(
                      recommendation: message.recommendation!,
                      onBookAppointment: onBookAppointment,
                    ),
                  ],

                  // Error Retry button
                  if (message.isError && onRetry != null) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Retry'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE11D48),
                        side: const BorderSide(color: Color(0xFFFDA4AF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],

                  // Suggested Follow-up chips
                  if (message.suggestedFollowUps.isNotEmpty &&
                      onSelectFollowUp != null) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: message.suggestedFollowUps.map((chip) {
                        return ActionChip(
                          onPressed: () => onSelectFollowUp!(chip),
                          backgroundColor: isEmergency
                              ? const Color(0xFFFFE4E6)
                              : const Color(0xFFF1F5F9),
                          side: BorderSide(
                            color: isEmergency
                                ? const Color(0xFFFECDD3)
                                : const Color(0xFFE2E8F0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          label: Text(
                            chip,
                            style: TextStyle(
                              color: isEmergency
                                  ? const Color(0xFF9F1239)
                                  : const Color(0xFF334155),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
