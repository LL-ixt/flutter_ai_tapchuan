import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://group1.it4788.sukkaito.id.vn/it4788';
  
  // Login to get a fresh token
  print("Logging in...");
  final loginRes = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'phonenumber': '0359882538',
      'password': '123456',
      'devtoken': 'mock_device'
    }),
  );
  
  if (loginRes.statusCode != 200) {
    print("Login failed: ${loginRes.body}");
    return;
  }
  
  final loginData = jsonDecode(loginRes.body);
  final token = loginData['data']['token'];
  final myUserId = loginData['data']['id'];
  print("Login success. Token: $token, My User ID: $myUserId");

  while (true) {
    print("\n--- Try fetching list posts ---");
    
    // Case 1: passing own user_id
    print("Case 1: passing own user_id ($myUserId)");
    final res1 = await http.post(
      Uri.parse('$baseUrl/get_list_posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'category_id': '0',
        'last_id': '0',
        'index': '0',
        'count': '10',
        'user_id': myUserId,
      }),
    );
    print("Res 1: ${res1.body}");

    // Case 2: passing empty user_id
    print("Case 2: passing empty user_id");
    final res2 = await http.post(
      Uri.parse('$baseUrl/get_list_posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'category_id': '0',
        'last_id': '0',
        'index': '0',
        'count': '10',
        'user_id': '',
      }),
    );
    print("Res 2: ${res2.body}");

    // Case 3: omitting user_id
    print("Case 3: omitting user_id");
    final res3 = await http.post(
      Uri.parse('$baseUrl/get_list_posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'category_id': '0',
        'last_id': '0',
        'index': '0',
        'count': '10',
      }),
    );
    print("Res 3: ${res3.body}");

    if (res1.body.contains("Can not connect to DB")) {
      print("DB is down. Retrying in 5 seconds...");
      await Future.delayed(Duration(seconds: 5));
    } else {
      break;
    }
  }
}
