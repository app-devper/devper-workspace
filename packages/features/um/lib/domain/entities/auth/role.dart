/// A UM user's permission tier.
///
/// UM owns the ordering (`sessionclient.Role` in um-api), and every service
/// checks a minimum with `AtLeast`. Asking "is this exactly ADMIN?" instead
/// shut SUPER out of screens the server lets it use.
enum Role {
  user('USER'),
  manager('MANAGER'),
  admin('ADMIN'),
  superuser('SUPER');

  const Role(this.wire);

  /// How the role is spelled in a UM token.
  final String wire;

  /// The role [value] names, or null when it names none. An unreadable role
  /// grants nothing.
  static Role? parse(String? value) {
    for (final role in values) {
      if (role.wire == value) return role;
    }
    return null;
  }

  bool atLeast(Role min) => index >= min.index;
}
