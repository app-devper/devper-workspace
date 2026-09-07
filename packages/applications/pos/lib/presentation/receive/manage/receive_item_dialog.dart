import 'package:flutter/material.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/receive/receive_item.dart';

class ReceiveItemDialog extends StatefulWidget {
  final String receiveId;
  final List<Product> products;
  const ReceiveItemDialog(
      {super.key, required this.receiveId, required this.products});

  @override
  State<ReceiveItemDialog> createState() => _ReceiveItemDialogState();
}

class _ReceiveItemDialogState extends State<ReceiveItemDialog> {
  final _form = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _cost = TextEditingController();
  final _lot = TextEditingController();
  final _expiry = TextEditingController();
  Product? _product;

  @override
  void dispose() {
    for (final controller in [_quantity, _cost, _lot, _expiry]) {
      controller.dispose();
    }
    super.dispose();
  }

  DateTime? _expiryDate(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return null;
    final date = DateTime.tryParse(value);
    return date != null && date.toIso8601String().startsWith(value)
        ? date
        : null;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('เพิ่มรายการรับสินค้า'),
        content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
                child: Form(
              key: _form,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<Product>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'สินค้า'),
                  items: widget.products
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p.name)))
                      .toList(),
                  onChanged: (p) => setState(() {
                    _product = p;
                    _cost.text = '${p?.costPrice ?? 0}';
                  }),
                  validator: (p) => p == null ? 'เลือกสินค้า' : null,
                ),
                TextFormField(
                    controller: _quantity,
                    decoration: InputDecoration(
                        labelText: 'จำนวน (${_product?.unit ?? "หน่วยหลัก"})'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0
                        ? null
                        : 'ระบุจำนวนเต็มมากกว่า 0'),
                TextFormField(
                    controller: _cost,
                    decoration:
                        const InputDecoration(labelText: 'ต้นทุนต่อหน่วย'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      return n != null && n.isFinite && n > 0
                          ? null
                          : 'ระบุต้นทุนมากกว่า 0';
                    }),
                TextFormField(
                    controller: _lot,
                    decoration: const InputDecoration(labelText: 'เลขล็อต'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'ระบุเลขล็อต' : null),
                TextFormField(
                    controller: _expiry,
                    decoration: const InputDecoration(
                        labelText: 'วันหมดอายุ (YYYY-MM-DD)'),
                    validator: (v) => _expiryDate(v ?? '') == null
                        ? 'ระบุวันที่ให้ถูกต้อง'
                        : null),
              ]),
            ))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก')),
          FilledButton(
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                Navigator.pop(
                    context,
                    ReceiveItem(
                      receiveId: widget.receiveId,
                      productId: _product!.id,
                      product: _product,
                      quantity: int.parse(_quantity.text),
                      costPrice: double.parse(_cost.text),
                      lotNumber: _lot.text.trim(),
                      expireDate:
                          _expiryDate(_expiry.text)!.toUtc().toIso8601String(),
                    ));
              },
              child: const Text('เพิ่มรายการ')),
        ],
      );
}
