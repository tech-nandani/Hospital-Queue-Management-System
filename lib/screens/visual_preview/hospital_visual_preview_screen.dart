import 'package:flutter/material.dart';
import '../../widgets/hospital_workflow_visual.dart';
import '../../widgets/split_auth_layout.dart';
import '../login/login_screen.dart';

/// Interactive preview screen to inspect the Left Side Hospital Visual & Animation.
class HospitalVisualPreviewScreen extends StatefulWidget {
  const HospitalVisualPreviewScreen({super.key});

  @override
  State<HospitalVisualPreviewScreen> createState() =>
      _HospitalVisualPreviewScreenState();
}

class _HospitalVisualPreviewScreenState
    extends State<HospitalVisualPreviewScreen> {
  bool _splitMode = true;
  bool _useIllustrationAsset = false;
  String _activeToken = 'A-104';
  int _waitMinutes = 4;

  final List<String> _tokens = ['A-104', 'A-105', 'B-201', 'C-012'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Left Side — Hospital Visual / Animation'),
        backgroundColor: const Color(0xFF0F2642),
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              IconButton(
                tooltip: _useIllustrationAsset
                    ? 'Switch to Vector Mode'
                    : 'Switch to Concept Render Mode',
                icon: Icon(
                  _useIllustrationAsset
                      ? Icons.auto_awesome_rounded
                      : Icons.brush_rounded,
                  color: const Color(0xFF38EF7D),
                ),
                onPressed: () {
                  setState(() {
                    _useIllustrationAsset = !_useIllustrationAsset;
                  });
                },
              ),
              const Text('Split View', style: TextStyle(fontSize: 12)),
              Switch(
                value: _splitMode,
                activeThumbColor: const Color(0xFF38EF7D),
                onChanged: (val) {
                  setState(() {
                    _splitMode = val;
                  });
                },
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.token_rounded, color: Color(0xFF38BDF8)),
                tooltip: 'Simulate Next Token',
                onSelected: (token) {
                  setState(() {
                    _activeToken = token;
                    _waitMinutes = (_waitMinutes % 8) + 2;
                  });
                },
                itemBuilder: (context) => _tokens
                    .map((t) => PopupMenuItem(value: t, child: Text('Token $t')))
                    .toList(),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: _splitMode
          ? SplitAuthLayout(
              activeToken: _activeToken,
              estimatedWaitMinutes: _waitMinutes,
              child: _buildMockLoginPanel(),
            )
          : HospitalWorkflowVisual(
              activeToken: _activeToken,
              estimatedWaitMinutes: _waitMinutes,
              useIllustrationAsset: _useIllustrationAsset,
            ),
    );
  }

  Widget _buildMockLoginPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            color: Color(0xFF1976D2),
            size: 30,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'CareFlow',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16324F),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in to access patient registration, appointment slots, and real-time counter queue telemetry.',
          style: TextStyle(color: Color(0xFF6B7A8C), fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          icon: const Icon(Icons.login_rounded),
          label: const Text('Open Full Login Screen'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
