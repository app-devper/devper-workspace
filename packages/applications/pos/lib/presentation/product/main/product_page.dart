// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/widgets/responsive.dart';
import 'package:common/core/widgets/title_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/core/dialog_widget.dart';
import 'package:pos/presentation/product/add/product_add_page.dart';
import 'package:pos/presentation/product/edit/product_edit_page.dart';
import 'package:pos/presentation/product/main/product_detail_widget.dart';
import 'package:pos/presentation/product/main/product_menu_widget.dart';
import 'package:pos/presentation/product/main/product_state.dart';
import 'package:pos/presentation/product/main/product_view_model.dart';
import 'package:pos/presentation/product/main/products_widget.dart';

// Package imports:

class ProductsPage extends StatefulWidget {
  final String? mode;

  const ProductsPage({super.key, this.mode});

  @override
  State<StatefulWidget> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  PageState _pageState = MainPage();

  late ProductViewModel _viewModel;

  @override
  void initState() {
    _viewModel = sl<ProductViewModel>();
    _viewModel.states.listen((state) {
      if (state is ProductInfoState) {
        setState(() {
          _pageState = InfoPage(data: state.data);
        });
      } else if (state is ImportCSVState) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'นำเข้าสำเร็จ ${state.data.success} รายการ, ล้มเหลว ${state.data.failed} รายการ',
              ),
            ),
          );
        }
      } else if (state is ClearSoldFirstState) {
        setState(() {
          _pageState = InfoPage(data: state.data);
        });
      } else if (state is ErrorState) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: _buildMobile(),
      desktop: _buildDesktop(),
    );
  }

  _buildDesktop() {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: ProductsWidget(
            onMenu: () {
              _showProductMenuDialog();
            },
            onSelected: (value) {
              _viewModel.getProduct(value.id);
            },
          ),
        ),
        Container(width: 1, color: Colors.grey[200]),
        Expanded(
          child: _buildPage(),
        ),
      ],
    );
  }

  _buildMobile() {
    return Row(
      children: [
        Expanded(
          child: _buildPage(),
        ),
      ],
    );
  }

  _buildPage() {
    if (_pageState is MainPage) {
      final isMobile = Responsive.isMobile(context);
      if (isMobile) {
        return ProductsWidget(
          onMenu: () {
            _showProductMenuDialog();
          },
          onSelected: (value) {
            _viewModel.getProduct(value.id);
          },
        );
      } else {
        return ProductMenuWidget(
          onAdd: () {
            setState(() {
              _pageState = AddPage();
            });
          },
          onExport: () {
            _viewModel.exportProducts();
          },
          onImportCsv: () {
            _pickAndImportCSV();
          },
        );
      }
    } else if (_pageState is InfoPage) {
      final product = (_pageState as InfoPage).data;
      return ProductDetailWidget(
        onEdit: () {
          _viewModel.getProduct(product.id);
        },
        product: product,
        onBack: () {
          setState(() {
            _pageState = MainPage();
          });
        },
        onClickEdit: () {
          setState(() {
            _pageState = EditPage(data: product);
          });
        },
        onClearSoldFirst: (productId) {
          _viewModel.clearSoldFirst(productId);
        },
      );
    } else if (_pageState is EditPage) {
      final product = (_pageState as EditPage).data;
      return ProductEditPage(
        product: product,
        onBack: () {
          setState(() {
            _pageState = InfoPage(data: product);
          });
        },
        onEdit: () {
          _viewModel.getProduct(product.id);
        },
        onRemove: () {
          _viewModel.getProduct(product.id);
        },
      );
    } else if (_pageState is AddPage) {
      return ProductAddPage(
        onBack: () {
          setState(() {
            _pageState = MainPage();
          });
        },
        onAdd: () {
          setState(() {
            _pageState = MainPage();
          });
        },
      );
    }
  }

  void _pickAndImportCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        final multipartFile = http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        );
        _viewModel.importCSV(multipartFile);
      }
    }
  }

  _showProductMenuDialog() {
    showRightDialog(
      context,
      builder: (context) => Column(
        children: [
          TitleBar(
            title: "เมนู",
            onBack: () {
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1),
          Expanded(
              child: ProductMenuWidget(
            onAdd: () {
              Navigator.pop(context);
              setState(() {
                _pageState = AddPage();
              });
            },
            onExport: () {
              Navigator.pop(context);
              _viewModel.exportProducts();
            },
            onImportCsv: () {
              Navigator.pop(context);
              _pickAndImportCSV();
            },
          )),
        ],
      ),
    );
  }
}

abstract class PageState {}

class MainPage extends PageState {}

class AddPage extends PageState {}

class InfoPage extends PageState {
  final Product data;

  InfoPage({
    required this.data,
  });
}

class EditPage extends PageState {
  final Product data;

  EditPage({
    required this.data,
  });
}
