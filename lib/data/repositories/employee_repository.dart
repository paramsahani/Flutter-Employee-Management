import 'package:my_app/core/constants/api_constants.dart';
import 'package:my_app/data/services/network_service.dart';

class EmployeeRepository {
  final _api = NetworkService();

  /// GET (LIST)
  Future<List<Map<String, dynamic>>> getEmployees() async {
    try {
      final res = await _api.get(ApiConstants.getEndpoint);

      final data = res.data;

      if (data == null) return [];

      if (data is List) {
        return data.map<Map<String, dynamic>>((e) {
          return Map<String, dynamic>.from(e);
        }).toList();
      }

      if (data is Map && data["data"] != null) {
        return (data["data"] as List).map<Map<String, dynamic>>((e) {
          return Map<String, dynamic>.from(e);
        }).toList();
      }

      return [];
    } catch (e) {
      throw Exception(e.toString()); //  forward clean error
    }
  }

  ///  ADD
  Future<void> addEmployee(Map<String, dynamic> data) async {
    try {
      await _api.post(ApiConstants.endpoint, data: data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  ///  UPDATE
  Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
    try {
      await _api.put("${ApiConstants.endpoint}/$id", data: data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  ///  DELETE
  Future<void> deleteEmployee(String id) async {
    try {
      await _api.delete("${ApiConstants.endpoint}/$id");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
