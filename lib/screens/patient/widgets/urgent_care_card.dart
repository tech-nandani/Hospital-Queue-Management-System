import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrgentCareCard extends StatelessWidget {
  final VoidCallback? onEmergencyCall;
  final ValueChanged<String>? onCallNumber;

  const UrgentCareCard({
    super.key,
    this.onEmergencyCall,
    this.onCallNumber,
  });

  Future<void> _makeCall(BuildContext context, String number) async {
    if (onCallNumber != null) {
      onCallNumber!(number);
      return;
    }
    if (onEmergencyCall != null) {
      onEmergencyCall!();
      return;
    }
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please dial $number immediately from your phone.'),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECDD3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE4E6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.5),
                topRight: Radius.circular(16.5),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: Color(0xFFE11D48),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'URGENT MEDICAL ATTENTION',
                    style: TextStyle(
                      color: Color(0xFFBE123C),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Text(
                  'Urgent Care Alert',
                  style: TextStyle(
                    color: Color(0xFFBE123C),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your symptoms may require immediate medical evaluation. Please do not wait for a routine appointment if symptoms are severe or worsening.',
                  style: TextStyle(
                    color: Color(0xFF881337),
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),

                // Emergency Action Buttons
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 420;
                    return Flex(
                      direction: isNarrow ? Axis.vertical : Axis.horizontal,
                      children: [
                        // Primary Button: 108
                        Expanded(
                          flex: isNarrow ? 0 : 1,
                          child: SizedBox(
                            width: isNarrow ? double.infinity : null,
                            child: ElevatedButton.icon(
                              onPressed: () => _makeCall(context, '108'),
                              icon: const Icon(Icons.phone_in_talk_rounded, size: 17),
                              label: const Text(
                                'Call Emergency — 108',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE11D48),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isNarrow ? 0 : 10,
                          height: isNarrow ? 10 : 0,
                        ),
                        // Secondary Button: 112
                        Expanded(
                          flex: isNarrow ? 0 : 1,
                          child: SizedBox(
                            width: isNarrow ? double.infinity : null,
                            child: OutlinedButton.icon(
                              onPressed: () => _makeCall(context, '112'),
                              icon: const Icon(Icons.emergency_rounded, size: 17),
                              label: const Text(
                                'National SOS — 112',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFBE123C),
                                side: const BorderSide(
                                  color: Color(0xFFFDA4AF),
                                  width: 1.4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Note
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Color(0xFF9F1239),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'If symptoms are severe or worsening, call emergency services now.',
                        style: TextStyle(
                          color: Color(0xFF9F1239),
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
