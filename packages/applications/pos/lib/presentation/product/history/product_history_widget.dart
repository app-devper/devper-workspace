// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/number_ext.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/product_history.dart';
import 'package:pos/presentation/product/history/product_history_state.dart';
import 'package:pos/presentation/product/history/product_history_view_model.dart';
import 'package:pos/presentation/theme.dart';

class ProductHistoryWidget extends StatefulWidget {
  final String productId;

  const ProductHistoryWidget({
    super.key,
    required this.productId,
  });

  @override
  State<StatefulWidget> createState() => _ProductHistoryWidgetState();
}

class _ProductHistoryWidgetState extends State<ProductHistoryWidget> {
  late ProductHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductHistoryViewModel>();
    _viewModel.getHistoriesByProductId(widget.productId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProductHistoryState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, ProductHistoryState state, _) {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _viewModel.getHistoriesByProductId(widget.productId);
                  },
                  child: const Text('ลองอีกครั้ง'),
                ),
              ],
            ),
          );
        }
        if (state.items.isEmpty) {
          return const Center(
            child: Text(
              'ไม่มีประวัติ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        return _buildHistoryList(state.items);
      },
    );
  }

  Widget _buildHistoryList(List<ProductHistory> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final history = items[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(history.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getTypeLabel(history.type),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getTypeColor(history.type),
                        ),
                      ),
                    ),
                    Text(
                      history.getCreatedDate(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (history.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    history.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('หน่วย', history.unit),
                    _buildInfoColumn('นำเข้า', '${history.import}'),
                    _buildInfoColumn('จำนวน', '${history.quantity}'),
                    _buildInfoColumn('คงเหลือ', '${history.balance}'),
                    _buildInfoColumn('ต้นทุน', '฿${formatDouble(history.costPrice)}'),
                    _buildInfoColumn('ราคา', '฿${formatDouble(history.price)}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'import':
      case 'receive':
        return Colors.green;
      case 'sale':
      case 'sold':
        return Colors.blue;
      case 'adjust':
      case 'adjustment':
        return Colors.orange;
      case 'return':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'import':
      case 'receive':
        return 'นำเข้า';
      case 'sale':
      case 'sold':
        return 'ขาย';
      case 'adjust':
      case 'adjustment':
        return 'ปรับปรุง';
      case 'return':
        return 'คืนสินค้า';
      default:
        return type;
    }
  }
}
