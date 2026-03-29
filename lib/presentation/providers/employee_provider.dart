import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:my_app/data/repositories/employee_repository.dart';

class EmployeeProvider extends ChangeNotifier {
  final repo = EmployeeRepository();

  final localBox = Hive.box('employees');

  List<Map<String, dynamic>> employees = [];

  bool isLoading = false;
  String? error;

  /// LOAD
  Future loadEmployees() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      ///  LOCAL DATA (UI)
      employees = localBox.values.map((e) {
        return Map<String, dynamic>.from(e);
      }).toList();

      ///  API (BACKGROUND)
      await repo.getEmployees();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  ///  ADD
  Future addEmployee(Map<String, dynamic> data) async {
    error = null;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newData = {"id": id, ...data};

    /// LOCAL UPDATE FIRST
    await localBox.put(id, newData);
    employees.insert(0, newData);
    notifyListeners();

    ///  API CALL
    try {
      isLoading = true;
      notifyListeners();

      await repo.addEmployee(data);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///  UPDATE
  Future updateEmployee(String id, Map<String, dynamic> data) async {
    error = null;

    final updated = {"id": id, ...data};

    ///  LOCAL UPDATE
    await localBox.put(id, updated);

    final index = employees.indexWhere((e) => e["id"] == id);
    if (index != -1) {
      employees[index] = updated;
    }

    notifyListeners();

    ///  API CALL
    try {
      isLoading = true;
      notifyListeners();

      await repo.updateEmployee(id, data);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///  DELETE
  Future deleteEmployee(String id) async {
    error = null;

    ///  LOCAL DELETE
    await localBox.delete(id);
    employees.removeWhere((e) => e["id"] == id);
    notifyListeners();

    ///  API CALL
    try {
      isLoading = true;
      notifyListeners();

      await repo.deleteEmployee(id);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
