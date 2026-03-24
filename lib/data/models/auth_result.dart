class AuthResult {
  final bool success;
  final String? message;
  final dynamic data;

  const AuthResult({required this.success, this.message, this.data});

  factory AuthResult.success({String? message, dynamic data}) =>
      AuthResult(success: true, message: message, data: data);

  factory AuthResult.failure(String message) =>
      AuthResult(success: false, message: message);
}