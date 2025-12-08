String firebaseErrorToTurkish(String errorCode) {
  switch (errorCode) {
    case "invalid-email":
      return "Geçersiz e-posta formatı.";
    case "user-not-found":
      return "Böyle bir kullanıcı bulunamadı.";
    case "wrong-password":
      return "Şifre hatalı.";
    case "user-disabled":
      return "Bu kullanıcı hesabı devre dışı bırakılmış.";
    case "email-already-in-use":
      return "Bu öğrenci numarası ile zaten kayıt olunmuş.";
    case "weak-password":
      return "Şifre çok zayıf. Daha güçlü bir şifre deneyin.";
    case "too-many-requests":
      return "Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin.";
    case "operation-not-allowed":
      return "Bu işlem şu anda aktif değil.";
    default:
      return "Kullanıcı adı veya şifre hatalı.";
  }
}
