import 'package:flutter/material.dart';

import '../../services/patient_service.dart';

class PatientRecordsScreen extends StatefulWidget {
  final PatientService service;

  const PatientRecordsScreen({super.key, required this.service});

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  int selectedCategory = 0;

  static const categories = ['Visits', 'Prescriptions', 'Reports'];

  @override
  Widget build(BuildContext context) {
    final records = widget.service.records
        .where((record) => record.category == categories[selectedCategory])
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        const Text(
          'Medical records',
          style: TextStyle(
            color: Color(0xFF16324F),
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your visit documents will be available here after consultation.',
          style: TextStyle(color: Color(0xFF718096)),
        ),
        const SizedBox(height: 20),
        SegmentedButton<int>(
          segments: [
            for (var index = 0; index < categories.length; index++)
              ButtonSegment(value: index, label: Text(categories[index])),
          ],
          selected: {selectedCategory},
          onSelectionChanged: (selection) =>
              setState(() => selectedCategory = selection.first),
        ),
        const SizedBox(height: 18),
        if (records.isEmpty)
          const _RecordsEmptyState()
        else
          ...records.map(
            (record) => Card(
              color: Colors.white,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF3FF),
                  child: Icon(
                    Icons.description_outlined,
                    color: Color(0xFF1976D2),
                  ),
                ),
                title: Text(
                  record.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(record.description),
                trailing: IconButton(
                  tooltip: 'View record',
                  onPressed: () => _showRecord(context, record),
                  icon: const Icon(Icons.visibility_outlined),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showRecord(BuildContext context, PatientRecord record) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(record.title),
        content: Text(record.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _RecordsEmptyState extends StatelessWidget {
  const _RecordsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EAF3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.folder_open_outlined, size: 42, color: Color(0xFF9AA8B7)),
          SizedBox(height: 12),
          Text(
            'No records available yet.',
            style: TextStyle(
              color: Color(0xFF16324F),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Prescriptions and reports shared by your doctor will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF718096)),
          ),
        ],
      ),
    );
  }
}
