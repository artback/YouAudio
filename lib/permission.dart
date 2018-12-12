import 'package:simple_permissions/simple_permissions.dart';

_getPermission(status,Permission perm) {
  if (!status)
    SimplePermissions.requestPermission(perm);
}
Future checkOrActivatePermission(Permission perm){
  return SimplePermissions.checkPermission(perm)
      .then((status) => _getPermission(status,perm));
}
