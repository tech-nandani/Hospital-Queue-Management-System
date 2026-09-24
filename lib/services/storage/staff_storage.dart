import 'staff_storage_stub.dart'
    if (dart.library.html) 'staff_storage_web.dart';

abstract class StaffStorage {
  static List<Map<String, dynamic>> loadApplications() =>
      loadApplicationsImpl();

  static void saveApplications(List<Map<String, dynamic>> applications) =>
      saveApplicationsImpl(applications);

  static Map<String, String?> loadRememberedEmails() =>
      loadRememberedEmailsImpl();

  static void saveRememberedEmails(Map<String, String?> emails) =>
      saveRememberedEmailsImpl(emails);
}
