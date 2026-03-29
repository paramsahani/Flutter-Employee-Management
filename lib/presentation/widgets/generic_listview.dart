import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/core/theme/theme.dart';
import 'package:my_app/presentation/providers/themeProvider.dart';
import 'package:provider/provider.dart';

class GenericListView<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Widget Function(T item) iconBuilder;
  final List<Widget> Function(T item) detailsBuilder;

  final void Function(T item)? onEdit;
  final void Function(T item)? onDelete;
  final VoidCallback? onAdd;

  const GenericListView({
    super.key,
    required this.title,
    required this.items,
    required this.iconBuilder,
    required this.detailsBuilder,
    this.onEdit,
    this.onDelete,
    this.onAdd,
  });

  @override
  State<GenericListView<T>> createState() => _GenericListViewState<T>();
}

class _GenericListViewState<T> extends State<GenericListView<T>> {
  late ThemeTokens root;

  int currentPage = 1;
  final int itemsPerPage = 4;

  String searchQuery = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    root = context.read<ThemeProvider>().root!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    ///  FILTERED DATA
    final filteredItems = widget.items.where((item) {
      if (searchQuery.isEmpty) return true;

      return item.toString().toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    ///  PAGINATION
    final int totalItems = filteredItems.length;
    final int totalPages = (totalItems / itemsPerPage).ceil() == 0
        ? 1
        : (totalItems / itemsPerPage).ceil();

    final int startIndex = (currentPage - 1) * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage > totalItems)
        ? totalItems
        : startIndex + itemsPerPage;

    final List<T> itemsToDisplay = totalItems == 0
        ? []
        : filteredItems.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: root("form.input.background"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: theme.titleMedium),
                IconButton(
                  onPressed: widget.onAdd,
                  icon: SvgPicture.asset(
                    'assets/images/svg-add.svg',
                    width: 22,
                    height: 22,
                    color: root("text.primary"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ///  SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  currentPage = 1; //  reset page
                });
              },
            ),

            const SizedBox(height: 16),

            /// EMPTY
            if (itemsToDisplay.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("No results found"),
              ),

            /// LIST
            ...itemsToDisplay.map((item) {
              final details = widget.detailsBuilder(item);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: root("divider.color")),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.iconBuilder(item),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: details,
                      ),
                    ),

                    Row(
                      children: [
                        if (widget.onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => widget.onEdit!(item),
                          ),

                        if (widget.onDelete != null)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete"),
                                  content: const Text(
                                    "Are you sure you want to delete?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pop(true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                widget.onDelete!(item);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            ///  PAGINATION
            if (totalItems > itemsPerPage)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage > 1
                        ? () => setState(() => currentPage--)
                        : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text("Page $currentPage of $totalPages"),
                  IconButton(
                    onPressed: currentPage < totalPages
                        ? () => setState(() => currentPage++)
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
