import 'package:flutter/foundation.dart';

import 'patient_api_service.dart';

typedef AIChatHandler = Future<Map<String, dynamic>> Function({
  required String message,
  List<Map<String, dynamic>>? history,
  String? token,
});

enum MessageSender {
  user,
  ai,
}

class SymptomRecommendation {
  final String department;
  final String doctor;
  final String urgency;
  final String explanation;
  final bool emergency;

  const SymptomRecommendation({
    required this.department,
    required this.doctor,
    required this.urgency,
    required this.explanation,
    required this.emergency,
  });
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final SymptomRecommendation? recommendation;
  final bool isEmergency;
  final List<String> bulletPoints;
  final List<String> suggestedFollowUps;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.recommendation,
    this.isEmergency = false,
    this.bulletPoints = const [],
    this.suggestedFollowUps = const [],
    this.isError = false,
  });

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? text,
    DateTime? timestamp,
    SymptomRecommendation? recommendation,
    bool? isEmergency,
    List<String>? bulletPoints,
    List<String>? suggestedFollowUps,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      recommendation: recommendation ?? this.recommendation,
      isEmergency: isEmergency ?? this.isEmergency,
      bulletPoints: bulletPoints ?? this.bulletPoints,
      suggestedFollowUps: suggestedFollowUps ?? this.suggestedFollowUps,
      isError: isError ?? this.isError,
    );
  }
}

class ChatSession {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];
}

class SymptomAssistantService extends ChangeNotifier {
  SymptomAssistantService._() {
    _ensureInitialSession();
  }

  static final SymptomAssistantService instance = SymptomAssistantService._();

  final List<ChatSession> _sessions = [];
  String? _activeSessionId;
  bool _isThinking = false;
  String? _currentPatientEmail;

  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  bool get isThinking => _isThinking;
  String? get activeSessionId => _activeSessionId;

  ChatSession get currentSession {
    _ensureInitialSession();
    return _sessions.firstWhere(
      (s) => s.id == _activeSessionId,
      orElse: () => _sessions.first,
    );
  }

  List<ChatMessage> get currentMessages => currentSession.messages;

  static int _sessionCounter = 0;

  void _ensureInitialSession() {
    if (_sessions.isEmpty) {
      final now = DateTime.now();
      final newSession = ChatSession(
        id: 'session_${now.millisecondsSinceEpoch}_${++_sessionCounter}',
        title: 'New conversation',
        createdAt: now,
        updatedAt: now,
      );
      _sessions.add(newSession);
      _activeSessionId = newSession.id;
    } else if (_activeSessionId == null ||
        !_sessions.any((s) => s.id == _activeSessionId)) {
      _activeSessionId = _sessions.first.id;
    }
  }

  /// Start a completely new chat session.
  void createNewSession() {
    final now = DateTime.now();
    final session = ChatSession(
      id: 'session_${now.millisecondsSinceEpoch}_${++_sessionCounter}',
      title: 'New conversation',
      createdAt: now,
      updatedAt: now,
    );
    _sessions.insert(0, session);
    _activeSessionId = session.id;
    _isThinking = false;
    notifyListeners();
  }

  /// Select an existing chat session.
  void selectSession(String sessionId) {
    if (_activeSessionId == sessionId) return;
    if (_sessions.any((s) => s.id == sessionId)) {
      _activeSessionId = sessionId;
      _isThinking = false;
      notifyListeners();
    }
  }

  /// Clear messages of the active session.
  void clearCurrentSession() {
    final session = currentSession;
    session.messages.clear();
    session.title = 'New conversation';
    session.updatedAt = DateTime.now();
    _isThinking = false;
    notifyListeners();
  }

