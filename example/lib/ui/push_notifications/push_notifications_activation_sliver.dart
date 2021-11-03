import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../push_notifications/push_notification_service.dart';
import '../bool_stream_button.dart';

class PushNotificationsActivationSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;
  final bool isIOSSimulator;

  const PushNotificationsActivationSliver(this._pushNotificationService,
      {required this.isIOSSimulator, Key? key})
      : super(key: key);

  Future<void> showErrorDialog(
      BuildContext context, ably.AblyException error) async {
    await showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(error.message ?? 'No error message'),
      ),
    );
  }

  Future<void> handleActivateDeviceButton(BuildContext context) async {
    try {
      await _pushNotificationService.activateDevice();
      await showPermissionReminder(context);
    } on ably.AblyException catch (error) {
      await showErrorDialog(context, error);
    }
    await _pushNotificationService.getDevice();
  }

  Future<void> handleDeactivateDeviceButton(BuildContext context) async {
    try {
      await _pushNotificationService.deactivateDevice();
    } on ably.AblyException catch (error) {
      await showErrorDialog(context, error);
    }
    await _pushNotificationService.getDevice();
  }

  Widget buildiOSSimulatorWarningText() {
    if (isIOSSimulator) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: RichText(
            text: const TextSpan(children: [
          TextSpan(
              text: 'Warning: ',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          TextSpan(
              text: 'APNs is not available on iOS simulators, so you cannot '
                  'activate the device Ably, since this step requires the'
                  ' APNs device token.',
              style: TextStyle(color: Colors.black))
        ])),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Activation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            // TODO test emulator on Android can receive messages/ activate with Ably
            buildiOSSimulatorWarningText(),
            Row(
              children: [
                Expanded(
                  child: BoolStreamButton(
                      stream: _pushNotificationService.hasPushChannelStream,
                      onPressed: () => handleActivateDeviceButton(context),
                      child: const Text('Activate device')),
                ),
                Expanded(
                  child: BoolStreamButton(
                      stream: _pushNotificationService.hasPushChannelStream,
                      onPressed: () => handleDeactivateDeviceButton(context),
                      child: const Text('Deactivate device')),
                ),
              ],
            ),
            const Text('Once devices are activated, a Push Admin can '
                "send push messages to devices by it's device ID, client ID or "
                'FCM/ APNs token. To send push messages between users, the '
                'device must push-subscribe to the channel and a push payload '
                'is added to the channel message.'),
          ],
        ),
      );

  Future<void> showPermissionReminder(BuildContext context) async {
    if (Platform.isIOS) {
      final authorizationStatus = _pushNotificationService
          .notificationSettingsStream.value.authorizationStatus;
      if (authorizationStatus == ably.UNAuthorizationStatus.notDetermined) {
        await showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Reminder for the developer'),
            content: const Text(
                'You should request permission to show notifications to the '
                'user or a provisional permissions.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  _pushNotificationService.requestNotificationPermission(
                      provisional: true);
                  Navigator.pop(context);
                },
                child: const Text('Request provisional permission'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  _pushNotificationService.requestNotificationPermission();
                  Navigator.pop(context);
                },
                child: const Text('Request permission'),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Do not request permission'),
              ),
            ],
          ),
        );
      } else if (authorizationStatus == ably.UNAuthorizationStatus.denied) {
        await Fluttertoast.showToast(
            msg: 'The user has previously denied notifications from this app.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16);
      }
    }
  }
}