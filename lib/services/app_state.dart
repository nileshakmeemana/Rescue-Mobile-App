import 'package:flutter/material.dart';

class AppNotification {
  final String id, titlee, message;
  final DateTime time;
  bool isRead;
  AppNotification({required this.id, required this.title,
    required this.message, required this.time, this.isRead = false});
}

const Map<String, List<Map<String, String>>> _regionNumbers = {
  'Colombo': [
    {'number': '119',         'label': 'Sri Lanka Police – Colombo'},
    {'number': '1990',        'label': 'Suwaseriya Ambulanceee'},
    {'number': '110',         'label': 'Fire & Rescue – Colombo'},
    {'number': '011-2691111', 'label': 'National Hospital Colombo'},
    {'number': '011-2432682', 'label': 'Army Head Quarter'},
    {'number': '011-2695728', 'label': 'Blood Bank – Colombo'},
    {'number': '011-2672727', 'label': 'Red Cross Sri Lanka'},
  ],
  'Galle': [
    {'number': '119',         'label': 'Sri Lanka Police – Galle'},
    {'number': '1990',        'label': 'Suwaseriya Ambulance'},
    {'number': '091-2222222', 'label': 'Karapitiya Teaching Hospital'},
    {'number': '091-2234567', 'label': 'Galle Fire Brigade'},
    {'number': '091-2220099', 'label': 'Galle Base Hospital'},
    {'number': '011-2695728', 'label': 'Blood Bank (National)'},
    {'number': '011-2672727', 'label': 'Red Cross Sri Lanka'},
  ],
  'Kandy': [
    {'number': '119',         'label': 'Sri Lanka Police – Kandy'},
    {'number': '1990',        'label': 'Suwaseriya Ambulance'},
    {'number': '081-2223337', 'label': 'Kandy Teaching Hospital'},
    {'number': '081-2234444', 'label': 'Kandy Fire Brigade'},
    {'number': '011-2695728', 'label': 'Blood Bank (National)'},
    {'number': '011-2672727', 'label': 'Red Cross Sri Lanka'},
  ],
  'Maharagama': [
    {'number': '119',         'label': 'Sri Lanka Police – Maharagama'},
    {'number': '1990',        'label': 'Suwaseriya Ambulance'},
    {'number': '011-2850670', 'label': 'Apeksha Hospital Maharagama'},
    {'number': '011-2851010', 'label': 'Maharagama Fire Station'},
    {'number': '011-2695728', 'label': 'Blood Bank (National)'},
    {'number': '011-2672727', 'label': 'Red Cross Sri Lanka'},
  ],
};

const Map<String, List<Map<String, dynamic>>> _regionIncidents = {
  'Colombo': [
    {'location': 'Galle Road, Colombo', 'type': 'Road Accident',
     'description': 'Vehicle collision near Galle Road. Motorcycle rider injured. Emergency services dispatched.', 'hasPin': true},
    {'location': 'Pettah, Colombo', 'type': 'Fire',
     'description': 'Fire at a commercial building in Pettah. Fire brigade on scene. Nearby residents please evacuate.', 'hasPin': true},
  ],
  'Galle': [
    {'location': 'Galle Fort Road', 'type': 'Flood',
     'description': 'Flash flooding near Galle Fort. Roads impassable. Stay indoors.', 'hasPin': true},
  ],
  'Kandy': [
    {'location': 'Kandy Lake Road', 'type': 'Medical',
     'description': 'Medical emergency near Kandy Lake. Ambulance dispatched.', 'hasPin': true},
  ],
  'Maharagama': [
    {'location': 'High Level Road, Maharagama', 'type': 'Accident',
     'description': 'Multi-vehicle accident. 3 injured. Police on scene.', 'hasPin': true},
    {'location': 'Katuwawala, Maharagama', 'type': 'Robbery',
     'description': 'Robbery at a local store. Police notified.', 'hasPin': true},
  ],
};

const Map<String, List<Map<String, dynamic>>> _regionPosts = {
  'Colombo': [
    {'rawTitle': 'Heavy Weather', 'title': 'Heavy Weather →',
     'subtitle': 'Please remain indoors.',
     'fullDesc': 'A heavy weather warning issued in Colombo. Please remain indoors, avoid flooded roads, and stay updated through the app for real-time alerts.',
     'color': 0xFF7CB342},
    {'rawTitle': 'Stay Safe', 'title': 'Stay Safe →',
     'subtitle': 'Stay prepared, stay connected.',
     'fullDesc': 'Stay prepared in Colombo. Keep emergency contacts handy and follow official guidance during emergencies.',
     'color': 0xFFFF9800},
  ],
  'Galle': [
    {'rawTitle': 'Flood Warning', 'title': 'Flood Warning →',
     'subtitle': 'Avoid low-lying areas.',
     'fullDesc': 'Flood warning issued for Galle district. Avoid low-lying coastal areas and stay tuned to official alerts.',
     'color': 0xFF1565C0},
    {'rawTitle': 'Road Closure', 'title': 'Road Closure →',
     'subtitle': 'Galle Fort Road closed.',
     'fullDesc': 'Galle Fort Road closed due to flooding. Use alternative routes via Hikkaduwa highway.',
     'color': 0xFFE53935},
  ],
  'Kandy': [
    {'rawTitle': 'Traffic Alert', 'title': 'Traffic Alert →',
     'subtitle': 'Avoid Kandy city centre.',
     'fullDesc': 'Heavy traffic around Kandy city centre. Plan your travel accordingly.',
     'color': 0xFF6A1B9A},
    {'rawTitle': 'Community Watch', 'title': 'Community Watch →',
     'subtitle': 'Neighbourhood alert active.',
     'fullDesc': 'Community neighbourhood watch is active in Kandy. Report suspicious activity to local police.',
     'color': 0xFF00838F},
  ],
  'Maharagama': [
    {'rawTitle': 'Community Watch', 'title': 'Community Watch →',
     'subtitle': 'Neighbourhood alert active.',
     'fullDesc': 'Community watch active in Maharagama. Report suspicious activity to local police.',
     'color': 0xFF00838F},
    {'rawTitle': 'Road Works', 'title': 'Road Works →',
     'subtitle': 'High Level Road works.',
     'fullDesc': 'Road works on High Level Road near Maharagama junction. Expect delays.',
     'color': 0xFFFF8F00},
  ],
};

