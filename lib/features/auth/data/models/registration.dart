/// What the user has entered so far in the sign-up flow. Each registration
/// step fills in its part when the user continues past it.
class Registration {
  const Registration({
    this.fullName = '',
    this.email = '',
    this.username = '',
    this.dateOfBirth,
    this.avatar,
    this.interests = const {},
  });

  /// Step 1 (Create Your Account).
  final String fullName;
  final String email;

  /// Step 3 (Secure Your Profile).
  final String username;
  final DateTime? dateOfBirth;

  /// Step 4 (Add a Profile Photo): the chosen preset avatar's asset, or null
  /// when the step was skipped.
  final String? avatar;

  /// "Choose Your Interests"; empty when skipped.
  final Set<String> interests;

  Registration copyWith({
    String? fullName,
    String? email,
    String? username,
    DateTime? dateOfBirth,
    String? avatar,
    bool clearAvatar = false,
    Set<String>? interests,
  }) => Registration(
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    username: username ?? this.username,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    avatar: clearAvatar ? null : (avatar ?? this.avatar),
    interests: interests ?? this.interests,
  );
}
