import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/theme/theme.dart';
import 'package:my_app/presentation/providers/themeProvider.dart';
import 'package:my_app/presentation/widgets/PrimaryButton.dart';
import 'package:my_app/presentation/widgets/SecondaryButton.dart';
import 'package:provider/provider.dart';

class AppDropdown extends StatefulWidget {
  final String label;
  final String? hint;
  final bool isRequired;
  final String? value;
  final String? errorMessage;
  final List<String> items;
  final void Function(String?)? onChanged;
  final FormFieldValidator<String>? validator;
  final IconData? icon;
  final bool allowCreate;
  final Future<String?> Function(String text)? onCreateNew;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.validator,
    this.errorMessage,
    this.icon,
    this.allowCreate = false,
    this.onCreateNew,
    this.enabled = true,
  });

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  late ThemeTokens root;
  late bool isDark;
  final ValueNotifier<String?> _valueNotifier = ValueNotifier(null);
  static const double _itemHeight = 48;
  static const int _visibleItemCount = 4;
  static const double _dropdownPadding = 16;

  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
    _valueNotifier.value = widget.value;
  }

  @override
  void didUpdateWidget(covariant AppDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _selectedValue = widget.value;
      _valueNotifier.value = widget.value;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final themeProvider = context.watch<ThemeProvider>();
    root = themeProvider.root!;
    isDark = themeProvider.themeMode == ThemeMode.dark;
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  double _calculateDropdownHeight(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return (_itemHeight * _visibleItemCount) + _dropdownPadding;
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSpace = screenHeight - position.dy - renderBox.size.height;

    final desiredHeight = (_itemHeight * _visibleItemCount) + _dropdownPadding;

    if (bottomSpace <= 0) return _itemHeight;

    return bottomSpace < desiredHeight ? bottomSpace - 8 : desiredHeight;
  }

  // Desktop Items
  List<DropdownItem<String>> _buildDesktopItems() {
    return widget.items.map((val) {
      final isSelected = val == _selectedValue;

      return DropdownItem<String>(
        value: val,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          color: isSelected
              ? root("background.primaryblue").withOpacity(0.2)
              : root("transparentColor"),
          child: Text(
            val,
            style: TextStyle(
              fontSize: 12,
              color: widget.enabled
                  ? root("text.primary")
                  : root("form.input.content.disabled"),
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _showBottomSheet(BuildContext context) async {
    String localSearch = '';
    final baseItems = widget.items;

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: root("transparentColor"),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final lower = localSearch.toLowerCase();
            final filtered = baseItems
                .where((e) => e.toLowerCase().contains(lower))
                .toList();

            final trimmed = localSearch.trim();
            final hasExact = baseItems.any(
              (e) => e.toLowerCase() == trimmed.toLowerCase(),
            );
            final showCreate =
                widget.allowCreate &&
                widget.onCreateNew != null &&
                trimmed.isNotEmpty &&
                !hasExact;

            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: root("form.input.background"),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 4,
                          decoration: BoxDecoration(
                            color: root("text.primary"),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.hint != null)
                        Text(
                          widget.hint!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 14,
                                color: root("form.input.content.default"),
                              ),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (v) => setSheetState(() => localSearch = v),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search or type to add',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: root("text.primary")),
                          ),
                          suffixIcon: IconButton(
                            icon: showCreate
                                ? Icon(
                                    Icons.add,
                                    color: root("background.primaryblue"),
                                  )
                                : Icon(
                                    Icons.search,
                                    color: root("text.primary"),
                                  ),
                            onPressed: () async {
                              if (showCreate) {
                                final created = await widget.onCreateNew?.call(
                                  trimmed,
                                );
                                if (created != null && created.isNotEmpty) {
                                  Navigator.of(context).pop(created);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filtered.map(
                        (item) => InkWell(
                          onTap: () => Navigator.of(context).pop(item),
                          child: Container(
                            color: item == _selectedValue
                                ? root("text.secondary").withOpacity(0.2)
                                : root("transparentColor"),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Text(
                              item,
                              style: TextStyle(
                                color: root("text.primary"),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() => _selectedValue = selected);
      widget.onChanged?.call(selected);
    }
  }

  Future<void> _handleDesktopChange(String? val) async {
    setState(() => _selectedValue = val);
    widget.onChanged?.call(val);
  }

  Future<void> _showAddDialog(
    BuildContext context, {
    String initialText = '',
  }) async {
    if (!widget.allowCreate || widget.onCreateNew == null) return;

    final TextEditingController ctl = TextEditingController(text: initialText);

    bool isValidInput(String text) {
      // Regex to allow only alphabets and spaces
      final regExp = RegExp(r'^[a-zA-Z\s]+$');
      return regExp.hasMatch(text.trim());
    }

    bool isValidLength(String text) {
      return text.trim().length <= 128;
    }

    final created = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: root("form.input.background"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New ${widget.label}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: root("form.label.default"),
                    ),
                  ),
                  Text(
                    ' *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: TextField(
                controller: ctl,
                decoration: InputDecoration(
                  hintText: 'Type new ${widget.label}',
                  hintStyle: TextStyle(
                    color: root("form.input.content.placeholder"),
                  ),
                  fillColor: root("form.input.background"),
                  errorText: errorText,
                  errorStyle: TextStyle(color: Colors.red),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                onChanged: (value) {
                  if (errorText != null) {
                    setState(() => errorText = null);
                  }
                },
                onSubmitted: (v) async {
                  final t = v.trim();
                  if (t.isEmpty) {
                    setState(() => errorText = 'This field is required');
                    return;
                  }

                  if (!isValidInput(t)) {
                    setState(
                      () => errorText = 'Only alphabets and spaces allowed',
                    );
                    return;
                  }

                  if (!isValidLength(t)) {
                    setState(
                      () => errorText = 'Maximum 128 characters allowed',
                    );

                    return;
                  }

                  final result = await widget.onCreateNew!(t);
                  Navigator.of(ctx).pop(result);
                },
              ),
              actions: [
                SecondaryButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.of(ctx).pop(null),
                ),
                PrimaryButton(
                  onPressed: () async {
                    final t = ctl.text.trim();
                    if (t.isEmpty) {
                      setState(() => errorText = 'This field is required');
                      return;
                    }

                    if (!isValidInput(t)) {
                      setState(
                        () => errorText = 'Only alphabets and spaces allowed',
                      );

                      return;
                    }

                    if (!isValidLength(t)) {
                      setState(
                        () => errorText = 'Maximum 128 characters allowed',
                      );

                      return;
                    }

                    final result = await widget.onCreateNew!(t);
                    Navigator.of(ctx).pop(result);
                  },
                  text: 'Add',
                ),
              ],
            );
          },
        );
      },
    );

    if (created != null && created.isNotEmpty) {
      final trimmedCreated = created.trim();

      // Final validation before setting the value
      if (isValidInput(trimmedCreated)) {
        setState(() => _selectedValue = trimmedCreated);
        widget.onChanged?.call(trimmedCreated);
      } else {
        // Show toast for invalid input
      }
    }
  }

  // Desktop Dropdown

  Widget _buildDesktopDropdown(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return DropdownButtonFormField2<String>(
      valueListenable: _valueNotifier, //  FIX

      isExpanded: true,

      onChanged: widget.enabled
          ? (val) {
              _valueNotifier.value = val; //  UPDATE VALUE
              _handleDesktopChange(val);
            }
          : null,

      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: root("form.input.background"),
        contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.enabled
                ? root("form.input.border.disabled")
                : root("form.input.content.disabled"),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.enabled
                ? root("form.input.border.focused")
                : root("form.input.border.disabled"),
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),

        errorStyle: const TextStyle(color: Colors.red),
      ),

      hint: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(
          widget.hint ?? '',
          style: theme.bodyMedium?.copyWith(
            fontSize: 12,
            color: widget.onChanged == null
                ? root("form.input.content.disabled")
                : root("form.input.content.placeholder"),
          ),
        ),
      ),

      items: _buildDesktopItems(), //  CORRECT

      menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.zero),

      selectedItemBuilder: (context) {
        return widget.items.map((item) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item,
              style: theme.bodyMedium?.copyWith(
                fontSize: 12,
                color: widget.enabled
                    ? root("text.primary")
                    : root("form.input.content.disabled"),
              ),
            ),
          );
        }).toList();
      },

      validator: (val) {
        if (widget.isRequired && (val == null || val.isEmpty)) {
          return widget.errorMessage ?? 'This field is required';
        }
        return widget.validator?.call(val);
      },

      dropdownStyleData: DropdownStyleData(
        elevation: 4,
        maxHeight: _calculateDropdownHeight(context),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: root("form.input.background"),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // NEW LABEL WITH ADD BUTTON (like DocumentUpload)
  Widget _buildLabel(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              text: widget.label,
              style: theme.bodyMedium?.copyWith(
                color: root("form.label.default"),
              ),
              children: widget.isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: theme.bodyMedium?.copyWith(
                          color: root("form.input.helper.error"),
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
        ),
        if (widget.allowCreate && widget.enabled)
          TextButton.icon(
            onPressed: () => _showAddDialog(context, initialText: ''),
            icon: Icon(
              Icons.add,
              size: 14,
              color: root("form.input.border.focused"),
            ),
            label: Text(
              "Add",
              style: TextStyle(
                fontSize: 12,
                color: root("form.input.border.focused"),
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context),
        SizedBox(height: isMobile ? 2 : 4),
        if (isMobile)
          GestureDetector(
            onTap: widget.enabled ? () => _showBottomSheet(context) : null,
            child: AbsorbPointer(child: _buildDesktopDropdown(context)),
          )
        else
          _buildDesktopDropdown(context),
      ],
    );
  }
}
