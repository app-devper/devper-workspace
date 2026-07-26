// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/app_bar.dart';
import 'package:design_system/widgets/snack_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/category/argument.dart';
import 'package:pos/presentation/constants.dart';
import 'package:design_system/theme/color.dart';
import 'category_state.dart';
import 'category_view_model.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late CustomSnackBar _snackBar;
  late CategoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<CategoryViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getCategories();
    });
  }

  void _onStateChanged() {
    final error = _viewModel.state.value.error;
    if (error != null) {
      _snackBar.hideAll();
      _snackBar.showErrorSnackBar(error);
      _viewModel.consumeError();
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(
        Languages.of(context).categoryTitle,
        actions: _buildAction(context),
      ),
      body: _buildBody(context),
    );
  }

  List<Widget> _buildAction(BuildContext context) {
    return [
      IconButton(
        splashRadius: 20,
        onPressed: () {
          _nextToCategoryAdd(context);
        },
        icon: const Icon(Icons.add),
      ),
    ];
  }

  Widget _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        children: <Widget>[
          _buildCategoryList(),
        ],
      ),
    );
  }

  _buildCategoryList() {
    return ValueListenableBuilder<CategoryState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, CategoryState state, _) {
        if (state.loading && state.items.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: CustomColor.primary,
              strokeCap: StrokeCap.round,
            ),
          );
        }
        return _buildCategory(state.items);
      },
    );
  }

  _buildCategory(List<Category> item) {
    return Expanded(
      child: ListView.builder(
        itemCount: item.length,
        itemBuilder: (context, index) {
          final content = item[index];
          return ListTile(
            title: Text(content.name),
            subtitle: Text(content.value),
            onTap: () {
              _nextToCategoryEdit(context, content);
            },
          );
        },
      ),
    );
  }

  _nextToCategoryEdit(BuildContext context, Category content) async {
    var _ = await Navigator.pushNamed(context, categoryEditRoute,
        arguments: CategoryArgument(content));
    _viewModel.getCategories();
  }

  _nextToCategoryAdd(BuildContext context) async {
    var _ = await Navigator.pushNamed(context, categoryAddRoute);
    _viewModel.getCategories();
  }
}
