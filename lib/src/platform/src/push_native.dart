import '../../generated/platform_constants.dart';
import '../../push_notifications/push_notifications.dart';
import '../platform.dart';

class PushNative extends PlatformObject implements Push {
  Future<int?> _handle;

  PushNative(this._handle) : super();

  @override
  Future<DeviceDetails> activate() =>
      invokeRequest<DeviceDetails>(PlatformMethod.pushActivate);

  @override
  Future<String> deactivate() =>
      invokeRequest<String>(PlatformMethod.pushDeactivate);

  @override
  PushAdmin? admin;

  @override
  Future<int?> createPlatformInstance() {
    // if (_client is Realtime) {
    //   return (_client as Realtime).handle;
    // }
    return _handle;
  }
}