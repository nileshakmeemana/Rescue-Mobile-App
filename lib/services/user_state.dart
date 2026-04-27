import 'package:flutter/material.dart';

/// Global user state — profile image, name, etc.
/// Shared between HomeScreen avatar and ProfileScreen
class UserState extends ChangeNotifier {
  static final UserState _i = UserState._();
  factory UserState() => _i;
  UserState._();

  // Profile image — null means no custom image (show icon)
  MemoryImage? _profileImage;
  MemoryImage? get profileImage => _profileImage;

  String _name = 'Nilesh Akmeemana';
  String get name => _name;

  void setProfileImage(MemoryImage img) {
    _profileImage = img;
    notifyListeners();
  }

  void setName(String n) {
    _name = n;
    notifyListeners();
  }
}
