import 'package:aio_tech/utils/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../Widgets/auth_fields.dart';
import '../services/auth_services.dart';
import '../utils/validations.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key, required this.onSignUpSuccess});

  final VoidCallback onSignUpSuccess;
  @override
  State<SignUp> createState() => _SignUpState();
}

// Added SingleTickerProviderStateMixin for the animation controller
class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  String? selectedGender;
  int? selectedAge;
  final List<int> ages = List.generate(93, (index) => index + 8);
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _error = '';

  // Lazy initialization of Animation controllers to prevent LateInitializationError
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

  void _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await _authService.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      age: selectedAge,
      gender: selectedGender,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      widget.onSignUpSuccess();
    } else {
      setState(() {
        _error = result['message'] ?? 'Signup failed. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _bgController.dispose(); // Dispose the animation controller
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a Stack to place content over the animated background
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Text(
                      tr('signup'),
                      // Changed to white for dark background contrast
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 60),
                    Form(
                      key: _signUpFormKey,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Column(
                            spacing: 20,
                            children: [
                              AuthFields(
                                controller: _nameController,
                                validator: (value) => value == null || value.isEmpty
                                    ? "Name is required"
                                    : null,
                                label: tr('full name'),
                                suffixIcon: const Icon(Icons.account_circle, color: Colors.white70),
                              ),
                              AuthFields(
                                controller: _emailController,
                                validator: Validators.validateEmail,
                                label: tr('email'),
                                suffixIcon: const Icon(Icons.email, color: Colors.white70),
                              ),
                              AuthFields(
                                label: tr('password'),
                                obscure: _obscurePassword,
                                controller: _passwordController,
                                validator: Validators.validatePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              AuthFields(
                                label: tr('confirm your password'),
                                obscure: _obscurePassword,
                                controller: _confirmPasswordController,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return "Passwords do not match";
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        // Glassmorphism effect for Dropdowns
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          width: 1.5,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedGender,
                                          // Keep dropdown items readable on dark menus
                                          dropdownColor: const Color(0xFF18498D),
                                          iconEnabledColor: Colors.white70,
                                          style: const TextStyle(color: Colors.white, fontSize: 16),
                                          hint: Text(
                                            tr('gender'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                          isExpanded: true,
                                          items:  [
                                            DropdownMenuItem(
                                              value: "Man",
                                              child: Text(tr('man')),
                                            ),
                                            DropdownMenuItem(
                                              value: "Woman",
                                              child: Text(tr('woman')),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              selectedGender = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        // Glassmorphism effect for Dropdowns
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          width: 1.5,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: selectedAge,
                                          // Keep dropdown items readable on dark menus
                                          dropdownColor: const Color(0xFF18498D),
                                          iconEnabledColor: Colors.white70,
                                          style: const TextStyle(color: Colors.white, fontSize: 16),
                                          hint: Text(
                                            tr('age'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                          isExpanded: true,
                                          items: ages.map((age) {
                                            return DropdownMenuItem<int>(
                                              value: age,
                                              child: Text(age.toString()),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedAge = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                              _isLoading
                                  ? const CircularProgressIndicator(
                                color: AppColors.buttonBackground,
                              )
                                  : SizedBox(
                                width: 200,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _handleSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    AppColors.buttonBackground,
                                  ),
                                  child: Text(
                                    tr('create new'),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}