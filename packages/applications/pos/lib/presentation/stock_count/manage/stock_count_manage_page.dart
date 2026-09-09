// Flutter imports:
import 'package:flutter/material.dart';
import 'package:design_system/theme/app_colors.dart';

// Package imports:
import 'package:design_system/widgets/app_bar.dart';
import 'package:design_system/widgets/snack_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:design_system/widgets/dialogs.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_item_picker_widget.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_manage_state.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_manage_view_model.dart';

class StockCountManagePage extends StatefulWidget {
  final String? stockCountId;

  const StockCountManagePage({super.key, this.stockCountId});

  @override
  State<StatefulWidget> createState() => _StockCountManagePageState();
}

class _StockCountManagePageState extends State<StockCountManagePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _noteController = TextEditingController();

  late CustomSnackBar _snackBar;
  late StockCountManageViewModel _viewModel;

  bool get _isViewOnly => widget.stockCountId != null;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<StockCountManageViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getStockCountById(widget.stockCountId);
    });
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.error != null) {
      _snackBar.hideAll();
      _snackBar.showErrorSnackBar(state.error!);
      _viewModel.consumeError();
    }
    if (state.created != null) {
      _viewModel.consumeCreated();
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _noteController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(
        _isViewOnly ? Languages.of(context).stockCountManageTitle : Languages.of(context).stockCountCreateTitle,
        actions: _isViewOnly
            ? null
            : [
                IconButton(
                  splashRadius: 20,
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                ),
              ],
      ),
      body: ValueListenableBuilder<StockCountManageState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) {
          if (_isViewOnly) {
            return _buildDetail(state.stockCount);
          }
          return _buildCreateForm(state);
        },
      ),
    );
  }

  Widget _buildDetail(StockCount? stockCount) {
    if (stockCount == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          stockCount.countNo,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          stockCount.getCreatedDate(),
          style: TextStyle(color: AppColors.of(context).textSecondary),
        ),
        if (stockCount.note.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(stockCount.note),
        ],
        const SizedBox(height: 16),
        Divider(height: 1),
        ...stockCount.items.map(
          (item) => Column(
            children: [
              ListTile(
                title: Text('สินค้า ${item.productId}'),
                subtitle: Text('ในระบบ ${item.systemQuantity} / นับได้ ${item.countedQuantity}'),
                trailing: Text(
                  item.delta == 0 ? 'ตรงกัน' : (item.delta > 0 ? '+${item.delta}' : '${item.delta}'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.delta == 0 ? AppColors.of(context).textSecondary : (item.delta > 0 ? Colors.green : Colors.red),
                  ),
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateForm(StockCountManageState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'หมายเหตุ',
              hintText: 'โปรดระบุหมายเหตุ (ถ้ามี)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Expanded(
          child: state.items.isEmpty
              ? Center(
                  child: Text(
                    'ยังไม่มีสินค้าที่นับ',
                    style: TextStyle(color: AppColors.of(context).textSecondary),
                  ),
                )
              : ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(item.productName),
                          subtitle: Text('ล็อต ${item.lotNumber}, ในระบบ ${item.systemQuantity}'),
                          trailing: SizedBox(
                            width: 140,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    key: ValueKey(item.stockId),
                                    initialValue: item.counted.toString(),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(labelText: 'นับได้'),
                                    onChanged: (value) {
                                      _viewModel.updateCounted(index, int.tryParse(value) ?? -1);
                                    },
                                  ),
                                ),
                                IconButton(
                                  splashRadius: 20,
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _viewModel.removeItem(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มสินค้า'),
            ),
          ),
        ),
      ],
    );
  }

  void _addItem() {
    showCenterDialog(
      context: context,
      builder: (context) => StockCountItemPickerWidget(
        onSelected: (item) {
          _viewModel.addItem(item);
        },
      ),
    );
  }

  void _submit() {
    if (_viewModel.state.value.items.isEmpty) {
      _snackBar.hideAll();
      _snackBar.showErrorSnackBar('โปรดเพิ่มสินค้าอย่างน้อย 1 รายการ');
      return;
    }
    _viewModel.createStockCount(_noteController.text);
  }
}
