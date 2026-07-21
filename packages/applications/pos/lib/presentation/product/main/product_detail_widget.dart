// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/date_ext.dart';
import 'package:common/core/ext/number_ext.dart';
import 'package:common/core/widgets/title_bar.dart';

// Project imports:
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/core/dialog_widget.dart';
import 'package:pos/presentation/product/history/product_history_widget.dart';
import 'package:pos/presentation/product/price/product_price_widget.dart';
import 'package:pos/presentation/product/stock/product_stock_quantity_widget.dart';
import 'package:pos/presentation/product/stock/product_stock_sequence_widget.dart';
import 'package:pos/presentation/product/stock/product_stock_widget.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_history_widget.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_widget.dart';
import 'package:pos/presentation/product/unit/product_unit_widget.dart';
import 'package:pos/presentation/theme.dart';

class ProductDetailWidget extends StatefulWidget {
  final Product product;
  final Function() onBack;
  final Function() onEdit;
  final Function() onClickEdit;
  final Function(String productId)? onClearSoldFirst;

  const ProductDetailWidget({
    super.key,
    required this.onBack,
    required this.product,
    required this.onEdit,
    required this.onClickEdit,
    this.onClearSoldFirst,
  });

  @override
  State<StatefulWidget> createState() => _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends State<ProductDetailWidget>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 6, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          title: widget.product.name,
          onBack: () {
            widget.onBack();
          },
          action: "แก้ไข",
          onAction: () {
            widget.onClickEdit();
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: buildTabBar(),
        )
      ],
    );
  }

  Widget buildTabBar() {
    return Column(
      children: <Widget>[
        Stack(
          fit: StackFit.passthrough,
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            const Divider(height: 1),
            TabBar.secondary(
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
              isScrollable: false,
              labelColor: Colors.black,
              controller: _tabController,
              tabs: const <Widget>[
                Tab(
                  height: 36,
                  child: Text('ข้อมูลทั่วไป', maxLines: 1),
                ),
                Tab(
                  height: 36,
                  child: Text('หน่วยนับ', maxLines: 1),
                ),
                Tab(
                  height: 36,
                  child: Text('ราคา', maxLines: 1),
                ),
                Tab(
                  height: 36,
                  child: Text('สต็อก', maxLines: 1),
                ),
                Tab(
                  height: 36,
                  child: Text('ประวัติ', maxLines: 1),
                ),
                Tab(
                  height: 36,
                  child: Text('ปรับสต็อก', maxLines: 1),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(8.0),
                child: _buildProductInfo(widget.product),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: _buildUnits(widget.product),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: _buildPrices(widget.product),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: _buildStocks(widget.product),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: ProductHistoryWidget(
                  productId: widget.product.id,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: StockAdjustmentHistoryWidget(
                  productId: widget.product.id,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(Product product) {
    Color colorStatus = Colors.green;
    if (product.status == productStatusInactive) {
      colorStatus = Colors.red;
    }
    final drugInfo = product.drugInfo;
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                _buildListItem(
                    'ประเภทสินค้า', findCategoryType(product.category).name),
                _buildListItem('ชื่อสินค้า', product.name),
                if (product.nameEn != null && product.nameEn!.isNotEmpty)
                  _buildListItem('ชื่อสินค้า (EN)', product.nameEn!),
                _buildListItem('บาร์โค้ด/รหัส',
                    product.serialNumber.isEmpty ? '-' : product.serialNumber),
                _buildListItem('การแสดงข้อมูลสินค้า',
                    findProductStatus(product.status).name,
                    color: colorStatus),
                _buildListItem('สต็อกขั้นต่ำ', '${product.minStock}'),
                if (product.soldFirst > 0) ...[
                  _buildListItem(
                      'ขายก่อน (Sold First)', '${product.soldFirst}'),
                  if (widget.onClearSoldFirst != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            widget.onClearSoldFirst!(product.id);
                          },
                          child: const Text(
                            'ล้างค่าขายก่อน',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
                if (product.description != null &&
                    product.description!.isNotEmpty)
                  _buildListItem('คำอธิบาย', product.description!),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (product.drugRegistrations.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      'ทะเบียนยา',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...product.drugRegistrations.map(
                    (reg) => _buildListItem('', reg),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          if (drugInfo != null)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      'ข้อมูลยา',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (drugInfo.genericName != null &&
                      drugInfo.genericName!.isNotEmpty)
                    _buildListItem('ชื่อสามัญ', drugInfo.genericName!),
                  if (drugInfo.drugType != null &&
                      drugInfo.drugType!.isNotEmpty)
                    _buildListItem('ประเภทยา', drugInfo.drugType!),
                  if (drugInfo.dosageForm != null &&
                      drugInfo.dosageForm!.isNotEmpty)
                    _buildListItem('รูปแบบยา', drugInfo.dosageForm!),
                  if (drugInfo.strength != null &&
                      drugInfo.strength!.isNotEmpty)
                    _buildListItem('ความแรง', drugInfo.strength!),
                  if (drugInfo.indication != null &&
                      drugInfo.indication!.isNotEmpty)
                    _buildListItem('ข้อบ่งใช้', drugInfo.indication!),
                  if (drugInfo.dosage != null && drugInfo.dosage!.isNotEmpty)
                    _buildListItem('ขนาดยา', drugInfo.dosage!),
                  if (drugInfo.sideEffects != null &&
                      drugInfo.sideEffects!.isNotEmpty)
                    _buildListItem('ผลข้างเคียง', drugInfo.sideEffects!),
                  if (drugInfo.contraindications != null &&
                      drugInfo.contraindications!.isNotEmpty)
                    _buildListItem('ข้อห้ามใช้', drugInfo.contraindications!),
                  if (drugInfo.storageCondition != null &&
                      drugInfo.storageCondition!.isNotEmpty)
                    _buildListItem(
                        'เงื่อนไขการเก็บรักษา', drugInfo.storageCondition!),
                  if (drugInfo.manufacturer != null &&
                      drugInfo.manufacturer!.isNotEmpty)
                    _buildListItem('ผู้ผลิต', drugInfo.manufacturer!),
                  if (drugInfo.registrationNo != null &&
                      drugInfo.registrationNo!.isNotEmpty)
                    _buildListItem('เลขทะเบียน', drugInfo.registrationNo!),
                  if (drugInfo.isControlled != null)
                    _buildListItem(
                        'ยาควบคุม', drugInfo.isControlled! ? 'ใช่' : 'ไม่ใช่'),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    String title,
    String subtitle, {
    Color color = Colors.black,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
          trailing: Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 16.0,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(height: 1),
        )
      ],
    );
  }

  Widget _buildUnits(Product product) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      itemCount: product.units.length,
      itemBuilder: (context, index) {
        final unit = product.units[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      unit.unit,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    InkWell(
                      onTap: () {
                        _showEditUnitDialog(context, unit: unit);
                      },
                      child: const Text(
                        'แก้ไข',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer()
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  'บาร์โค้ด: ${unit.barcode}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'ขนาดบรรจุ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '${unit.size}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'ต้นทุน',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '฿${formatDouble(unit.costPrice)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'ปริมาณ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '${unit.volume > 0 ? unit.volume : "-"}${unit.volumeUnit}',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrices(Product product) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      itemCount: product.units.length,
      itemBuilder: (context, index) {
        final unit = product.units[index];
        final prices = product.getProductPricesUnit(unit.id);
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    unit.unit,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _showAddPriceDialog(context, unit: unit, prices: prices);
                    },
                    child: const Text(
                      'เพิ่มราคาขาย',
                      style: TextStyle(
                        color: CustomColor.primary,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 4.0),
                Text(
                  'ต้นทุนของสินค้า: ฿${formatDouble(unit.costPrice)}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ผูกกับประเภทลูกค้า',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        ...prices.map(
                          (e) => Row(
                            children: [
                              Text(
                                e.getCustomerTypeDisplay(),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              InkWell(
                                onTap: () {
                                  _showEditPriceDialog(
                                    context,
                                    unit: unit,
                                    price: e,
                                    prices: prices,
                                  );
                                },
                                child: const Text(
                                  'แก้ไข',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'ราคา',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        ...prices.map(
                          (e) => Text(
                            '฿${formatDouble(e.price)}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStocks(Product product) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      itemCount: product.units.length,
      itemBuilder: (context, index) {
        final unit = product.units[index];
        final stock = product.getProductStocksUnit(unit.id);
        final total = stock.fold(
            0, (previousValue, element) => previousValue + element.quantity);
        final price = product.getDefaultPriceUnit(unit.id);
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    unit.unit,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(children: [
                    TextButton(
                      onPressed: () {
                        _showEditStockSequenceDialog(context,
                            stocks: stock, unit: unit);
                      },
                      child: const Text(
                        'จัดเรียงสต็อก',
                        style: TextStyle(
                          color: CustomColor.primary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showAddStockDialog(context, unit: unit, price: price);
                      },
                      child: const Text(
                        'เพิ่มสต็อก',
                        style: TextStyle(
                          color: CustomColor.primary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ])
                ]),
                const SizedBox(height: 4.0),
                Text(
                  'คงเหลือรวมทั้งหมด: $total ${unit.unit}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'นำเข้าเมื่อ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        ...stock.map(
                          (e) => Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                e.importDate.formatShortDate(),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              InkWell(
                                onTap: () {
                                  _showEditStockDialog(
                                    context,
                                    unit: unit,
                                    price: price,
                                    stock: e,
                                  );
                                },
                                child: const Text(
                                  'แก้ไข',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'วันหมดอายุ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        ...stock.map(
                          (e) => Text(
                            e.expireDate.formatShortDate(),
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'ต้นทุน',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        ...stock.map(
                          (e) => e.costPrice > 0
                              ? Text(
                                  '฿${formatDouble(e.costPrice)}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  '฿${formatDouble(unit.costPrice)}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'ราคาขาย',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        ...stock.map(
                          (e) => e.price > 0
                              ? Text(
                                  '฿${formatDouble(e.price)}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  '฿${formatDouble(price.price)}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'นำเข้า',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        ...stock.map(
                          (e) => Text(
                            '${e.import}x',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'คงเหลือ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        ...stock.map(
                          (e) => InkWell(
                            onTap: () {
                              _showEditStockQuantityDialog(context, stock: e);
                            },
                            child: Text(
                              '${e.quantity}x',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 22.0),
                        ...stock.map(
                          (e) => SizedBox(
                            width: 32,
                            height: 24,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              splashRadius: 16,
                              icon: const Icon(Icons.tune, size: 18),
                              tooltip: 'ปรับสต็อก',
                              onPressed: () {
                                _showStockAdjustmentDialog(context, stock: e);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _showAddPriceDialog(
    BuildContext context, {
    required ProductUnit unit,
    required List<ProductPrice> prices,
  }) {
    showCenterDialog(
      context: context,
      builder: (context) => ProductPriceWidget(
        unit: unit,
        prices: prices,
        onComplete: (price) {
          widget.onEdit();
        },
      ),
    );
  }

  _showEditPriceDialog(
    BuildContext context, {
    required ProductUnit unit,
    required ProductPrice price,
    required List<ProductPrice> prices,
  }) {
    showCenterDialog(
      context: context,
      builder: (context) => ProductPriceWidget(
        unit: unit,
        prices: prices,
        price: price,
        onComplete: (price) {
          widget.onEdit();
        },
      ),
    );
  }

  _showEditUnitDialog(
    BuildContext context, {
    required ProductUnit unit,
  }) {
    showCenterDialog(
      context: context,
      builder: (context) => ProductUnitWidget(
        unit: unit,
        onComplete: (unit) {
          widget.onEdit();
        },
      ),
    );
  }

  void _showAddStockDialog(
    BuildContext context, {
    required ProductUnit unit,
    required ProductPrice price,
  }) {
    showCenterDialog(
      context: context,
      builder: (context) => ProductStockWidget(
        price: price,
        unit: unit,
        onComplete: (stock) {
          widget.onEdit();
        },
      ),
    );
  }

  void _showEditStockDialog(
    BuildContext context, {
    required ProductUnit unit,
    required ProductPrice price,
    required ProductStock stock,
  }) {
    showCenterDialog(
      context: context,
      builder: (context) => ProductStockWidget(
        price: price,
        stock: stock,
        unit: unit,
        onComplete: (stock) {
          widget.onEdit();
        },
      ),
    );
  }

  void _showEditStockQuantityDialog(
    BuildContext context, {
    required ProductStock stock,
  }) {
    showCenterDialog(
      minWidth: 320,
      minHeight: 430,
      maxHeight: 430,
      maxWidth: 320,
      context: context,
      builder: (context) => ProductStockQuantityWidget(
        stock: stock,
        onComplete: (stock) {
          widget.onEdit();
        },
      ),
    );
  }

  void _showStockAdjustmentDialog(
    BuildContext context, {
    required ProductStock stock,
  }) {
    showCenterDialog(
      minWidth: 360,
      minHeight: 560,
      maxHeight: 560,
      maxWidth: 360,
      context: context,
      builder: (context) => StockAdjustmentWidget(
        stock: stock,
        onComplete: () {
          widget.onEdit();
        },
      ),
    );
  }

  void _showEditStockSequenceDialog(
    BuildContext context, {
    required List<ProductStock> stocks,
    required ProductUnit unit,
  }) {
    showCenterDialog(
      context: context,
      builder: (context) => ProductStockSequenceWidget(
        stocks: stocks,
        unit: unit.unit,
        onComplete: (stock) {
          widget.onEdit();
        },
      ),
    );
  }
}
