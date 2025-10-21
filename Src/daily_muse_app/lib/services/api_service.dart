import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  static Future<Map<String, dynamic>> register(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        await saveUsername(username);
        return {'success': true, 'message': data['message']};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': '网络错误: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        await saveUsername(username);
        return {
          'success': true,
          'message': data['message'],
          'token': data['token'],
          'is_admin': data['is_admin'] ?? false
        };
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': '网络错误: $e'};
    }
  }

  static Future<Map<String, dynamic>> getTodayArticle() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': '请先登录'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/article/today'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': '暂无今日文章'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': '网络错误: $e'};
    }
  }

  static Future<Map<String, dynamic>> getTodayQuote() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': '请先登录'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/quote/today'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': '暂无今日名言'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': '网络错误: $e'};
    }
  }

  static Future<Map<String, dynamic>> addArticle(
      String title, String content, String author) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': '请先登录'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/admin/article/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(
            {'title': title, 'content': content, 'author': author}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': '网络错误: $e'};
    }
  }

  static Future<Map<String, dynamic>> addQuote(
      String content, String author, String category) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': '请先登录'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/admin/quote/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(
            {'content': content, 'author': author, 'category': category}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': '网络错误: $e'};
    }
  }

  static Future<Map<String, dynamic>> initAdmin(
      String username, String password, String secretKey) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/init'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'secret_key': secretKey
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        await saveUsername(username);
        return {
          'success': true,
          'message': data['message'],
          'token': data['token']
        };
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': '网络错误: $e'};
    }
  }

  static Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': '请先登录'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notification/settings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': '网络错误: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateNotificationSettings(
      bool articleEnabled, bool quoteEnabled) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': '请先登录'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/notification/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'article_enabled': articleEnabled,
          'quote_enabled': quoteEnabled
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': '网络错误: $e'};
    }
  }
}
