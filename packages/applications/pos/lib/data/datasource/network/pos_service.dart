// Package imports:
import 'package:common/config/network_config.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:http/http.dart' as http;

class PosService {
  final NetworkConfig networkConfig;
  final CustomClient client;

  PosService({
    required this.networkConfig,
    required this.client,
  });

  Future<http.Response> createProduct(String jsonBody) {
    var url = Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/products');
    return client.post(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> createProductReceive(String jsonBody) {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/products/receive');
    return client.post(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getProducts() {
    var url = Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/products');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getProductById(String productId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/$productId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateProductById(String productId, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/$productId');
    return client.put(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> generateSerialNumber() {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/serial-number');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getProductBySerialNumber(String serialNumber) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/serial-number/$serialNumber');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> removeProductById(String productId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/$productId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getProductLotById(String lotId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/lots/$lotId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateProductLotById(String lotId, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/lots/$lotId');
    return client.put(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getProductLots(String startDate, String endDate) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/lots?startDate=$startDate&endDate=$endDate');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getProductLotsExpired() {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/lots/expire-notify');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> createProductLot(String jsonBody) {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/products/lots');
    return client.post(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> deleteProductLotById(String lotId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/lots/$lotId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> addProductUnit(String jsonBody) {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/products/units');
    return client.post(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getProductUnitsByProductId(String productId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/$productId/units');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateProductUnitById(String unitId, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/units/$unitId');
    return client.put(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> removeProductUnitById(String unitId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/units/$unitId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> addProductPrice(String jsonBody) {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/products/prices');
    return client.post(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getProductPricesByProductId(String productId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/$productId/prices');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateProductPriceById(
      String priceId, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/prices/$priceId');
    return client.put(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> removeProductPriceById(String priceId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/prices/$priceId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> addProductStock(String jsonBody) {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/products/stocks');
    return client.post(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getProductStocksByProductId(String productId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/$productId/stocks');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateProductStockById(
      String stockId, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/stocks/$stockId');
    return client.put(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> removeProductStockById(String stockId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/stocks/$stockId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateProductStockQuantityById(
      String id, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/stocks/$id/quantity');
    return client.patch(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  // Order Api
  Future<http.Response> createOrder(String jsonBody) {
    var url = Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/orders');
    return client.post(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getOrderRange(String startDate, String endDate) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/orders?startDate=$startDate&endDate=$endDate');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getOrderById(String orderId) {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/orders/$orderId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> removeOrderById(String orderId) {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/orders/$orderId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> removeProductByOrderProductId(
      String orderId, String productId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/orders/$orderId/products/$productId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getOrderItemById(String itemId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/orders/items/$itemId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> removeOrderItemById(String itemId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/orders/items/$itemId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getOrderItemByProductId(String productId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/orders/items/products/$productId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getOrderItemDetailByProductId(String productId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/orders/item-details/products/$productId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  // Category Api
  Future<http.Response> createCategory(String jsonBody) {
    var url = Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/categories');
    return client.post(url,
        headers: networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> getCategories() {
    var url = Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/categories');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getCategoryById(String categoryId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/categories/$categoryId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateCategoryById(String categoryId, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/categories/$categoryId');
    return client.put(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateDefaultCategoryId(String categoryId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/categories/$categoryId/default');
    return client.patch(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> removeCategoryById(String categoryId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/categories/$categoryId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  // Customer Api
  Future<http.Response> createCustomer(String jsonBody) {
    var url = Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/customers');
    return client.post(url,
        headers: networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> getCustomers() {
    var url = Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/customers');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getCustomerById(String customerId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/customers/$customerId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getCustomerByCode(String customerCode) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/customers/code/$customerCode');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateCustomerById(String customerId, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/customers/$customerId');
    return client.put(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> removeCustomerById(String categoryId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/customers/$categoryId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateCustomerStatusById(
      String customerId, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/customers/$customerId/status');
    return client.patch(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  // Supplier Api
  Future<http.Response> updateSupplierInfo(String jsonBody) {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/suppliers/info');
    return client.put(url,
        headers: networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> getSupplierInfo() {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/suppliers/info');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> createSupplier(String jsonBody) {
    var url = Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/suppliers');
    return client.post(url,
        headers: networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> getSuppliers() {
    var url = Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/suppliers');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getSupplierById(String supplierId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/suppliers/$supplierId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateSupplierById(String supplierId, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/suppliers/$supplierId');
    return client.put(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> removeSupplierById(String supplierId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/suppliers/$supplierId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  // Receive Api
  Future<http.Response> createReceive(String jsonBody) {
    var url = Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/receives');
    return client.post(url,
        headers: networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> getReceives(String startDate, String endDate) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/receives?startDate=$startDate&endDate=$endDate');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getReceiveById(String receiveId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/receives/$receiveId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateReceiveById(String receiveId, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/receives/$receiveId');
    return client.put(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> removeReceiveById(String receiveId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/receives/$receiveId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateReceiveTotalCostById(
      String receiveId, String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/receives/$receiveId/total-cost');
    return client.patch(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> importReceiveById(String receiveId) {
    final url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/receives/$receiveId/import');
    return client.patch(url, headers: networkConfig.getHeaders(url));
  }

  // Product History Api
  Future<http.Response> getProductHistoriesByProductId(String productId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/$productId/histories');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getProductHistoriesByDateRange(
      String startDate, String endDate) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/histories?startDate=$startDate&endDate=$endDate');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  // Clear Sold-First
  Future<http.Response> clearQuantitySoldFirstById(String productId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/$productId/sold-first');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

  // Drug Interaction Check
  Future<http.Response> checkDrugInteractions(String jsonBody) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/drug-interaction-check');
    return client.post(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  // CSV Import
  Future<http.Response> importProductCSV({
    required List<int> bytes,
    required String filename,
  }) async {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/import-csv');
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(networkConfig.getHeaders(url));
    request.files
        .add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updateProductStockSequence(
      String updateProductStockSequenceRequest) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/products/stocks/sequence');
    return client.patch(url,
        body: updateProductStockSequenceRequest,
        headers: networkConfig.getHeaders(url));
  }

  // Stock Adjustment Api
  Future<http.Response> createStockAdjustment(String jsonBody) {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/stock-adjustments');
    return client.post(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getStockAdjustmentsByProductId(String productId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/stock-adjustments/product/$productId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  // Stock Count Api
  Future<http.Response> createStockCount(String jsonBody) {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/stock-counts');
    return client.post(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getStockCounts() {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/stock-counts');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getStockCountById(String stockCountId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/stock-counts/$stockCountId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  // Product Return Api
  Future<http.Response> createProductReturn(String jsonBody) {
    var url =
        Uri.parse('${networkConfig.getHostApp()}/api/pos/v1/product-returns');
    return client.post(url,
        body: jsonBody, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> getProductReturnsByOrderId(String orderId) {
    var url = Uri.parse(
        '${networkConfig.getHostApp()}/api/pos/v1/product-returns/order/$orderId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }
}
