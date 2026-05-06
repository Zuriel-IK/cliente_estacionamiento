import 'package:dio/dio.dart';
import '../../models/auth_model.dart';

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      String serverMessage = 'No fue posible iniciar sesión';

      if (responseData is Map<String, dynamic>) {
        serverMessage =
            responseData['message']?.toString() ?? serverMessage;
      }

      if (statusCode == 401) {
        throw serverMessage.isNotEmpty
            ? serverMessage
            : 'Correo o contraseña incorrectos';
      }

      if (statusCode == 400) {
        throw serverMessage.isNotEmpty
            ? serverMessage
            : 'Verifica los datos enviados';
      }

      if (statusCode == 403) {
        throw serverMessage.isNotEmpty
            ? serverMessage
            : 'Acceso denegado';
      }

      if (statusCode == 500) {
        throw 'Error interno del servidor';
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw 'Tiempo de espera agotado. Intenta de nuevo';
      }

      if (e.type == DioExceptionType.connectionError) {
        throw 'Error de conexión. Revisa tu internet o el servidor';
      }

      throw serverMessage;
    } catch (_) {
      throw 'Ocurrió un error inesperado al iniciar sesión';
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } on DioException catch (e) {

      rethrow;
    }
  }

  Future<User> getUserProfile() async {
    try {
      final response = await _dio.get('/api/auth/profile');


      if (response.data == null) {
        throw 'Datos de usuario no encontrados';
      }

      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? 'Error inesperado';
    }
  }
}