const _defaultNumbers = [
  {'number': '119',         'label': 'Sri Lanka Police'},
  {'number': '1990',        'label': 'Suwaseriya Ambulance'},
  {'number': '110',         'label': 'Fire & Rescue'},
  {'number': '011-2691111', 'label': 'General Hospital'},
  {'number': '011-2432682', 'label': 'Army Head Quarter'},
  {'number': '011-2695728', 'label': 'Blood Bank'},
  {'number': '011-2672727', 'label': 'Red Cross'},
];

class AppState extends ChangeNotifier {
  static final AppState _i = AppState._();
  factory AppState() => _i;
  AppState._() { _seedNotifications(); }

  // ── Location & Region ───────────────────────────────────────────────────────
  String _region = '';
  String _locationLabel = '';
  bool get hasLocation => _region.isNotEmpty;
  String get region => _region;
  String get locationLabel => _locationLabel;

  void setLocation(String loc) {
    _locationLabel = loc;
    _region = _match(loc);
    _pushNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Location Updated',
      message: 'Region set to $_region. Emergency numbers and local alerts updated.',
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  String _match(String loc) {
    final l = loc.toLowerCase();
    if (l.contains('galle')) return 'Galle';
    if (l.contains('kandy')) return 'Kandy';
    if (l.contains('maharagama') || l.contains('kalubowila') ||
        l.contains('katuwawala')) return 'Maharagama';
    return 'Colombo';
  }

  // ── SOS Setup ───────────────────────────────────────────────────────────────
  String _policeStation = '';
  String _hospital = '';
  String get policeStation => _policeStation;
  String get hospital => _hospital;

  void setupSOS({required String police, required String hosp,
    required String loc}) {
    _policeStation = police;
    _hospital = hosp;
    setLocation(loc); // also updates region & notifies
  }

  // ── Emergency numbers ───────────────────────────────────────────────────────
  List<Map<String, String>> get emergencyNumbers {
    if (_region.isEmpty) {
      return List<Map<String, String>>.from(
          _defaultNumbers.map((e) => Map<String, String>.from(e)));
    }
    return (_regionNumbers[_region] ?? _defaultNumbers)
        .map((e) => Map<String, String>.from(e))
        .toList();
  }

  // ── Regional incidents ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> get regionalIncidents {
    return (_regionIncidents[_region] ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ── Regional posts ──────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get regionalPosts {
    return (_regionPosts[_region] ?? _regionPosts['Colombo']!)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ── Notifications ───────────────────────────────────────────────────────────
  final List<AppNotification> _notifs = [];
  final List<Map<String, dynamic>> _userIncidents = [];
  final List<Map<String, dynamic>> _userPosts = [];
  List<AppNotification> get notifications =>
      List.unmodifiable(_notifs.reversed.toList());
  int get unreadCount => _notifs.where((n) => !n.isRead).length;

  void _seedNotifications() {
    _notifs.addAll([
      AppNotification(id: 'n1', title: 'Welcome to Rescue',
        message: 'Set up your location to get regional alerts & emergency numbers.',
        time: DateTime.now().subtract(const Duration(hours: 2))),
      AppNotification(id: 'n2', title: 'Road Accident Reported',
        message: 'A road accident has been reported near Galle Road, Colombo.',
        time: DateTime.now().subtract(const Duration(hours: 1))),
      AppNotification(id: 'n3', title: 'Community Alert',
        message: 'Heavy weather warning issued. Stay indoors and stay safe.',
        time: DateTime.now().subtract(const Duration(minutes: 30))),
    ]);
  }

  void addNotification(AppNotification n) {
    _notifs.add(n);
    notifyListeners();
  }

  void _pushNotification(AppNotification n) => _notifs.add(n);

  void markAllRead() {
    for (final n in _notifs) n.isRead = true;
    notifyListeners();
  }

  void markRead(String id) {
    try {
      _notifs.firstWhere((n) => n.id == id).isRead = true;
      notifyListeners();
    } catch (_) {}
  }
}

// ─── Extension: user-generated content stored in AppState ───────────────────
extension UserContent on AppState {
  // User incidents
  List<Map<String, dynamic>> get userIncidents => _userIncidents;
  void addUserIncident(Map<String, dynamic> inc) {
    _userIncidents.add(inc);
    notifyListeners();
  }
  void removeUserIncident(int i) {
    _userIncidents.removeAt(i);
    notifyListeners();
  }

  // User posts
  List<Map<String, dynamic>> get userPosts => _userPosts;
  void addUserPost(Map<String, dynamic> post) {
    _userPosts.insert(0, post);
    notifyListeners();
  }
  void removeUserPost(int i) {
    _userPosts.removeAt(i);
    notifyListeners();
  }
}
