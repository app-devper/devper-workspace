// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product_return/product_return.dart';
import 'package:pos/presentation/order/return/product_returns_history_state.dart';
import 'package:pos/presentation/order/return/product_returns_history_view_model.dart';
import 'package:design_system/theme/app_colors.dart';
import 'package:design_system/theme/color.dart';

class ProductReturnsHistoryWidget extends StatefulWidget {
  final String orderId;

  const ProductReturnsHistoryWidget({
    super.key,
    required this.orderId,
  });

  @override
  State<StatefulWidget> createState() => _ProductReturnsHistoryWidgetState();
}

class _ProductReturnsHistoryWidgetState extends State<ProductReturnsHistoryWidget> {
  late ProductReturnsHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductReturnsHistoryViewModel>();
    _viewModel.getProductReturnsByOrderId(widget.orderId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          title: "ประวัติการคืนสินค้า",
          onBack: () {
            Navigator.of(context).pop();
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: ValueListenableBuilder<ProductReturnsHistoryState>(
            valueListenable: _viewModel.state,
            builder: (context, state, _) {
              if (state.loading) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: CustomColor.primary,
                    strokeCap: StrokeCap.round,
                  ),
                );
              }
              if (state.error != null) {
                return Center(
                  child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                );
              }
              if (state.items.isEmpty) {
                return Center(
                  child: Text('ไม่มีประวัติการคืนสินค้า', style: TextStyle(color: AppColors.of(context).textSecondary)),
                );
              }
              return _buildList(state.items);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<ProductReturn> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final productReturn = items[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      productReturn.returnNo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      productReturn.getCreatedDate(),
                      style: TextStyle(fontSize: 13, color: AppColors.of(context).textSecondary),
                    ),
                  ],
                ),
                if (productReturn.reason.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(productReturn.reason),
                ],
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...productReturn.items.map(
                  (item) => Text('จำนวน ${item.quantity}, คืนเงิน ฿${item.refund.toStringAsFixed(2)}'),
                ),
                const SizedBox(height: 4),
                Text(
                  'คืนเงินรวม ฿${productReturn.totalRefund.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
