import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Role Login Example', home: const LoginPage());
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController(
    text: 'admin@123gmail.com',
  );
  final TextEditingController _password = TextEditingController(
    text: 'admin123',
  );
  bool _loading = false;
  String? _error;

  final _storage = const FlutterSecureStorage();

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final url = Uri.parse('http://localhost:3000/authentication/log-in');
    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email.text.trim(),
          'password': _password.text,
        }),
      );

      final body = jsonDecode(resp.body);
      if (resp.statusCode != 200) {
        setState(() => _error = body['message'] ?? 'Login failed');
        return;
      }

      // The backend returns `user.role` in the response; use it to route UI.
      final accessToken = body['accessToken'] as String?;
      final roleFromBody = body['user']?['role'] as String?;

      String? role = roleFromBody;

      // If we received an access token, store it and decode role from token
      if (accessToken != null) {
        await _storage.write(key: 'accessToken', value: accessToken);
        try {
          final payload = Jwt.parseJwt(accessToken);
          if (payload['role'] != null) {
            role = payload['role'] as String;
          }
        } catch (_) {
          // ignore decode errors, fallback to body role
        }
      }

      if (role == 'ADMIN') {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const AdminHome()));
      } else if (role == 'STAFF') {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const StaffHome()));
      } else {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const UserHome()));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(child: Text('Welcome, Admin!')),
    );
  }
}

class StaffHome extends StatelessWidget {
  const StaffHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Dashboard')),
      body: const Center(child: Text('Welcome, Staff!')),
    );
  }
}

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Home')),
      body: const Center(child: Text('Welcome, User!')),
    );
  }
}
