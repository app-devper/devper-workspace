import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/entities/user/user.dart';

class Session {
  final String accessToken;
  final User user;
  final System system;

  Session({
    required this.accessToken,
    required this.user,
    required this.system,
  });
}
