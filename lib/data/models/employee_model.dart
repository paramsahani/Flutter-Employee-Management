class Employee {
  String id;
  String name;
  String email;
  String phone;
  String role;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "phone": phone,
    "role": role,
  };

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      role: json["role"] ?? "",
    );
  }
}
