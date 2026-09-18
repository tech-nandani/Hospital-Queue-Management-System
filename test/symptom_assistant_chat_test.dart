import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_queue_management/screens/patient/symptom_assistant_screen.dart';
import 'package:hospital_queue_management/screens/patient/widgets/chat_composer.dart';
import 'package:hospital_queue_management/screens/patient/widgets/chat_empty_state.dart';
import 'package:hospital_queue_management/screens/patient/widgets/department_recommendation_card.dart';
import 'package:hospital_queue_management/screens/patient/widgets/urgent_care_card.dart';
import 'package:hospital_queue_management/services/symptom_assistant_service.dart';

void main() {
  setUp(() {
    SymptomAssistantService.instance.simulatedDelay = Duration.zero;
    SymptomAssistantService.instance.resetState();
    SymptomAssistantService.instance.useLocalEngine = true;
  });

  group('CareFlow AI Assistant - Specific Test Cases (Section 14)', () {
    test('TEST 1: "I have a headache." recommends Neurology and relevant guidance', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I have a headache.');

      expect(service.currentMessages.length, 2);
      final aiMsg = service.currentMessages[1];
      expect(aiMsg.sender, MessageSender.ai);
      expect(aiMsg.recommendation, isNotNull);
      expect(aiMsg.recommendation!.department, 'Neurology');
      expect(aiMsg.recommendation!.emergency, isFalse);
      expect(aiMsg.text, contains('Neurology'));
      expect(aiMsg.bulletPoints, isNotEmpty);
    });

    test('TEST 2: "I have stomach pain and vomiting." recommends Gastroenterology', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I have stomach pain and vomiting.');

      expect(service.currentMessages.length, 2);
      final aiMsg = service.currentMessages[1];
      expect(aiMsg.sender, MessageSender.ai);
      expect(aiMsg.recommendation, isNotNull);
      expect(aiMsg.recommendation!.department, 'Gastroenterology');
      expect(aiMsg.recommendation!.emergency, isFalse);
      expect(aiMsg.text, contains('Gastroenterology'));
    });

    test('TEST 3: "What should I bring to my appointment?" provides checklist with NO department card', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('What should I bring to my appointment?');

      expect(service.currentMessages.length, 2);
      final aiMsg = service.currentMessages[1];
      expect(aiMsg.sender, MessageSender.ai);
      // Must NOT recommend General Medicine or any department card
      expect(aiMsg.recommendation, isNull);
      expect(aiMsg.text, contains('bring the following items'));
      expect(aiMsg.bulletPoints.any((bp) => bp.contains('photo ID') || bp.contains('ID')), isTrue);
      expect(aiMsg.bulletPoints.any((bp) => bp.contains('medication') || bp.contains('records')), isTrue);
    });

    test('TEST 4: "Can I take home remedies?" provides safe home guidance with NO department card', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('Can I take home remedies?');

      expect(service.currentMessages.length, 2);
      final aiMsg = service.currentMessages[1];
      expect(aiMsg.sender, MessageSender.ai);
      // Must NOT recommend General Medicine or any department card
      expect(aiMsg.recommendation, isNull);
      expect(aiMsg.text, contains('Supportive home care'));
      expect(aiMsg.bulletPoints.any((bp) => bp.contains('hydrated')), isTrue);
    });

    test('TEST 5: "How do I book an appointment?" explains CareFlow booking flow with NO department card', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('How do I book an appointment?');

      expect(service.currentMessages.length, 2);
      final aiMsg = service.currentMessages[1];
      expect(aiMsg.sender, MessageSender.ai);
      // Must NOT recommend General Medicine or any department card
      expect(aiMsg.recommendation, isNull);
      expect(aiMsg.text, contains('Book Appointment'));
      expect(aiMsg.text, contains('queue token'));
    });

    test('TEST 6: "Which department should I visit?" uses conversation symptoms context', () async {
      final service = SymptomAssistantService.instance;
      // First turn: discuss headache
      await service.sendMessage('I have a severe headache and dizziness');
      expect(service.currentMessages.length, 2);

      // Second turn: asks which department
      await service.sendMessage('Which department should I visit?');
      expect(service.currentMessages.length, 4);

      final aiMsg = service.currentMessages[3];
      expect(aiMsg.sender, MessageSender.ai);
      expect(aiMsg.recommendation, isNotNull);
      expect(aiMsg.recommendation!.department, 'Neurology');
      expect(aiMsg.text, contains('Neurology'));
    });

    test('TEST 7: "I am having severe difficulty breathing." prioritizes Urgent Emergency care', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I am having severe difficulty breathing.');

      expect(service.currentMessages.length, 2);
      final aiMsg = service.currentMessages[1];
      expect(aiMsg.sender, MessageSender.ai);
      expect(aiMsg.isEmergency, isTrue);
      expect(aiMsg.recommendation, isNotNull);
      expect(aiMsg.recommendation!.department, 'Emergency Medicine');
      expect(aiMsg.recommendation!.emergency, isTrue);
      expect(aiMsg.bulletPoints.any((bp) => bp.contains('108') || bp.contains('112')), isTrue);
    });

    test('TEST 8: Contextual timeline follow-up ("I have fever" then "Since yesterday.")', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I have fever');
      expect(service.currentMessages.length, 2);

      await service.sendMessage('Since yesterday.');
      expect(service.currentMessages.length, 4);

      final secondUserMsg = service.currentMessages[2];
      final secondAiMsg = service.currentMessages[3];
      expect(secondUserMsg.text, 'Since yesterday.');
      expect(secondAiMsg.sender, MessageSender.ai);
      expect(secondAiMsg.text, contains('timeline'));
      expect(secondAiMsg.text, contains('Since yesterday.'));
      // Follow-up recognizes fever context and routes to General Medicine appropriately
      expect(secondAiMsg.recommendation, isNotNull);
      expect(secondAiMsg.recommendation!.department, 'General Medicine');
    });

    test('TEST 9: Non-medical question politely redirects without fake medical advice', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('What is the weather today?');

      expect(service.currentMessages.length, 2);
      final aiMsg = service.currentMessages[1];
      expect(aiMsg.recommendation, isNull);
      expect(aiMsg.text, contains('CareFlow Healthcare AI Assistant'));
      expect(aiMsg.text, contains('cannot assist with general non-medical topics'));
    });

    test('TEST 10: API failure shows error bubble with Retry and NO fake medical advice', () async {
      final service = SymptomAssistantService.instance;
      service.useLocalEngine = false; // Connect to API
      service.chatApiHandler = ({required message, history, token}) async {
        throw Exception('Network unreachable or server offline');
      };

      await service.sendMessage('I have a cough');

      expect(service.currentMessages.length, 2);
      final errAiMsg = service.currentMessages[1];
      expect(errAiMsg.isError, isTrue);
      expect(errAiMsg.recommendation, isNull);
      expect(errAiMsg.text, contains("Sorry, I couldn't process"));
      expect(errAiMsg.suggestedFollowUps, contains('Try again'));
    });

    test('TEST 11: New Chat starts fresh conversation without carrying over recommendations', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I have skin rash and itching');
      expect(service.currentMessages.length, 2);
      expect(service.currentMessages[1].recommendation?.department, 'Dermatology');

      service.createNewSession();
      expect(service.currentMessages, isEmpty);
      expect(service.currentSession.title, 'New conversation');
    });

    test('FOLLOW-UP FIX: "What should I tell the emergency team?" then "before 3 days and in chest"', () async {
      final service = SymptomAssistantService.instance;
      // Step 1: User asks what to tell emergency team
      await service.sendMessage('What should I tell the emergency team?');
      expect(service.currentMessages.length, 2);
      expect(service.currentMessages[1].text, contains('emergency response team'));
      expect(service.currentMessages[1].recommendation, isNull);

      // Step 2: User replies with duration + location
      await service.sendMessage('before 3 days and in chest');
      expect(service.currentMessages.length, 4);

      final followUpAiMsg = service.currentMessages[3];
      expect(followUpAiMsg.sender, MessageSender.ai);
      // AI must understand chest discomfort starting ~3 days ago
      expect(followUpAiMsg.text, contains('chest'));
      expect(followUpAiMsg.text, contains('before 3 days'));
      expect(followUpAiMsg.text, contains('difficulty breathing'));
      expect(followUpAiMsg.recommendation, isNotNull);
      expect(followUpAiMsg.recommendation!.department, 'Cardiology');
      expect(followUpAiMsg.recommendation!.urgency, 'Priority visit');
    });

    test('TEST A: Headache follow-up ("I have a headache." then "Since yesterday.")', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I have a headache.');
      expect(service.currentMessages.length, 2);

      await service.sendMessage('Since yesterday.');
      expect(service.currentMessages.length, 4);

      final aiMsg = service.currentMessages[3];
      expect(aiMsg.text.toLowerCase(), contains('headache'));
      expect(aiMsg.text.toLowerCase(), contains('since yesterday'));
      expect(aiMsg.recommendation, isNotNull);
      expect(aiMsg.recommendation!.department, 'Neurology');
    });

    test('TEST B: Stomach pain location ("I have stomach pain." then "Lower right side.")', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I have stomach pain.');
      expect(service.currentMessages.length, 2);

      await service.sendMessage('Lower right side.');
      expect(service.currentMessages.length, 4);

      final aiMsg = service.currentMessages[3];
      expect(aiMsg.text.toLowerCase(), contains('lower right'));
      expect(aiMsg.recommendation, isNotNull);
      expect(aiMsg.recommendation!.department, 'Gastroenterology');
      expect(aiMsg.bulletPoints.any((bp) => bp.toLowerCase().contains('appendicitis')), isTrue);
    });

    test('TEST C: Fever additional symptoms ("I have fever." then "Cough and sore throat.")', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I have fever.');
      expect(service.currentMessages.length, 2);

      await service.sendMessage('Cough and sore throat.');
      expect(service.currentMessages.length, 4);

      final aiMsg = service.currentMessages[3];
      expect(aiMsg.text.toLowerCase(), contains('cough'));
      expect(aiMsg.text.toLowerCase(), contains('respiratory'));
      expect(aiMsg.recommendation, isNotNull);
      expect(aiMsg.recommendation!.department, 'General Medicine');
    });

    test('TEST D: General question ("What should I bring to my appointment?")', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('What should I bring to my appointment?');
      expect(service.currentMessages.length, 2);

      final aiMsg = service.currentMessages[1];
      expect(aiMsg.recommendation, isNull);
      expect(aiMsg.bulletPoints, isNotEmpty);
      expect(aiMsg.bulletPoints.any((b) => b.contains('photo ID') || b.contains('ID')), isTrue);
    });

    test('TEST E: Emergency ("I have severe chest pain and difficulty breathing.")', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I have severe chest pain and difficulty breathing.');
      expect(service.currentMessages.length, 2);

      final aiMsg = service.currentMessages[1];
      expect(aiMsg.isEmergency, isTrue);
      expect(aiMsg.recommendation, isNotNull);
      expect(aiMsg.recommendation!.department, 'Emergency Medicine');
      expect(aiMsg.recommendation!.emergency, isTrue);
    });

    test('TEST F: Multi-turn ("I have fever." then "3 days." then "Cough.")', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I have fever.');
      expect(service.currentMessages.length, 2);

      await service.sendMessage('3 days.');
      expect(service.currentMessages.length, 4);

      await service.sendMessage('Cough.');
      expect(service.currentMessages.length, 6);

      final aiMsg = service.currentMessages[5];
      expect(aiMsg.text.toLowerCase(), contains('fever'));
      expect(aiMsg.text.toLowerCase(), contains('3 days'));
      expect(aiMsg.text.toLowerCase(), contains('cough'));
      expect(aiMsg.recommendation, isNotNull);
      expect(aiMsg.recommendation!.department, 'General Medicine');
    });

    test('API PAYLOAD: ensures history payload maps roles and does NOT duplicate current message', () async {
      final service = SymptomAssistantService.instance;
      service.useLocalEngine = false;

      List<Map<String, dynamic>>? capturedHistory;
      String? capturedMessage;

      service.chatApiHandler = ({required message, history, token}) async {
        capturedMessage = message;
        capturedHistory = history;
        return {
          'text': 'API response received successfully.',
          'department': 'Cardiology',
          'is_emergency': false,
        };
      };

      // Turn 1
      await service.sendMessage('I have chest discomfort.');
      expect(capturedMessage, 'I have chest discomfort.');
      expect(capturedHistory, isEmpty);

      // Turn 2
      await service.sendMessage('before 3 days and in chest');
      expect(capturedMessage, 'before 3 days and in chest');
      expect(capturedHistory, isNotNull);
      // History should have exactly Turn 1 user message and Turn 1 AI message
      expect(capturedHistory!.length, 2);
      expect(capturedHistory![0]['role'], 'user');
      expect(capturedHistory![0]['content'], 'I have chest discomfort.');
      expect(capturedHistory![1]['role'], 'assistant');
      expect(capturedHistory![1]['content'], 'API response received successfully.');

      // Verify Turn 2 message is NOT in capturedHistory
      expect(capturedHistory!.any((h) => h['content'] == 'before 3 days and in chest'), isFalse);
    });

    test('RECENT CHAT: selecting an existing chat preserves its own conversation context', () async {
      final service = SymptomAssistantService.instance;
      service.useLocalEngine = true;

      // Chat 1: Headache
      await service.sendMessage('I have a headache.');
      final chat1Id = service.activeSessionId!;
      expect(service.currentMessages.length, 2);

      // Chat 2: Stomach pain
      service.createNewSession();
      final chat2Id = service.activeSessionId!;
      expect(chat2Id, isNot(chat1Id));
      expect(service.currentMessages, isEmpty);

      await service.sendMessage('I have stomach pain.');
      expect(service.currentMessages.length, 2);

      // Switch back to Chat 1
      service.selectSession(chat1Id);
      expect(service.currentMessages.length, 2);
      expect(service.currentMessages[0].text, 'I have a headache.');

      // Follow up in Chat 1: Since yesterday
      await service.sendMessage('Since yesterday.');
      expect(service.currentMessages.length, 4);
      expect(service.currentMessages[3].recommendation?.department, 'Neurology');

      // Switch back to Chat 2 and verify it is untainted by Chat 1
      service.selectSession(chat2Id);
      expect(service.currentMessages.length, 2);
      expect(service.currentMessages[0].text, 'I have stomach pain.');
    });
  });

  group('EXACT TEST SEQUENCE (Section 15)', () {
    test('Sequence 1 to 6 executed consecutively within the same session', () async {
      final service = SymptomAssistantService.instance;

      // TEST 1: User: "I have a headache."
      await service.sendMessage('I have a headache.');
      expect(service.currentMessages.length, 2);
      final m1 = service.currentMessages[1];
      expect(m1.recommendation?.department, 'Neurology');
      expect(m1.recommendation?.emergency, isFalse);
      expect(m1.text.toLowerCase(), contains('neurology'));

      // TEST 2: User: "Since yesterday."
      await service.sendMessage('Since yesterday.');
      expect(service.currentMessages.length, 4);
      final m2 = service.currentMessages[3];
      expect(m2.text.toLowerCase(), contains('yesterday'));
      expect(m2.recommendation?.department, 'Neurology');

      // TEST 3: User: "How early should I arrive for my appointment?"
      // Context has headache, but this is an appointment arrival question!
      // Must NOT say "I understand you are experiencing these symptoms..."
      // Must NOT recommend ENT or General Medicine or Neurology!
      // Must NOT show a department card!
      await service.sendMessage('How early should I arrive for my appointment?');
      expect(service.currentMessages.length, 6);
      final m3 = service.currentMessages[5];
      expect(m3.recommendation, isNull);
      expect(m3.text, contains('15 to 20 minutes'));
      expect(m3.text.toLowerCase(), isNot(contains('i understand you are experiencing these symptoms')));
      expect(m3.text.toLowerCase(), isNot(contains('headache')));
      expect(RegExp(r'\bENT\b', caseSensitive: false).hasMatch(m3.text), isFalse);

      // TEST 4: User: "Can I bring a companion?"
      // Answer companion/visitor question.
      // Do NOT ask "Where are you feeling discomfort?"
      // Do NOT recommend a department.
      await service.sendMessage('Can I bring a companion?');
      expect(service.currentMessages.length, 8);
      final m4 = service.currentMessages[7];
      expect(m4.recommendation, isNull);
      expect(m4.text.toLowerCase(), contains('companion'));
      expect(m4.text.toLowerCase(), isNot(contains('where are you feeling discomfort')));

      // TEST 5: User: "What should I bring to my appointment?"
      // Answer appointment preparation question.
      // NO department recommendation.
      await service.sendMessage('What should I bring to my appointment?');
      expect(service.currentMessages.length, 10);
      final m5 = service.currentMessages[9];
      expect(m5.recommendation, isNull);
      expect(m5.bulletPoints.any((b) => b.contains('photo ID') || b.contains('ID')), isTrue);

      // TEST 6: User: "I have severe chest pain and difficulty breathing."
      // Urgent/emergency guidance.
      // NO routine department recommendation as primary response.
      await service.sendMessage('I have severe chest pain and difficulty breathing.');
      expect(service.currentMessages.length, 12);
      final m6 = service.currentMessages[11];
      expect(m6.isEmergency, isTrue);
      expect(m6.recommendation?.emergency, isTrue);
      expect(m6.recommendation?.department, 'Emergency Medicine');

      // TEST 7: New Chat: User: "What department should I visit for stomach pain?"
      service.createNewSession();
      await service.sendMessage('What department should I visit for stomach pain?');
      expect(service.currentMessages.length, 2);
      final m7 = service.currentMessages[1];
      expect(m7.recommendation?.department, 'Gastroenterology');
      expect(m7.recommendation?.emergency, isFalse);
    });

    test('Fresh chat arrival query "How early should I arrive?" has NO ENT, NO General Medicine', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('How early should I arrive?');
      expect(service.currentMessages.length, 2);
      final m = service.currentMessages[1];
      expect(m.recommendation, isNull);
      expect(m.text, contains('15 to 20 minutes'));
      expect(RegExp(r'\bENT\b', caseSensitive: false).hasMatch(m.text), isFalse);
      expect(m.text.toLowerCase(), isNot(contains('general medicine')));
    });
  });

  group('SymptomAssistantScreen Widget Tests', () {
    testWidgets('Renders empty state with greeting and 4 suggestion chips', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SymptomAssistantScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI Care Assistant'), findsWidgets);
      expect(find.text("Hi! I'm CareFlow AI."), findsOneWidget);
      expect(find.byType(ChatEmptyState), findsOneWidget);
      expect(find.text('I have a fever'), findsOneWidget);
      expect(find.text('I have a headache'), findsOneWidget);
      expect(find.text('I have stomach pain'), findsOneWidget);
      expect(find.text("I'm having breathing problems"), findsOneWidget);
      expect(find.byType(ChatComposer), findsOneWidget);
    });

    testWidgets('Tapping prompt chip sends message and renders chat bubbles', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SymptomAssistantScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "I have a fever" prompt chip
      await tester.tap(find.text('I have a fever'));
      await tester.pumpAndSettle();

      // Empty state should be replaced by message bubbles
      expect(find.byType(ChatEmptyState), findsNothing);
      expect(find.text('CareFlow AI'), findsWidgets);
      expect(find.byType(DepartmentRecommendationCard), findsOneWidget);
      expect(find.text('Suggested Department'), findsOneWidget);
      expect(find.text('General Medicine'), findsWidgets);

      // Scroll up to view the user message that auto-scroll moved past
      await tester.drag(find.byType(ListView).first, const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(find.text('I have a fever'), findsOneWidget);
    });

    testWidgets('Non-symptom query ("What should I bring?") does NOT render DepartmentRecommendationCard', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SymptomAssistantScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'What should I bring with me to my appointment?',
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();

      // Verify NO department recommendation card is shown
      expect(find.byType(DepartmentRecommendationCard), findsNothing);
      expect(find.text('Suggested Department'), findsNothing);
      expect(find.textContaining('bring the following items'), findsOneWidget);
    });

    testWidgets('Book Appointment CTA invokes onBookAppointment callback', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? bookedDept;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomAssistantScreen(
              onBookAppointment: (dept) {
                bookedDept = dept;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Send symptom via text composer
      await tester.enterText(
        find.byType(TextField),
        'I have skin rash and itching',
      );
      await tester.pump();

      // Tap send button
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();

      expect(find.text('Dermatology'), findsWidgets);
      expect(find.text('Book Appointment'), findsOneWidget);

      await tester.tap(find.text('Book Appointment'));
      await tester.pumpAndSettle();

      expect(find.text('Dermatology'), findsWidgets);
      expect(find.text('Book Appointment'), findsOneWidget);

      await tester.tap(find.text('Book Appointment'));
      await tester.pumpAndSettle();

      expect(bookedDept, 'Dermatology');
    });

    testWidgets('Emergency symptoms trigger Red Emergency Response Card with 108/112 buttons and NO Book Appointment', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SymptomAssistantScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Severe chest pain and cannot breathe',
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();

      // Renders UrgentCareCard
      expect(find.byType(UrgentCareCard), findsOneWidget);

      // Distinct Red Card Headings
      expect(find.text('URGENT MEDICAL ATTENTION'), findsWidgets);
      expect(find.text('Urgent Care Alert'), findsOneWidget);

      // Emergency Action Buttons
      expect(find.text('Call Emergency — 108'), findsOneWidget);
      expect(find.text('National SOS — 112'), findsOneWidget);

      // Note is visible
      expect(find.text('If symptoms are severe or worsening, call emergency services now.'), findsOneWidget);

      // CRITICAL: NO Book Appointment button for emergencies!
      expect(find.text('Book Appointment'), findsNothing);

      // Tap emergency call button safely
      await tester.tap(find.text('Call Emergency — 108'));
      await tester.pumpAndSettle();
    });
  });

  group('CAREFlow AI Assistant - Emergency Response UI & Action Tests (Section 19)', () {
    test('TEST 1 — NORMAL: "I have a mild headache." returns normal AI response without red emergency card', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I have a mild headache.');

      expect(service.currentMessages.length, 2);
      final aiMsg = service.currentMessages[1];
      expect(aiMsg.isEmergency, isFalse);
      expect(aiMsg.recommendation, isNotNull);
      expect(aiMsg.recommendation!.emergency, isFalse);
      expect(aiMsg.recommendation!.department, 'Neurology');
    });

    test('TEST 2 — NORMAL APPOINTMENT: "How early should I arrive?" returns arrival answer without emergency UI or department card', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('How early should I arrive?');

      expect(service.currentMessages.length, 2);
      final aiMsg = service.currentMessages[1];
      expect(aiMsg.isEmergency, isFalse);
      expect(aiMsg.recommendation, isNull);
      expect(aiMsg.text, contains('15 to 20 minutes'));
    });

    test('TEST 3 — SERIOUS: "I\'m having severe difficulty breathing." triggers RED emergency card with 108/112 buttons and NO Book Appointment', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage("I'm having severe difficulty breathing.");

      expect(service.currentMessages.length, 2);
      final aiMsg = service.currentMessages[1];
      expect(aiMsg.isEmergency, isTrue);
      expect(aiMsg.recommendation?.emergency, isTrue);
      expect(aiMsg.recommendation?.department, contains('Emergency'));
      expect(aiMsg.text.toLowerCase(), contains('difficulty breathing'));
      expect(aiMsg.bulletPoints.any((b) => b.contains('108') || b.contains('112')), isTrue);
    });

    test('TEST 4 — SERIOUS COMBINATION: "I have severe chest pain and difficulty breathing." triggers emergency response and call actions', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage('I have severe chest pain and difficulty breathing.');

      expect(service.currentMessages.length, 2);
      final aiMsg = service.currentMessages[1];
      expect(aiMsg.isEmergency, isTrue);
      expect(aiMsg.recommendation?.emergency, isTrue);
      expect(aiMsg.text.toLowerCase(), contains('chest'));
      expect(aiMsg.text.toLowerCase(), contains('breathing'));
    });

    test('TEST 5 — EMERGENCY FOLLOW-UP: "I have chest pain." then "I am also struggling to breathe." escalates to emergency response', () async {
      final service = SymptomAssistantService.instance;
      // Turn 1: Chest pain
      await service.sendMessage('I have chest pain.');
      expect(service.currentMessages.length, 2);
      expect(service.currentMessages[1].isEmergency, isFalse);
      expect(service.currentMessages[1].recommendation?.department, 'Cardiology');

      // Turn 2: Struggling to breathe follow-up
      await service.sendMessage('I am also struggling to breathe.');
      expect(service.currentMessages.length, 4);
      final followUpAiMsg = service.currentMessages[3];
      expect(followUpAiMsg.isEmergency, isTrue);
      expect(followUpAiMsg.recommendation?.emergency, isTrue);
      expect(followUpAiMsg.text.toLowerCase(), contains('emergency'));
      expect(followUpAiMsg.text.toLowerCase(), contains('breathing'));
    });

    test('TEST 6 — NORMAL AFTER EMERGENCY: "How do I change my profile?" after emergency conversation does NOT trigger emergency UI', () async {
      final service = SymptomAssistantService.instance;
      // Emergency turn
      await service.sendMessage('I have severe chest pain and difficulty breathing.');
      expect(service.currentMessages.length, 2);
      expect(service.currentMessages[1].isEmergency, isTrue);

      // Unrelated account question
      await service.sendMessage('How do I change my profile?');
      expect(service.currentMessages.length, 4);
      final profileAiMsg = service.currentMessages[3];
      expect(profileAiMsg.isEmergency, isFalse);
      expect(profileAiMsg.recommendation, isNull);
      expect(profileAiMsg.text.toLowerCase(), contains('profile'));
    });

    test('Active emergency blocks routine booking ("Can I book an appointment for this?")', () async {
      final service = SymptomAssistantService.instance;
      await service.sendMessage("I'm having severe difficulty breathing.");
      expect(service.currentMessages.length, 2);
      expect(service.currentMessages[1].isEmergency, isTrue);

      await service.sendMessage('Can I book an appointment for this?');
      expect(service.currentMessages.length, 4);
      final bookingMsg = service.currentMessages[3];
      expect(bookingMsg.isEmergency, isTrue);
      expect(bookingMsg.text.toLowerCase(), contains('routine appointment is not advised'));
      expect(bookingMsg.text.toLowerCase(), contains('immediate emergency'));
    });
  });
}
