/// Validasi awal di perangkat. Validasi akun tetap wajib dilakukan oleh server.
abstract final class SignupValidation {
  static String? name(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Isi nama lengkapmu.';
    if (text.length > 150) return 'Nama maksimal 150 karakter.';
    return null;
  }

  static String? username(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Isi username.';
    if (!RegExp(r'^[A-Za-z0-9_.-]{3,30}$').hasMatch(text)) {
      return 'Gunakan 3–30 huruf, angka, titik, _ atau -.';
    }
    return null;
  }

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.length > 150 ||
        text.codeUnits.any((unit) => unit > 127) ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
      return 'Masukkan email yang valid.';
    }
    return null;
  }

  static bool hasUppercase(String value) => RegExp(r'[A-Z]').hasMatch(value);
  static bool hasNumber(String value) => RegExp(r'[0-9]').hasMatch(value);
  static bool hasSymbol(String value) => RegExp(r'[^\w\s]|_').hasMatch(value);

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Buat kata sandi.';
    if (text.length < 8) return 'Gunakan minimal 8 karakter.';
    if (!hasUppercase(text)) return 'Tambahkan huruf kapital.';
    if (!hasNumber(text)) return 'Tambahkan angka.';
    if (!hasSymbol(text)) return 'Tambahkan simbol.';
    return null;
  }

  static String? confirmation(String? value, String password) {
    if (value == null || value.isEmpty) return 'Ulangi kata sandi.';
    if (value != password) return 'Kata sandi belum cocok.';
    return null;
  }
}
