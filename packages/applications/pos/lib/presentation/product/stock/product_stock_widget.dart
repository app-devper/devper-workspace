// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/date_ext.dart';
import 'package:common/core/ext/number_ext.dart';
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/widgets/title_bar.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/core/core_widget.dart';
import 'package:pos/presentation/product/stock/product_stock_view_model.dart';

class ProductStockWidget extends StatefulWidget {
  final ProductUnit unit;
  final ProductPrice price;
  final ProductStock? stock;
  final Function(ProductStock) onComplete;

  const ProductStockWidget({
    super.key,
    required this.unit,
    required this.price,
    required this.onComplete,
    this.stock,
  });

  @override
  State<StatefulWidget> createState() => _ProductStockWidgetState();
}

class _ProductStockWidgetState extends State<ProductStockWidget> {
  final _formKey = GlobalKey<FormState>();
  final _lotNumberController = TextEditingController();
  final _lotNumberFocus = FocusNode();
  final _importController = TextEditingController();
  final _importFocus = FocusNode();
  final _importDateController = TextEditingController();
  final _importDateFocus = FocusNode();
  final _priceController = TextEditingController();
  final _priceFocus = FocusNode();
  final _costPriceController = TextEditingController();
  final _costPriceFocus = FocusNode();
  final _expireDateController = TextEditingController();
  final _expireDateFocus = FocusNode();

