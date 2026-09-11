import 'dart:io';

import 'package:common/config/network_config.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos/data/datasource/network/pos_service.dart';

/// Every route pos-api registers, as "METHOD /path" with parameter names
/// normalised to `:param`.
///
/// This is a copy of `docs/routes.txt` in the pos-api repository, which a Go
/// test there regenerates from the router and guards against drift. The two
/// repositories have separate CI that only ever checks out one of them, so a
/// reviewed file is the only place the client and the service can meet.
///
/// When pos-api changes a route, copy its `docs/routes.txt` over
/// `pos_api_routes.txt` and this test says whether the client still fits.
const _manifest = 'test/data/datasource/network/pos_api_routes.txt';
const _serviceSource = 'lib/data/datasource/network/pos_service.dart';

/// Tests run with the package directory as the working directory under melos,
/// but from the workspace root in some IDE configurations.
File _resolve(String pathFromPackageRoot) {
  final local = File(pathFromPackageRoot);
  if (local.existsSync()) return local;
  final fromWorkspace = File('packages/applications/pos/$pathFromPackageRoot');
  if (fromWorkspace.existsSync()) return fromWorkspace;
  fail('cannot find $pathFromPackageRoot (cwd ${Directory.current.path})');
}

/// The value handed to every id-shaped argument, so a recorded path can be
/// turned back into the shape the service registered.
const _sentinel = '__param__';

class _FakeNetworkConfig implements NetworkConfig {
  @override
  String getHostApp() => 'https://api.example.test';

  @override
  String getHostUm() => 'https://um.example.test';

  @override
  Map<String, String> getHeaders(Uri uri) => const {};

  @override
  bool isDebug() => false;
}

/// Records what the service asked for and answers every request the same way.
class _Recorder {
  final List<String> calls = [];

  CustomClient client() {
    return CustomClient(
      inner: MockClient((request) async {
        calls.add('${request.method} ${_shape(request.url)}');
        return http.Response('{}', 200);
      }),
    );
  }
}

/// Turns a concrete request URL into the route shape pos-api registered:
/// drops the host and query string, and puts `:param` back where a sentinel
/// argument was interpolated.
String _shape(Uri url) {
  final segments = url.pathSegments
      .map((segment) => segment == _sentinel ? ':param' : segment)
      .join('/');
  return '/$segments';
}

Set<String> _loadManifest() => _parse(_resolve(_manifest).readAsLinesSync());

Set<String> _parse(List<String> lines) {
  return lines
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !line.startsWith('#'))
      .toSet();
}

void main() {
  late _Recorder recorder;
  late PosService service;

  setUp(() {
    recorder = _Recorder();
    service = PosService(
      networkConfig: _FakeNetworkConfig(),
      client: recorder.client(),
    );
  });

  /// Drives every method that routes through CustomClient. `importProductCSV`
  /// is absent on purpose — it builds its own MultipartRequest and sends it
  /// through the default client, so nothing here can observe it. It is asserted
  /// separately below.
  Future<void> callEveryEndpoint() async {
    const id = _sentinel;
    const body = '{}';

    await service.createProduct(body);
    await service.createProductReceive(body);
    await service.getProducts();
    await service.getProductById(id);
    await service.updateProductById(id, body);
    await service.generateSerialNumber();
    await service.getProductBySerialNumber(id);
    await service.removeProductById(id);

    await service.getProductLotById(id);
    await service.updateProductLotById(id, body);
    await service.getProductLots('2026-01-01', '2026-01-31');
    await service.getProductLotsExpired();
    await service.createProductLot(body);
    await service.deleteProductLotById(id);

    await service.addProductUnit(body);
    await service.getProductUnitsByProductId(id);
    await service.updateProductUnitById(id, body);
    await service.removeProductUnitById(id);

    await service.addProductPrice(body);
    await service.getProductPricesByProductId(id);
    await service.updateProductPriceById(id, body);
    await service.removeProductPriceById(id);

    await service.addProductStock(body);
    await service.getProductStocksByProductId(id);
    await service.updateProductStockById(id, body);
    await service.removeProductStockById(id);
    await service.updateProductStockQuantityById(id, body);
    await service.updateProductStockSequence(body);

    await service.createOrder(body);
    await service.getOrderRange('2026-01-01', '2026-01-31');
    await service.getOrderById(id);
    await service.removeOrderById(id);
    await service.removeProductByOrderProductId(id, id);
    await service.getOrderItemById(id);
    await service.removeOrderItemById(id);
    await service.getOrderItemByProductId(id);
    await service.getOrderItemDetailByProductId(id);

    await service.createCategory(body);
    await service.getCategories();
    await service.getCategoryById(id);
    await service.updateCategoryById(id, body);
    await service.updateDefaultCategoryId(id);
    await service.removeCategoryById(id);

    await service.createCustomer(body);
    await service.getCustomers();
    await service.getCustomerById(id);
    await service.getCustomerByCode(id);
    await service.updateCustomerById(id, body);
    await service.removeCustomerById(id);
    await service.updateCustomerStatusById(id, body);

    await service.updateSupplierInfo(body);
    await service.getSupplierInfo();
    await service.createSupplier(body);
    await service.getSuppliers();
    await service.getSupplierById(id);
    await service.updateSupplierById(id, body);
    await service.removeSupplierById(id);

    await service.createReceive(body);
    await service.getReceives('2026-01-01', '2026-01-31');
    await service.getReceiveById(id);
    await service.updateReceiveById(id, body);
    await service.removeReceiveById(id);
    await service.updateReceiveTotalCostById(id, body);
    await service.importReceiveById(id);

    await service.getProductHistoriesByProductId(id);
    await service.getProductHistoriesByDateRange('2026-01-01', '2026-01-31');
    await service.clearQuantitySoldFirstById(id);
    await service.checkDrugInteractions(body);

    await service.createStockAdjustment(body);
    await service.getStockAdjustmentsByProductId(id);

    await service.createStockCount(body);
    await service.getStockCounts();
    await service.getStockCountById(id);

    await service.createProductReturn(body);
    await service.getProductReturnsByOrderId(id);
  }

  test('every path the client calls exists on pos-api', () async {
    final routes = _loadManifest();
    expect(routes, isNotEmpty, reason: 'the route manifest is empty');

    await callEveryEndpoint();

    final missing = recorder.calls.toSet().difference(routes).toList()..sort();

    expect(
      missing,
      isEmpty,
      reason: 'these calls have no matching route on pos-api. Either the '
          'service renamed or dropped them, or the manifest is stale — copy '
          "pos-api's docs/routes.txt over pos_api_routes.txt and look again.",
    );
  });

  test('the CSV import path exists on pos-api', () {
    // importProductCSV bypasses CustomClient with its own MultipartRequest, so
    // it cannot be recorded. Its path is asserted by hand instead; if the
    // method's URL changes, change this line with it.
    expect(_loadManifest(), contains('POST /api/pos/v1/products/import-csv'));
  });

  test('the contract covers every endpoint the client exposes', () async {
    await callEveryEndpoint();

    // One recorded call per driven method, plus importProductCSV which cannot
    // be. If someone adds a method to PosService without adding it above, this
    // is what notices.
    final driven = recorder.calls.length + 1;
    final declared = RegExp(r'Future<http\.Response>\s+\w+\(')
        .allMatches(_resolve(_serviceSource).readAsStringSync())
        .length;

    expect(driven, declared,
        reason: 'PosService declares $declared endpoints but the contract test '
            'drives $driven. Add the new method to callEveryEndpoint.');
  });
}
