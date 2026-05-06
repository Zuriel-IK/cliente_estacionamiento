import 'package:dio/dio.dart';
import '../../models/dashboard_model.dart';
import '../../models/api_response_model.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository(this._dio);

  Future<DashboardModel> getDashboard() async {
    try {
      final response = await _dio.get('/api/dashboard');

      final apiResponse = ApiResponse<DashboardModel>.fromJson(
        response.data as Map<String, dynamic>,
            (json) => DashboardModel.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.data == null) {
        throw 'Respuesta del servidor sin datos';
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw 'Sesión expirada';
      throw e.response?.data?['message'] ?? 'Error de red';
    }
  }
}