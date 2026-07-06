// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/appbar_widget.dart';
import 'package:common/core/widgets/button_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/theme.dart';
import 'category_add_state.dart';
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

  bool? _requireCustomerOrder = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<CategoryAddViewModel>();
    _viewModel.states.stream.listen((state) {
      if (state is ErrorState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
        hideLoadingDialog(context);
      } else if (state is LoadingState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        showLoadingDialog(context);
      } else if (state is CreateCategoryState) {
        hideLoadingDialog(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showSnackBar(text: "Add ${state.data.name} success");
        });
        _nameEditingController.text = "";
        _valueEditingController.text = "";
        _descriptionEditingController.text = "";
        FocusScope.of(context).requestFocus(_nameNode);
      }
    });
  }

  @override
  void dispose() {
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

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }

  _buildForm(BuildContext context) {
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

  _buildTextFormField(
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
          labelText: labelText,
        ),
        cursorColor: CustomColor.hintColor,
        onFieldSubmitted: (term) {
          fieldFocusChange(context, focusNode, nextNode);
        },
      ),
    );
  }

  _buildAddButton() {
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

  _getCategoryParam() {
    return CategoryParam(
      name: _nameEditingController.text,
      value: _valueEditingController.text,
      description: _descriptionEditingController.text,
      requireCustomerOrder: _requireCustomerOrder ?? false,
    );
  }
}
