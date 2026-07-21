// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/widgets/app_bar.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/product/argument.dart';
import 'scanner_view_model.dart';

class ScannerPage extends StatefulWidget {
  final String mode;

  const ScannerPage({super.key, required this.mode});

  @override
  State<StatefulWidget> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _qrKey = GlobalKey();

  late ScannerViewModel _viewModel;
  late CustomSnackBar _snackBar;

  QRViewController? controller;

  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ScannerViewModel>();
    _viewModel.state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.loading && !_loadingShown) {
      _loadingShown = true;
      showLoadingDialog(context);
    } else if (!state.loading && _loadingShown) {
      _loadingShown = false;
      hideLoadingDialog(context);
    }
    if (state.error != null) {
      _viewModel.consumeError();
      showAlertDialog(context, "ไม่สามารถค้นหาสินค้าได้", () {
        controller?.resumeCamera();
      });
    }
    if (state.loaded != null) {
      final data = state.loaded!;
      _viewModel.consumeLoaded();
      _nextToProductEdit(context, data);
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return Scaffold(
      appBar: buildAppBar(
        Languages.of(context).productFindTitle,
        actions: [
          IconButton(
            onPressed: () {
              controller?.toggleFlash();
            },
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            onPressed: () {
              controller?.flipCamera();
            },
            icon: const Icon(Icons.flip_camera_ios),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _buildQrView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 850 ||
            MediaQuery.of(context).size.width < 850)
        ? 300.0
        : 600.0;
    return QRView(
      key: _qrKey,
      onQRViewCreated: (ctrl) => _onQRViewCreated(context, ctrl),
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(BuildContext context, QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (widget.mode == "SCAN") {
        this.controller?.pauseCamera();
        Navigator.of(context).pop(scanData);
      } else {
        this.controller?.pauseCamera();
        _viewModel.getProductBySerialNumber(scanData.code ?? "");
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      _snackBar.showErrorSnackBar("No Permission Camera");
    }
  }

  _nextToProductEdit(BuildContext context, Product content) async {
    var _ = await Navigator.pushNamed(context, PRODUCT_EDIT_ROUTE,
        arguments: ProductArgument(content));
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    controller?.dispose();
    _viewModel.dispose();
    super.dispose();
  }
}
