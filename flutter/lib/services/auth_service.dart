import 'api_client.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  final ApiClient apiClient;

  Future<void> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final token = response.data?['token'];
      if (token is! String || token.isEmpty) {
        throw const ApiException('Token tidak ditemukan pada respons login');
      }
      await apiClient.secureStorage.write(key: 'auth_token', value: token);
    } catch (error) {
      throw ApiClient.exceptionFrom(error);
    }
  }

  Future<void> logout() => apiClient.secureStorage.delete(key: 'auth_token');

  Future<String?> readToken() =>
      apiClient.secureStorage.read(key: 'auth_token');
}
