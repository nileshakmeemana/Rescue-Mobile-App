import 'package:flutter/material.dart';

/// Global user state — profile image, name, etc.
/// Shared between HomeScreen avatar and ProfileScreen
class UserState extends ChangeNotifier {
  static final UserState _i = UserState._();
  factory UserState() => _i;
  UserState._();

  static const String _defaultName = 'Nilesh Akmeemana';
  static const ImageProvider _defaultProfileImage =
      AssetImage('assets/images/user.png');

  ImageProvider? _profileImage = _defaultProfileImage;
  ImageProvider? get profileImage => _profileImage;

  String _name = _defaultName;
  String get name => _name;

  void setProfileImage(ImageProvider img) {
    _profileImage = img;
    notifyListeners();
  }

  void setName(String n) {
    _name = n;
    notifyListeners();
  }

  void clearProfileImage() {
    _profileImage = _defaultProfileImage;
    notifyListeners();
  }

  void reset() {
    _profileImage = _defaultProfileImage;
    _name = _defaultName;
    notifyListeners();
  }
}