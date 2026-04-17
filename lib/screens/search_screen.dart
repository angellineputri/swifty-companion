import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isLoggedIn = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final success = await _apiService.login();

    setState(() {
      _isLoading = false;
      _isLoggedIn = success;
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swifty Companion'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _isLoggedIn
                ? const Text('Logged in!')
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login with 42'),
                  ),
      ),
    );
  }
}