import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'forgot_password_confirmation_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  bool isEmailValid = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains("@")) {
      setState(() {
        isEmailValid = false;
      });
      return;
    }

    setState(() {
      isEmailValid = true;
      _isLoading = true;
    });

    final success = await AuthService().sendPasswordResetEmail(email);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ForgotPasswordConfirmationPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to send reset email. Try again."),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF2E7D32);
    final lightGreen = const Color(0xFFE8F5E9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Back button
                          SizedBox(
                            height: 60,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: primary,
                                  size: 20,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: lightGreen,
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                            ),
                          ),

                          // Main content
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon
                                Container(
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: lightGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.lock_reset_rounded,
                                    size: 64,
                                    color: primary,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Title
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [primary, primary.withOpacity(0.7)],
                                  ).createShader(bounds),
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Subtitle
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    "Enter your email and we'll send you reset instructions",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // Email field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Email Address",
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (value) {
                                        if (!isEmailValid) {
                                          setState(() {
                                            isEmailValid = true;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintText: "youremail@gmail.com",
                                        hintStyle: TextStyle(color: Colors.grey[400]),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: Colors.grey[600],
                                          size: 22,
                                        ),
                                        errorText: isEmailValid
                                            ? null
                                            : "Please enter a valid email",
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 18,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: primary,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.red.shade400,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.red.shade400,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Bottom buttons
                          Column(
                            children: [
                              // Send Reset Link Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _sendResetEmail,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    disabledBackgroundColor: primary.withOpacity(0.6),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                      : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Send Reset Link",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.send_rounded, size: 20),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Back to Login
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_rounded,
                                      color: primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Back to Login",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}