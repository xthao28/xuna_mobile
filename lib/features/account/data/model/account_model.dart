/// Firebase user fields the app uses. Built by the auth data source.
class AccountModel {
  const AccountModel({required this.uid, this.email, this.displayName});

  final String uid;
  final String? email;
  final String? displayName;
}
