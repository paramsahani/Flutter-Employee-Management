import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/presentation/providers/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class GenericDataGrid extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final Map<String, String> columnMapping;
  final Set<String> sortableColumns;

  final String? pillColumnKey;
  final Map<String, Color> Function(dynamic value)? pillColorResolver;

  final String? statusColumnKey;

  // Old builder (value only) - keep for backward compatibility
  final Widget Function(dynamic value)? statusBuilder;

  // New builder: gets (value + full row map)
  final Widget Function(dynamic value, Map<String, dynamic> row)?
  statusBuilderWithRow;

  final void Function(Map<String, dynamic>)? onEdit;
  final void Function(Map<String, dynamic>)? onView;
  final void Function(Map<String, dynamic>)? onDelete;

  // Cancel action
  final bool Function(Map<String, dynamic> row)? showCancelAction;
  final bool Function(Map<String, dynamic> row)? isCancelDisabled;
  final void Function(Map<String, dynamic> row)? onCancelTap;

  // Pullback action
  final bool Function(Map<String, dynamic> row)? showPullbackAction;
  final bool Function(Map<String, dynamic> row)? isPullbackDisabled;
  final void Function(Map<String, dynamic> row)? onPullbackTap;

  final Widget Function(BuildContext context, bool disabled)?
  pullbackIconBuilder;

  final String? headerLineOne;
  final String? headerLineTwo;

  final bool enableSearch;
  final String searchHint;

  final bool isLoading;
  final bool isAddingRow;

  final Widget? searchTrailingWidget;

  final String actionsColumnTitle;
  final Widget? trailingHeaderWidget;
  const GenericDataGrid(
    this.data, {
    super.key,
    required this.columnMapping,
    this.sortableColumns = const {},
    this.onEdit,
    this.onView,
    this.onDelete,
    this.statusColumnKey,
    this.statusBuilder,
    this.statusBuilderWithRow,
    this.isLoading = false,
    this.isAddingRow = false,
    this.pillColumnKey,
    this.pillColorResolver,
    this.showCancelAction,
    this.isCancelDisabled,
    this.onCancelTap,
    this.showPullbackAction,
    this.isPullbackDisabled,
    this.onPullbackTap,
    this.pullbackIconBuilder,
    this.headerLineOne,
    this.headerLineTwo,
    this.trailingHeaderWidget,
    this.enableSearch = false,
    this.searchHint = 'Search...',
    this.searchTrailingWidget,
    this.actionsColumnTitle = 'Actions',
  });

  bool get hasActions =>
      onEdit != null ||
      onView != null ||
      onDelete != null ||
      onCancelTap != null ||
      onPullbackTap != null;

  @override
  State<GenericDataGrid> createState() => GenericDataGridState();
}

class GenericDataGridState extends State<GenericDataGrid> {
  late GenericDataGridSource dataSource;
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _filteredData = [];
  String? sortColumn;
  bool isAscending = true;

  late bool isDark;
  late ThemeProvider themeProvider;
  late dynamic root;

  int _currentPage = 1;
  int _pageSize = 5;

  int get _totalRecords => _filteredData.length;
  int get _totalPages =>
      _totalRecords == 0 ? 1 : (_totalRecords / _pageSize).ceil();

  List<Map<String, dynamic>> get _paginatedData {
    final start = (_currentPage - 1) * _pageSize;
    final end = start + _pageSize;
    return _filteredData.sublist(
      start,
      end > _totalRecords ? _totalRecords : end,
    );
  }

  final Map<String, GlobalKey> sortIconKeys = {};
  static const double rowHeight = 56.0;

  late TextTheme textTheme;
  bool _internalLoading = true;