  late ProductStockViewModel _viewModel;

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
    _viewModel = sl<ProductStockViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    if (widget.stock != null) {
      _importController.text = widget.stock!.import.toString();
      _importDateController.text = widget.stock!.importDate.formatDate();
      if (widget.stock!.price > 0) {
        _priceController.text = widget.stock!.price.toString();
      }
      if (widget.stock!.costPrice > 0) {
        _costPriceController.text = widget.stock!.costPrice.toString();
      }
      _expireDateController.text = widget.stock!.expireDate.formatDate();
      _lotNumberController.text = widget.stock!.lotNumber;
    } else {
      _importDateController.text = getCurrentDate().formatDate();
    }
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _importController.dispose();
    _importFocus.dispose();
    _priceController.dispose();
    _priceFocus.dispose();
    _costPriceController.dispose();
    _costPriceFocus.dispose();
    _importDateController.dispose();
    _importDateFocus.dispose();
    _lotNumberController.dispose();
    _lotNumberFocus.dispose();
    _expireDateController.dispose();
    _expireDateFocus.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildStock(widget.unit);
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.tryParseDate() ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Widget _buildStock(ProductUnit unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleBar(
          title: widget.stock == null ? "เพิ่มสต็อก ร้านค้า" : "แก้ไขสต็อก ${widget.stock!.importDate.formatDate()}",
          onBack: () {
            Navigator.of(context).pop();
          },
          action: 'ยืนยัน',
          onAction: () {
            if (_formKey.currentState!.validate()) {
              if (widget.stock != null) {
                _viewModel.updateProductStockById(
                  widget.stock!.id,
                  ProductStockParam(
                    quantity: int.tryParse(_importController.text) ?? 0,
                    importDate: _importDateController.text.toServerDate(),
                    price: double.tryParse(_priceController.text) ?? 0,
                    costPrice: double.tryParse(_costPriceController.text) ?? 0,
                    lotNumber: _lotNumberController.text,
                    expireDate: _expireDateController.text.toServerDate(),
                    productId: widget.unit.productId,
                    unitId: widget.unit.id,
                  ),
                );
              } else {
                _viewModel.addProductStock(
                  ProductStockParam(
                    quantity: int.tryParse(_importController.text) ?? 0,
                    importDate: _importDateController.text.toServerDate(),
                    price: double.tryParse(_priceController.text) ?? 0,
                    costPrice: double.tryParse(_costPriceController.text) ?? 0,
                    lotNumber: _lotNumberController.text,
                    expireDate: _expireDateController.text.toServerDate(),
                    productId: widget.unit.productId,
                    unitId: widget.unit.id,
                  ),
                );
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
                  'ข้อมูลสต็อก "${unit.unit}"',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'โปรดระบุข้อมูลสต็อก',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(4),
                              ],
                              focusNode: _importFocus,
                              controller: _importController,
                              readOnly: widget.stock != null,
                              keyboardType: TextInputType.number,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: buildInputDecoration(
                                labelText: 'จำนวนที่นำเข้า',
                                hintText: 'โปรดระบุจำนวนที่นำเข้า',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty || int.tryParse(value) == 0) {
                                  return 'โปรดระบุจำนวนที่นำเข้า';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'จำนวนที่นำเข้าต้องเป็นตัวเลขเท่านั้น';
                                } else if (int.tryParse(value) != null && int.tryParse(value)! < 0) {
                                  return 'จำนวนที่นำเข้าต้องมากกว่า 0';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                DateFormatter(),
                              ],
                              focusNode: _importDateFocus,
                              controller: _importDateController,
                              keyboardType: TextInputType.number,
                              decoration: buildInputDecoration(
                                labelText: 'วันที่นำเข้า',
                                hintText: 'โปรดระบุวันที่นำเข้า',
                                suffix: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  splashRadius: 20,
                                  color: Colors.blue,
                                  onPressed: () => _selectDate(_importDateController),
                                ),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'โปรดระบุวันที่นำเข้า';
                                }
                                if (value.tryParseDate() == null) {
                                  return 'รูปแบบวันที่ไม่ถูกต้อง';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              focusNode: _priceFocus,
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: buildInputDecoration(
                                labelText: 'ราคาขายต่อหน่วย',
                                hintText: '฿${formatDouble(widget.price.price)} จากหน่วยนับ',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                if (double.tryParse(value) == null) {
                                  return 'ราคาขายต่อหน่วยต้องเป็นตัวเลขเท่านั้น';
                                } else if (double.tryParse(value)! < 0) {
                                  return 'ราคาขายต่อหน่วยต้องมากกว่า 0';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              focusNode: _costPriceFocus,
                              controller: _costPriceController,
                              keyboardType: TextInputType.number,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: buildInputDecoration(
                                labelText: 'ราคาทุนต่อหน่วย',
                                hintText: '฿${formatDouble(widget.unit.costPrice)} จากหน่วยนับ',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                if (double.tryParse(value) == null) {
                                  return 'ราคาทุนต่อหน่วยต้องเป็นตัวเลขเท่านั้น';
                                } else if (double.tryParse(value)! < 0) {
                                  return 'ราคาทุนต่อหน่วยต้องมากกว่า 0';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              flex: 1,
                              child: TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(20),
                                ],
                                focusNode: _lotNumberFocus,
                                controller: _lotNumberController,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: buildInputDecoration(
                                  labelText: 'หมายเลขล็อต',
                                  hintText: 'โปรดระบุหมายเลขล็อต',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  return null;
                                },
                              )),
                          const SizedBox(width: 16),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                DateFormatter(),
                              ],
                              focusNode: _expireDateFocus,
                              controller: _expireDateController,
                              keyboardType: TextInputType.number,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: buildInputDecoration(
                                labelText: 'วันหมดอายุ',
                                hintText: 'โปรดระบุวันหมดอายุ',
                                suffix: IconButton(
                                  splashRadius: 20,
                                  color: Colors.blue,
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => _selectDate(_expireDateController),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'โปรดระบุวันหมดอายุ';
                                }
                                if (value.tryParseDate() == null) {
                                  return 'รูปแบบวันที่ไม่ถูกต้อง';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const Spacer(),
                widget.stock != null
                    ? TextButton(
                        onPressed: () {
                          showConfirmDialog(
                            context,
                            'ยืนยันการลบสต็อกสินค้า ${widget.stock!.importDate.formatDate()}',
                            () {
                              _viewModel.removeProductStockById(widget.stock!.id);
                            },
                          );
                        },
                        child: const Text(
                          'ลบสต็อกสินค้า',
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
