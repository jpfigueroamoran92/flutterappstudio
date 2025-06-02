import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/user.dart'; 
import 'package:myapp/models/tour.dart'; 

class ApiService {
  // Updated to point to your likely production API base URL
  static const String _baseUrl = "https://mihogarideal.com.mx/php_backend_example/api"; 

  Future<User> login(String email, String password) async {
    final Uri loginUri = Uri.parse('$_baseUrl/login.php');
    print('Attempting to login to: \$loginUri'); // For debugging

    final response = await http.post(
      loginUri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    print('Login response status: \${response.statusCode}'); // For debugging
    print('Login response body: \${response.body}'); // For debugging

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromJson(responseData);
    } else {
      String errorMessage = 'Failed to login.';
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? 'Login failed: \${response.reasonPhrase} (\${response.statusCode})';
      } catch(_){ errorMessage = 'Login failed with status: \${response.statusCode}. Response: \${response.body}'; }
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    String? company,
    required String email,
    String? phone,
    required String password,
    String? role, // Added role parameter
  }) async {
    final Uri registerUri = Uri.parse('$_baseUrl/register.php');
    print('Attempting to register to: \$registerUri'); // For debugging

    final Map<String, String?> requestBody = {
        'name': name,
        'email': email,
        'password': password,
    };
    if (company != null) requestBody['company'] = company;
    if (phone != null) requestBody['phone'] = phone;
    if (role != null) requestBody['role'] = role; // Add role if provided

    final response = await http.post(
      registerUri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(requestBody),
    );
    print('Register response status: \${response.statusCode}'); // For debugging
    print('Register response body: \${response.body}'); // For debugging

    if (response.statusCode == 201 || response.statusCode == 200) { 
      return json.decode(response.body);
    } else {
      String errorMessage = 'Failed to register.';
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? 'Registration failed: \${response.reasonPhrase} (\${response.statusCode})';
      } catch(_){ errorMessage = 'Registration failed with status: \${response.statusCode}. Response: \${response.body}'; }
      throw Exception(errorMessage);
    }
  }

  Future<List<Tour>> getTours(String token) async {
    final Uri toursUri = Uri.parse('$_baseUrl/get_tours.php');
    print('Attempting to get tours from: \$toursUri with token: \$token'); // For debugging

    final response = await http.get(
      toursUri, 
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer \$token',
      },
    );
    print('Get tours response status: \${response.statusCode}'); // For debugging
    print('Get tours response body: \${response.body}'); // For debugging

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((tourJson) => Tour.fromJson(tourJson)).toList();
    } else {
      String errorMessage = 'Failed to fetch tours.';
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? 'Failed to fetch tours: \${response.reasonPhrase} (\${response.statusCode})';
      } catch(_){ errorMessage = 'Failed to fetch tours with status: \${response.statusCode}. Response: \${response.body}'; }
      throw Exception(errorMessage);
    }
  }
}