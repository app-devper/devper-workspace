// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/widgets/app_bar.dart';
import 'package:design_system/widgets/buttons.dart';
import 'package:design_system/widgets/snack_bar.dart';

import 'package:design_system/widgets/page_container.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:design_system/theme/app_colors.dart';
import 'category_add_view_model.dart';

class CategoryAddPage extends StatefulWidget {
  const CategoryAddPage({super.key});

  @override
  State<StatefulWidget> createState() => _CategoryAddPageState();
}

class _CategoryAddPageState extends State<CategoryAddPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _nameEditingController = TextEditingController();
  final _valueEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();

  final _viewNode = FocusNode();
  final _nameNode = FocusNode();
  final _valueNode = FocusNode();
  final _descriptionNode = FocusNode();

  late CustomSnackBar _snackBar;

  late CategoryAddViewModel _viewModel;

  bool _loadingShown = false;
  bool? _requireCustomerOrder = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<CategoryAddViewModel>();
    _viewModel.state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.saving && !_loadingShown) {
      _loadingShown = true;
      showLoadingDialog(context);
    } else if (!state.saving && _loadingShown) {
      _loadingShown = false;
      hideLoadingDialog(context);
    }
    if (state.error != null) {
      _snackBar.hideAll();
      _snackBar.showErrorSnackBar(state.error!);
      _viewModel.consumeError();
    }
    if (state.created != null) {
      _snackBar.hideAll();
      _snackBar.showSnackBar(text: "Add ${state.created!.name} success");
      _nameEditingController.text = "";
      _valueEditingController.text = "";
      _descriptionEditingController.text = "";
      FocusScope.of(context).requestFocus(_nameNode);
      _viewModel.consumeCreated();
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _nameNode.dispose();
    _valueNode.dispose();
    _descriptionNode.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(Languages.of(context).categoryAddTitle),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        maxWidth: 640,
        padding: const EdgeInsets.all(defaultPagePadding),
        child: Column(
          children: <Widget>[
            _buildForm(context),
            const Padding(
              padding: EdgeInsets.only(top: defaultPagePadding),
            ),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Column _buildForm(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        _buildTextFormField(
          context,
          _nameNode,
          _nameEditingController,
          "Name*",
          TextInputType.text,
          _valueNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        _buildTextFormField(
          context,
          _valueNode,
          _valueEditingController,
          "Value*",
          TextInputType.text,
          _descriptionNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        _buildTextFormField(
          context,
          _descriptionNode,
          _descriptionEditingController,
          "Description",
          TextInputType.text,
          _viewNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        CheckboxListTile(
          title: const Text(
            "Require customer order",
          ),
          value: _requireCustomerOrder,
          onChanged: (newValue) {
            setState(() {
              _requireCustomerOrder = newValue;
            });
          },
          controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
        )
      ],
    );
  }

  SizedBox _buildTextFormField(
    BuildContext context,
    FocusNode focusNode,
    TextEditingController controller,
    String labelText,
    TextInputType textInputType,
    FocusNode nextNode,
  ) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: 50,
      child: TextFormField(
        focusNode: focusNode,
        controller: controller,
        keyboardType: textInputType,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(
              color: AppColors.of(context).surfaceSunken,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(
              color: AppColors.of(context).surfaceSunken,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(
              color: AppColors.of(context).surfaceSunken,
            ),
          ),
          focusColor: AppColors.of(context).textHint,
          hoverColor: AppColors.of(context).surfaceSunken,
          fillColor: AppColors.of(context).surfaceSunken,
          filled: true,
          labelText: labelText,
        ),
        cursorColor: AppColors.of(context).textHint,
        onFieldSubmitted: (term) {
          fieldFocusChange(context, focusNode, nextNode);
        },
      ),
    );
  }

  SizedBox _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ButtonWidget(
        key: const Key("Add"),
        onClicked: () {
          _viewModel.createCategory(_getCategoryParam());
        },
        text: "Add",
      ),
    );
  }

  CategoryParam _getCategoryParam() {
    return CategoryParam(
      name: _nameEditingController.text,
      value: _valueEditingController.text,
      description: _descriptionEditingController.text,
      requireCustomerOrder: _requireCustomerOrder ?? false,
    );
  }
}
