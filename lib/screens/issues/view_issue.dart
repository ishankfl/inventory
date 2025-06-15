// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inventory/models/product_issue.dart';
import 'package:inventory/services/issue_service.dart';

class ViewIssue extends StatefulWidget {
  const ViewIssue({super.key});

  @override
  State<ViewIssue> createState() => _ViewIssueState();
}

class _ViewIssueState extends State<ViewIssue> with TickerProviderStateMixin {
  List<ProductIssue> issuedProducts = [];
  List<ProductIssue> filteredProducts = [];
  bool isLoading = true;
  String? errorMessage;

  // Filter controllers
  String? selectedDepartment;
  String? selectedUser;
  String quantityFilter = '';
  bool sortAscending = true;
  String sortField = 'date';
  bool isFilterExpanded = false;

  // Unique lists for dropdowns
  late List<String> departments;
  late List<String> users;

  // Animation controllers
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
    fetchIssue();
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    super.dispose();
  }

  Future<void> fetchIssue() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final items = await IssueService.getAllProductIssue();
      setState(() {
        issuedProducts = items;
        filteredProducts = items;

        // Extract unique departments and users
        departments = items.map((e) => e.department.name).toSet().toList();
        users = items.map((e) => e.issuedBy.fullName).toSet().toList();

        isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load issues: $e';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading issues: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _applyFilters() {
    List<ProductIssue> filtered = issuedProducts;
    if (selectedDepartment != null) {
      filtered = filtered
          .where((issue) => issue.department.name == selectedDepartment)
          .toList();
    }

    if (selectedUser != null) {
      filtered = filtered
          .where((issue) => issue.issuedBy.fullName == selectedUser)
          .toList();
    }

    if (quantityFilter.isNotEmpty) {
      final qty = int.tryParse(quantityFilter) ?? 0;
      filtered = filtered
          .where((issue) =>
              issue.issueItems.any((item) => item.quantityIssued == qty))
          .toList();
    }
    filtered.sort((a, b) {
      int result;
      switch (sortField) {
        case 'department':
          result = a.department.name.compareTo(b.department.name);
          break;
        case 'user':
          result = a.issuedBy.fullName.compareTo(b.issuedBy.fullName);
          break;
        case 'quantity':
          final aQty =
              a.issueItems.fold(0, (sum, item) => sum + item.quantityIssued);
          final bQty =
              b.issueItems.fold(0, (sum, item) => sum + item.quantityIssued);
          result = aQty.compareTo(bQty);
          break;
        case 'date':
        default:
          result = a.issueDate.compareTo(b.issueDate);
      }
      return sortAscending ? result : -result;
    });

    setState(() {
      filteredProducts = filtered;
    });
  }

  void _toggleFilters() {
    setState(() {
      isFilterExpanded = !isFilterExpanded;
    });
    if (isFilterExpanded) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _clearFilters() {
    setState(() {
      selectedDepartment = null;
      selectedUser = null;
      quantityFilter = '';
      sortField = 'date';
      sortAscending = true;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Product Issues'),
        actions: [
          if (filteredProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () {},
              tooltip: 'Download Issues',
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: fetchIssue,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterHeader(colorScheme),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: isFilterExpanded
                ? _buildFilterControls(theme)
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: _buildIssuesList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(ColorScheme colorScheme) {
    final hasActiveFilters = selectedDepartment != null ||
        selectedUser != null ||
        quantityFilter.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Filters & Sort',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasActiveFilters)
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_rounded, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            IconButton(
              onPressed: _toggleFilters,
              icon: AnimatedRotation(
                turns: isFilterExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(
                  Icons.expand_more_rounded,
                  color: Colors.white,
                ),
              ),
              tooltip: isFilterExpanded ? 'Hide Filters' : 'Show Filters',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterControls(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        // color: Theme.of(context).primaryColor,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStyledDropdown(
                  width: 190,
                  value: selectedDepartment,
                  label: 'Department',
                  icon: Icons.business_rounded,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Department'),
                    ),
                    ...departments.map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedDepartment = value;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 10),
                // Expanded(
                //   child: _buildStyledDropdown(
                //     value: selectedUser,
                //     label: 'Issued By',
                //     icon: Icons.person_rounded,
                //     items: [
                //       const DropdownMenuItem(
                //         value: null,
                //         child: Text('All Users'),
                //       ),
                //       ...users.map((user) => DropdownMenuItem(
                //             value: user,
                //             child: Text(user),
                //           )),
                //     ],
                //     onChanged: (value) {
                //       setState(() {
                //         selectedUser = value;
                //         _applyFilters();
                //       });
                //     },
                //   ),
                // ),
                _buildStyledDropdown(
                  width: 170,
                  value: selectedUser,
                  label: 'Issued By',
                  icon: Icons.person_rounded,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Users'),
                    ),
                    ...users.map((user) => DropdownMenuItem(
                          value: user,
                          child: Text(user),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedUser = value;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Fixed width TextFormField
                // SizedBox(
                //   width: 100,
                //   height: 50,
                //   child: TextFormField(
                //     decoration: InputDecoration(
                //       labelText: 'Filter by Quantity',
                //       prefixIcon: const Icon(Icons.numbers_rounded),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       filled: true,
                //       fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                //     ),
                //     keyboardType: TextInputType.number,
                //     onChanged: (value) {
                //       setState(() {
                //         quantityFilter = value;
                //         _applyFilters();
                //       });
                //     },
                //   ),
                // ),

                const SizedBox(width: 10),

                // Styled fixed width dropdown
                _buildStyledDropdown(
                  width: 250,
                  value: sortField,
                  label: 'Sort by',
                  icon: Icons.sort,
                  items: const [
                    DropdownMenuItem(
                        value: 'date', child: Text('Sort by Date')),
                    DropdownMenuItem(
                        value: 'department', child: Text('Sort by Department')),
                    DropdownMenuItem(
                        value: 'user', child: Text('Sort by User')),
                    DropdownMenuItem(
                        value: 'quantity', child: Text('Sort by Quantity')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortField = value!;
                      _applyFilters();
                    });
                  },
                ),

                const SizedBox(width: 10),

                // Sort toggle button
                Container(
                  height: 50, // match height of text fields
                  width: 58,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      sortAscending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        sortAscending = !sortAscending;
                        _applyFilters();
                      });
                    },
                    tooltip: sortAscending ? 'Ascending' : 'Descending',
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStyledDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    double width = 250, // default width
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildIssuesList(ThemeData theme) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading issues...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchIssue,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No issues found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final issue = filteredProducts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildIssueCard(issue, theme),
        );
      },
    );
  }

  Widget _buildIssueCard(ProductIssue issue, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final totalQuantity =
        issue.issueItems.fold(0, (sum, item) => sum + item.quantityIssued);
    final totalPrice = issue.issueItems.fold(0.0,
        (sum, item) => sum + (item.product?.price ?? 0) * item.quantityIssued);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: issue.isCompleted
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            issue.isCompleted ? Icons.check_rounded : Icons.pending_rounded,
            color: issue.isCompleted ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          issue.department.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  issue.issuedBy.fullName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${issue.issueDate.day}/${issue.issueDate.month}/${issue.issueDate.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Chip(
              label: Text(
                '$totalQuantity items',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: StadiumBorder(
                side: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
            ),
            // const SizedBox(height: 4),
            // Text(
            //   '\$${totalPrice.toStringAsFixed(2)}',
            //   style: theme.textTheme.bodyMedium?.copyWith(
            //     fontWeight: FontWeight.bold,
            //     color: Theme.of(context).primaryColor,
            //   ),
            // ),
          ],
        ),
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outline.withOpacity(0.1),
                ),
                const SizedBox(height: 12),
                Text(
                  'ITEMS ISSUED',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                ...issue.issueItems.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                item.quantityIssued.toString(),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product?.name ?? 'Unknown Product',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (item.product?.description != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    item.product!.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '\$${(item.product?.price ?? 0).toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: issue.isCompleted
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              issue.isCompleted
                                  ? Icons.check_circle_outline
                                  : Icons.pending_outlined,
                              size: 16,
                              color: issue.isCompleted
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            issue.isCompleted ? 'Completed' : 'Pending',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: issue.isCompleted
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${issue.issueItems.length} items • \$${totalPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
