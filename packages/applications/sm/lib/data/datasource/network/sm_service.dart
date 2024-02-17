// Package imports:
import 'package:common/config/network_config.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:http/http.dart' as http;

class SmService {
  final NetworkConfig networkConfig;
  final CustomClient client;

  SmService({
    required this.networkConfig,
    required this.client,
  });

  // System
  Future<http.Response> getSystems() {
    var url = Uri.parse('${networkConfig.getHostUm()}/api/um/v1/system');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> createSystem(String jsonBody) {
    var url = Uri.parse('${networkConfig.getHostUm()}/api/um/v1/system');
    return client.post(url, headers: networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> getSystemById(String systemId) {
    var url = Uri.parse('${networkConfig.getHostUm()}/api/um/v1/system/$systemId');
    return client.get(url, headers: networkConfig.getHeaders(url));
  }

  Future<http.Response> updateSystemById(String systemId, String jsonBody) {
    var url = Uri.parse('${networkConfig.getHostUm()}/api/um/v1/system/$systemId');
    return client.put(url, headers: networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> removeSystemById(String systemId) {
    var url = Uri.parse('${networkConfig.getHostUm()}/api/um/v1/system/$systemId');
    return client.delete(url, headers: networkConfig.getHeaders(url));
  }

}
