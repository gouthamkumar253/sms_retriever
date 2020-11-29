import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_maintained/contact.dart';
import 'package:sms_maintained/sms.dart';
import 'package:smsretriever/data/preferences_client.dart';
import 'package:smsretriever/models/custom_message.dart';
import 'package:smsretriever/utils/app_constants.dart';
import 'package:smsretriever/utils/permission_utils.dart';

class SmsRetriever {
  SmsQuery query = SmsQuery();
  List<SmsMessage> messages = <SmsMessage>[];
  final PermissionsUtils permissionsUtils = PermissionsUtils();
  RegExp creditedMatchCheck = RegExp(AppConstants.credited);
  RegExp debitedMatchCheck = RegExp(AppConstants.debited);
  PermissionResult result;
  List<CustomMessage> displayMessages = <CustomMessage>[];

  Future<List<CustomMessage>> returnSavedMessages(String type) async {
    final PreferencesClient _preferencesService = PreferencesClient(
      prefs: await SharedPreferences.getInstance(),
    );

    CustomMessagesList temp = _preferencesService.getInboxMessages();
    List<CustomMessage> savedMessages =
        temp != null ? temp.customMessages : <CustomMessage>[];
    print(savedMessages.toList());
    if (savedMessages != null && savedMessages.isNotEmpty) {
      for (CustomMessage savedMessage in savedMessages) {
        for (CustomMessage currentMessage in displayMessages) {
          if (currentMessage.smsMessage.id == savedMessage.smsMessage.id) {
            displayMessages[displayMessages.indexOf(currentMessage)] =
                savedMessage;
            print(currentMessage.toJson());
          }
        }
      }
    }
    return displayMessages;
  }

  Future<void> saveTaggedInboxImage(CustomMessage message) async {
    final PreferencesClient _preferencesService = PreferencesClient(
      prefs: await SharedPreferences.getInstance(),
    );
    _preferencesService.saveTaggedInboxMessages(message);
    displayMessages = await returnSavedMessages('type');
  }

  Future<CustomMessage> findContact(CustomMessage message) async {
    ContactQuery query = ContactQuery();
    Contact contact = await query.queryContact(message.smsMessage.address);
    if (contact != null && contact.fullName != null) {
      message = message.copyWith(contactName: contact.fullName);
    } else {
      message = message.copyWith(contactName: message.smsMessage.address);
    }
    return message;
  }

  Future<List<CustomMessage>> _rawMessageToCustomMessage(
      List<CustomMessage> displayMessages) async {
    for (SmsMessage rawMessage in messages) {
      CustomMessage message = CustomMessage(
        smsMessage: CustomSmsMessage(
          id: rawMessage.id,
          address: rawMessage.address,
          body: rawMessage.body,
          date: rawMessage.date,
          dateSent: rawMessage.dateSent,
        ),
      );
      message = await findContact(message);
      displayMessages.add(message);
    }
    return displayMessages;
  }

  Future<List<CustomMessage>> fetchInboxMessage() async {
    try {
      result = await permissionsUtils.checkPermissions();
      if (result == PermissionResult.granted) {
        messages = await query.querySms(kinds: [SmsQueryKind.Inbox]);
        displayMessages = await _rawMessageToCustomMessage(displayMessages);
        displayMessages = await returnSavedMessages('inbox');
      }
    } catch (e) {
      print(e.toString());
    }
    return displayMessages;
  }

  Future<List<CustomMessage>> fetchSentMessages() async {
    try {
      result = await permissionsUtils.checkPermissions();

      if (result == PermissionResult.granted) {
        messages = await query.querySms(kinds: [SmsQueryKind.Sent]);
        displayMessages = await _rawMessageToCustomMessage(displayMessages);
        displayMessages = await returnSavedMessages('sent');
      }
    } catch (e) {
      print(e.toString());
    }
    return displayMessages;
  }

  Future<Map<String, List<CustomMessage>>> fetchTransactionalMessages() async {
    Map<String, List<CustomMessage>> transactionalMessages =
        <String, List<CustomMessage>>{
      AppConstants.income: <CustomMessage>[],
      AppConstants.expense: <CustomMessage>[],
    };

    try {
      result = await permissionsUtils.checkPermissions();

      if (result == PermissionResult.granted) {
        messages = await query.querySms(kinds: [SmsQueryKind.Inbox]);
        displayMessages = await _rawMessageToCustomMessage(displayMessages);
        displayMessages = await returnSavedMessages('transaction');
        for (CustomMessage message in displayMessages) {
          if (creditedMatchCheck
              .hasMatch(message.smsMessage.body.toLowerCase())) {
            transactionalMessages[AppConstants.income].add(message);
          } else if (debitedMatchCheck
              .hasMatch(message.smsMessage.body.toLowerCase())) {
            transactionalMessages[AppConstants.expense].add(message);
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return transactionalMessages;
  }

  Future<List<CustomMessage>> fetchTaggedMessages() async {
    try {
      result = await permissionsUtils.checkPermissions();

      if (result == PermissionResult.granted) {
        messages = await query
            .querySms(kinds: [SmsQueryKind.Sent, SmsQueryKind.Inbox]);
        displayMessages = await _rawMessageToCustomMessage(displayMessages);
        displayMessages = await returnSavedMessages('tagged');
      }
    } catch (e) {
      print(e.toString());
    }
    return displayMessages.where((element) => element.tag != null).toList();
  }

  Future<List<String>> fetchTags() async {
    List<String> tags = <String>[];
    try {
      result = await permissionsUtils.checkPermissions();

      if (result == PermissionResult.granted) {
        messages = await query
            .querySms(kinds: [SmsQueryKind.Sent, SmsQueryKind.Inbox]);
        displayMessages = await _rawMessageToCustomMessage(displayMessages);
        displayMessages = await returnSavedMessages('tagged');
      }
    } catch (e) {
      print(e.toString());
    }
    for (CustomMessage message in displayMessages) {
      if (message.tag != null) {
        tags.add(message.tag);
      }
    }
    return tags;
  }
}
