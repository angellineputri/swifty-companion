import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isLoggedIn = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final success = await _apiService.login();
    setState(() {
      _isLoading = false;
      _isLoggedIn = success;
    });
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  Future<void> _search() async {
    final login = _searchController.text.trim();
    if (login.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a login.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = await _apiService.getUser(login);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(user: user),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User "$login" not found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoggedIn ? _buildSearchView() : _buildLoginView(),
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.pink),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '42 NETWORK',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(
                            text: 'Swifty\n',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          TextSpan(
                            text: 'Companion',
                            style: TextStyle(color: AppColors.pink),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore student profiles,\nskills and projects.',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            child: const Text('Login with 42'),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'Uses your 42 intra account',
            style: TextStyle(color: AppColors.textHint, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Search',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _searchController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter a 42 login...',
          ),
          onSubmitted: (_) => _search(),
        ),
        const SizedBox(height: 4),
        const Text(
          'e.g. aputri-a, dfasius',
          style: TextStyle(color: AppColors.textHint, fontSize: 12),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _search,
            child: const Text('Search'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}