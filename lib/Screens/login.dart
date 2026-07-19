import 'package:aio_tech/Screens/sign_up.dart';
import 'package:aio_tech/Widgets/auth_fields.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../utils/app_colors.dart';
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

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  // Declare unique keys and controllers specifically for the Login screen
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _error = '';

  // Lazy initialization of Animation controllers.
  // Using 'late final' with an inline initializer prevents LateInitializationError
  // during Hot Reloads, making the code much more robust and safer to develop.
  late final AnimationController _bgController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  late final Animation<Alignment> _topAlignment = AlignmentTween(
    begin: Alignment.topLeft,
    end: Alignment.topRight,
  ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

  late final Animation<Alignment> _bottomAlignment = AlignmentTween(
    begin: Alignment.bottomRight,
    end: Alignment.bottomLeft,
  ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    // Animation initializations are now handled lazily above.
  }

  void _handleLogin() async {
    // Use the local key to validate form fields
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
    _bgController.dispose(); // Dispose the animation controller
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use a Stack to place the main content over the animated background
      body: Stack(
        children: [
          // Animated Gradient Background Layer
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFF0C133D), // Dark indigo (Top)
                      Color(0xFF18498D), // Deep blue (Middle)
                      Color(0xFF2CB5E8), // Cyan/Light Blue (Bottom)
                    ],
                    begin: _topAlignment.value,
                    end: _bottomAlignment.value,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          // Main content layer
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      spacing: 30,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        Text(tr('login'),
                          // Changed title to white for better contrast against dark background
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 60),

                        Form(
                          // Attach the local key here
                          key: _loginFormKey,
                          child: Column(
                            children: [
                              AuthFields(
                                // Attach local controller
                                controller: _emailController,
                                validator: Validators.validateEmail,
                                label: tr('email'),
                                // Styled icon to match the new dark theme
                                suffixIcon: const Icon(Icons.email, color: Colors.white70),
                              ),
                              const SizedBox(height: 20),
                              AuthFields(
                                // Attach local controller
                                controller: _passwordController,
                                validator: Validators.validatePassword,
                                label: tr('password'),
                                obscure: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white70,
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
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 30,),

                                  TextButton(
                                    onPressed: () {
                                      widget.onNavigateToSignUp();
                                    },
                                    child: Text(
                                      tr('create new'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ),
                              SizedBox(height: 20,),
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
                                  child: Text(
                                    tr('confirm'),
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
            ),
          ),
        ],
      ),
    );
  }
}