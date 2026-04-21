import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  /// Текущий пользователь
  static User? get currentUser => _auth.currentUser;

  /// Вход через Google
  static Future<User?> signInWithGoogle() async {
    // 1️⃣ Тихий вход (если есть сохранённая сессия GoogleSignIn)
    try {
      final silentUser = await _googleSignIn.signInSilently();
      if (silentUser != null) {
        final googleAuth = await silentUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential =
            await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      // Ошибку тихого входа не считаем фатальной, просто пойдём на обычный вход
    }

    // 2️⃣ Обычный вход (popup). Отмена = null, ошибка = исключение.
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Пользователь закрыл диалог — не ошибка
        return null;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      // Пробрасываем ошибку наверх, чтобы UI мог показать понятное сообщение
      throw Exception('Google sign-in error: $e');
    }
  }

  /// Выход
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
