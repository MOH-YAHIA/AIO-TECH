import 'package:aio_tech/Screens/sign_up.dart';
import 'package:aio_tech/Widgets/auth_fields.dart';
import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../utils/app_colors.dart';
// Note: We no longer need constants.dart here for the keys/controllers
import '../utils/validations.dart';

class Login extends StatefulWidget {
  final VoidCallback onNavigateToSignUp;
  final VoidCallback onSignUpSuccess;

  const Login({
    super.key,
    required this.onNavigateToSignUp,
    required this.onSignUpSuccess,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // 1. Declare unique keys and controllers specifically for the Login screen
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _error = '';

  void _handleLogin() async {
    // 2. Use the local key
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      widget.onSignUpSuccess();
    } else {
      setState(() {
        _error = result['message'] ?? 'Login failed. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const Text(
                  "Login",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
                const SizedBox(height: 60),
                Form(
                  // 5. Attach the local key here
                  key: _loginFormKey,
                  child: Column(
                    children: [
                      AuthFields(
                        // 6. Attach local controller
                        controller: _emailController,
                        validator: Validators.validateEmail,
                        label: "Email",
                        suffixIcon: const Icon(Icons.email),
                      ),
                      const SizedBox(height: 20),
                      AuthFields(
                        // 6. Attach local controller
                        controller: _passwordController,
                        validator: Validators.validatePassword,
                        label: "Password",
                        obscure: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _error,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.onNavigateToSignUp();
                            },
                            child: const Text(
                              "Create new Account",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _isLoading
                          ? const CircularProgressIndicator(color: AppColors.buttonBackground)
                          : SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonBackground,
                          ),
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}