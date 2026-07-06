// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/presentation/core/core_widget.dart';
import 'receive_edit_state.dart';
import 'receive_edit_view_model.dart';

class ReceiveEditPage extends StatefulWidget {
  final Receive data;
  final Function() onBack;
  final Function() onEdit;
  final Function() onRemove;

  const ReceiveEditPage({
    super.key,
    required this.data,
    required this.onBack,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  State<StatefulWidget> createState() => _ReceiveEditPageState();
}

class _ReceiveEditPageState extends State<ReceiveEditPage> {
  final _nameEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();

  final _nameNode = FocusNode();
  final _descriptionNode = FocusNode();

  late ReceiveEditViewModel _viewModel;

  ItemType? _category;
  final List<ItemType> _categories = categoryTypes;

  ItemType? _status;
  final List<ItemType> _productStatus = productStatus;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ReceiveEditViewModel>();
    _viewModel.states.listen((state) {
      if (state is ErrorState) {
        hideLoadingDialog(context);
      } else if (state is LoadingState) {
        showLoadingDialog(context);
      }
    });
  }

  @override
  void dispose() {
    _nameNode.dispose();
    _descriptionNode.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          title: widget.data.code,
          onBack: () {
            widget.onBack();
          },
          action: "ยืนยัน",
          onAction: () {},
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildBody(),
        )
      ],
    );
  }

  void _setupReceive(Receive data) {}

  _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'ข้อมูลทั่วไป',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'โปรดระบุข้อมูลสินค้า',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildFormInfo(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
          TextButton(
            onPressed: () => _showConfirmDialog(context),
            child: const Text(
              "ลบสินค้า",
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildFormInfo() {
    return Column(
      children: <Widget>[
        DropdownButtonFormField<ItemType>(
          validator: (value) {
            return null;
          },
          decoration: buildInputDecoration(
            labelText: 'ประเภทสินค้า',
            hintText: 'โปรดเลือกประเภทสินค้า',
          ),
          value: _category,
          onChanged: (value) {
            setState(() {
              _category = value;
            });
          },
          items: _categories.map((ItemType value) {
            return DropdownMenuItem<ItemType>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(50),
          ],
          focusNode: _nameNode,
          controller: _nameEditingController,
          keyboardType: TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: buildInputDecoration(
            labelText: 'ชื่อสินค้า',
            hintText: 'โปรดระบุชื่อสินค้า',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'โปรดระบุชื่อสินค้า';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
          ],
          focusNode: _descriptionNode,
          controller: _descriptionEditingController,
          keyboardType: TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: buildInputDecoration(
            labelText: 'คำอธิบายสินค้า',
            hintText: 'โปรดระบุคำอธิบายสินค้า',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ItemType>(
          validator: (value) {
            return null;
          },
          decoration: buildInputDecoration(
            labelText: 'การแสดงข้อมูลสินค้า',
            hintText: 'โปรดเลือกการแสดงข้อมูลสินค้า',
          ),
          value: _status,
          onChanged: (value) {
            setState(() {
              _status = value;
            });
          },
          items: _productStatus.map((ItemType value) {
            return DropdownMenuItem<ItemType>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  _showConfirmDialog(BuildContext context) {
    showConfirmDialog(context, "ต้องการลบสินค้าใช่หรือไม่", () {

    });
  }
}
