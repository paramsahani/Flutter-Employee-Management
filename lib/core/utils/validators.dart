class Validators {
  static final RegExp nameRegex = RegExp(r'^[a-zA-Z ]{2,}$');

  static final RegExp emailRegex = RegExp(
    r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  static final RegExp phoneRegex = RegExp(r'^[0-9]{10}$');

  static String? validateName(String? value) {
    final v = value?.trim() ?? "";

    if (v.isEmpty) return "Name is required";
    if (!nameRegex.hasMatch(v)) return "Enter valid name";

    return null;
  }

  static String? validateEmail(String? value) {
    final v = value?.trim() ?? "";

    if (v.isEmpty) return "Email is required";
    if (!emailRegex.hasMatch(v)) return "Enter valid email";

    return null;
  }

  static String? validatePhone(String? value) {
    final v = value?.trim() ?? "";

    if (v.isEmpty) return "Phone is required";
    if (!phoneRegex.hasMatch(v)) return "Enter 10 digit number";

    return null;
  }

  static String? validateRole(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Role is required";
    }
    return null;
  }
}
