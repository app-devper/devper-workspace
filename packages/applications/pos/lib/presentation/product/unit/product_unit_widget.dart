// Flutter imports:
import 'package:flutter/material.dart';
import 'package:design_system/theme/app_colors.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/core/core_widget.dart';
import 'package:design_system/widgets/dialogs.dart';
import 'package:pos/presentation/product/unit/product_unit_view_model.dart';
import 'package:pos/presentation/product/unit/product_volume_unit_widget.dart';

class ProductUnitWidget extends StatefulWidget {
  final ProductUnit? unit;
  final Function(ProductUnit) onComplete;

  const ProductUnitWidget({
    super.key,
    this.unit,
    required this.onComplete,
  });

  @override
  State<StatefulWidget> createState() => _ProductUnitWidgetState();
}

class _ProductUnitWidgetState extends State<ProductUnitWidget> {
  final _formKey = GlobalKey<FormState>();

  final _unitController = TextEditingController();
  final _unitFocus = FocusNode();
  final _sizeController = TextEditingController();
  final _sizeFocus = FocusNode();
  final _costPriceController = TextEditingController();
  final _costPriceFocus = FocusNode();
  final _volumeController = TextEditingController();
  final _volumeFocus = FocusNode();
  final _barcodeController = TextEditingController();
  final _barcodeFocus = FocusNode();

  String _volumeUnit = 'ml';

  late ProductUnitViewModel _viewModel;

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
    _viewModel = sl<ProductUnitViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    if (widget.unit != null) {
      _sizeController.text = widget.unit!.size.toString();
      _unitController.text = widget.unit!.unit;
      _costPriceController.text = widget.unit!.costPrice.toString();
      if (widget.unit!.volume == 0) {
        _volumeController.text = '';
      } else {
        _volumeController.text = widget.unit!.volume.toString();
      }
      _barcodeController.text = widget.unit!.barcode;
      if (widget.unit!.volumeUnit.isNotEmpty) {
        _volumeUnit = widget.unit!.volumeUnit;
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _viewModel.dispose();
    _unitController.dispose();
    _unitFocus.dispose();
    _sizeController.dispose();
    _sizeFocus.dispose();
    _costPriceController.dispose();
    _costPriceFocus.dispose();
    _barcodeController.dispose();
    _barcodeFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildUnit();
  }

  Widget _buildUnit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleBar(
          title: widget.unit == null ? "เพิ่มหน่วยนับใหม่" : "แก้ไขหน่วยนับ ${widget.unit!.unit}",
          onBack: () {
            Navigator.of(context).pop();
          },
          action: 'ยืนยัน',
          onAction: () {
            if (_formKey.currentState!.validate()) {
              if (widget.unit != null) {
                _viewModel.updateProductUnitById(
                  widget.unit!.id,
                  ProductUnitParam(
                    unit: _unitController.text,
                    size: int.parse(_sizeController.text),
                    costPrice: double.parse(_costPriceController.text),
                    volume: _volumeController.text.isEmpty ? 0 : double.parse(_volumeController.text),
                    barcode: _barcodeController.text,
                    productId: widget.unit!.productId,
                    volumeUnit: _volumeUnit,
                  ),
                );
              } else {
                _viewModel.addProductUnit(
                  ProductUnitParam(
                    unit: _unitController.text,
                    size: int.parse(_sizeController.text),
                    costPrice: double.parse(_costPriceController.text),
                    volume: _volumeController.text.isEmpty ? 0 : double.parse(_volumeController.text),
                    barcode: _barcodeController.text,
                    productId: widget.unit!.productId,
                    volumeUnit: _volumeUnit,
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
                  'ข้อมูลหน่วยนับ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'โปรดระบุข้อมูลหน่วยนับของสินค้า',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.of(context).textPrimary.withValues(alpha: 0.6),
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
                            flex: 2,
                            child: TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              focusNode: _unitFocus,
                              controller: _unitController,
                              keyboardType: TextInputType.text,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: buildInputDecoration(
                                context: context,
                                labelText: 'ชื่อหน่วยนับ',
                                hintText: 'โปรดระบุชื่อหน่วยนับ',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'โปรดระบุชื่อหน่วยนับ';
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
                                LengthLimitingTextInputFormatter(3),
                              ],
                              focusNode: _sizeFocus,
                              controller: _sizeController,
                              readOnly: widget.unit != null && widget.unit!.size == 1,
                              keyboardType: TextInputType.number,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: buildInputDecoration(
                                context: context,
                                labelText: 'ขนาดบรรจุ',
                                hintText: '',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'โปรดระบุขนาดบรรจุ';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'ขนาดบรรจุต้องเป็นตัวเลขเท่านั้น';
                                } else if (int.parse(value) < 1) {
                                  return 'ขนาดบรรจุต้องมากกว่า 0';
                                }
                                return null;
                              },
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 2,
                            child: TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              focusNode: _costPriceFocus,
                              controller: _costPriceController,
                              keyboardType: TextInputType.number,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: buildInputDecoration(
                                context: context,
                                labelText: 'ราคาทุนต่อหน่วย',
                                hintText: 'โปรดระบุราคาทุนต่อหน่วย',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'โปรดระบุราคาทุนต่อหน่วย';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'ราคาทุนต่อหน่วยต้องเป็นตัวเลขเท่านั้น';
                                } else if (double.parse(value) <= 0) {
                                  return 'ราคาทุนต่อหน่วยต้องมากกว่า 0';
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
                              focusNode: _volumeFocus,
                              controller: _volumeController,
                              keyboardType: TextInputType.number,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: buildInputDecoration(
                                context: context,
                                labelText: 'ปริมาณหรือน้ำหนัก',
                                hintText: '',
                                suffix: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: InkWell(
                                    onTap: () {
                                      _showVolumeUnitDialog();
                                    },
                                    child: Center(
                                      child: Text(
                                        _volumeUnit,
                                        style: const TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                if (double.tryParse(value) == null) {
                                  return 'ปริมาณต้องเป็นตัวเลขเท่านั้น';
                                } else if (double.parse(value) <= 0) {
                                  return 'ปริมาณต้องมากกว่า 0';
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
                        children: [
                          Flexible(
                              child: TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(20),
                            ],
                            focusNode: _barcodeFocus,
                            controller: _barcodeController,
                            keyboardType: TextInputType.text,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: buildInputDecoration(
                              context: context,
                              labelText: 'บาร์โค้ด',
                              hintText: 'โปรดระบุบาร์โค้ด',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'โปรดระบุบาร์โค้ด';
                              }
                              return null;
                            },
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const Spacer(),
                widget.unit != null && widget.unit!.size != 1
                    ? TextButton(
                        onPressed: () {
                          showConfirmDialog(context, 'ยืนยันการลบหน่วยนับ ${widget.unit!.unit}', () {
                            _viewModel.removeProductUnitById(widget.unit!.id);
                          });
                        },
                        child: Text(
                          'ลบหน่วยนับ ${widget.unit!.unit}',
                          style: const TextStyle(
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

  void _showVolumeUnitDialog() {
    showCenterDialog(
      context: context,
      minWidth: 320,
      minHeight: 400,
      maxHeight: 400,
      maxWidth: 320,
      builder: (context) {
        return ProductVolumeUnitWidget(
          unit: _volumeUnit,
          onSelected: (value) {
            setState(() {
              _volumeUnit = value;
            });
          },
        );
      },
    );
  }
}
