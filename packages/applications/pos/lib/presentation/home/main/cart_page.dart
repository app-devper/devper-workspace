// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/date_ext.dart';
import 'package:common/core/ext/number_ext.dart';
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:design_system/widgets/dialogs.dart';
import 'package:pos/presentation/core/dialog_widget.dart';
import 'package:pos/presentation/customer/add/customer_add_page.dart';
import 'package:pos/presentation/home/main/cart_widget.dart';
import 'package:pos/presentation/home/main/customer_search.dart';
import 'package:pos/presentation/home/main/payment_screen.dart';
import 'package:pos/presentation/home/main/product_search.dart';
import 'package:design_system/theme/color.dart';
import 'cart_view_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<StatefulWidget> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with WidgetsBindingObserver {
  final _alertKey = GlobalKey();

  late CustomSnackBar _snackBar;
  late CartViewModel _viewModel;

  List<OrderItem> _orderItems = [];
  Function refreshCustomer = () {};

  DateTime currentDate = getCurrentDate();

  String? _patientId;
  String? _prescriberName;
  String? _pharmacistName;

  bool _loadingShown = false;
  bool _orderSavingShown = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _viewModel = sl<CartViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.prepareData();
    });
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.loading && !_loadingShown) {
      _loadingShown = true;
      _snackBar.hideAll();
      _snackBar.showLoadingSnackBar();
    } else if (!state.loading && _loadingShown) {
      _loadingShown = false;
      _snackBar.hideAll();
    }
    if (state.orderSaving && !_orderSavingShown) {
      _orderSavingShown = true;
      showLoadingDialog(context);
    } else if (!state.orderSaving && _orderSavingShown) {
      _orderSavingShown = false;
      hideLoadingDialog(context);
    }
    if (state.error != null) {
      final message = state.error!;
      _viewModel.consumeError();
      _snackBar.hideAll();
      _snackBar.showErrorSnackBar(message);
    }
    if (state.orderItems != null) {
      setState(() {
        _orderItems = state.orderItems!;
      });
    }
    if (state.orderResult != null) {
      _viewModel.consumeOrderResult();
      _snackBar.hideAll();
      _snackBar.showSnackBar(text: "Order success");
      _viewModel.clearCart();
      _viewModel.prepareData();
      setState(() {
        _patientId = null;
        _prescriberName = null;
        _pharmacistName = null;
      });
      if (_alertKey.currentContext != null) {
        Navigator.of(context).pop();
      }
    }
    if (state.orderError != null) {
      final message = state.orderError!;
      _viewModel.consumeOrderError();
      _snackBar.hideAll();
      _snackBar.showErrorSnackBar(message);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.state.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewModel.prepareData();
    }
  }

  static const double _tabletBreakpoint = 600;
  static const double _desktopBreakpoint = 850;

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    final width = MediaQuery.of(context).size.width;
    if (width >= _desktopBreakpoint) {
      return _buildDesktop();
    } else if (width >= _tabletBreakpoint) {
      return _buildTablet();
    } else {
      return _buildMobile();
    }
  }

  _buildMobile() {
    return Row(
      children: [
        Expanded(
          child: _buildCart(showSearchIcon: true),
        ),
        Container(width: 1, color: Colors.grey[200]),
        SizedBox(
          width: 50,
          child: _buildCartItem(),
        ),
      ],
    );
  }

  _buildTablet() {
    return Row(
      children: [
        Expanded(
          child: ProductSearch(
            onSelected: (serialNumber) {
              _viewModel.addOrderItem(serialNumber, _orderItems);
            },
          ),
        ),
        Container(width: 1, color: Colors.grey[200]),
        SizedBox(
          width: 340,
          child: _buildCart(),
        ),
        Container(width: 1, color: Colors.grey[200]),
        SizedBox(
          width: 50,
          child: _buildCartItem(),
        ),
      ],
    );
  }

  _buildDesktop() {
    return Row(
      children: [
        Expanded(
          child: ProductSearch(
            onSelected: (serialNumber) {
              _viewModel.addOrderItem(serialNumber, _orderItems);
            },
          ),
        ),
        Container(width: 1, color: Colors.grey[200]),
        SizedBox(
          width: 400,
          child: _buildCart(),
        ),
        Container(width: 1, color: Colors.grey[200]),
        SizedBox(
          width: 50,
          child: _buildCartItem(),
        ),
      ],
    );
  }

  _buildCart({bool showSearchIcon = false}) {
    final showCustomer = _viewModel.cartStore.customer != null;
    return Column(
      children: [
        Row(children: [
          if (showSearchIcon) ...[
            const SizedBox(width: 4),
            SizedBox(
              height: 40,
              width: 40,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                splashRadius: 20,
                onPressed: () {
                  _showProductDialog();
                },
                icon: const Icon(
                  Icons.search,
                  color: CustomColor.primary,
                ),
              ),
            )
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'ตะกร้าสินค้า #${_viewModel.cartStore.cartIndex + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ]),
        const Divider(height: 1),
        const ListTile(
          visualDensity: VisualDensity(vertical: -4),
          dense: true,
          title: Text(
            'รายการ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: SizedBox(
            width: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'จำนวน',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'ราคา',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        _buildCartOrderItems(),
        const Divider(height: 1),
        ListTile(
          leading: const CircleAvatar(
            radius: 20,
            child: Icon(Icons.person),
          ),
          title: Text(
            !showCustomer
                ? 'ข้อมูลลูกค้า'
                : _viewModel.cartStore.customer?.name ?? "",
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Text(
            !showCustomer
                ? 'เลือกลูกค้า'
                : _viewModel.cartStore.customer?.code ?? "",
            style: const TextStyle(fontSize: 14),
          ),
          trailing: !showCustomer
              ? const Icon(Icons.arrow_forward_ios, size: 16)
              : IconButton(
                  splashRadius: 16,
                  onPressed: () {
                    setState(() {
                      _viewModel.cartStore.customer = null;
                    });
                  },
                  color: Colors.red,
                  icon: const Icon(Icons.close, size: 24),
                ),
          onTap: () {
            _showCustomerDialog();
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: const CircleAvatar(
            radius: 20,
            child: Icon(Icons.medical_information_outlined),
          ),
          title: const Text(
            'ข้อมูลยาควบคุม',
            style: TextStyle(fontSize: 18),
          ),
          subtitle: Text(
            _hasComplianceInfo()
                ? 'ระบุแล้ว: ${_getComplianceSummary()}'
                : 'ไม่บังคับ ระบุเมื่อจำเป็น',
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showComplianceDialog();
          },
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('ราคาเฉพาะสินค้า'),
          trailing: Text('฿${formatDouble(_getPrice())}'),
        ),
        const Divider(height: 1),
        const ListTile(
          title: Text('ส่วนลด (%)'),
          trailing: Text('-'),
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text(
            'ยอดรวมสุทธิ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          trailing: Text(
            '฿${formatDouble(_getPrice())}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: _orderItems.isEmpty ? null : _showPaymentDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColor.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE8EDF3),
              disabledForegroundColor: const Color(0xFF596579),
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _orderItems.isEmpty
                      ? "เลือกสินค้าเพื่อเริ่มขาย"
                      : "ชำระเงิน (${_orderItems.length} รายการ)",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '฿${formatDouble(_getPrice())}',
                  style: const TextStyle(
                    height: 1.4,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  _buildCartItem() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _viewModel.cartStore.cartCount,
            itemBuilder: (context, index) {
              return CartItem(
                active: index == _viewModel.cartStore.cartIndex,
                index: index + 1,
                onTap: () {
                  _viewModel.selectCart(index);
                },
                haveOrder:
                    _viewModel.cartStore.cart[index]?.isNotEmpty ?? false,
              );
            },
          ),
        ),
        const Divider(height: 1),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            const Text(
              'วันนี้',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            Text(
              currentDate.formatShortDate(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  _buildCartOrderItems() {
    return Expanded(
      child: ListView.builder(
        itemCount: _orderItems.length,
        itemBuilder: (context, index) {
          final content = _orderItems[index];
          return CartOrderItem(
            title: content.product.name,
            quantity: content.quantity,
            price: content.priceType.price,
            unit: content.unit,
            discount: content.discount,
            priceDetail: content.getPriceDetail(),
            allowOversell: content.allowOversell,
            onToggleOversell: () {
              _viewModel.toggleAllowOversell(index, _orderItems);
            },
            onRemove: () {
              _viewModel.minusItem(index, _orderItems);
            },
            onAdd: () {
              _viewModel.plusItem(index, _orderItems);
            },
            onEdit: () {
              showInputNumberDialog(
                context,
                title: 'จำนวนสินค้า',
                onCompleted: (value) {
                  _viewModel.editItem(index, value, _orderItems);
                },
              );
            },
            onEditPrice: () {
              showEditOrderItemDialog(
                context,
                orderItem: content,
                onCompleted: (value) {
                  _viewModel.editOrderItem(index, value, _orderItems);
                },
                onRemove: () {
                  _viewModel.removeItem(index, _orderItems);
                },
              );
            },
          );
        },
      ),
    );
  }

  double _getPrice() {
    double price = 0;
    for (var x in _orderItems) {
      price += x.amountPriceWithDiscount();
    }
    return price;
  }

  _showCustomerDialog() {
    showRightDialog(
      context,
      builder: (context) => Column(
        children: [
          TitleBar(
            title: "เลือกลูกค้า",
            onBack: () {
              Navigator.pop(context);
            },
            action: "เพิ่มลูกค้า",
            onAction: () {
              _showAddCustomerDialog();
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: CustomerSearch(
              onRefresh: (func) {
                refreshCustomer = func;
              },
              onSelected: (Customer customer) {
                setState(() {
                  _viewModel.cartStore.customer = customer;
                });
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }

  bool _hasComplianceInfo() {
    return (_patientId?.isNotEmpty ?? false) ||
        (_prescriberName?.isNotEmpty ?? false) ||
        (_pharmacistName?.isNotEmpty ?? false);
  }

  String _getComplianceSummary() {
    final parts = [
      if (_patientId?.isNotEmpty ?? false) 'ผู้ป่วย: $_patientId',
      if (_prescriberName?.isNotEmpty ?? false) 'แพทย์: $_prescriberName',
      if (_pharmacistName?.isNotEmpty ?? false) 'เภสัชกร: $_pharmacistName',
    ];
    return parts.join(', ');
  }

  _showComplianceDialog() {
    final patientController = TextEditingController(text: _patientId);
    final prescriberController = TextEditingController(text: _prescriberName);
    final pharmacistController = TextEditingController(text: _pharmacistName);
    showCenterDialog(
      context: context,
      minWidth: 360,
      maxWidth: 360,
      minHeight: 420,
      maxHeight: 420,
      builder: (dialogContext) => Column(
        children: [
          TitleBar(
            title: "ข้อมูลยาควบคุม",
            onBack: () {
              Navigator.pop(dialogContext);
            },
            action: "บันทึก",
            onAction: () {
              setState(() {
                _patientId = patientController.text.trim();
                _prescriberName = prescriberController.text.trim();
                _pharmacistName = pharmacistController.text.trim();
              });
              Navigator.pop(dialogContext);
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: patientController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อ/รหัสผู้ป่วย',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: prescriberController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อแพทย์ผู้สั่งยา',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pharmacistController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อเภสัชกรผู้จ่ายยา',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showAddCustomerDialog() {
    showCenterDialog(
      context: context,
      builder: (context) => CustomerAddPage(onBack: () {
        Navigator.pop(context);
      }, onAdd: () {
        Navigator.pop(context);
        refreshCustomer();
      }),
    );
  }

  _showProductDialog() {
    showRightDialog(
      context,
      builder: (context) => Column(
        children: [
          TitleBar(
            title: "เลือกสินค้า",
            onBack: () {
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: ProductSearch(
              onSelected: (serialNumber) {
                _viewModel.addOrderItem(serialNumber, _orderItems);
              },
            ),
          ),
        ],
      ),
    );
  }

  _showPaymentDialog() {
    showCenterDialog(
      context: context,
      alertKey: _alertKey,
      builder: (dialogContext) => _buildPaymentScreen(dialogContext),
    );
  }

  _buildPaymentScreen(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          title: "ชำระเงิน",
          onBack: () {
            Navigator.pop(context);
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: PaymentScreen(
            amount: _getPrice(),
            onCompleted: (amount, typeMode) {
              _viewModel.createOrder(_getOrderParam(amount, typeMode));
            },
            onError: () {
              final snackBar =
                  CustomSnackBar(key: const Key("snackbar"), context: context);
              snackBar.showErrorSnackBar("คุณรับเงินน้อยกว่ายอดราคาสินค้า");
            },
          ),
        )
      ],
    );
  }

  _getOrderParam(amount, typeMode) {
    return CreateOrderParam(
      customerCode: _viewModel.cartStore.customer?.code ?? "",
      customerName: _viewModel.cartStore.customer?.name ?? "",
      amount: amount,
      items: _orderItems,
      type: typeMode,
      payments: [
        OrderPayment(amount: amount, type: typeMode),
      ],
      patientId: _patientId?.isNotEmpty ?? false ? _patientId : null,
      prescriberName:
          _prescriberName?.isNotEmpty ?? false ? _prescriberName : null,
      pharmacistName:
          _pharmacistName?.isNotEmpty ?? false ? _pharmacistName : null,
    );
  }
}
