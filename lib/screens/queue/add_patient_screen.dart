import 'package:flutter/material.dart';
import '../../services/queue_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() =>
      _AddPatientScreenState();
}

class _AddPatientScreenState
    extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final reasonController = TextEditingController();

  String gender = 'Male';
  String priority = 'Normal';

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  void _addPatient() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final patient =
    QueueService.instance.addPatient(
      name: nameController.text.trim(),
      age: int.parse(ageController.text.trim()),
      gender: gender,
      phone: phoneController.text.trim(),
      reason: reasonController.text.trim(),
      priority: priority,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${patient.name} added with Token ${patient.token}',
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  InputDecoration _decoration(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFDCE6F2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFDCE6F2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF1976D2),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F8FD),
        elevation: 0,
        title: const Text(
          'Add Patient',
          style: TextStyle(
            color: Color(0xFF16324F),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF16324F),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFDCE6F2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                        Color(0xFFEAF3FF),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Enter patient information',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16324F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: nameController,
                  decoration: _decoration(
                    'Patient Name',
                    Icons.person_outline_rounded,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter patient name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: _decoration(
                    'Age',
                    Icons.cake_outlined,
                  ),
                  validator: (value) {
                    final age =
                    int.tryParse(value ?? '');

                    if (age == null ||
                        age <= 0 ||
                        age > 120) {
                      return 'Enter a valid age';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: _decoration(
                    'Gender',
                    Icons.people_outline_rounded,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Male',
                      child: Text('Male'),
                    ),
                    DropdownMenuItem(
                      value: 'Female',
                      child: Text('Female'),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child: Text('Other'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        gender = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _decoration(
                    'Contact Number',
                    Icons.phone_outlined,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().length < 10) {
                      return 'Enter a valid contact number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: _decoration(
                    'Reason / Symptoms',
                    Icons.medical_information_outlined,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter reason';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: _decoration(
                    'Priority',
                    Icons.priority_high_rounded,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Normal',
                      child: Text('Normal'),
                    ),
                    DropdownMenuItem(
                      value: 'High',
                      child: Text('High Priority'),
                    ),
                    DropdownMenuItem(
                      value: 'Low',
                      child: Text('Low'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        priority = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _addPatient,
                    icon: const Icon(
                      Icons.add_rounded,
                    ),
                    label: const Text(
                      'Add Patient to Queue',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}