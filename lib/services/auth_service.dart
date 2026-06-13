import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tenant_management_app/models/user.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─── Trạng thái phiên ────────────────────────────────────────────────────────

  /// Stream lắng nghe thay đổi trạng thái xác thực (dùng trong SessionGate).
  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Kiểm tra xem người dùng đã đăng nhập chưa.
  static bool isLoggedIn() => _auth.currentUser != null;

  /// Trả về UID của người dùng hiện tại.
  static String? getUserId() => _auth.currentUser?.uid;

  /// Trả về vai trò ('admin' hoặc 'tenant') từ Firestore.
  static Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return 'tenant';
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['role'] as String? ?? 'tenant';
  }

  /// Trả về tên hiển thị từ Firestore hoặc Firebase Auth.
  static Future<String> getUserName() async {
    final user = _auth.currentUser;
    if (user == null) return '';
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['fullName'] as String? ??
        user.displayName ??
        user.email?.split('@').first ??
        '';
  }

  /// Lấy UserModel đầy đủ từ Firestore.
  static Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ─── Đăng nhập bằng Email/Password ──────────────────────────────────────────

  /// Đăng nhập bằng email và mật khẩu.
  /// Trả về UserModel nếu thành công, ném exception nếu thất bại.
  static Future<UserModel?> signInWithEmail(
      String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) return null;
    return getCurrentUserModel();
  }

  // ─── Đăng ký bằng Email/Password ────────────────────────────────────────────

  /// Tạo tài khoản mới bằng email/mật khẩu và ghi hồ sơ vào Firestore.
  static Future<UserModel?> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;

    // Cập nhật displayName trên Firebase Auth
    await user.updateDisplayName(fullName);

    // Ghi hồ sơ vào Firestore
    final userModel = UserModel(
      uid: user.uid,
      fullName: fullName,
      email: email,
      phone: phone,
      role: 'tenant', // Mặc định là tenant
      createdAt: DateTime.now(),
      provider: 'email',
    );
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());

    return userModel;
  }

  // ─── Đăng nhập bằng Google ──────────────────────────────────────────────────

  /// Đăng nhập bằng tài khoản Google.
  /// Tạo hồ sơ Firestore nếu là lần đầu đăng nhập.
  static Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // Người dùng huỷ

    final googleAuth = await googleUser.authentication;
    final oauthCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final credential = await _auth.signInWithCredential(oauthCredential);
    final user = credential.user;
    if (user == null) return null;

    // Kiểm tra và tạo/cập nhật hồ sơ Firestore
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Lần đầu đăng nhập → tạo hồ sơ mới
      final userModel = UserModel(
        uid: user.uid,
        fullName: user.displayName ?? googleUser.displayName ?? '',
        email: user.email ?? googleUser.email,
        role: 'tenant',
        createdAt: DateTime.now(),
        provider: 'google',
      );
      await docRef.set(userModel.toFirestore());
      return userModel;
    }

    return UserModel.fromFirestore(doc);
  }

  // ─── Quên mật khẩu ──────────────────────────────────────────────────────────

  /// Gửi email đặt lại mật khẩu.
  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Đổi mật khẩu ───────────────────────────────────────────────────────────

  /// Đổi mật khẩu cho người dùng đang đăng nhập.
  /// Yêu cầu xác thực lại (reauthenticate) trước khi đổi.
  static Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
          code: 'no-user', message: 'Không có người dùng đăng nhập.');
    }

    // Xác thực lại bằng mật khẩu cũ
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Đổi mật khẩu
    await user.updatePassword(newPassword);
  }

  // ─── Đăng xuất ──────────────────────────────────────────────────────────────

  /// Đăng xuất khỏi cả Firebase Auth và Google Sign-In.
  static Future<void> clearSession() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