  @override
  void initState() {
    super.initState();
    _filteredData = widget.data;
    _internalLoading = widget.isLoading;

    dataSource = GenericDataGridSource(
      widget.data,
      widget.columnMapping,
      context: context,
      onEdit: widget.onEdit,
      onView: widget.onView,
      onDelete: widget.onDelete,
      statusColumnKey: widget.statusColumnKey,
      statusBuilder: widget.statusBuilder,
      statusBuilderWithRow: widget.statusBuilderWithRow,
      pillColumnKey: widget.pillColumnKey,
      pillColorResolver: widget.pillColorResolver,
      isLoading: _internalLoading,
      showCancelAction: widget.showCancelAction,
      isCancelDisabled: widget.isCancelDisabled,
      onCancelTap: widget.onCancelTap,
      showPullbackAction: widget.showPullbackAction,
      isPullbackDisabled: widget.isPullbackDisabled,
      onPullbackTap: widget.onPullbackTap,
      pullbackIconBuilder: widget.pullbackIconBuilder,
    );

    dataSource.buildDataGridRows(
      _paginatedData,
      sortColumn: sortColumn,
      isAscending: isAscending,
      isLoading: _internalLoading,
      isAddingRow: widget.isAddingRow,
    );

    for (final column in widget.sortableColumns) {
      sortIconKeys[column] = GlobalKey();
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;

    setState(() {
      _currentPage = page;
      dataSource.buildDataGridRows(
        _paginatedData,
        sortColumn: sortColumn,
        isAscending: isAscending,
        isLoading: _internalLoading,
        isAddingRow: widget.isAddingRow,
      );
    });
  }

  void _applySearch(String query) {
    final q = query.toLowerCase().trim();

    if (q.isEmpty) {
      _filteredData = widget.data;
    } else {
      _filteredData = widget.data.where((row) {
        return row.values.any((value) {
          if (value == null) return false;

          String text = value.toString();

          return text.toLowerCase().contains(q);
        });
      }).toList();
    }

    _currentPage = 1;

    dataSource.buildDataGridRows(
      _paginatedData,
      sortColumn: sortColumn,
      isAscending: isAscending,
      isLoading: _internalLoading,
      isAddingRow: widget.isAddingRow,
    );
  }

  @override
  void didUpdateWidget(covariant GenericDataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    _internalLoading = widget.isLoading;
    _filteredData = widget.data;

    dataSource = GenericDataGridSource(
      widget.data,
      widget.columnMapping,
      context: context,
      onEdit: widget.onEdit,
      onView: widget.onView,
      onDelete: widget.onDelete,
      statusColumnKey: widget.statusColumnKey,
      statusBuilder: widget.statusBuilder,
      statusBuilderWithRow: widget.statusBuilderWithRow,
      pillColumnKey: widget.pillColumnKey,
      pillColorResolver: widget.pillColorResolver,
      isLoading: _internalLoading,
      showCancelAction: widget.showCancelAction,
      isCancelDisabled: widget.isCancelDisabled,
      onCancelTap: widget.onCancelTap,
      showPullbackAction: widget.showPullbackAction,
      isPullbackDisabled: widget.isPullbackDisabled,
      onPullbackTap: widget.onPullbackTap,
      pullbackIconBuilder: widget.pullbackIconBuilder,
    );

    _applySearch(_searchCtrl.text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    textTheme = Theme.of(context).textTheme;
    themeProvider = context.watch<ThemeProvider>();
    root = themeProvider.root;
    isDark = themeProvider.themeMode == ThemeMode.dark;
  }

  void showSortOptions(String columnName) async {
    final iconKey = sortIconKeys[columnName];
    if (iconKey?.currentContext == null) return;

    final renderBox = iconKey!.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(
          renderBox.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final themeRoot = context.read<ThemeProvider>().root!;
    final value = await showMenu<String>(
      context: context,
      position: position,
      color: themeRoot("layout.background"),
      items: [
        PopupMenuItem<String>(
          value: 'asc',
          height: 30,
          child: Text(
            'Ascending',
            style: TextStyle(
              color: sortColumn == columnName && isAscending
                  ? themeRoot("background.primaryblue")
                  : themeRoot("text.primary"),
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'desc',
          height: 30,
          child: Text(
            'Descending',
            style: TextStyle(
              color: sortColumn == columnName && !isAscending
                  ? themeRoot("background.primaryblue")
                  : themeRoot("text.primary"),
            ),
          ),
        ),
      ],
    );

    if (value != null && mounted) {
      setState(() {
        sortColumn = columnName;
        isAscending = value == 'asc';
        dataSource.buildDataGridRows(
          _paginatedData,
          sortColumn: sortColumn,
          isAscending: isAscending,
          isLoading: _internalLoading,
          isAddingRow: widget.isAddingRow,
        );
      });
    }
  }

  Widget _buildPagination() {
    const int visiblePageCount = 5;

    int startPage = (_currentPage - (visiblePageCount ~/ 2)).clamp(
      1,
      _totalPages,
    );
    int endPage = (startPage + visiblePageCount - 1).clamp(1, _totalPages);

    if (endPage - startPage + 1 < visiblePageCount) {
      startPage = (endPage - visiblePageCount + 1).clamp(1, _totalPages);
    }

    final List<int> pageSizeOptions = [5, 10, 15, 20, 25];
    return Column(
      children: [
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// LEFT SIDE
            Row(
              children: [
                Text(
                  "Rows per page:",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: root("text.secondary"),
                  ),
                ),

                const SizedBox(width: 5),
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: root("form.input.background"),
                    border: Border.all(color: root("divider.color")),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    // This centers the text vertically
                    child: DropdownButton<int>(
                      value: _pageSize,
                      underline: const SizedBox(),
                      isDense: true,
                      iconSize: 18,
                      dropdownColor: root("form.input.background"),
                      items: pageSizeOptions.map((size) {
                        //psgesizeoptions local variable created
                        return DropdownMenuItem(
                          value: size,
                          child: Text(
                            size.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              height: 1.2, // helps vertical alignment
                              color: root("text.secondary"),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _pageSize =
                              value; // pagesize was final currently it is var
                          _currentPage = 1;

                          dataSource.buildDataGridRows(
                            _paginatedData,
                            sortColumn: sortColumn,
                            isAscending: isAscending,
                            isLoading: _internalLoading,
                            isAddingRow: widget.isAddingRow,
                          );
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  'Showing $_currentPage out of $_totalPages pages of $_totalRecords entries',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: root("text.secondary"),
                  ),
                ),
              ],
            ),

            /// RIGHT SIDE PAGINATION
            Row(
              children: [
                _pageButton(
                  label: '<<',
                  onTap: _currentPage > 1 ? () => _goToPage(1) : null,
                ),
                _pageButton(
                  label: '<',
                  onTap: _currentPage > 1
                      ? () => _goToPage(_currentPage - 1)
                      : null,
                ),
                for (int page = startPage; page <= endPage; page++)
                  _pageNumber(page),
                _pageButton(
                  label: '>',
                  onTap: _currentPage < _totalPages
                      ? () => _goToPage(_currentPage + 1)
                      : null,
                ),
                _pageButton(
                  label: '>>',
                  onTap: _currentPage < _totalPages
                      ? () => _goToPage(_totalPages)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _pageButton({required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 25,
        height: 25,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: root("divider.color")),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: onTap == null
                  ? root("text.secondary")
                  : root("text.primary"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageNumber(int page) {
    final bool isActive = page == _currentPage;

    return InkWell(
      onTap: () => _goToPage(page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? root("background.primaryblue") : Colors.transparent,
          border: Border.all(color: root("divider.color")),
        ),
        child: Center(
          child: Text(
            '$page',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.white : root("text.primary"),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Map columns from columnMapping
    final columns = widget.columnMapping.entries.map((entry) {
      final bool isSortable = widget.sortableColumns.contains(entry.key);

      return GridColumn(
        columnName: entry.key,
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: const Color(0x1A1A181A),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: root("form.label.default"),
                  ),
                ),
              ),

              /// SHOW SORT ICON ONLY FOR SORTABLE COLUMNS
              if (isSortable)
                GestureDetector(
                  key: sortIconKeys[entry.key],
                  onTap: () => showSortOptions(entry.key),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: sortColumn == entry.key
                        ? root("background.primaryblue")
                        : root("form.label.default"),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();

    // 2. Add Actions column if enabled
    if (widget.hasActions) {
      columns.add(
        GridColumn(
          columnName: 'actions',
          label: Container(
            alignment: Alignment.center,
            color: const Color(0x1A1A181A),
            child: Text(
              widget.actionsColumnTitle,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: root("form.label.default"),
              ),
            ),
          ),
        ),
      );
    }

    // 3. Calculate height dynamically based on row count
    final rowCount = _paginatedData.isEmpty ? _pageSize : _paginatedData.length;
    final cardHeight = (rowCount * GenericDataGridState.rowHeight) + 56;

    return Container(
      decoration: BoxDecoration(
        color: root("form.input.background"),
        borderRadius: BorderRadius.circular(6),
        border: isDark
            ? Border.all(color: root("form.input.border.disabled"), width: 1)
            : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(.10),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section: Titles, Search, and Trailing Widgets
          if (widget.headerLineOne != null ||
              widget.headerLineTwo != null ||
              widget.enableSearch) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.headerLineOne != null)
                        Text(
                          widget.headerLineOne!,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: root("text.primary"),
                          ),
                        ),
                      if (widget.headerLineTwo != null)
                        Text(
                          widget.headerLineTwo!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: root("text.secondary"),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.enableSearch)
                        SizedBox(
                          width: 280,
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: _applySearch,
                            style: GoogleFonts.poppins(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: widget.searchHint,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      if (widget.trailingHeaderWidget != null) ...[
                        const SizedBox(width: 12),
                        Flexible(child: widget.trailingHeaderWidget!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: root("divider.color")),
            const SizedBox(height: 12),
          ],

          // Data Grid Section
          SizedBox(
            height: cardHeight,
            child: SfDataGrid(
              source: dataSource,
              columns: columns,
              columnWidthMode: ColumnWidthMode.fill,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              rowHeight: GenericDataGridState.rowHeight,
              // headerHeight: 56,
              headerRowHeight: 56,
            ),
          ),

          // Pagination Footer
          _buildPagination(),
        ],
      ),
    );
  }
}

class GenericDataGridSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  final BuildContext context;
  final Map<String, String> columnMapping;

  final String? pillColumnKey;
  final Map<String, Color> Function(dynamic value)? pillColorResolver;

  final void Function(Map<String, dynamic>)? onEdit;
  final void Function(Map<String, dynamic>)? onView;
  final void Function(Map<String, dynamic>)? onDelete;

  final String? statusColumnKey;
  final Widget Function(dynamic value)? statusBuilder;

  final Widget Function(dynamic value, Map<String, dynamic> row)?
  statusBuilderWithRow;

  final bool Function(Map<String, dynamic> row)? showCancelAction;
  final bool Function(Map<String, dynamic> row)? isCancelDisabled;
  final void Function(Map<String, dynamic> row)? onCancelTap;

  final bool Function(Map<String, dynamic> row)? showPullbackAction;
  final bool Function(Map<String, dynamic> row)? isPullbackDisabled;
  final void Function(Map<String, dynamic> row)? onPullbackTap;
  final Widget Function(BuildContext context, bool disabled)?
  pullbackIconBuilder;

  bool isLoading;

  GenericDataGridSource(
    List<Map<String, dynamic>> data,
    this.columnMapping, {
    required this.context,
    this.onEdit,
    this.onView,
    this.onDelete,
    this.statusColumnKey,
    this.statusBuilder,
    this.statusBuilderWithRow,
    this.isLoading = false,
    this.pillColumnKey,
    this.pillColorResolver,
    this.showCancelAction,
    this.isCancelDisabled,
    this.onCancelTap,
    this.showPullbackAction,
    this.isPullbackDisabled,
    this.onPullbackTap,
    this.pullbackIconBuilder,
  }) {
    buildDataGridRows(data);
  }

  bool get hasActions =>
      onEdit != null ||
      onView != null ||
      onDelete != null ||
      onCancelTap != null ||
      onPullbackTap != null;

  void buildDataGridRows(
    List<Map<String, dynamic>> data, {
    String? sortColumn,
    bool isAscending = true,
    bool isLoading = false,
    bool isAddingRow = false,
  }) {
    this.isLoading = isLoading;

    final columns = [...columnMapping.keys, if (hasActions) 'actions'];

    final sortedData = _getSortedRows(data, sortColumn, isAscending);

    if (isLoading) {
      _rows = List.generate(
        5,
        (_) => DataGridRow(
          cells: columns
              .map((c) => DataGridCell(columnName: c, value: null))
              .toList(),
        ),
      );
    } else {
      _rows = sortedData.map((item) {
        return DataGridRow(
          cells: columns.map((col) {
            if (col == 'actions') {
              return DataGridCell(columnName: col, value: item);
            }
            return DataGridCell(columnName: col, value: item[col]);
          }).toList(),
        );
      }).toList();
    }

    notifyListeners();
  }

  static List<Map<String, dynamic>> _getSortedRows(
    List<Map<String, dynamic>> data,
    String? sortColumn,
    bool isAscending,
  ) {
    final sorted = [...data];

    if (sortColumn == null) {
      return sorted.reversed.toList();
    }
    ;

    sorted.sort((a, b) {
      final av = a[sortColumn];
      final bv = b[sortColumn];

      /// SAFER DATE SORT

      if (av is Comparable && bv is Comparable) {
        return isAscending ? av.compareTo(bv) : bv.compareTo(av);
      }
      return 0;
    });

    return sorted;
  }

  @override
  List<DataGridRow> get rows => _rows;

  Widget _actionIconBox({
    required Color bg,
    required Widget icon,
    required bool disabled,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: disabled ? 0.45 : 1,
        child: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final root = context.watch<ThemeProvider>().root!;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: root("form.label.default"));

    final isSkeleton = row.getCells().every((c) => c.value == null);

    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        final value = cell.value;
        if (value is Widget) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: value,
          );
        }

        // --- Handle Pill/Status Columns ---
        if (cell.columnName == pillColumnKey && pillColorResolver != null) {
          final map = pillColorResolver!(cell.value);
          final text = map.keys.first;
          final color = map.values.first;

          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          );
        }

        // --- Handle Status Builder ---
        if (statusColumnKey != null &&
            cell.columnName == statusColumnKey &&
            (statusBuilderWithRow != null || statusBuilder != null)) {
          //  Recreate full row map properly (LIKE OLD CODE)
          final cellMap = {
            for (final c in row.getCells()) c.columnName: c.value,
          };

          final rowMap = (cellMap['actions'] is Map<String, dynamic>)
              ? cellMap['actions'] as Map<String, dynamic>
              : <String, dynamic>{};

          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: statusBuilderWithRow != null
                ? statusBuilderWithRow!(value, rowMap)
                : statusBuilder!(value),
          );
        }

        // --- Handle 'actions' column when value is a Map (Original Logic) ---
        if (cell.columnName == 'actions' && value is Map<String, dynamic>) {
          final rowMap = value;

          final bool showCancel = showCancelAction?.call(rowMap) ?? false;
          final bool cancelDisabled = isCancelDisabled?.call(rowMap) ?? false;
          final bool showPullback = showPullbackAction?.call(rowMap) ?? false;
          final bool pullbackDisabled =
              isPullbackDisabled?.call(rowMap) ?? false;

          if (showCancel || showPullback) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showPullback)
                  Tooltip(
                    message: 'Pull back this action',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _actionIconBox(
                        bg: root("background.primaryblue"),
                        disabled: pullbackDisabled || onPullbackTap == null,
                        onTap: () => onPullbackTap?.call(rowMap),
                        icon: pullbackIconBuilder != null
                            ? pullbackIconBuilder!(context, pullbackDisabled)
                            : Icon(
                                Icons.undo_rounded,
                                color: root("layout.background"),
                                size: 18,
                              ),
                      ),
                    ),
                  ),
                if (showCancel)
                  Tooltip(
                    message: 'Cancel this action',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _actionIconBox(
                        bg: cancelDisabled
                            ? root("CancelCrossIcon.disabled")
                            : root("CancelCrossIcon.default"),
                        disabled: cancelDisabled || onCancelTap == null,
                        onTap: () => onCancelTap?.call(rowMap),
                        icon: Icon(
                          Icons.close,
                          color: root("layout.background"),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onView != null)
                IconButton(
                  padding: const EdgeInsets.all(0.5),
                  icon: SvgPicture.asset(
                    'assets/icons/view.svg',
                    width: 30,
                    height: 30,
                    color: root("background.primaryblue"),
                  ),
                  onPressed: () => onView!(rowMap),
                ),

              if (onEdit != null)
                IconButton(
                  padding: const EdgeInsets.all(0.5),
                  icon: SvgPicture.asset(
                    'assets/icons/edit.svg',
                    width: 30,
                    height: 30,
                    color: root("background.primaryblue"),
                  ),
                  onPressed: () => onEdit!(rowMap),
                ),

              // DELETE BUTTON
              if (onDelete != null)
                IconButton(
                  padding: const EdgeInsets.all(0.5),
                  icon: Icon(Icons.delete, color: Colors.red, size: 22),
                  onPressed: () => onDelete!(rowMap),
                ),
            ],
          );
        }

        // --- Default Text Rendering ---
        final displayValue = value?.toString() ?? '';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(displayValue, style: textStyle),
        );
      }).toList(),
    );
  }
}
