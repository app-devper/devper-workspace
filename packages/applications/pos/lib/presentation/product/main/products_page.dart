// Flutter imports:
import 'package:common/core/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:common/core/widgets/dropdown_widget.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/order/argument.dart';
import 'package:pos/presentation/product/argument.dart';
import 'package:pos/presentation/theme.dart';
import 'products_state.dart';
import 'products_ui_model.dart';
import 'products_view_model.dart';

class ProductsPage extends StatefulWidget {
  final String? mode;

  const ProductsPage({super.key, this.mode});

  @override
  State<StatefulWidget> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _searchEditingController = TextEditingController();
  final _searchNumberNode = FocusNode();
  final _viewNode = FocusNode();

  final _format = NumberFormat("#,##0.00", "en_US");

  late CustomSnackBar _snackBar;
  late ProductsViewModel _viewModel;

  Mode _mode = Mode.list;
  bool _isAdmin = false;
  SortProduct _sort = SortProduct.createdAsc;
  double _totalCost = 0;

  List<Category> _categories = [];
  Category? _category;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductsViewModel>();
    _viewModel.states.stream.listen((state) {
      if (state is ErrorState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
      } else if (state is LoadingState) {
      } else if (state is ListProductsState) {
        _viewModel.setProducts(state.data);
      } else if (state is ProductsResultState) {
        setState(() {
          _totalCost = state.totalCost;
        });
        _viewModel.setProducts(state.data);
      } else if (state is LoggedState) {
        setState(() {
          _isAdmin = state.isAdmin;
        });
      } else if (state is RemoveProductState) {
        _viewModel.getProducts(_sort, _category?.value ?? "");
      } else if (state is GetCategoryState) {
        setState(() {
          _categories = state.data;
          _category = state.data.firstOrNull;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.mode == "FIND") {
        setState(() {
          _mode = Mode.search;
        });
      } else {
        _viewModel.checkLogin();
      }
      _viewModel.getProducts(_sort, _category?.value ?? "");
    });

    _viewModel.initData();
  }

  @override
  void dispose() {
    _searchNumberNode.dispose();
    _viewNode.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: CustomColor.fontBlack,
        ),
        elevation: 0,
        backgroundColor: CustomColor.white,
        centerTitle: true,
        title: _buildTitle(context),
        actions: _buildAction(context),
      ),
      body: _buildBody(context),
    );
  }

  _buildMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: _buildCategory(),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: _buildDropdown(context),
          ),
        ],
      ),
    );
  }

  _buildCategory() {
    return SizedBox(
      height: 50,
      child: DropdownInput<Category>(
        hintText: "Category",
        options: _categories,
        value: _category,
        onChanged: (Category? value) {
          setState(() {
            _category = value;
          });
          _viewModel.getProducts(_sort, value?.value ?? "");
        },
        getLabel: (Category value) => value.name,
      ),
    );
  }

  _buildDropdown(BuildContext context) {
    return StreamBuilder(
      stream: _viewModel.dropdownItems.stream,
      builder: (BuildContext context, AsyncSnapshot<List<ListItem>> snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data ?? [];
          return Container(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 50,
              child: DropdownButton(
                value: _sort,
                icon: const Icon(Icons.sort),
                alignment: AlignmentDirectional.center,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: CustomColor.fontBlack,
                ),
                items: data.map((ListItem item) {
                  return DropdownMenuItem<SortProduct>(
                    value: item.value,
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: CustomColor.fontBlack,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sort = value as SortProduct;
                  });
                  _viewModel.getProducts(value as SortProduct, _category?.value ?? "");
                },
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  List<Widget> _buildAction(BuildContext context) {
    if (_mode == Mode.list) {
      List<Widget> action = [
        IconButton(
          splashRadius: 20,
          onPressed: () {
            setState(() {
              _mode = Mode.search;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FocusScope.of(context).requestFocus(_searchNumberNode);
            });
          },
          icon: const Icon(Icons.search),
        )
      ];
      if (_isAdmin) {
        action.add(IconButton(
          splashRadius: 20,
          onPressed: () {
            _viewModel.downloadProducts();
          },
          icon: const Icon(Icons.download),
        ));
      }
      return action;
    } else {
      return [];
    }
  }

  _buildTitle(BuildContext context) {
    if (_mode == Mode.list) {
      return Text(Languages.of(context).productsTitle, style: buildAppBarTextStyle());
    } else {
      return _buildSearchField(context);
    }
  }

  _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        children: <Widget>[
          _buildMenu(context),
          _buildProductList(),
          _buildSummaryTotal(),
        ],
      ),
    );
  }

  _buildProductList() {
    return StreamBuilder(
      stream: _viewModel.products.stream,
      builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data;
          return _buildProducts(data ?? []);
        } else {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 6,
                color: CustomColor.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
          );
        }
      },
    );
  }

  _buildProducts(List<Product> item) {
    return Expanded(
      child: ListView.builder(
        itemCount: item.length,
        itemBuilder: (context, index) {
          final content = item[index];
          return ListTile(
            leading: _buildListMenu(context, content),
            title: Text(content.name),
            trailing: Text(_format.format(content.price)),
            subtitle: Text(content.serialNumber),
            onTap: () {
              if (widget.mode == "FIND") {
                Navigator.pop(context, content.serialNumber);
              } else {
                _nextToProductEdit(context, content);
              }
            },
          );
        },
      ),
    );
  }

  _buildListMenu(BuildContext context, Product content) {
    if (_isAdmin) {
      return SizedBox(
          width: 70,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () {
                  _nextToOrderHistory(context, content);
                },
                child: const Icon(Icons.history),
              ),
              Text(
                '${content.quantity}',
              ),
            ],
          ));
    } else {
      return Text(
        '${content.quantity}',
      );
    }
  }

  _buildSummaryTotal() {
    if (_isAdmin && _mode == Mode.list) {
      return Container(
        padding: const EdgeInsets.all(defaultPagePadding),
        child: Column(
          children: <Widget>[
            _buildTotal(),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  _buildTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text(
          'Total Cost',
        ),
        Text(
          '฿ ${_format.format(_totalCost)}',
        ),
      ],
    );
  }

  _buildSearchField(BuildContext context) {
    return TextFormField(
      focusNode: _searchNumberNode,
      controller: _searchEditingController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        focusColor: CustomColor.hintColor,
        hoverColor: CustomColor.textFieldBackground,
        fillColor: CustomColor.textFieldBackground,
        hintText: "Search product.",
        suffixIcon: IconButton(
          splashRadius: 20,
          onPressed: () {
            setState(() {
              _mode = Mode.list;
            });
            FocusScope.of(context).requestFocus(_viewNode);
            _searchEditingController.text = "";
          },
          icon: const Icon(Icons.clear),
        ),
      ),
      cursorColor: CustomColor.hintColor,
      onChanged: (text) {
        _viewModel.searchProduct(text);
      },
    );
  }

  _nextToProductEdit(BuildContext context, Product content) async {
    var result = await Navigator.pushNamed(context, PRODUCT_EDIT_ROUTE, arguments: ProductArgument(content));
    if (result != null) {
      _viewModel.getProducts(_sort, _category?.value ?? "");
    }
  }

  _nextToOrderHistory(BuildContext context, Product? product) async {
    if (product != null) {
      var _ = await Navigator.pushNamed(context, ORDER_HISTORY_ROUTE, arguments: OrderHistoryArgument(product));
    }
  }
}
