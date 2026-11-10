// External dependencies
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/domain/entities/user/user.dart';

class UserNotifier {
  final BehaviorSubject<User> _userSubject;
  final _logger = sl<Logger>();

  UserNotifier() : _userSubject = BehaviorSubject.seeded(UserModel.empty());

  // Public stream for Cubits to subscribe
  Stream<User> get userStream => _userSubject.stream;

  void updateUser(User user) {
    _logger.d("User notifier updated with: ${user.name}");
    _userSubject.add(user);
  }

  User get currentUser => _userSubject.value;

  /// Forgets the current user. Used when an account is unlinked from the device
  /// (WP #151): a notifier still holding the removed user would sign it back in
  /// on the next screen that reads [currentUser].
  void clear() {
    _logger.d("User notifier cleared");
    _userSubject.add(UserModel.empty());
  }

  void dispose() => _userSubject.close();
}
