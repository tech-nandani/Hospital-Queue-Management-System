import 'package:flutter/material.dart';

class ChatContextPanel extends StatelessWidget {
  final VoidCallback? onClose;

  const ChatContextPanel({
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFFEDF2F7), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: Color(0xFF1D72FE),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Care Guide',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: const Color(0xFF64748B),
                    onPressed: onClose,
                    tooltip: 'Close panel',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEDF2F7)),

          // Scrollable Info Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Emergency Quick Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.emergency_rounded,
                              size: 16, color: Color(0xFFE11D48)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Emergency Hotlines',
                              style: TextStyle(
                                color: Color(0xFF9F1239),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _contactRow('Ambulance', '108'),
                      _contactRow('National SOS', '112'),
                      _contactRow('Hospital Desk', '1800-419-7890'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Preparation Checklist
                const Text(
                  'BEFORE YOUR DOCTOR VISIT',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                _tipItem(
                  Icons.timer_outlined,
                  'Track onset',
                  'Note the exact day and time your symptoms started.',
                ),
                _tipItem(
                  Icons.medication_outlined,
                  'Medication list',
                  'Keep a note of any current prescriptions or supplements.',
                ),
                _tipItem(
                  Icons.trending_up_rounded,
                  'Severity changes',
                  'Observe if pain or discomfort worsens after specific triggers.',
                ),
                _tipItem(
                  Icons.folder_shared_outlined,
                  'Past records',
                  'View your previous visits in the Medical Records tab.',
                ),

                const SizedBox(height: 20),

                // Privacy Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 15,
                        color: Color(0xFF64748B),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your health conversations are confidential and session-isolated.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(String label, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF881337),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            number,
            style: const TextStyle(
              color: Color(0xFF9F1239),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipItem(IconData icon, String title, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF1D72FE)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
