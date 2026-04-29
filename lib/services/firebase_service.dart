import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Central Firebase service — all Firestore / Auth / Storage calls live here.
class FirebaseService {
  static final FirebaseService _i = FirebaseService._();
  factory FirebaseService() => _i;
  FirebaseService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Uuid _uuid = const Uuid();

  static const String _pushTopic = 'rescue_all_users';
  static const String _pushPrefKey = 'push_notifications_enabled';

  // ── Auth ──────────────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmailPassword({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      await credential.user!.updateDisplayName(name);
    }

    await createUserProfile(
      name: name,
      email: email,
      address: address,
      phone: phone,
      notificationsEnabled: true,
    );
    await initializePushNotifications();
    return credential;
  }

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await initializePushNotifications();
    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Send OTP to phone number (e.g. "+94771234567")
  Future<void> sendOTP({
    required String phone,
    required void Function(String vId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential cred) async {
        await _auth.signInWithCredential(cred);
      },
      verificationFailed: onError,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Verify OTP and sign in
  Future<UserCredential> verifyOTP(String verificationId, String smsCode) {
    final cred = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(cred);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> deleteCurrentUserAccount() async {
    final user = _auth.currentUser;
    final userId = user?.uid;
    if (user == null || userId == null) return;

    try {
      await _storage.ref('profile_photos/$userId.jpg').delete();
    } catch (_) {}

    await _users.doc(userId).delete();
    await user.delete();
  }

  // ── User Profile ──────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> createUserProfile({
    required String name,
    required String email,
    required String address,
    required String phone,
    bool notificationsEnabled = true,
  }) async {
    if (uid == null) return;
    await _users.doc(uid).set({
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'region': '',
      'policeStation': '',
      'hospital': '',
      'photoURL': '',
      'notificationsEnabled': notificationsEnabled,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (uid == null) return null;
    final snap = await _users.doc(uid).get();
    return snap.data();
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (uid == null) return;
    await _users.doc(uid).set(
      {...data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<bool> arePushNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(_pushPrefKey);
    if (stored != null) return stored;

    final profile = await getUserProfile();
    final enabled = profile?['notificationsEnabled'] as bool? ?? true;
    await prefs.setBool(_pushPrefKey, enabled);
    return enabled;
  }

  Future<void> setPushNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushPrefKey, enabled);

    if (uid != null) {
      await _users.doc(uid).set(
        {
          'notificationsEnabled': enabled,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    if (enabled) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus != AuthorizationStatus.denied) {
        await _messaging.subscribeToTopic(_pushTopic);
      }
    } else {
      await _messaging.unsubscribeFromTopic(_pushTopic);
    }
  }

  Future<void> initializePushNotifications() async {
    if (uid == null) return;

    final enabled = await arePushNotificationsEnabled();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (!enabled) {
      await _messaging.unsubscribeFromTopic(_pushTopic);
      return;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.denied) {
      await _messaging.subscribeToTopic(_pushTopic);
    }
  }

  /// Upload profile photo and return download URL
  Future<String> uploadProfilePhoto(File file) async {
    if (uid == null) throw Exception('Not logged in');
    final ref = _storage.ref('profile_photos/$uid.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  // ── Incidents ─────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection('incidents');

  /// Add incident and return its document ID
  Future<String> addIncident({
    required String type,
    required String description,
    required String location,
    required String region,
    List<String> mediaUrls = const [],
    double? latitude,
    double? longitude,
  }) async {
    final id = _uuid.v4();
    await _incidents.doc(id).set({
      'id': id,
      'type': type,
      'description': description,
      'location': location,
      'region': region,
      'mediaUrls': mediaUrls,
      'locationLat': latitude,
      'locationLng': longitude,
      'reportedBy': uid ?? 'anonymous',
      'hasPin': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  /// Delete own incident
  Future<void> deleteIncident(String id) => _incidents.doc(id).delete();

  /// Stream of incidents for a region (reported by others)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamRegionalIncidents(
          String region) =>
      _incidents
          .where('region', isEqualTo: region)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots();

  /// Stream of incidents reported by current user
  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyIncidents() {
    if (uid == null) return const Stream.empty();
    return _incidents
        .where('reportedBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ── Community Posts ───────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('community_posts');

  Future<String> addPost({
    required String title,
    required String description,
    required String location,
    required String region,
    List<String> mediaUrls = const [],
    double? latitude,
    double? longitude,
  }) async {
    final id = _uuid.v4();
    await _posts.doc(id).set({
      'id': id,
      'rawTitle': title,
      'title': '$title →',
      'subtitle': description.split('\n').first,
      'fullDesc': description,
      'location': location,
      'region': region,
      'mediaUrls': mediaUrls,
      'locationLat': latitude,
      'locationLng': longitude,
      'color': 0xFF4CAF50,
      'postedBy': uid ?? 'anonymous',
      'userAdded': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  Future<void> deletePost(String id) => _posts.doc(id).delete();

  Stream<QuerySnapshot<Map<String, dynamic>>> streamRegionalPosts(
          String region) =>
      _posts
          .where('region', isEqualTo: region)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyPosts() {
    if (uid == null) return const Stream.empty();
    return _posts
        .where('postedBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ── Media Upload ──────────────────────────────────────────────────────────

  Future<String> uploadMedia(File file, String folder) async {
    final id = _uuid.v4();
    final ext = file.path.split('.').last;
    final ref = _storage.ref('$folder/$id.$ext');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _notifs =>
      _db.collection('notifications');

  Future<void> addNotification({
    required String title,
    required String message,
    required String region,
  }) async {
    if (uid == null) return;
    await _notifs.add({
      'userId': uid,
      'title': title,
      'message': message,
      'region': region,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamNotifications() {
    if (uid == null) return const Stream.empty();
    return _notifs
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots();
  }

  Future<void> markNotificationRead(String id) =>
      _notifs.doc(id).update({'isRead': true});

  Future<void> markAllNotificationsRead() async {
    if (uid == null) return;
    final snap = await _notifs
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  static Map<String, dynamic> incidentFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return {
      'id': doc.id,
      'type': d['type'] ?? 'Unknown',
      'description': d['description'] ?? '',
      'location': d['location'] ?? '',
      'locationLat': d['locationLat'],
      'locationLng': d['locationLng'],
      'region': d['region'] ?? '',
      'mediaUrls': List<String>.from(d['mediaUrls'] ?? []),
      'reportedBy': d['reportedBy'] ?? '',
      'hasPin': d['hasPin'] ?? true,
      'createdAt': d['createdAt'],
    };
  }

  static Map<String, dynamic> postFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return {
      'id': doc.id,
      'rawTitle': d['rawTitle'] ?? '',
      'title': d['title'] ?? '',
      'subtitle': d['subtitle'] ?? '',
      'fullDesc': d['fullDesc'] ?? '',
      'location': d['location'] ?? '',
      'locationLat': d['locationLat'],
      'locationLng': d['locationLng'],
      'region': d['region'] ?? '',
      'mediaUrls': List<String>.from(d['mediaUrls'] ?? []),
      'color': d['color'] ?? 0xFF4CAF50,
      'postedBy': d['postedBy'] ?? '',
      'userAdded': d['userAdded'] ?? false,
      'createdAt': d['createdAt'],
    };
  }
}
