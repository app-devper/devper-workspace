// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/config/app_config.dart';
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/utils/device.dart';
import 'package:common/core/widgets/button_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:um/presentation/constants.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order_item.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/home/argument.dart';
import 'package:pos/presentation/product/argument.dart';
import 'package:pos/presentation/theme.dart';
import 'home_state.dart';
import 'home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _serialNumberEditingController = TextEditingController();
  final _customerEditingController = TextEditingController();
  final _amountEditingController = TextEditingController();
  final _quantityEditingController = TextEditingController();
  final _priceEditingController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _format = NumberFormat("#,##0.00", "en_US");

  final _serialNumberNode = FocusNode();
  final _customerNode = FocusNode();
  final _amountNode = FocusNode();
  final _quantityNode = FocusNode();
  final _priceNode = FocusNode();
  final _viewNode = FocusNode();

  late CustomSnackBar _snackBar;
  late HomeViewModel _viewModel;
  late AppConfig _config;

  double change = 0;
  bool isAdmin = false;
  String typeMode = "Cash";

  List<OrderItem> orderItems = [];
  String? customerCode;
  bool showCustomer = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _viewModel = sl<HomeViewModel>();
    _config = sl<AppConfig>();
    _viewModel.states.listen((state) {
      if (state is ErrorState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
        FocusScope.of(context).requestFocus(_serialNumberNode);
      } else if (state is LoadingState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showLoadingSnackBar();
        });
      } else if (state is OrderItemState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        setState(() {
          orderItems = state.orderItems;
        });
        _serialNumberEditingController.clear();
        FocusScope.of(context).requestFocus(_serialNumberNode);
        _calculate();
      } else if (state is ChangeState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        setState(() {
          change = state.change;
        });
      } else if (state is OrderLoadingState) {
        showLoadingDialog(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
      } else if (state is OrderState) {
        hideLoadingDialog(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showSnackBar(text: "Order success");
        });
        setState(() {
          change = 0;
          orderItems = [];
          customerCode = null;
          showCustomer = false;
        });
        _amountEditingController.clear();
        _customerEditingController.clear();

        FocusScope.of(context).requestFocus(_serialNumberNode);
      } else if (state is OrderErrorState) {
        hideLoadingDialog(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
        FocusScope.of(context).requestFocus(_serialNumberNode);
      } else if (state is CheckRoleState) {
        setState(() {
          isAdmin = state.isAdmin;
        });
      } else if (state is LogoutState) {
        Navigator.popAndPushNamed(context, routeLogin);
      } else if (state is RequireCustomerState) {
        if (!showCustomer) {
          _showCustomerDialog();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.prepareData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _serialNumberNode.dispose();
    _amountNode.dispose();
    _quantityNode.dispose();
    _priceNode.dispose();
    _viewNode.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewModel.prepareData();
    }
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_viewNode),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: CustomTheme.mainTheme.iconTheme,
          backgroundColor: typeMode == "Cash" ? CustomColor.white : Colors.lightBlueAccent,
          centerTitle: true,
          title: Text(
            typeMode == "Cash" ? Languages.of(context).homeTitle : "$typeMode Mode",
            style: CustomTheme.mainTheme.textTheme.headlineSmall,
          ),
          actions: _buildAction(context),
        ),
        drawer: _buildDrawer(),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: CustomColor.statusBarColor,
          ),
          child: _buildBody(context),
        ),
      ),
    );
  }

  List<Widget> _buildAction(BuildContext context) {
    if (isAdmin) {
      return [
        IconButton(
          splashRadius: 20,
          onPressed: () {
            Navigator.pushNamed(context, PRODUCTS_ROUTE);
          },
          icon: const Icon(Icons.list),
        ),
        IconButton(
          splashRadius: 20,
          onPressed: () {
            Navigator.pushNamed(context, RECEIVE_MANAGE_ROUTE);
          },
          icon: const Icon(Icons.add),
        ),
        PopupMenuButton<int>(
          splashRadius: 20,
          icon: const Icon(Icons.more_vert),
          onSelected: (item) => handleClick(item),
          itemBuilder: (context) => [
            PopupMenuItem<int>(value: 0, child: Text(Languages.of(context).userInfoTitle)),
            PopupMenuItem<int>(value: 1, child: Text(Languages.of(context).changePasswordTitle)),
            PopupMenuItem<int>(value: 2, child: Text(typeMode == "Cash" ? "Mode: Online" : "Mode: Store")),
            const PopupMenuItem<int>(value: 3, child: Text('Logout')),
          ],
        ),
      ];
    } else {
      return [
        PopupMenuButton<int>(
          splashRadius: 20,
          icon: const Icon(Icons.more_vert),
          onSelected: (item) => handleClick(item),
          itemBuilder: (context) => [
            PopupMenuItem<int>(value: 0, child: Text(Languages.of(context).userInfoTitle)),
            PopupMenuItem<int>(value: 1, child: Text(Languages.of(context).changePasswordTitle)),
            const PopupMenuItem<int>(value: 3, child: Text('Logout')),
          ],
        ),
      ];
    }
  }

  void handleClick(int item) {
    switch (item) {
      case 0:
        Navigator.pushNamed(context, routeUserInfo);
        break;
      case 1:
        Navigator.pushNamed(context, routeChangePassword);
        break;
      case 2:
        setState(() {
          if (typeMode == "Cash") {
            typeMode = "Online";
            _calculate();
          } else {
            typeMode = "Cash";
          }
        });
        break;
      case 3:
        setState(() {
          typeMode = "Cash";
        });
        _viewModel.logout();
        break;
    }
  }

  Widget _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      padding: const EdgeInsets.all(DEFAULT_PAGE_PADDING),
      child: Column(
        children: <Widget>[
          _buildSerialNumber(),
          _buildCustomer(),
          _buildOrderItem(),
          _buildPrice(),
          const Padding(
            padding: EdgeInsets.only(top: 14),
          ),
          _buildChange(),
          const Padding(
            padding: EdgeInsets.only(top: 14),
          ),
          _buildPayment(context)
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    if (isAdmin) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_config.logo),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Text(''),
            ),
            ListTile(
              title: Text(
                Languages.of(context).productsTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, PRODUCTS_ROUTE);
              },
            ),
            ListTile(
              title: Text(
                Languages.of(context).receiveManageTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, RECEIVE_MANAGE_ROUTE);
              },
            ),
            ListTile(
              title: Text(
                Languages.of(context).receivesTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, RECEIVES_ROUTE);
              },
            ),
            ListTile(
              title: Text(
                Languages.of(context).productsExpiredTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                _nextToProductsExpired(context);
              },
            ),
            ListTile(
              title: Text(
                Languages.of(context).ordersTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, ORDERS_ROUTE);
              },
            ),
            ListTile(
              title: Text(
                Languages.of(context).customerManageTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                _nextToCustomer(context);
              },
            ),
            ListTile(
              title: Text(
                Languages.of(context).categoryTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                _nextToCategory(context);
              },
            ),
            ListTile(
              title: Text(
                Languages.of(context).userManageTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, routeUsers);
              },
            ),
            ListTile(
              title: Text(
                Languages.of(context).supplierInfoTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                _nextToSupplier(context);
              },
            ),
            ListTile(
              title: Text(
                Languages.of(context).suppliersTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                _nextToSuppliers(context);
              },
            ),
          ],
        ),
      );
    } else {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_config.logo),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Text(''),
            ),
            ListTile(
              title: Text(
                Languages.of(context).ordersTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, ORDERS_ROUTE);
              },
            ),
            ListTile(
              title: Text(
                Languages.of(context).customerManageTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                _nextToCustomer(context);
              },
            ),
            ListTile(
              title: Text(
                Languages.of(context).supplierInfoTitle,
                style: CustomTheme.mainTheme.textTheme.headlineSmall,
              ),
              onTap: () {
                _nextToSupplier(context);
              },
            ),
          ],
        ),
      );
    }
  }

  Expanded _buildOrderItem() {
    return Expanded(
      child: ListView.builder(
        itemCount: orderItems.length,
        itemBuilder: (context, index) {
          final content = orderItems[index];
          return ListTile(
            leading: SizedBox(
              width: 120,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _viewModel.removeItem(index, orderItems);
                    },
                    child: const Icon(Icons.delete),
                  ),
                  InkWell(
                    onTap: () {
                      _viewModel.plusItem(index, orderItems);
                    },
                    child: const Icon(Icons.add),
                  ),
                  Text(
                    '${content.quantity}',
                  ),
                  InkWell(
                    onTap: () {
                      _viewModel.minusItem(index, orderItems);
                    },
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
            title: Text(content.product.name),
            trailing: Text(_format.format(content.amountPrice())),
            onTap: () {
              _showEditItemDialog(index, content);
            },
          );
        },
      ),
    );
  }

  Widget _buildPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Total',
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
        Text(
          '฿ ${_format.format(getPrice())}',
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
      ],
    );
  }

  Widget _buildChange() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Change',
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
        Text(
          '฿ ${_format.format(change)}',
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
      ],
    );
  }

  double getPrice() {
    double price = 0;
    for (var x in orderItems) {
      price += x.amountPrice();
    }
    return price;
  }

  _buildSerialNumber() {
    final Size size = MediaQuery.of(context).size;
    if (Device.isMobile()) {
      return SizedBox(
        width: size.width,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: _buildSerialNumberAuto(context),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 60,
              height: 50,
              child: ButtonIconWidget(
                key: const Key("Scan"),
                onClicked: () {
                  _nextToScan(context);
                },
                icon: const Icon(Icons.qr_code_scanner),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: size.width,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: _buildSerialNumberAuto(context),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 60,
              height: 50,
              child: ButtonIconWidget(
                key: const Key("Customer"),
                onClicked: () {
                  _showCustomerDialog();
                },
                icon: const Icon(Icons.person),
              ),
            ),
          ],
        ),
      );
    }
  }

  _buildCustomer() {
    final Size size = MediaQuery.of(context).size;
    if (showCustomer) {
      return Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Customer: ${_customerEditingController.text}",
              style: CustomTheme.mainTheme.textTheme.headlineSmall,
            ),
            const SizedBox(width: 10),
            IconButton(
              iconSize: 18,
              splashRadius: 18,
              onPressed: () {
                setState(() {
                  showCustomer = false;
                });
                _customerEditingController.text = "";
                customerCode = "";
              },
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  _buildSerialNumberAuto(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<Product>(
          focusNode: _serialNumberNode,
          textEditingController: _serialNumberEditingController,
          optionsBuilder: (TextEditingValue fruitTextEditingValue) {
            final text = fruitTextEditingValue.text;
            if (text.isEmpty) {
              return [];
            } else {
              List<Product> filtered = [];
              for (var item in _viewModel.products) {
                if (item.name.toLowerCase().contains(text.toLowerCase()) || item.serialNumber.contains(text)) {
                  filtered.add(item);
                }
              }
              return filtered;
            }
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<Product> onSelected,
            Iterable<Product> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final content = options.elementAt(index);
                      return ListTile(
                        title: Text(content.name),
                        trailing: Text(_format.format(content.price)),
                        subtitle: Text(content.serialNumber),
                        onTap: () {
                          onSelected(content);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              focusNode: fieldFocusNode,
              controller: fieldTextEditingController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: CustomColor.textFieldBackground,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: CustomColor.textFieldBackground,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: CustomColor.textFieldBackground,
                  ),
                ),
                focusColor: CustomColor.hintColor,
                hoverColor: CustomColor.textFieldBackground,
                fillColor: CustomColor.textFieldBackground,
                filled: true,
                labelText: "SerialNumber*",
                labelStyle: CustomTheme.mainTheme.textTheme.bodyMedium,
                suffixIcon: IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    _nextToFindProduct(context);
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
              cursorColor: CustomColor.hintColor,
              onFieldSubmitted: (term) {
                final serialNumber = fieldTextEditingController.text;
                if (serialNumber.isNotEmpty) {
                  _viewModel.addOrderItem(serialNumber, orderItems);
                  fieldFocusNode.unfocus();
                } else {
                  fieldFocusChange(context, fieldFocusNode, _amountNode);
                }
              },
            );
          },
          onSelected: (Product value) {
            _viewModel.addOrderItem(value.serialNumber, orderItems);
          },
        );
      },
    );
  }

  _buildCustomerAuto(BuildContext context, VoidCallback onSelected) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<Customer>(
          focusNode: _customerNode,
          textEditingController: _customerEditingController,
          optionsBuilder: (TextEditingValue fruitTextEditingValue) {
            final text = fruitTextEditingValue.text;
            if (text.isEmpty) {
              return _viewModel.customers;
            } else {
              List<Customer> filtered = [];
              for (var item in _viewModel.customers) {
                if (item.name.toLowerCase().contains(text.toLowerCase()) || item.code.toLowerCase().contains(text.toLowerCase())) {
                  filtered.add(item);
                }
              }
              return filtered;
            }
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<Customer> onSelected,
            Iterable<Customer> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final content = options.elementAt(index);
                      return ListTile(
                        title: Text(content.name),
                        subtitle: Text(content.code),
                        onTap: () {
                          onSelected(content);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              focusNode: fieldFocusNode,
              controller: fieldTextEditingController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: CustomColor.textFieldBackground,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: CustomColor.textFieldBackground,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: CustomColor.textFieldBackground,
                  ),
                ),
                focusColor: CustomColor.hintColor,
                hoverColor: CustomColor.textFieldBackground,
                fillColor: CustomColor.textFieldBackground,
                filled: true,
                labelText: "Customer",
                labelStyle: CustomTheme.mainTheme.textTheme.bodyMedium,
              ),
              cursorColor: CustomColor.hintColor,
              onFieldSubmitted: (term) {
                onFieldSubmitted.call();
              },
              onChanged: (term) {
                customerCode = "";
              },
            );
          },
          onSelected: (Customer value) {
            _customerEditingController.text = value.name;
            customerCode = value.code;
            onSelected.call();
          },
        );
      },
    );
  }

  Widget _buildPayment(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(child: _buildAmountField(context)),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            height: 50,
            child: ElevatedButton(
              key: const Key("Submit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              onPressed: () {
                final amount = _amountEditingController.text;
                if (amount.isNotEmpty && orderItems.isNotEmpty) {
                  _viewModel.createOrder(_getOrderParam());
                }
              },
              child: Text(
                "Submit",
                style: CustomTheme.mainTheme.textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showEditItemDialog(int index, OrderItem item) {
    _quantityEditingController.text = item.quantity.toString();
    _priceEditingController.text = item.price.toString();

    AlertDialog alert = AlertDialog(
      title: Text(item.product.name),
      contentPadding: const EdgeInsets.all(16.0),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildTextFormField(
              context,
              _quantityNode,
              _quantityEditingController,
              "Quantity*",
              const TextInputType.numberWithOptions(),
              _priceNode,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12),
            ),
            buildTextFormField(
              context,
              _priceNode,
              _priceEditingController,
              "Price*",
              const TextInputType.numberWithOptions(decimal: true),
              _viewNode,
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
            FocusScope.of(context).requestFocus(_serialNumberNode);
          },
        ),
        TextButton(
          child: const Text('Edit'),
          onPressed: () {
            Navigator.pop(context);
            _updateOrderItem(index);
          },
        )
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showCustomerDialog() {
    AlertDialog alert = AlertDialog(
      title: const Text("Input Customer"),
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 500,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: _buildCustomerAuto(context, () {
                    if (_customerEditingController.text.isNotEmpty) {
                      setState(() {
                        showCustomer = true;
                      });
                    }
                    Navigator.pop(context);
                  }),
                ),
              ],
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Confirm'),
          onPressed: () {
            setState(() {
              showCustomer = _customerEditingController.text.isNotEmpty;
            });
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  TextFormField _buildAmountField(BuildContext context) {
    return TextFormField(
      focusNode: _amountNode,
      readOnly: typeMode == "Online",
      controller: _amountEditingController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: CustomTheme.mainTheme.textTheme.headlineSmall,
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: CustomColor.textFieldBackground,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: CustomColor.textFieldBackground,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: CustomColor.textFieldBackground,
          ),
        ),
        focusColor: CustomColor.hintColor,
        hoverColor: CustomColor.textFieldBackground,
        fillColor: CustomColor.textFieldBackground,
        filled: true,
        labelText: "Amount*",
        labelStyle: CustomTheme.mainTheme.textTheme.bodyMedium,
        prefixText: "฿ ",
        prefixStyle: CustomTheme.mainTheme.textTheme.headlineSmall,
      ),
      cursorColor: CustomColor.hintColor,
      onChanged: (text) {
        final amount = _amountEditingController.text;
        if (amount.isNotEmpty) {
          _viewModel.calculate(getPrice(), double.parse(amount));
        } else {
          setState(() {
            change = 0;
          });
        }
      },
      onFieldSubmitted: (term) {
        _calculate();
      },
    );
  }

  _calculate() {
    if (typeMode == "Online") {
      _amountEditingController.text = getPrice().toString();
    }
    final amount = _amountEditingController.text;
    try {
      if (amount.isNotEmpty) {
        _amountNode.unfocus();
        _viewModel.calculate(getPrice(), double.parse(amount));
      } else {
        setState(() {
          change = 0;
        });
      }
    } catch (e) {
      setState(() {
        change = 0;
      });
    }
  }

  _updateOrderItem(int index) {
    if (typeMode == "Online") {
      _amountEditingController.text = getPrice().toString();
    }
    final quantity = _quantityEditingController.text;
    final price = _priceEditingController.text;
    try {
      if (quantity.isNotEmpty && price.isNotEmpty) {
        _viewModel.updatePriceItem(index, int.parse(quantity), double.parse(price), orderItems);
      }
    } catch (e) {}
  }

  _getOrderParam() {
    final amount = _amountEditingController.text;
    return CreateOrderParam(
      customerCode: customerCode ?? "",
      customerName: _customerEditingController.text.trim(),
      amount: double.parse(amount),
      items: orderItems,
      type: typeMode,
    );
  }

  _nextToFindProduct(BuildContext context) async {
    var result = await Navigator.pushNamed(context, PRODUCTS_ROUTE, arguments: ProductsArgument("FIND")) as String?;
    if (result != null) {
      _viewModel.addOrderItem(result, orderItems);
    }
  }

  _nextToScan(BuildContext context) async {
    var result = await Navigator.pushNamed(context, SCAN_ROUTE, arguments: ScannerArgument("SCAN")) as Barcode?;
    if (result != null) {
      _viewModel.addOrderItem(result.code ?? "", orderItems);
    }
  }

  _nextToCustomer(BuildContext context) async {
    var _ = await Navigator.popAndPushNamed(context, CUSTOMERS_ROUTE);
    _viewModel.getCacheCustomers();
  }

  _nextToCategory(BuildContext context) async {
    var _ = await Navigator.popAndPushNamed(context, CATEGORIES_ROUTE);
  }

  _nextToSupplier(BuildContext context) async {
    var _ = await Navigator.popAndPushNamed(context, SUPPLIER_ROUTE);
  }

  _nextToSuppliers(BuildContext context) async {
    var _ = await Navigator.popAndPushNamed(context, SUPPLIERS_ROUTE);
  }
  _nextToProductsExpired(BuildContext context) async {
    var _ = await Navigator.popAndPushNamed(context, PRODUCT_EXPIRED_ROUTE);
  }
}
