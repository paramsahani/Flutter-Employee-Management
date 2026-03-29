import 'package:flutter/material.dart';
import 'package:my_app/core/utils/validators.dart';
import 'package:my_app/presentation/providers/employee_provider.dart';
import 'package:my_app/presentation/widgets/DropdownFormFieldBuilder.dart';
import 'package:my_app/presentation/widgets/PrimaryButton.dart';
import 'package:my_app/presentation/widgets/SecondaryButton.dart';
import 'package:my_app/presentation/widgets/TextFormFieldBuilder.dart';
import 'package:my_app/presentation/widgets/dataGrid.dart';
import 'package:my_app/presentation/widgets/generic_listview.dart';
import 'package:my_app/presentation/screens/employee_form_page.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter/services.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedId;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();

  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<EmployeeProvider>(context, listen: false).loadEmployees(),
    );
  }

  void resetForm() {
    selectedId = null; // ADD
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _roleController.clear();
    setState(() => isEditMode = false);
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<EmployeeProvider>(context, listen: false);

    final data = {
      "name": _nameController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "role": _roleController.text,
    };

    if (isEditMode) {
      await provider.updateEmployee(selectedId!, data); // FIX
    } else {
      await provider.addEmployee(data);
    }

    resetForm();
  }

  List<Widget> buildFormFields() {
    return [
      AppTextField(
        controller: _nameController,
        label: "Name",
        isRequired: true,
        validator: Validators.validateName,
      ),
      AppTextField(
        controller: _emailController,
        label: "Email",
        isRequired: true,
        validator: Validators.validateEmail,
      ),
      AppTextField(
        controller: _phoneController,
        label: "Phone",
        isRequired: true,
        validator: Validators.validatePhone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
      ),
      AppDropdown(
        label: "Role",
        hint: "Select Role",
        value: _roleController.text.isEmpty ? null : _roleController.text,
        items: ["Developer", "Software Engineer", "Manager", "Tester", "HR"],
        isRequired: true,
        onChanged: (val) {
          setState(() {
            _roleController.text = val ?? "";
          });
        },
      ),
    ];
  }

  Widget buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SecondaryButton(text: "Reset", onPressed: resetForm),
        const SizedBox(width: 10),
        PrimaryButton(
          text: isEditMode ? "Update" : "Submit",
          onPressed: submitForm,
        ),
      ],
    );
  }

  /// 💻 DESKTOP
  Widget buildDesktop() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Wrap(
              spacing: 18,
              runSpacing: 24,
              children: buildFormFields()
                  .map((e) => SizedBox(width: 340, child: e))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          buildButtons(),
          const SizedBox(height: 30),

          Consumer<EmployeeProvider>(
            builder: (context, provider, _) {
              return GenericDataGrid(
                provider.employees,
                columnMapping: const {
                  "name": "Name",
                  "email": "Email",
                  "phone": "Phone",
                  "role": "Role",
                },
                enableSearch: true,

                onEdit: (row) {
                  selectedId = row["id"]; // IMPORTANT

                  _nameController.text = row["name"];
                  _emailController.text = row["email"];
                  _phoneController.text = row["phone"];
                  _roleController.text = row["role"];

                  isEditMode = true;
                  setState(() {});
                },

                onDelete: (row) async {
                  await Provider.of<EmployeeProvider>(
                    context,
                    listen: false,
                  ).deleteEmployee(row["id"]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// 📱 MOBILE (FIXED)
  Widget buildMobile() {
    return Consumer<EmployeeProvider>(
      builder: (context, provider, _) {
        return GenericListView<Map<String, dynamic>>(
          title: "Employees",
          items: provider.employees,

          // showAllRecordsOnCurrentScreen: true,
          iconBuilder: (item) => const Icon(Icons.person_outline),

          detailsBuilder: (item) => [
            Text(
              item["name"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(item["email"]),
            Text(item["phone"]),
            Text(item["role"]),
          ],

          ///  EDIT
          onEdit: (item) async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EmployeeFormPage(initialData: item),
              ),
            );

            if (result == true) {
              context.read<EmployeeProvider>().loadEmployees();
            }
          },

          ///  DELETE (FIXED)
          onDelete: (item) async {
            final id = item["id"];

            if (id == null) return;

            await context.read<EmployeeProvider>().deleteEmployee(id);
            //  await context.read<EmployeeProvider>().loadEmployees();
          },

          /// ➕ ADD
          onAdd: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmployeeFormPage()),
            );

            if (result == true) {
              context.read<EmployeeProvider>().loadEmployees();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        builder: (context, sizing) {
          return sizing.isMobile ? buildMobile() : buildDesktop();
        },
      ),
    );
  }
}
