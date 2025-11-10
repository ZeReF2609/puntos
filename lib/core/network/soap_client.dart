import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

class SoapClient {
  final Dio _dio;
  final String baseUrl;

  SoapClient({required this.baseUrl}) : _dio = Dio() {
    _dio.options.headers = {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': '',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<XmlDocument> sendRequest({
    required String soapAction,
    required String soapBody,
    Map<String, String>? headers,
  }) async {
    try {
      final soapEnvelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Header/>
  <soap:Body>
    $soapBody
  </soap:Body>
</soap:Envelope>''';

      final options = Options(
        headers: {
          ..._dio.options.headers,
          'SOAPAction': soapAction,
          if (headers != null) ...headers,
        },
      );

      final response = await _dio.post(
        baseUrl,
        data: soapEnvelope,
        options: options,
      );

      if (response.statusCode == 200) {
        return XmlDocument.parse(response.data);
      } else {
        throw Exception('SOAP request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('SOAP parsing error: ${e.toString()}');
    }
  }

  String extractValue(XmlDocument document, String tagName) {
    final element = document.findAllElements(tagName).firstOrNull;
    return element?.text ?? '';
  }

  List<XmlElement> extractElements(XmlDocument document, String tagName) {
    return document.findAllElements(tagName).toList();
  }
}