  /// Delete a specific session.
  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_activeSessionId == sessionId) {
      _activeSessionId = _sessions.isNotEmpty ? _sessions.first.id : null;
    }
    _ensureInitialSession();
    notifyListeners();
  }

  Duration simulatedDelay = const Duration(milliseconds: 200);
  AIChatHandler? chatApiHandler;
  bool useLocalEngine = false;

  /// Reset all sessions for patient data isolation upon login/logout.
  void resetForPatient([String? email, bool force = false]) {
    if (force || _currentPatientEmail != email || email == null) {
      _currentPatientEmail = email;
      _sessions.clear();
      _activeSessionId = null;
      _isThinking = false;
      _ensureInitialSession();
      notifyListeners();
    }
  }

  /// Reset state completely (convenient for test setup).
  void resetState() {
    _currentPatientEmail = null;
    _sessions.clear();
    _activeSessionId = null;
    _isThinking = false;
    chatApiHandler = null;
    useLocalEngine = false;
    _ensureInitialSession();
    notifyListeners();
  }

  /// Core conversational messaging flow.
  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final session = currentSession;

    // Update title on first patient message
    if (session.messages.isEmpty) {
      session.title = _generateSessionTitle(cleanText);
    }

    final userMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_u',
      sender: MessageSender.user,
      text: cleanText,
      timestamp: DateTime.now(),
    );

    // Build history payload strictly from PRIOR non-error messages BEFORE adding userMessage.
    // This guarantees the current message is sent once in `message` and not duplicated in history.
    final priorNonErrorMessages = session.messages
        .where((m) => !m.isError)
        .toList();

    final recentHistory = priorNonErrorMessages.length > 20
        ? priorNonErrorMessages.sublist(priorNonErrorMessages.length - 20)
        : priorNonErrorMessages;

    final historyPayload = recentHistory
        .map((m) => {
              'role': m.sender == MessageSender.user ? 'user' : 'assistant',
              'content': m.text,
              'sender': m.sender == MessageSender.user ? 'user' : 'ai',
              'text': m.text,
            })
        .toList();

    session.messages.add(userMessage);
    session.updatedAt = DateTime.now();
    _isThinking = true;
    notifyListeners();

    try {
      if (simulatedDelay > Duration.zero) {
        await Future.delayed(simulatedDelay);
      }

      ChatMessage aiResponse;
      if (useLocalEngine) {
        aiResponse = _buildAIResponse(cleanText, session.messages);
      } else {
        final res = await (chatApiHandler ?? PatientApiService.instance.chatWithAI)(
          message: cleanText,
          history: historyPayload,
        );

        final respText = res['text'] as String? ??
            'I am here to assist you with your healthcare inquiries.';
        final deptName = res['department'] as String?;
        final doctorName = res['doctor'] as String?;
        final urgency = res['urgency'] as String?;
        final explanation = res['explanation'] as String?;
        final isEmergency = res['is_emergency'] as bool? ?? false;
        final bullets = (res['bullet_points'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[];
        final followUps = (res['suggested_follow_ups'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[];

        SymptomRecommendation? recommendation;
        if (deptName != null && deptName.isNotEmpty) {
          recommendation = SymptomRecommendation(
            department: deptName,
            doctor: doctorName ?? 'Available Specialist',
            urgency: urgency ?? 'Routine visit',
            explanation: explanation ??
                'Recommended based on your symptoms and clinical criteria.',
            emergency: isEmergency,
          );
        }

        aiResponse = ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
          sender: MessageSender.ai,
          text: respText,
          timestamp: DateTime.now(),
          recommendation: recommendation,
          isEmergency: isEmergency,
          bulletPoints: bullets,
          suggestedFollowUps: followUps,
        );
      }

      session.messages.add(aiResponse);
      session.updatedAt = DateTime.now();
    } catch (_) {
      session.messages.add(
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_err',
          sender: MessageSender.ai,
          text: 'Sorry, I couldn\'t process that right now. Please try again.',
          timestamp: DateTime.now(),
          isError: true,
          suggestedFollowUps: const ['Try again'],
        ),
      );
    } finally {
      _isThinking = false;
      notifyListeners();
    }
  }

  /// Retry the last user prompt if an error occurred.
  Future<void> retryLastMessage() async {
    final session = currentSession;
    if (session.messages.isEmpty) return;

    final lastUserMsg = session.messages.lastWhere(
      (m) => m.sender == MessageSender.user,
      orElse: () => session.messages.first,
    );

    if (session.messages.isNotEmpty && session.messages.last.isError) {
      session.messages.removeLast();
    }

    await sendMessage(lastUserMsg.text);
  }

  String _generateSessionTitle(String text) {
    final singleLine = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (singleLine.length <= 26) {
      return singleLine[0].toUpperCase() + singleLine.substring(1);
    }
    return '${singleLine.substring(0, 24).trim()}…';
  }

  bool _containsWord(String text, List<String> terms) {
    for (final term in terms) {
      final reg = RegExp(r'\b' + RegExp.escape(term.toLowerCase()) + r'\b', caseSensitive: false);
      if (reg.hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  ChatMessage _buildAIResponse(String userInput, List<ChatMessage> history) {
    final currentText = userInput.trim();
    final currentLower = currentText.toLowerCase();

    // Prior messages excluding the current user message and errors
    final priorMessages = history
        .where((m) => !m.isError && m != history.last)
        .toList();

    final priorUserTexts = priorMessages
        .where((m) => m.sender == MessageSender.user)
        .map((m) => m.text.trim())
        .toList();

    final priorUserText = priorUserTexts.join(' ').toLowerCase();

    // =============================================================
    // 1. EMERGENCY CHECK (CURRENT MESSAGE + MULTI-TURN COMBINATION)
    // =============================================================
    final hasBreathingEmergency = _containsWord(currentLower, [
      'difficulty breathing', 'shortness of breath', 'cannot breathe', "can't breathe",
      'struggling to breathe', 'hard to breathe', 'trouble breathing', 'gasping',
      'not getting enough air', 'suffocating', 'choking', 'severe breathlessness', 'breathless',
      'breathing problems', 'having breathing problems',
    ]);

    final hasChestEmergency = _containsWord(currentLower, [
      'severe chest pain', 'crushing chest pain', 'chest pressure', 'heart attack',
      'chest tightness and sweating', 'crushing chest discomfort', 'severe chest discomfort',
    ]);

    final hasStrokeEmergency = _containsWord(currentLower, [
      'stroke', 'facial drooping', 'face drooping', 'slurred speech', 'difficulty speaking',
      'sudden weakness', 'sudden numbness', 'paralysis', 'cannot move my arm',
    ]);

    final hasConsciousnessEmergency = _containsWord(currentLower, [
      'loss of consciousness', 'unconscious', 'passed out', 'fainted', 'fainting',
      'blacked out', 'collapsed', 'unresponsive',
    ]);

    final hasBleedingEmergency = _containsWord(currentLower, [
      'severe bleeding', 'bleeding heavily', 'cannot stop bleeding', 'coughing blood', 'vomiting blood',
    ]);

    final hasAllergicEmergency = _containsWord(currentLower, [
      'anaphylaxis', 'severe allergic reaction', 'throat swelling', 'swollen tongue and breathing',
    ]);

    final hasSeizureEmergency = _containsWord(currentLower, [
      'seizure', 'seizures', 'convulsions', 'epileptic fit',
    ]);

    final hasConfusionEmergency = _containsWord(currentLower, [
      'severe confusion', 'acute confusion', 'sudden confusion',
    ]);

    // Check multi-turn combination: chest symptoms in prior + breathing distress in current
    final hadPriorChest = _containsWord(priorUserText, ['chest', 'chest pain', 'chest discomfort', 'heart']);
    final hadPriorBreathing = _containsWord(priorUserText, ['breathing', 'breath', 'shortness of breath']);
    final isMultiTurnChestBreathing = (hadPriorChest && (hasBreathingEmergency || _containsWord(currentLower, ['breathing', 'breath', 'struggling']))) ||
        (hadPriorBreathing && (hasChestEmergency || _containsWord(currentLower, ['chest pain', 'chest discomfort'])));

    // Check if user is asking to book appointment while in an active emergency
    final hadPriorEmergency = priorMessages.any((m) => m.isEmergency);
    final isBookingDuringEmergency = hadPriorEmergency &&
        _containsAny(currentLower, ['book an appointment', 'book appointment', 'schedule an appointment', 'can i book', 'should i book', 'book slot']);

    final isEmergency = hasBreathingEmergency ||
        hasChestEmergency ||
        hasStrokeEmergency ||
        hasConsciousnessEmergency ||
        hasBleedingEmergency ||
        hasAllergicEmergency ||
        hasSeizureEmergency ||
        hasConfusionEmergency ||
        isMultiTurnChestBreathing ||
        isBookingDuringEmergency;

    if (isEmergency) {
      String emergencyText;
      if (isBookingDuringEmergency) {
        emergencyText = 'Because your symptoms require urgent clinical evaluation, '
            'scheduling a routine appointment is not advised at this time. '
            'Please seek immediate emergency medical care rather than waiting for a clinic consultation.';
      } else if (isMultiTurnChestBreathing || (hasChestEmergency && hasBreathingEmergency)) {
        emergencyText = 'Severe chest discomfort combined with difficulty breathing can indicate a critical medical emergency. '
            'Please seek immediate, in-person emergency care. Do not wait for a routine clinic appointment or attempt to drive yourself.';
      } else if (hasBreathingEmergency) {
        emergencyText = 'Difficulty breathing and shortness of breath can be serious, especially when symptoms feel severe or affect normal activities. '
            'Please seek immediate emergency medical attention rather than waiting for a routine appointment.';
      } else if (hasChestEmergency) {
        emergencyText = 'Severe chest pain or crushing pressure can indicate a critical cardiovascular emergency. '
            'Please seek immediate, in-person clinical care immediately. Do not attempt to drive yourself to the clinic.';
      } else if (hasStrokeEmergency) {
        emergencyText = 'Sudden weakness, facial drooping, numbness, or difficulty speaking are critical warning signs of a neurological emergency. '
            'Immediate emergency evaluation is vital—every minute matters. Please seek urgent medical care right away.';
      } else if (hasConsciousnessEmergency) {
        emergencyText = 'Loss of consciousness, fainting, or sudden collapse can indicate a serious medical condition requiring urgent in-person evaluation. '
            'Please seek immediate emergency medical care to ensure patient safety and stabilization.';
      } else if (hasBleedingEmergency) {
        emergencyText = 'Severe or uncontrolled bleeding requires immediate medical attention to stabilize blood loss and provide emergency clinical intervention.';
      } else if (hasAllergicEmergency) {
        emergencyText = 'A severe allergic reaction, particularly when involving facial swelling or airway restriction, can rapidly become life-threatening. '
            'Please seek immediate emergency medical care now.';
      } else if (hasSeizureEmergency) {
        emergencyText = 'Seizures require prompt emergency medical attention to ensure airway safety, prevent injury, and provide medical stabilization. '
            'Please contact emergency services immediately.';
      } else {
        emergencyText = 'These symptoms can indicate a critical medical emergency requiring immediate, in-person clinical care. '
            'Please do not wait for a routine clinic appointment.';
      }

      return ChatMessage(
        id: 'msg_emergency_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.ai,
        text: emergencyText,
        timestamp: DateTime.now(),
        isEmergency: true,
        recommendation: const SymptomRecommendation(
          department: 'Emergency Medicine',
          doctor: 'Emergency Response Team',
          urgency: 'Immediate Emergency Care',
          explanation: 'These severe symptoms need immediate in-person assessment by emergency medical staff.',
          emergency: true,
        ),
        bulletPoints: const [
          'If symptoms are severe or worsening, call emergency services now (dial 108 or 112)',
          'Do not drive yourself if experiencing severe chest pain, breathlessness, or dizziness',
          'Keep your identification and emergency contacts accessible',
        ],
        suggestedFollowUps: const [
          'What should I tell the emergency team?',
          'Emergency contact numbers',
        ],
      );
    }

    // =============================================================
    // 2. GREETINGS & GRATITUDE (Standalone)
    // =============================================================
    if (_isGreeting(currentLower) && priorMessages.isEmpty) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'Hello! I am CareFlow AI, your healthcare guidance companion. '
            'Tell me what symptoms or health concerns you are experiencing, or ask any questions '
            'about hospital visits, appointments, and clinics.',
        timestamp: DateTime.now(),
        bulletPoints: const [
          'Describe how long you have felt this way',
          'Ask appointment questions (arrival times, what to bring, companion policy)',
          'Inquire about hospital departments and doctor specialties',
        ],
        suggestedFollowUps: const [
          '🤒 I have a fever',
          'How early should I arrive?',
          'What should I bring to my appointment?',
          'Can I bring a companion?',
        ],
      );
    }

    if (_isGratitude(currentLower)) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'You are very welcome! Take good care of yourself, and please proceed to book an appointment '
            'if your symptoms persist or cause you discomfort. I am always here whenever you need guidance.',
        timestamp: DateTime.now(),
        bulletPoints: const [
          'Rest and maintain adequate hydration',
          'Reach out if your symptoms change or escalate',
        ],
        suggestedFollowUps: const [
          'How do I book an appointment?',
          'How early should I arrive?',
          'What should I bring to my appointment?',
        ],
      );
    }

    // =============================================================
    // 3. APPOINTMENT & HOSPITAL PROCESS QUESTIONS
    // (Must answer directly with NO symptom analysis, NO department card!)
    // =============================================================

    // 3A. Arrival Time / Reporting Time
    if (_containsAny(currentLower, [
      'how early should i arrive', 'when should i arrive', 'arrival time', 'how early to arrive',
      'reporting time', 'how much in advance', 'when to reach', 'reach before appointment',
      'how early should i be', 'when should i come', 'how early do i need to arrive',
    ]) || (_containsWord(currentLower, ['early']) && _containsWord(currentLower, ['arrive', 'reach', 'come']))) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'For your appointment at CareFlow, it is generally recommended to arrive '
            '**15 to 20 minutes before your scheduled consultation time**.\n\n'
            'Arriving early allows sufficient time to complete reception check-in, verify your patient registration, '
            'have basic vital signs recorded, and activate your digital queue token at the clinic kiosk. '
            'If your CareFlow appointment confirmation specifies a particular reporting time, please follow that instruction.',
        timestamp: DateTime.now(),
        bulletPoints: const [
          'Arrive 15–20 minutes early to complete check-in and queue token activation',
          'Have your digital booking confirmation or SMS accessible on your phone',
          'Consultation queues move dynamically based on doctor availability',
        ],
        suggestedFollowUps: const [
          'What should I bring to my appointment?',
          'Can I bring a companion?',
          'How do I book an appointment?',
        ],
      );
    }

    // 3B. Companion / Visitor Policy
    if (_containsAny(currentLower, [
      'can i bring a companion', 'bring a companion', 'can someone come with me', 'can i bring someone',
      'visitor policy', 'companion policy', 'family member allowed', 'bring someone with me',
      'can my family come', 'can a friend come', 'bring companion', 'visitor rules',
      'can i bring my spouse', 'allow companion', 'allow visitors', 'can someone accompany me',
    ]) || (_containsWord(currentLower, ['companion', 'attendant', 'visitor']) && !_containsWord(currentLower, ['pain', 'fever', 'headache']))) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'Yes, you are welcome to bring a companion, family member, or caregiver with you to your CareFlow appointment.\n\n'
            'Companions can assist you with registration, taking notes during consultation, mobility, and collecting medications. '
            'To maintain patient comfort and privacy in consultation rooms, clinics generally recommend that '
            '**one companion** accompany you inside the doctor\'s consultation area.',
        timestamp: DateTime.now(),
        bulletPoints: const [
          'One companion is recommended inside the consultation room for patient privacy',
          'Caregivers can help describe symptoms and note physician instructions',
          'Spacious waiting lounges and wheelchair-accessible seating are available throughout the hospital',
        ],
        suggestedFollowUps: const [
          'How early should I arrive?',
          'What should I bring to my appointment?',
          'How do I book an appointment?',
        ],
      );
    }

    // 3C. What should I bring to my appointment?
    if (_containsAny(currentLower, [
      'what should i bring', 'what to bring', 'what do i need to bring',
      'documents to bring', 'bring with me', 'what to carry', 'checklist for appointment', 'what documents',
    ])) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'For a smooth and comprehensive hospital consultation, please bring the following items with you:',
        timestamp: DateTime.now(),
        bulletPoints: const [
          'A government-issued photo ID (Aadhaar, Voter ID, Driver’s License, or Passport)',
          'Previous medical records, prescription slips, lab test results, or hospital discharge summaries',
          'An up-to-date list of all current medications, dosages, and dietary supplements',
          'Health insurance card or policy documentation (if applicable)',
          'A written note of your key symptoms and any specific questions for the physician',
        ],
        suggestedFollowUps: const [
          'How early should I arrive?',
          'Can I bring a companion?',
          'How do I book an appointment?',
        ],
      );
    }

    // 3D. How do I book an appointment?
    if (_containsAny(currentLower, [
      'how do i book', 'book an appointment', 'book appointment', 'how to book',
      'appointment process', 'schedule an appointment', 'book slot', 'booking appointment',
      'how can i book',
    ])) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'Booking an appointment in CareFlow is straightforward:\n'
            '1. Click the \'Book Appointment\' tab in the left navigation sidebar.\n'
            '2. Select your hospital department and preferred physician.\n'
            '3. Choose your desired date and available consultation time slot.\n'
            '4. Confirm your booking to immediately receive your digital queue token and live wait estimate.',
        timestamp: DateTime.now(),
        bulletPoints: const [
          'Appointments generate a real-time queue token automatically',
          'You can track or reschedule visits anytime in the My Visits tab',
          'Please arrive 15 minutes before your consultation time',
        ],
        suggestedFollowUps: const [
          'How early should I arrive?',
          'What should I bring to my appointment?',
          'Can I bring a companion?',
        ],
      );
    }

    // 3E. Rescheduling / Canceling
    if (_containsAny(currentLower, [
      'reschedule', 'cancel appointment', 'how to reschedule', 'how to cancel',
      'change appointment', 'cancel booking', 'cancel my appointment',
    ])) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'To reschedule or cancel an existing appointment in CareFlow:\n'
            '1. Click the \'My Visits\' tab in the left navigation sidebar.\n'
            '2. Find your upcoming appointment in the scheduled list.\n'
            '3. Click \'Reschedule\' to pick a new available consultation slot, or \'Cancel\' if you can no longer attend.\n'
            '4. Your queue token and confirmation will be updated immediately.',
        timestamp: DateTime.now(),
        bulletPoints: const [
          'Please reschedule at least 2 hours before your slot if possible',
          'Canceling releases your queue slot for waiting patients',
          'You can book a new appointment anytime in the Book Appointment tab',
        ],
        suggestedFollowUps: const [
          'How do I book an appointment?',
          'How early should I arrive?',
          'What should I bring to my appointment?',
        ],
      );
    }

    // 3F. Emergency contact numbers
    if (_containsAny(currentLower, [
      'emergency contact', 'emergency number', 'hotline', 'ambulance', 'helpline', 'phone number',
    ])) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'Here are the emergency contact numbers available for immediate medical assistance:',
        timestamp: DateTime.now(),
        bulletPoints: const [
          '108 — National Ambulance & Emergency Medical Services (Toll-Free, 24/7)',
          '112 — National Single Emergency Response Helpline',
          '1800-419-7890 — CareFlow Hospital 24/7 Support Desk',
        ],
        suggestedFollowUps: const [
          'What should I tell the emergency team?',
          'What should I bring to my appointment?',
          'How do I book an appointment?',
        ],
      );
    }

    // 3G. What should I tell the emergency team?
    if (_containsAny(currentLower, [
      'what should i tell the emergency team', 'what to tell the emergency team',
      'what to tell emergency', 'what to tell the ambulance', 'what should i say to the emergency',
      'what to say to emergency',
    ])) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'When speaking with the emergency response team (108/112) or triage staff, '
            'communicate these critical details clearly and calmly:',
        timestamp: DateTime.now(),
        bulletPoints: const [
          'Exact Location & Landmark: State where you are located so the ambulance can reach you immediately',
          'Primary Symptom: Describe what is happening (e.g., severe chest discomfort, shortness of breath, or sudden weakness)',
          'Onset & Duration: State when the symptom started (e.g., 10 minutes ago, or before 3 days)',
          'Known Health Conditions: Mention if there is a history of heart disease, high blood pressure, diabetes, or asthma',
          'Current State: Confirm whether the patient is conscious, able to speak, or in extreme pain',
        ],
        suggestedFollowUps: const [
          'Emergency contact numbers',
          'I am having chest discomfort',
          'What should I bring to my appointment?',
        ],
      );
    }

    // 3H. Profile, Settings, & Account Navigation
    if (_containsAny(currentLower, [
      'change my profile', 'change profile', 'update profile', 'edit profile',
      'my profile', 'change password', 'change email', 'log out', 'logout',
      'sign out', 'account settings', 'update my details', 'view profile',
    ])) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'To manage your account or profile in CareFlow:\n'
            '1. Click the \'Profile\' tab in the left navigation sidebar (or user menu at the top right).\n'
            '2. You can view and update your contact phone number, emergency contacts, and personal information.\n'
            '3. To log out securely, click the \'Logout\' button in the sidebar or menu.',
        timestamp: DateTime.now(),
        bulletPoints: const [
          'Keep your emergency contact phone numbers updated for hospital alerts',
          'Changes to your profile take effect across all hospital check-in kiosks',
          'You can view your active bookings anytime in the My Visits tab',
        ],
        suggestedFollowUps: const [
          'How do I book an appointment?',
          'How early should I arrive?',
          'What should I bring to my appointment?',
        ],
      );
    }

    // =============================================================
    // 4. GENERAL HEALTHCARE QUESTIONS (Non-Symptom)
    // =============================================================
    if (_containsAny(currentLower, [
      'home remedies', 'can i take home remedies', 'home care', 'remedies',
      'what can i do at home', 'natural remedies', 'home treatment', 'can i take paracetamol',
    ])) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'Supportive home care can offer temporary relief for mild, non-emergency discomfort, '
            'but should not replace a physician’s evaluation if symptoms persist:',
        timestamp: DateTime.now(),
        bulletPoints: const [
          'Stay well hydrated with clean water, oral electrolytes, or clear broths',
          'Rest in a quiet, well-ventilated space and allow your body adequate recovery time',
          'Avoid taking antibiotics or combining multiple over-the-counter medicines without medical advice',
          'Monitor your temperature twice daily with a digital thermometer',
          'Seek prompt medical care if symptoms worsen, cause severe distress, or last beyond 48–72 hours',
        ],
        suggestedFollowUps: const [
          'What are warning signs to watch for?',
          'Which department should I visit?',
          'How do I book an appointment?',
        ],
      );
    }

    // =============================================================
    // 5. DEPARTMENT INQUIRIES ("Which department should I visit?")
    // =============================================================
    if (_containsAny(currentLower, [
      'which department', 'what department', 'who should i see', 'suggest department',
      'department to visit', 'which doctor', 'recommend department', 'department should i visit',
    ])) {
      final currentMatch = matchDepartment(currentLower);
      if (currentMatch != null) {
        return ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
          sender: MessageSender.ai,
          text: 'Based on your inquiry, ${currentMatch.department} is the appropriate hospital department '
              'to consult for these symptoms.',
          timestamp: DateTime.now(),
          recommendation: currentMatch,
          bulletPoints: [
            'Specialist: ${currentMatch.doctor} in ${currentMatch.department}',
            'Mention how long symptoms have persisted during consultation',
            'Bring previous medical records or test reports if available',
          ],
          suggestedFollowUps: const [
            'What should I bring to my appointment?',
            'How do I book an appointment?',
            'Can I take home remedies?',
          ],
        );
      }

      final priorSymptoms = _extractSymptoms(priorUserText);
      final priorLocations = _extractLocations(priorUserText);
      if (priorSymptoms.isNotEmpty || priorLocations.isNotEmpty) {
        final priorMatch = matchDepartment(priorUserText);
        final targetDept = priorMatch?.department ?? 'General Medicine';
        final doc = priorMatch?.doctor ?? 'Dr. Sarah Khan';
        return ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
          sender: MessageSender.ai,
          text: 'Based on the symptoms discussed in our conversation, '
              '$targetDept is the most appropriate department for your visit.',
          timestamp: DateTime.now(),
          recommendation: SymptomRecommendation(
            department: targetDept,
            doctor: doc,
            urgency: 'Routine visit',
            explanation: 'A consultation with $targetDept can evaluate your specific symptoms thoroughly.',
            emergency: false,
          ),
          bulletPoints: [
            'Specialist: $doc in $targetDept',
            'Mention the timeline and specific symptoms during consultation',
            'Bring previous medical records if available',
          ],
          suggestedFollowUps: const [
            'What should I bring to my appointment?',
            'How do I book an appointment?',
            'Can I take home remedies?',
          ],
        );
      }
    }

    // =============================================================
    // 6. OFF-TOPIC / OUT-OF-SCOPE
    // =============================================================
    if (_containsAny(currentLower, [
      'weather', 'sports', 'football', 'cricket', 'movie', 'joke', 'song',
      'president', 'crypto', 'stock market', 'recipe', 'coding', 'python', 'flutter',
    ])) {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
        sender: MessageSender.ai,
        text: 'I am the CareFlow Healthcare AI Assistant, specialized in patient symptom guidance, '
            'hospital department recommendations, and clinic navigation. '
            'I cannot assist with general non-medical topics, but I would be glad to help with '
            'any health symptoms, hospital visits, or appointment booking questions you have.',
        timestamp: DateTime.now(),
        bulletPoints: const [
          'Describe symptoms you are experiencing',
          'Ask how to book an appointment with a hospital doctor',
          'Check what documents to bring to your visit',
        ],
        suggestedFollowUps: const [
          '🤒 I have a fever',
          'How early should I arrive?',
          'How do I book an appointment?',
        ],
      );
    }

    // =============================================================
    // 7. SYMPTOM CONVERSATION & CLINICAL FOLLOW-UP
    // =============================================================
    final curDuration = _extractDuration(currentLower);
    final curLocations = _extractLocations(currentLower);
    final curSymptoms = _extractSymptoms(currentLower);
    final curTriggers = _extractTriggers(currentLower);

    final priorSymptoms = _extractSymptoms(priorUserText);
    final priorLocations = _extractLocations(priorUserText);
    final priorDuration = _extractDuration(priorUserText);
    final priorTriggers = _extractTriggers(priorUserText);
    final hadPriorSymptomContext = priorSymptoms.isNotEmpty || priorLocations.isNotEmpty || priorDuration != null;

    if (curSymptoms.isNotEmpty ||
        curLocations.isNotEmpty ||
        (hadPriorSymptomContext &&
            (curDuration != null ||
                curTriggers.isNotEmpty ||
                _containsAny(currentLower, ['yes', 'no', 'cough', 'throat', 'chest', 'stomach', 'right side'])))) {
      final allDuration = curDuration ?? priorDuration;
      final allLocations = {...curLocations, ...priorLocations}.toList();
      final allSymptoms = {...curSymptoms, ...priorSymptoms}.toList();
      final allTriggers = {...curTriggers, ...priorTriggers}.toList();

      // 7A. Chest Symptoms Context
      if (allLocations.contains('chest') || allSymptoms.contains('chest discomfort') || currentLower.contains('chest')) {
        final durationStr = allDuration != null ? 'started about $allDuration' : 'is present in your chest';
        final triggerNote = allTriggers.isNotEmpty ? ' You also noted that this occurs ${allTriggers.first}.' : '';

        return ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
          sender: MessageSender.ai,
          text: 'Thanks for clarifying. So the chest discomfort $durationStr.$triggerNote '
              'Because symptoms involving the chest require careful attention, I want to check a few important warning signs: '
              'are you currently experiencing severe pain, difficulty breathing, dizziness, sweating, or pain spreading to your arm, jaw, or back?',
          timestamp: DateTime.now(),
          recommendation: const SymptomRecommendation(
            department: 'Cardiology',
            doctor: 'Dr. Sarah Khan',
            urgency: 'Priority visit',
            explanation: 'A heart and chest specialist should evaluate the origin of your chest symptoms.',
            emergency: false,
          ),
          bulletPoints: const [
            'If you develop crushing chest tightness, shortness of breath, or sweating, call 108/112 immediately',
            'Avoid strenuous physical activity or heavy lifting until evaluated',
            'If discomfort is mild and stable, a priority consultation with Cardiology is strongly recommended',
          ],
          suggestedFollowUps: const [
            'What should I tell the emergency team?',
            'Book appointment with Cardiology',
            'What should I bring to my appointment?',
          ],
        );
      }

      // 7B. Lower Right Abdominal Pain (TEST B)
      if (allLocations.contains('lower right abdomen') ||
          (allLocations.contains('stomach/abdomen') && _containsAny(currentLower, ['lower right', 'right side']))) {
        return ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
          sender: MessageSender.ai,
          text: 'Thank you for specifying the location. Pain localized in the lower right side of your abdomen '
              'is an important clinical detail that warrants careful attention:',
          timestamp: DateTime.now(),
          recommendation: const SymptomRecommendation(
            department: 'Gastroenterology',
            doctor: 'Dr. Emily Joseph',
            urgency: 'Priority visit',
            explanation:
                'Lower right abdominal symptoms should be evaluated promptly by a specialist to rule out appendicitis.',
            emergency: false,
          ),
          bulletPoints: const [
            'Lower right abdominal pain can be associated with appendicitis, localized digestive inflammation, or mesenteric strain',
            'Watch closely for warning signs such as fever, worsening sharp pain, nausea, vomiting, or abdominal tenderness',
            'Do NOT apply heat pads and avoid taking strong laxatives or painkillers before being evaluated by a physician',
            'A priority consultation with Gastroenterology or immediate urgent care evaluation is strongly advised',
          ],
          suggestedFollowUps: const [
            'What should I bring to my appointment?',
            'Book appointment with Gastroenterology',
            'Can I take home remedies?',
          ],
        );
      }

      // 7C. Headache + Timeline (TEST A & TEST 1)
      if (allSymptoms.contains('headache') || allLocations.contains('head')) {
        final timelineNote = allDuration != null ? 'started $allDuration' : 'is occurring';
        return ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
          sender: MessageSender.ai,
          text: 'Thank you for letting me know. Understanding that your headache $timelineNote '
              'helps assess your condition. Recent-onset headaches are often related to tension, dehydration, '
              'eye strain, lack of sleep, or early viral illness. A consultation with Neurology is recommended '
              'to properly evaluate the causes and ensure symptom relief:',
          timestamp: DateTime.now(),
          recommendation: const SymptomRecommendation(
            department: 'Neurology',
            doctor: 'Dr. Arjun Mehta',
            urgency: 'Priority visit',
            explanation: 'A neurologist can evaluate headaches, migraine patterns, and nerve-related symptoms.',
            emergency: false,
          ),
          bulletPoints: const [
            'Rest in a quiet, dark environment and maintain adequate hydration',
            'Track whether the headache is throbbing, constant, or accompanied by visual sensitivity',
            'Seek urgent medical attention if the headache is sudden and explosive (thunderclap) or accompanied by high fever or stiff neck',
            'If symptoms persist beyond 48 to 72 hours, a consultation with Neurology is recommended',
          ],
          suggestedFollowUps: const [
            'What should I bring to my appointment?',
            'Can I take home remedies?',
            'Book appointment with Neurology',
          ],
        );
      }

      // 7D. Fever + Additional Symptoms / Timeline (TEST C & TEST F)
      if (allSymptoms.contains('fever')) {
        final hasCoughOrThroat = allSymptoms.contains('cough') || allSymptoms.contains('sore throat');
        if (hasCoughOrThroat && allDuration != null) {
          final presentSyms = ['cough', 'sore throat'].where((s) => allSymptoms.contains(s)).join(', ');
          return ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
            sender: MessageSender.ai,
            text: 'Thank you for the update. You have had a fever for $allDuration, '
                'accompanied by respiratory symptoms ($presentSyms). '
                'When fever and respiratory symptoms persist for several days, a clinical examination of the chest and airways is advisable:',
            timestamp: DateTime.now(),
            recommendation: const SymptomRecommendation(
              department: 'General Medicine',
              doctor: 'Dr. Sarah Khan',
              urgency: 'Routine visit',
              explanation:
                  'General Medicine can examine your respiratory tract, listen to your lungs, and prescribe appropriate therapy.',
              emergency: false,
            ),
            bulletPoints: const [
              'A physical examination helps evaluate for bronchitis or secondary infection',
              'Stay well hydrated with warm liquids and rest your body',
              'Seek urgent care if you develop breathing difficulty, wheezing, or chest tightness',
              'A consultation with General Medicine or Pulmonology is recommended',
            ],
            suggestedFollowUps: const [
              'What should I bring to my appointment?',
              'Can I take home remedies?',
              'Book appointment with General Medicine',
            ],
          );
        } else if (hasCoughOrThroat) {
          return ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
            sender: MessageSender.ai,
            text: 'Thank you for providing the additional details. Experiencing a fever along with a cough and sore throat '
                'strongly indicates an acute upper respiratory infection (such as a viral infection, influenza, or pharyngitis):',
            timestamp: DateTime.now(),
            recommendation: const SymptomRecommendation(
              department: 'General Medicine',
              doctor: 'Dr. Sarah Khan',
              urgency: 'Routine visit',
              explanation:
                  'General Medicine is ideal for managing acute viral infections, fever, and upper respiratory symptoms.',
              emergency: false,
            ),
            bulletPoints: const [
              'Stay well hydrated with clean water, warm teas, and clear broths',
              'Gargle with warm salt water to soothe throat irritation',
              'Monitor your temperature twice daily with a digital thermometer',
              'Seek prompt medical care if symptoms worsen or if fever exceeds 102°F (39°C)',
            ],
            suggestedFollowUps: const [
              'What should I bring to my appointment?',
              'Can I take home remedies?',
              'Book appointment with General Medicine',
            ],
          );
        } else if (allDuration != null) {
          return ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
            sender: MessageSender.ai,
            text: 'Thank you for clarifying the timeline ($currentText). Understanding that your fever started $allDuration '
                'helps assess the course of illness. Acute fever often indicates an active immune response to a viral or bacterial pathogen:',
            timestamp: DateTime.now(),
            recommendation: const SymptomRecommendation(
              department: 'General Medicine',
              doctor: 'Dr. Sarah Khan',
              urgency: 'Routine visit',
              explanation:
                  'General Medicine can evaluate fever duration, systemic infection markers, and provide supportive care.',
              emergency: false,
            ),
            bulletPoints: const [
              'Record your body temperature twice daily in a log',
              'Maintain high fluid intake to prevent dehydration from fever',
              'Seek urgent medical care if you experience chills, breathing difficulties, or lethargy',
            ],
            suggestedFollowUps: const [
              'Do you have any other symptoms like cough or body ache?',
              'Can I take home remedies?',
              'Book appointment with General Medicine',
            ],
          );
        }
      }

      // 7E. Other Specialist Symptoms
      if (allSymptoms.contains('stomach pain') || allSymptoms.contains('vomiting/nausea')) {
        return ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
          sender: MessageSender.ai,
          text: 'I understand you are experiencing stomach pain or gastrointestinal discomfort. '
              'Based on what you have described, Gastroenterology may be an appropriate department to consult:',
          timestamp: DateTime.now(),
          recommendation: const SymptomRecommendation(
            department: 'Gastroenterology',
            doctor: 'Dr. Emily Joseph',
            urgency: 'Routine visit',
            explanation: 'A gastroenterologist examines digestive health, stomach pain, and gastrointestinal symptoms.',
            emergency: false,
          ),
          bulletPoints: const [
            'Note whether the discomfort is sharp, cramping, or dull',
            'Observe if the pain relates to eating meals or fasting',
            'Seek urgent medical attention if you experience severe persistent vomiting or high fever',
          ],
          suggestedFollowUps: const [
            'What should I bring to my appointment?',
            'Can I take home remedies?',
            'Book appointment with Gastroenterology',
          ],
        );
      }

      if (allSymptoms.contains('rash') || allLocations.contains('skin')) {
        return ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
          sender: MessageSender.ai,
          text: 'I understand you are experiencing skin symptoms. '
              'Based on what you have described, Dermatology is the most appropriate department to consult:',
          timestamp: DateTime.now(),
          recommendation: const SymptomRecommendation(
            department: 'Dermatology',
            doctor: 'Dr. Emily Joseph',
            urgency: 'Routine visit',
            explanation: 'A dermatologist specializes in skin disorders, rashes, and cutaneous allergies.',
            emergency: false,
          ),
          bulletPoints: const [
            'Avoid scratching or applying harsh medicated creams before your exam',
            'Note when the skin changes or itching began',
            'Seek prompt evaluation if the rash spreads rapidly or is accompanied by fever',
          ],
          suggestedFollowUps: const [
            'What should I bring to my appointment?',
            'How do I book an appointment?',
            'Book appointment with Dermatology',
          ],
        );
      }

      final matched = matchDepartment(currentLower) ?? matchDepartment(priorUserText);
      if (matched != null) {
        return ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
          sender: MessageSender.ai,
          text: 'I understand you are experiencing these symptoms. '
              'Based on what you have described, ${matched.department} may be an appropriate department '
              'to consult for an evaluation.',
          timestamp: DateTime.now(),
          recommendation: matched,
          bulletPoints: const [
            'Track whether your symptoms are constant or come in waves',
            'Note any specific triggers (e.g. food, exertion, posture)',
            'Seek urgent medical attention if symptoms worsen rapidly or cause severe distress',
          ],
          suggestedFollowUps: [
            'What should I bring to my appointment?',
            'Can I take home remedies?',
            'Book appointment with ${matched.department}',
          ],
        );
      }
    }

    // =============================================================
    // 8. GENERAL INQUIRY / NATURAL CLARIFICATION FALLBACK
    // (NOT assuming symptoms! NO General Medicine fallback!)
    // =============================================================
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
      sender: MessageSender.ai,
      text: 'Thank you for reaching out to CareFlow AI regarding: "$currentText". '
          'I am here to assist you with hospital visit navigation, appointment guidelines, '
          'or symptom guidance. Could you please provide a few more details so I can assist you accurately?',
      timestamp: DateTime.now(),
      bulletPoints: const [
        'Ask appointment questions (arrival times, visitor policies, documents to bring)',
        'Describe any health symptoms you are experiencing for department recommendations',
        'Inquire about how to book or manage your consultation in CareFlow',
      ],
      suggestedFollowUps: const [
        'How early should I arrive?',
        'Can I bring a companion?',
        'What should I bring to my appointment?',
        'How do I book an appointment?',
      ],
    );
  }

  String? _extractDuration(String text) {
    final patterns = [
      RegExp(r'before\s+(\d+|a|couple|few)\s+days?', caseSensitive: false),
      RegExp(r'(?:for|since|past|last)?\s*(\d+|a|couple|few)\s+days?', caseSensitive: false),
      RegExp(r'since\s+yesterday', caseSensitive: false),
      RegExp(r'\byesterday\b', caseSensitive: false),
      RegExp(r'since\s+morning', caseSensitive: false),
      RegExp(r'started\s+today', caseSensitive: false),
      RegExp(r'\btoday\b', caseSensitive: false),
      RegExp(r'(?:for|since)?\s*(\d+|a|couple|few)\s+weeks?', caseSensitive: false),
      RegExp(r'(?:for|since)?\s*(\d+|a|couple|few)\s+hours?', caseSensitive: false),
    ];
    for (final pat in patterns) {
      final m = pat.firstMatch(text);
      if (m != null) {
        return m.group(0)!.trim();
      }
    }
    return null;
  }

  List<String> _extractLocations(String text) {
    final locations = <String>[];
    if (_containsAny(text, ['chest', 'in chest', 'in my chest', 'breastbone', 'ribs'])) {
      locations.add('chest');
    }
    if (_containsAny(text, ['lower right', 'lower right side', 'right side of abdomen', 'right lower'])) {
      locations.add('lower right abdomen');
    } else if (_containsAny(text, ['stomach', 'abdomen', 'abdominal', 'belly', 'gut', 'tummy'])) {
      locations.add('stomach/abdomen');
    }
    if (_containsAny(text, ['head', 'headache', 'temple', 'forehead', 'migraine'])) {
      locations.add('head');
    }
    if (_containsAny(text, ['throat', 'sore throat'])) {
      locations.add('throat');
    }
    if (_containsAny(text, ['back', 'spine', 'lower back'])) {
      locations.add('back');
    }
    if (_containsAny(text, ['skin', 'rash'])) {
      locations.add('skin');
    }
    if (_containsAny(text, ['knee', 'joint', 'shoulder', 'leg', 'arm'])) {
      locations.add('joints/limbs');
    }
    return locations;
  }

  List<String> _extractSymptoms(String text) {
    final syms = <String>[];
    if (_containsAny(text, ['chest pain', 'chest discomfort', 'tightness in chest', 'chest pressure', 'chest'])) {
      syms.add('chest discomfort');
    }
    if (_containsAny(text, ['difficulty breathing', 'shortness of breath', 'cannot breathe', "can't breathe", 'breathing problem'])) {
      syms.add('breathing difficulty');
    }
    if (_containsAny(text, ['fever', 'chills', 'high temperature', 'feverish'])) {
      syms.add('fever');
    }
    if (_containsAny(text, ['headache', 'migraine', 'head ache'])) {
      syms.add('headache');
    }
    if (_containsAny(text, ['stomach pain', 'abdominal pain', 'belly pain', 'cramping'])) {
      syms.add('stomach pain');
    }
    if (_containsAny(text, ['vomiting', 'nausea', 'threw up'])) {
      syms.add('vomiting/nausea');
    }
    if (_containsAny(text, ['cough', 'coughing', 'phlegm'])) {
      syms.add('cough');
    }
    if (_containsAny(text, ['sore throat', 'throat pain'])) {
      syms.add('sore throat');
    }
    if (_containsAny(text, ['dizziness', 'dizzy', 'vertigo', 'lightheaded'])) {
      syms.add('dizziness');
    }
    if (_containsAny(text, ['rash', 'itching', 'hives', 'skin allergy'])) {
      syms.add('rash');
    }
    return syms;
  }

  List<String> _extractTriggers(String text) {
    final triggers = <String>[];
    if (_containsAny(text, ['when walking', 'while walking', 'walking', 'on exertion', 'with exercise', 'stair'])) {
      triggers.add('when walking or during physical exertion');
    }
    if (_containsAny(text, ['after eating', 'with food', 'meal'])) {
      triggers.add('after meals');
    }
    if (_containsAny(text, ['at night', 'lying down', 'sleeping'])) {
      triggers.add('at night or while lying down');
    }
    return triggers;
  }

  bool _isGreeting(String text) {
    final greetings = [
      'hi',
      'hello',
      'hey',
      'good morning',
      'good afternoon',
      'good evening',
      'start',
      'help',
    ];
    return greetings.any((g) => text == g || text.startsWith('$g '));
  }

  bool _isGratitude(String text) {
    final words = [
      'thank',
      'thanks',
      'thank you',
      'thx',
      'appreciate',
      'great help',
      'okay thanks',
    ];
    return words.any(text.contains);
  }

  /// Specific symptom-to-department matcher covering all 15 CareFlow departments.
  /// Returns null when no medical symptoms are identified, avoiding false department cards.
  SymptomRecommendation? matchDepartment(String symptoms) {
    final text = symptoms.toLowerCase();

    // 1. Emergency Medicine
    if (_containsWord(text, [
      'severe chest pain',
      'breathing problem',
      'shortness of breath',
      'cannot breathe',
      "can't breathe",
      'unconscious',
      'passed out',
      'severe bleeding',
      'stroke',
      'paralysis',
      'sudden numbness',
      'convulsion',
      'difficulty breathing',
      'heart attack',
      'crushing chest pain',
    ])) {
      return const SymptomRecommendation(
        department: 'Emergency Medicine',
        doctor: 'On-call Emergency Physician',
        urgency: 'Urgent attention',
        explanation:
            'These symptoms need immediate in-person assessment by emergency medical staff.',
        emergency: true,
      );
    }

    // 2. Cardiology
    if (_containsWord(text, [
      'heart',
      'palpitation',
      'palpitations',
      'blood pressure',
      'cardiac',
      'irregular heartbeat',
      'angina',
      'chest pain',
      'chest discomfort',
      'chest tightness',
      'chest pressure',
    ])) {
      return const SymptomRecommendation(
        department: 'Cardiology',
        doctor: 'Dr. Sarah Khan',
        urgency: 'Priority visit',
        explanation:
            'A heart specialist can assess circulation, blood pressure, and cardiovascular health.',
        emergency: false,
      );
    }

    // 3. Neurology
    if (_containsWord(text, [
      'headache',
      'migraine',
      'head ache',
      'seizure',
      'vertigo',
      'tremor',
      'numbness',
      'neurology',
      'neurologist',
      'dizziness',
      'dizzy',
    ])) {
      return const SymptomRecommendation(
        department: 'Neurology',
        doctor: 'Dr. Arjun Mehta',
        urgency: 'Priority visit',
        explanation:
            'A neurologist can evaluate headaches, dizziness, and nerve-related symptoms.',
        emergency: false,
      );
    }

    // 4. Pulmonology
    if (_containsWord(text, [
      'asthma',
      'wheezing',
      'persistent cough',
      'bronchitis',
      'pulmonology',
      'lungs',
    ])) {
      return const SymptomRecommendation(
        department: 'Pulmonology',
        doctor: 'Dr. Sarah Khan',
        urgency: 'Priority visit',
        explanation:
            'A pulmonologist specializes in lung health, airways, and respiratory conditions.',
        emergency: false,
      );
    }

    // 5. Gastroenterology
    if (_containsWord(text, [
      'stomach',
      'abdomen',
      'vomiting',
      'nausea',
      'diarrhea',
      'acidity',
      'digestion',
      'belly pain',
      'constipation',
      'food poisoning',
      'gut',
      'acid reflux',
      'gastric',
      'gastroenterology',
    ]) || text.contains('abdominal')) {
      return const SymptomRecommendation(
        department: 'Gastroenterology',
        doctor: 'Dr. Emily Joseph',
        urgency: 'Routine visit',
        explanation:
            'A gastroenterologist can examine abdominal symptoms, digestion, and stomach health.',
        emergency: false,
      );
    }

    // 6. Pediatrics
    if (_containsWord(text, [
      'child',
      'baby',
      'infant',
      'toddler',
      'pediatric',
      'pediatrics',
      'kid',
      'newborn',
    ])) {
      return const SymptomRecommendation(
        department: 'Pediatrics',
        doctor: 'Dr. Sarah Khan',
        urgency: 'Priority visit',
        explanation:
            'Pediatric specialists provide tailored medical care for children and infants.',
        emergency: false,
      );
    }

    // 7. Orthopedics
    if (_containsWord(text, [
      'bone',
      'joint',
      'joints',
      'back pain',
      'fracture',
      'knee',
      'shoulder',
      'spine',
      'sprain',
      'arthritis',
      'muscle pain',
      'neck pain',
    ])) {
      return const SymptomRecommendation(
        department: 'Orthopedics',
        doctor: 'Dr. Emily Joseph',
        urgency: 'Routine visit',
        explanation:
            'An orthopedic specialist can assess bones, joints, muscles, and mobility.',
        emergency: false,
      );
    }

    // 8. Dermatology
    if (_containsWord(text, [
      'skin',
      'rash',
      'itching',
      'acne',
      'allergy on skin',
      'eczema',
      'hives',
      'lesion',
      'dermatology',
      'dermatologist',
    ])) {
      return const SymptomRecommendation(
        department: 'Dermatology',
        doctor: 'Dr. Emily Joseph',
        urgency: 'Routine visit',
        explanation:
            'A dermatologist specializes in skin disorders, rashes, and cutaneous allergies.',
        emergency: false,
      );
    }

    // 9. ENT (word boundaries so "early" does NOT match "ear"!)
    if (_containsWord(text, [
      'ear',
      'ears',
      'earache',
      'throat',
      'sore throat',
      'nose',
      'sinus',
      'sinuses',
      'tonsil',
      'tonsils',
      'hearing',
      'nasal',
      'blocked nose',
    ])) {
      return const SymptomRecommendation(
        department: 'ENT',
        doctor: 'Dr. Arjun Mehta',
        urgency: 'Routine visit',
        explanation:
            'An ENT specialist assesses ear infections, throat conditions, and nasal or sinus symptoms.',
        emergency: false,
      );
    }

    // 10. Ophthalmology
    if (_containsWord(text, [
      'eye',
      'eyes',
      'vision',
      'blur',
      'red eye',
      'sight',
      'conjunctivitis',
      'watery eyes',
      'eye pain',
    ])) {
      return const SymptomRecommendation(
        department: 'Ophthalmology',
        doctor: 'Dr. Emily Joseph',
        urgency: 'Routine visit',
        explanation:
            'An ophthalmologist specializes in ocular health, vision clarity, and eye exams.',
        emergency: false,
      );
    }

    // 11. Dentistry
    if (_containsWord(text, [
      'tooth',
      'teeth',
      'gum',
      'gums',
      'dental',
      'dentist',
      'toothache',
      'cavity',
      'jaw pain',
    ])) {
      return const SymptomRecommendation(
        department: 'Dentistry',
        doctor: 'Dr. Arjun Mehta',
        urgency: 'Routine visit',
        explanation:
            'A dental specialist treats toothache, gum irritation, and oral hygiene issues.',
        emergency: false,
      );
    }

    // 12. Gynecology
    if (_containsWord(text, [
      'period',
      'periods',
      'menstrual',
      'pregnancy',
      'pregnant',
      'pelvic pain',
      'gynecology',
      'gynecologist',
      'ovary',
    ])) {
      return const SymptomRecommendation(
        department: 'Gynecology',
        doctor: 'Dr. Sarah Khan',
        urgency: 'Routine visit',
        explanation:
            'A gynecologist provides specialized care for reproductive and pelvic health.',
        emergency: false,
      );
    }

    // 13. Psychiatry
    if (_containsWord(text, [
      'anxiety',
      'depression',
      'panic',
      'stress',
      'insomnia',
      'mental health',
      'cannot sleep',
      'psychiatry',
    ])) {
      return const SymptomRecommendation(
        department: 'Psychiatry',
        doctor: 'Dr. Arjun Mehta',
        urgency: 'Routine visit',
        explanation:
            'A mental health specialist offers support for emotional wellbeing, stress, and anxiety.',
        emergency: false,
      );
    }

    // 14. Oncology
    if (_containsWord(text, [
      'tumor',
      'lump',
      'oncology',
      'chemotherapy',
      'cancer',
    ])) {
      return const SymptomRecommendation(
        department: 'Oncology',
        doctor: 'Dr. Sarah Khan',
        urgency: 'Priority visit',
        explanation:
            'An oncology specialist provides expert evaluation for cell growth, lumps, and specialized therapy.',
        emergency: false,
      );
    }

    // 15. General Medicine - ONLY for general systemic symptoms!
    if (_containsWord(text, [
      'fever',
      'chills',
      'cold',
      'flu',
      'infection',
      'weakness',
      'fatigue',
      'body ache',
      'body aches',
      'malaise',
      'sweating',
      'viral',
    ])) {
      return const SymptomRecommendation(
        department: 'General Medicine',
        doctor: 'Dr. Sarah Khan',
        urgency: 'Routine visit',
        explanation:
            'General Medicine can evaluate systemic symptoms, viral conditions, and routine health concerns.',
        emergency: false,
      );
    }

    return null;
  }

  /// Preserved department recommendation logic for backward compatibility.
  SymptomRecommendation recommend(String symptoms) {
    return matchDepartment(symptoms) ??
        const SymptomRecommendation(
          department: 'General Medicine',
          doctor: 'Dr. Sarah Khan',
          urgency: 'Routine visit',
          explanation:
              'General Medicine is a comprehensive first step for assessment and initial triage.',
          emergency: false,
        );
  }

  bool _containsAny(String text, List<String> terms) {
    final lower = text.toLowerCase();
    return terms.any((t) => lower.contains(t.toLowerCase()));
  }
}

