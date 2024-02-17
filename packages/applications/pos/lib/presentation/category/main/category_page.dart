// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/widgets/custom_snack_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/category/argument.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/theme.dart';
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
    _viewModel.states.stream.listen((state) {
      if (state is ErrorState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
      } else if (state is LoadingState) {
      } else if (state is ListCategoryState) {
        _viewModel.setCategories(state.data);
      } else if (state is UpdateCategoryState) {
        _viewModel.getCategories();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getCategories();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: CustomTheme.mainTheme.iconTheme,
        backgroundColor: CustomColor.white,
        centerTitle: true,
        title: Text(
          Languages.of(context).categoryTitle,
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
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
    return StreamBuilder(
      stream: _viewModel.categories.stream,
      builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data;
          return _buildCategory(data ?? []);
        } else {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: CustomColor.primary,
              strokeCap: StrokeCap.round,
            ),
          );
        }
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
    var _ = await Navigator.pushNamed(context, CATEGORY_EDIT_ROUTE, arguments: CategoryArgument(content));
    _viewModel.getCategories();
  }

  _nextToCategoryAdd(BuildContext context) async {
    var _ = await Navigator.pushNamed(context, CATEGORY_ADD_ROUTE);
    _viewModel.getCategories();
  }
}
