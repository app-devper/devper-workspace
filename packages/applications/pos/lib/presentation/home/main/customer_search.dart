// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/color.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/presentation/home/main/customer_search_view_model.dart';
import 'package:pos/presentation/home/main/customer_search_state.dart';

class CustomerSearch extends StatefulWidget {
  final Function(Function) onRefresh;
  final Function(Customer) onSelected;

  const CustomerSearch({
    super.key,
    required this.onSelected,
    required this.onRefresh,
  });

  @override
  State<StatefulWidget> createState() {
    return _CustomerSearchState();
  }
}

class _CustomerSearchState extends State<CustomerSearch> {
  final _customerEditingController = TextEditingController();
  final _customerNode = FocusNode();

  late CustomerSearchViewModel _viewModel;

  @override
  void initState() {
    _viewModel = sl<CustomerSearchViewModel>();
    _viewModel.getCacheCustomers();
    widget.onRefresh(() {
      _viewModel.getCacheCustomers();
    });
    super.initState();
  }

  @override
  void dispose() {
    _customerNode.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _customerNode.requestFocus();
    return _buildCustomers();
  }

  _buildCustomers() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: TextField(
            focusNode: _customerNode,
            controller: _customerEditingController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0),
              hintText: 'ค้นหา...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.grey[200],
              filled: true,
            ),
            onChanged: (value) {
              _viewModel.searchCustomer(value);
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ValueListenableBuilder<CustomerSearchState>(
            valueListenable: _viewModel.state,
            builder: (context, state, _) {
              if (state.loading) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: CustomColor.primary,
                    strokeCap: StrokeCap.round,
                  ),
                );
              }
              if (state.error != null) {
                return Center(
                  child: TextButton.icon(
                    onPressed: _viewModel.getCacheCustomers,
                    icon: const Icon(Icons.refresh),
                    label: Text(state.error!),
                  ),
                );
              }
              final items = state.items;
              return ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, i) => ListTile(
                  title: Text(items[i].name),
                  subtitle: Text(items[i].code),
                  onTap: () {
                    widget.onSelected(items[i]);
                  },
                ),
                itemCount: items.length,
              );
            },
          ),
        )
      ],
    );
  }
}
