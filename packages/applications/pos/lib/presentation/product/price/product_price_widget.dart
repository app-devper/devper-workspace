// Flutter imports:
import 'package:flutter/material.dart';
import 'package:design_system/theme/app_colors.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/core/core_widget.dart';
import 'package:pos/presentation/product/price/product_price_view_model.dart';

class ProductPriceWidget extends StatefulWidget {
  final ProductUnit unit;
  final ProductPrice? price;
  final List<ProductPrice> prices;
  final Function(ProductPrice) onComplete;

  const ProductPriceWidget({
    super.key,
    required this.unit,
    required this.prices,
    required this.onComplete,
    this.price,
  });

  @override
  State<StatefulWidget> createState() => _ProductPriceWidgetState();
}

class _ProductPriceWidgetState extends State<ProductPriceWidget> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _priceFocus = FocusNode();

  ItemType? customerType;

  late ProductPriceViewModel _viewModel;

  bool _loadingShown = false;

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.loading && !_loadingShown) {
      _loadingShown = true;
      showLoadingDialog(context);
    } else if (!state.loading && _loadingShown) {
      _loadingShown = false;
      hideLoadingDialog(context);
    }
    if (state.error != null) {
      final message = state.error!;
      _viewModel.consumeError();
      showAlertDialog(context, message, () {});
    }
    if (state.completed != null) {
      final data = state.completed!;
      _viewModel.consumeCompleted();
      Navigator.of(context).pop();
      widget.onComplete(data);
    }
  }

  @override
  void initState() {
    _viewModel = sl<ProductPriceViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    if (widget.price != null) {
      _priceController.text = widget.price!.price.toString();
      setState(() {
        customerType = customerTypes.firstWhere((element) => element.type == widget.price!.customerType);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _priceController.dispose();
    _priceFocus.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ItemType> customers = [];
    if (widget.price != null) {
      customers = customerTypes.where((customer) => customer.type == widget.price!.customerType).toList();
    } else {
      customers = customerTypes.where((customer) => !widget.prices.any((element) => element.customerType == customer.type)).toList();
      if (customers.isNotEmpty) {
        setState(() {
          customerType = customers.first;
        });
      }
    }
    _priceFocus.requestFocus();
    return _buildProductPrice(widget.unit, customers);
  }

  Widget _buildProductPrice(ProductUnit unit, List<ItemType> customers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleBar(
          title: widget.price == null ? "เพิ่มราคาขายใหม่" : "แก้ไขราคาขาย ${widget.price!.getCustomerTypeDisplay()}",
          onBack: () {
            Navigator.of(context).pop();
          },
          action: 'ยืนยัน',
          onAction: () {
            if (_formKey.currentState!.validate()) {
              if (widget.price != null) {
                _viewModel.updateProductPriceById(
                  widget.price!.id,
                  ProductPriceParam(
                    productId: unit.productId,
                    unitId: unit.id,
                    price: double.parse(_priceController.text),
                    customerType: customerType!.type,
                  ),
                );
              } else {
                _viewModel.addProductPrice(ProductPriceParam(
                  productId: unit.productId,
                  unitId: unit.id,
                  price: double.parse(_priceController.text),
                  customerType: customerType!.type,
                ));
              }
            }
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 64),
                Text(
                  'ข้อมูลราคาขาย "${unit.unit}"',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'โปรดระบุข้อมูลราคาขาย "${unit.unit}"',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.of(context).textPrimary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: DropdownButtonFormField<ItemType>(
                          validator: (value) {
                            if (value == null) {
                              return 'โปรดเลือกประเภทลูกค้า';
                            }
                            return null;
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          decoration: buildInputDecoration(
                            context: context,
                            labelText: 'ผูกกับประเภทลูกค้า',
                            hintText: 'เลือกประเภทลูกค้า',
                          ),
                          focusColor: Colors.transparent,
                          initialValue: customerType,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          items: customers.map<DropdownMenuItem<ItemType>>((ItemType value) {
                            return DropdownMenuItem<ItemType>(
                              value: value,
                              child: Text(value.name),
                            );
                          }).toList(),
                          onChanged: (ItemType? newValue) {
                            setState(() {
                              customerType = newValue;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          focusNode: _priceFocus,
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: buildInputDecoration(
                            context: context,
                            labelText: 'ราคาขายต่อหน่วย',
                            hintText: '0.00',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'โปรดระบุราคาขายต่อหน่วย';
                            }
                            if (double.tryParse(value) == null) {
                              return 'ราคาขายต่อหน่วยต้องเป็นตัวเลขเท่านั้น';
                            } else if (double.parse(value) <= 0) {
                              return 'ราคาขายต่อหน่วยต้องมากกว่า 0';
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                widget.price != null && widget.price!.customerType != "General"
                    ? TextButton(
                        onPressed: () {
                          showConfirmDialog(
                            context,
                            'ยืนยันการลบราคาขาย ${widget.price!.getCustomerTypeDisplay()}',
                            () {
                              _viewModel.removeProductPriceById(widget.price!.id);
                            },
                          );
                        },
                        child: const Text(
                          'ลบราคาขาย',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        )
      ],
    );
  }
}
