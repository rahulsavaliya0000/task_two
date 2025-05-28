import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/constants.dart';

class ApiService {
  final String _baseUrl = AppConstants.fakeStoreApiBaseUrl;

  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products/categories'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((category) => category.toString()).toList();
      } else {
        throw Exception('Failed to load categories (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<Product>> getProducts([String? category]) async {
    try {
      final String url = category == null || category.toLowerCase() == 'all'
          ? '$_baseUrl/products'
          : '$_baseUrl/products/category/$category';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return productFromJson(response.body);
      } else {
        throw Exception('Failed to load products (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Product> getProductById(int productId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products/$productId'));
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load product (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }
}