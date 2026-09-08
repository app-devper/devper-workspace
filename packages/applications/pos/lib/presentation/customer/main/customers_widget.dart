// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/responsive.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/customer/main/customers_state.dart';
import 'package:pos/presentation/customer/main/customers_view_model.dart';
import 'package:design_system/theme/app_colors.dart';
import 'package:design_system/theme/color.dart';

// Package imports:


class CustomersWidget extends StatefulWidget {
  final Function(Customer) onSelected;
  final Function() onBack;
  final Function() onAdd;

  const CustomersWidget({
    super.key,
    required this.onSelected,
    required this.onBack,
    required this.onAdd,
  });

  @override
  State<StatefulWidget> createState() => _CustomersWidgetState();
}

class _CustomersWidgetState extends State<CustomersWidget> {
  late CustomersViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<CustomersViewModel>();
    _viewModel.getCustomers();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    final isMobile = Responsive.isMobile(context);
    return Column(
      children: <Widget>[
        Row(
          children: [
            InkWell(
              onTap: () {
                widget.onBack();
              },
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.of(context).textSecondary,
                  size: 16,
                ),
              ),
            ),
            Expanded(
              child: Text(
                Languages.of(context).customerTitle,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.of(context).textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isMobile) ...[
              InkWell(
                onTap: () {
                  widget.onAdd();
                },
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.add,
                    color: CustomColor.primary,
                    size: 24,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(width: 40)
            ]
          ],
        ),
        const Divider(height: 1),
        _buildCustomerList(),
      ],
    );
  }

  ValueListenableBuilder<CustomersState> _buildCustomerList() {
    return ValueListenableBuilder<CustomersState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, CustomersState state, _) {
        if (state.loading && state.items.isEmpty) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 6,
                color: CustomColor.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
          );
        }
        return _buildCustomer(state.items);
      },
    );
  }

  Expanded _buildCustomer(List<Customer> item) {
    return Expanded(
      child: ListView.builder(
        itemCount: item.length,
        itemBuilder: (context, index) {
          final content = item[index];
          return Column(
            children: [
              ListTile(
                title: Text(content.name),
                subtitle: Text(content.code),
                onTap: () {
                  widget.onSelected(content);
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }
}
