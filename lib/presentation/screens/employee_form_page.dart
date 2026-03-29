import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/core/utils/validators.dart';
import 'package:my_app/presentation/widgets/DropdownFormFieldBuilder.dart';
import 'package:my_app/presentation/widgets/SecondaryButton.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/providers/employee_provider.dart';
import 'package:my_app/presentation/widgets/TextFormFieldBuilder.dart';
import 'package:my_app/presentation/widgets/PrimaryButton.dart';

class EmployeeFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const EmployeeFormPage({super.key, this.initialData});

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  String? id;
  String? selectedRole;
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final List<String> roles = [
    "Developer",
    "Software Engineer",
    "Manager",
    "Tester",
    "HR",
  ];
  bool isEdit = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      isEdit = true;

      id = widget.initialData!["id"];

      _name.text = widget.initialData!["name"] ?? "";
      _email.text = widget.initialData!["email"] ?? "";
      _phone.text = widget.initialData!["phone"] ?? "";

      selectedRole = widget.initialData!["role"];
    }
  }

  void resetForm() {
    _name.clear();
    _email.clear();
    _phone.clear();

    selectedRole = null;
    id = null;
    isEdit = false;

    setState(() {});
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<EmployeeProvider>();

    final data = {
      "name": _name.text.trim(),
      "email": _email.text.trim(),
      "phone": _phone.text.trim(),
      "role": selectedRole ?? "",
    };

    if (isEdit) {
      await provider.updateEmployee(id!, data);
    } else {
      await provider.addEmployee(data);
    }
    resetForm();
    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Employee" : "Add Employee")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction, // IMPORTANT
          child: SingleChildScrollView(
            //  FIX
            child: Column(
              children: [
                AppTextField(
                  controller: _name,
                  label: "Name",
                  isRequired: true,
                  validator: Validators.validateName,
                ),

                AppTextField(
                  controller: _email,
                  label: "Email",
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),

                AppTextField(
                  controller: _phone,
                  label: "Phone",
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  validator: Validators.validatePhone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                AppDropdown(
                  label: "Role",
                  hint: "Select Role",
                  value: selectedRole,
                  items: roles,
                  isRequired: true,
                  onChanged: (val) {
                    setState(() {
                      selectedRole = val;
                    });
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Role is required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: isEdit ? "Update" : "Submit",
                        onPressed: submit,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SecondaryButton(
                        text: "Reset",
                        onPressed: resetForm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
