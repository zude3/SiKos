import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/invoice.dart';
import 'api_client.dart';

class TagihanService {
  TagihanService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  final ApiClient apiClient;

  Future<List<Invoice>> getTagihan() async {
    try {
      final response = await apiClient.dio.get<List<dynamic>>('/tagihan');
      return (response.data ?? const [])
          .map((item) => Invoice.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw ApiClient.exceptionFrom(error);
    }
  }

  Future<Invoice> getTagihanDetail(String id) async {
    try {
      final response = await apiClient.dio.get<Map<String, dynamic>>(
        '/tagihan/$id',
      );
      return Invoice.fromJson(response.data!);
    } catch (error) {
      throw ApiClient.exceptionFrom(error);
    }
  }

  Future<void> uploadBukti(String id, Uint8List bytes, String fileName) async {
    try {
      final extension = fileName.toLowerCase().split('.').last;
      final subtype = switch (extension) {
        'png' => 'png',
        'webp' => 'webp',
        _ => 'jpeg',
      };
      final formData = FormData.fromMap({
        'bukti': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType('image', subtype),
        ),
      });
      await apiClient.dio.post<void>('/tagihan/$id/bukti', data: formData);
    } catch (error) {
      throw ApiClient.exceptionFrom(error);
    }
  }

  Future<void> deleteBukti(String id) async {
    try {
      await apiClient.dio.delete<void>('/tagihan/$id/bukti');
    } catch (error) {
      throw ApiClient.exceptionFrom(error);
    }
  }

  Future<Uint8List> getBukti(String id) async {
    try {
      final response = await apiClient.dio.get<List<int>>(
        '/tagihan/$id/bukti',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    } catch (error) {
      throw ApiClient.exceptionFrom(error);
    }
  }
}
