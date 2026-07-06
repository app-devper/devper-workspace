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
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/presentation/core/core_widget.dart';
import 'receive_add_state.dart';
import 'receive_add_view_model.dart';

class ReceiveAddPage extends StatefulWidget {
  final Function() onBack;
  final Function() onAdd;

  const ReceiveAddPage({
    super.key,
    required this.onBack,
    required this.onAdd,
  });

  @override
  State<StatefulWidget> createState() => _ReceiveAddPageState();
}

class _ReceiveAddPageState extends State<ReceiveAddPage> {
  final _formKey = GlobalKey<FormState>();

  final _referenceEditingController = TextEditingController();

  final _viewNode = FocusNode();
  final _referenceNode = FocusNode();

  late ReceiveAddViewModel _viewModel;

  Supplier? _supplier;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ReceiveAddViewModel>();
    _viewModel.states.stream.listen((state) {
      if (state is ErrorState) {
        hideLoadingDialog(context);
        showAlertDialog(context, state.message, () {});
      } else if (state is LoadingState) {
        showLoadingDialog(context);
      } else if (state is CreateProductState) {
        hideLoadingDialog(context);
        widget.onAdd();
      }
    });

    _viewModel.getCategories();
  }

  @override
  void dispose() {
    _viewNode.dispose();
    _referenceNode.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          title: "เพิ่มใบรับสินค้า",
          onBack: () {
            widget.onBack();
          },
          action: "เพิ่มใบรับ",
          onAction: () {
            if (_formKey.currentState!.validate()) {

            }
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildBody(),
        )
      ],
    );
  }

  _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Form(
        key: _formKey,
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
                    const SizedBox(height: 8),
                    Text(
                      'โปรดระบุข้อมูล',
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  _buildFormInfo() {
    final showSupplier = _supplier != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(50),
          ],
          focusNode: _referenceNode,
          controller: _referenceEditingController,
          keyboardType: TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: buildInputDecoration(
            labelText: 'เลขที่อ้างอิง',
            hintText: 'โปรดระบุเลขที่อ้างอิง',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'ข้อมูลผู้ส่งสินค้า',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const CircleAvatar(
            radius: 20,
            child: Icon(Icons.store),
          ),
          title: Text(
            !showSupplier ? 'ผู้ส่งสินค้า' : _supplier?.name ?? "",
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Text(
            !showSupplier ? 'เลือกผู้ส่งสินค้า' : _supplier?.phone ?? "",
            style: const TextStyle(fontSize: 14),
          ),
          trailing: !showSupplier
              ? const Icon(Icons.arrow_forward_ios, size: 16)
              : IconButton(
            splashRadius: 16,
            onPressed: () {
              setState(() {

              });
            },
            color: Colors.red,
            icon: const Icon(Icons.close, size: 24),
          ),
          onTap: () {

          },
        ),
      ],
    );
  }

}
