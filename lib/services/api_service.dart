import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://24b40000-ecaa-41c4-ac93-f03a58c88769.mock.pstmn.io';

  // Helper method to handle API responses
  static dynamic _handleResponse(http.Response response) {
    try {
      final decoded = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': decoded,
          'message': 'Success'
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': decoded is Map && decoded.containsKey('message')
              ? decoded['message']
              : 'API Error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Error parsing response: $e'
      };
    }
  }


  // 1. Fetch All Users
  static Future<Map<String, dynamic>> fetchAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Network error: $e'
      };
    }
  }

  // 2. User Login
  // Updated loginUser method in ApiService
  static Future<Map<String, dynamic>> loginUser(String mobile, String password) async {
    print('API login sent mobile: $mobile, password: $password');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users?mobile=$mobile&password=$password'),
        headers: {'Content-Type': 'application/json'},
      );

      print('API response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);

        // No need to filter again if already filtered from API
        if (users.isNotEmpty) {
          final user = users[0];
          print('User found: $user');

          final formattedUser = {
            'mobile': user['mobile'].toString(),
            'role': user['role']?.toString() ?? 'Operator',
          };

          String token = 'auth_token_${DateTime.now().millisecondsSinceEpoch}';

          return {
            'success': true,
            'token': token,
            'user': formattedUser,
            'message': 'Login successful',
          };
        } else {
          return {
            'success': false,
            'token': null,
            'user': null,
            'message': 'Invalid mobile number or password',
          };
        }
      } else {
        return {
          'success': false,
          'token': null,
          'user': null,
          'message': 'Invalid credentials',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'token': null,
        'user': null,
        'message': 'Login error: $e',
      };
    }
  }


  // 3. Register User
  static Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Network error: $e'
      };
    }
  }

  // 4. Delete User
  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Network error: $e'
      };
    }
  }

  // 5. Fetch All Persons
  static Future<Map<String, dynamic>> fetchAllPersons() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/persons'),
        headers: {'Content-Type': 'application/json'},
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Network error: $e'
      };
    }
  }

  // 6. Insert Person Data
  static Future<Map<String, dynamic>> insertPersonData(Map<String, dynamic> personData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/persons'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(personData),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Network error: $e'
      };
    }
  }

  // 7. Delete Person Data
  static Future<Map<String, dynamic>> deletePersonData(int personId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/persons/$personId'),
        headers: {'Content-Type': 'application/json'},
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Network error: $e'
      };
    }
  }

  // 8. Update User Token
  static Future<Map<String, dynamic>> updateUserToken(int userId, String token) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Network error: $e'
      };
    }
  }

  // Helper method to check network connectivity
  static Future<bool> checkConnectivity() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users')).timeout(
        Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Helper method to validate API response
  static bool isValidResponse(Map<String, dynamic> response) {
    return response['success'] == true && response['data'] != null;
  }
}