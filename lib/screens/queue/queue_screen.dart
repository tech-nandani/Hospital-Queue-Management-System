import 'package:flutter/material.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF1976D2),
          ),
        ),

        title: const Text(
          "My Queue",
          style: TextStyle(
            color: Color(0xFF172B4D),
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // =========================
            // HEADER
            // =========================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ],
                ),

                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                children: [

                  Container(
                    height: 58,
                    width: 58,

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: const Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Text(
                          "Your Queue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "Track your position and waiting "
                              "time in one place.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // EMPTY QUEUE
            // =========================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 35,
              ),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),

              child: Column(
                children: [

                  Container(
                    height: 85,
                    width: 85,

                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F2FF),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.confirmation_number_outlined,
                      color: Color(0xFF1976D2),
                      size: 42,
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "No Active Queue",
                    style: TextStyle(
                      color: Color(0xFF172B4D),
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "You don't have an active queue right now.\n"
                        "Book an appointment to get started.",
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 48,
                    width: 200,

                    child: ElevatedButton(
                      onPressed: () {},

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF1976D2),

                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),

                      child: const Text(
                        "Book Appointment",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // HOW IT WORKS
            // =========================

            const Text(
              "How Queue Works",
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const QueueStep(
              number: "01",
              icon: Icons.calendar_month_outlined,
              title: "Book an appointment",
              subtitle:
              "Choose your department, doctor, date and time.",
            ),

            const QueueStep(
              number: "02",
              icon: Icons.confirmation_number_outlined,
              title: "Receive your queue position",
              subtitle:
              "Your queue position will be generated after booking.",
            ),

            const QueueStep(
              number: "03",
              icon: Icons.track_changes_outlined,
              title: "Track your position",
              subtitle:
              "Monitor your queue status from the app.",
            ),

            const QueueStep(
              number: "04",
              icon: Icons.notifications_none_rounded,
              title: "Get notified",
              subtitle:
              "Receive notifications when your turn is approaching.",
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


// =====================================================
// QUEUE STEP
// =====================================================

class QueueStep extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String subtitle;

  const QueueStep({
    super.key,
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFE5EAF0),
        ),
      ),

      child: Row(
        children: [

          Container(
            height: 48,
            width: 48,

            decoration: BoxDecoration(
              color: const Color(0xFFE8F2FF),
              borderRadius: BorderRadius.circular(13),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF1976D2),
              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  "$number  $title",
                  style: const TextStyle(
                    color: Color(0xFF172B4D),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    height: 1.4,
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