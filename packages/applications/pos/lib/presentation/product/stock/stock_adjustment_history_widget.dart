// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_history_state.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_history_view_model.dart';
import 'package:pos/presentation/theme.dart';

class StockAdjustmentHistoryWidget extends StatefulWidget {
  final String productId;

  const StockAdjustmentHistoryWidget({
    super.key,
    required this.productId,
  });

  @override
  State<StatefulWidget> createState() => _StockAdjustmentHistoryWidgetState();
}

class _StockAdjustmentHistoryWidgetState extends State<StockAdjustmentHistoryWidget> {
  late StockAdjustmentHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<StockAdjustmentHistoryViewModel>();
    _viewModel.getStockAdjustmentsByProductId(widget.productId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StockAdjustmentHistoryState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, StockAdjustmentHistoryState state, _) {
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
                    _viewModel.getStockAdjustmentsByProductId(widget.productId);
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
              'ไม่มีประวัติการปรับสต็อก',
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

  Widget _buildHistoryList(List<StockAdjustment> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final adjustment = items[index];
        final isIncrease = adjustment.delta > 0;
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
                        color: (isIncrease ? Colors.green : Colors.red).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        adjustment.reason,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isIncrease ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    Text(
                      adjustment.getCreatedDate(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (adjustment.note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    adjustment.note,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('ก่อนปรับ', '${adjustment.before}'),
                    _buildInfoColumn('ปรับ', '${isIncrease ? '+' : ''}${adjustment.delta}'),
                    _buildInfoColumn('หลังปรับ', '${adjustment.after}'),
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
}
