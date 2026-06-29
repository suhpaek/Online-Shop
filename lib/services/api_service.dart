import '../models/product_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body
          .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> getProductDetails(int id) async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Product.fromJson(body);
    } else {
      throw Exception('Failed to load product details');
    }
  }
}