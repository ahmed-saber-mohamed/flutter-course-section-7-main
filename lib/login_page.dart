import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  bool _validateInputs() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty) {
      setState(() {
        _isSuccess = false;
        _message = 'Username cannot be empty';
      });
      return false;
    }

    if (password.length < 6) {
      setState(() {
        _isSuccess = false;
        _message = 'Password must be at least 6 characters';
      });
      return false;
    }

    return true;
  }

  Future<void> _login() async {
    if (!_validateInputs()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final success = await AuthService.login(username, password);
      if (!mounted) return;

      if (success) {
        context.go('/home');
      } else {
        setState(() {
          _isSuccess = false;
          _message = 'Wrong username or password';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSuccess = false;
        _message = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signup() async {
    if (!_validateInputs()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final success = await AuthService.signup(username, password);
      if (!mounted) return;

      if (success) {
        setState(() {
          _isSuccess = true;
          _message = 'Account created';
        });
        context.go('/home');
      } else {
        setState(() {
          _isSuccess = false;
          _message = 'Username already exists';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSuccess = false;
        _message = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyAnime Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_message != null)
                Text(
                  _message!,
                  style: TextStyle(
                    color: _isSuccess ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: const Text('Log in'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _signup,
                      child: const Text('Sign up'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}