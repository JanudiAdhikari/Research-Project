import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _rePasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureRePassword = true;

  String _selectedRole = '';

  // Error messages
  String? _emailError;
  String? _passwordError;
  String? _contactError;
  String? _passwordMatchError;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Add real-time validation listeners
    _emailController.addListener(() {
      setState(() {
        _emailError = _authService.validateEmail(_emailController.text);
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _passwordError = _authService.validatePassword(
          _passwordController.text,
        );
        // Check password match
        if (_rePasswordController.text.isNotEmpty) {
          _passwordMatchError =
              _passwordController.text != _rePasswordController.text
              ? "Passwords do not match"
              : null;
        }
      });
    });

    _rePasswordController.addListener(() {
      setState(() {
        if (_rePasswordController.text.isNotEmpty) {
          _passwordMatchError =
              _passwordController.text != _rePasswordController.text
              ? "Passwords do not match"
              : null;
        }
      });
    });

    _contactController.addListener(() {
      setState(() {
        _contactError = _authService.validateContactNumber(
          _contactController.text,
        );
      });
    });

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    // Basic validation
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all fields"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Validation checks
    if (_emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_emailError!),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_passwordError!),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_contactError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_contactError!),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_selectedRole.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Please select a role"), backgroundColor: Colors.red.shade400),
  );
  return;
}

    // Password match validation
    if (_passwordController.text != _rePasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Passwords do not match"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        contact: _contactController.text.trim(),
        role: _selectedRole,
      );

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        // Check for validation errors from service
        if (user.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(user['error'] ?? "Sign-up failed"),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }

        // Navigate to login screen with success message
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(
              successMessage: "Sign-up successful! Please login.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Sign-up failed"),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign-up error: $e"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final primary = const Color(0xFF2E7D32);
    final lightGreen = const Color(0xFFE8F5E9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },

        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.pagePadding,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ResponsiveSpacing(mobile: 40, tablet: 48),

                        // Back button
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: primary,
                              size: responsive.smallIconSize,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: lightGreen,
                              padding: EdgeInsets.all(responsive.smallSpacing),
                            ),
                          ),
                        ),

                        ResponsiveSpacing(mobile: 10, tablet: 16),

                        // Logo with background
                        Container(
                          padding: EdgeInsets.all(
                            responsive.spacing(mobile: 16, tablet: 20),
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: lightGreen,
                            border: Border.all(
                              color: primary.withOpacity(0.3),
                              width: responsive.value(mobile: 2, tablet: 2.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.25),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              "assets/images/logos/logo.png",
                              height: responsive.value(mobile: 80, tablet: 100),
                              width: responsive.value(mobile: 80, tablet: 100),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        ResponsiveSpacing(mobile: 24, tablet: 32),

                        // Title
                        ResponsiveText(
                          "Create Your",
                          mobileFontSize: 28,
                          tabletFontSize: 32,
                          desktopFontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.black87,
                        ),

                        const SizedBox(height: 4),

                        // Sign Up with gradient
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [primary, primary.withOpacity(0.7)],
                          ).createShader(bounds),
                          child: ResponsiveText(
                            "Account",
                            mobileFontSize: 32,
                            tabletFontSize: 38,
                            desktopFontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),

                        ResponsiveSpacing(mobile: 32, tablet: 40),

                        // Role Selection
                        _buildRoleSelection(responsive, primary),

                        ResponsiveSpacing(mobile: 32, tablet: 40),

                        // First name
                        _buildInputField(
                          responsive: responsive,
                          label: "First Name",
                          hint: "Enter your first name",
                          controller: _firstNameController,
                          icon: Icons.person_outline,
                          primary: primary,
                        ),

                        ResponsiveSpacing(mobile: 16, tablet: 20),

                        // Last name
                        _buildInputField(
                          responsive: responsive,
                          label: "Last Name",
                          hint: "Enter your last name",
                          controller: _lastNameController,
                          icon: Icons.person_outline,
                          primary: primary,
                        ),

                        ResponsiveSpacing(mobile: 16, tablet: 20),

                        // Email
                        _buildInputField(
                          responsive: responsive,
                          label: "Email Address",
                          hint: "youremail@gmail.com",
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          primary: primary,
                          errorText: _emailError,
                        ),

                        ResponsiveSpacing(mobile: 16, tablet: 20),

                        // Contact
                        _buildInputField(
                          responsive: responsive,
                          label: "Contact Number",
                          hint: "0712345678",
                          controller: _contactController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          primary: primary,
                          errorText: _contactError,
                        ),

                        ResponsiveSpacing(mobile: 16, tablet: 20),

                        // Password
                        _buildInputField(
                          responsive: responsive,
                          label: "Password",
                          hint: "Create a strong password",
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          primary: primary,
                          errorText: _passwordError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                              size: responsive.mediumIconSize,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),

                        ResponsiveSpacing(mobile: 16, tablet: 20),

                        // Re-enter password
                        _buildInputField(
                          responsive: responsive,
                          label: "Confirm Password",
                          hint: "Re-enter your password",
                          controller: _rePasswordController,
                          icon: Icons.lock_outline,
                          obscureText: _obscureRePassword,
                          primary: primary,
                          errorText: _passwordMatchError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureRePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                              size: responsive.mediumIconSize,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureRePassword = !_obscureRePassword;
                              });
                            },
                          ),
                        ),

                        ResponsiveSpacing(mobile: 32, tablet: 40),

                        // Sign Up Button with shadow
                        Container(
                          width: double.infinity,
                          height: responsive.buttonHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
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
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Create Account",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              responsive.titleFontSize + 1,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: responsive.smallIconSize,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        ResponsiveSpacing(mobile: 24, tablet: 28),

                        // Divider with "OR"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: responsive.bodyFontSize,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                          ],
                        ),

                        ResponsiveSpacing(mobile: 24, tablet: 28),

                        // Google sign up button
                        Container(
                          width: double.infinity,
                          height: responsive.buttonHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final user = await _authService
                                    .signInWithGoogle();

                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Google signup failed"),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(
                                      successMessage:
                                          "Signup successful! Continue with Google",
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(28),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/icons/google.png",
                                    height: responsive.mediumIconSize,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Sign up with Google",
                                    style: TextStyle(
                                      fontSize: responsive.titleFontSize,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        ResponsiveSpacing(mobile: 24, tablet: 32),

                        // Login link
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: responsive.bodyFontSize + 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _navigateToLogin,
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: responsive.bodyFontSize + 1,
                                ),
                              ),
                            ),
                          ],
                        ),

                        ResponsiveSpacing(mobile: 40, tablet: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required Responsive responsive,
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color primary,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: responsive.bodyFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(fontSize: responsive.bodyFontSize + 1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: responsive.bodyFontSize + 1,
            ),
            filled: true,
            fillColor: hasError ? Colors.red.shade50 : Colors.grey[50],
            prefixIcon: Icon(
              icon,
              color: hasError ? Colors.red : Colors.grey[600],
              size: responsive.mediumIconSize,
            ),
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.mediumSpacing,
              vertical: responsive.value(mobile: 18, tablet: 20),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade300 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : primary,
                width: 2,
              ),
            ),
            errorText: hasError ? errorText : null,
            errorStyle: TextStyle(
              color: Colors.red.shade700,
              fontSize: responsive.bodyFontSize - 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelection(Responsive responsive, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Your Role",
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: responsive.bodyFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Row(
            children: [
              // Farmer Option
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = 'farmer';
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(responsive.mediumSpacing),
                    decoration: BoxDecoration(
                      color: _selectedRole == 'farmer'
                          ? primary.withOpacity(0.15)
                          : Colors.transparent,
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.agriculture_rounded,
                          color: _selectedRole == 'farmer'
                              ? primary
                              : Colors.grey[600],
                          size: responsive.largeIconSize,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Farmer",
                          style: TextStyle(
                            color: _selectedRole == 'farmer'
                                ? primary
                                : Colors.grey[700],
                            fontWeight: _selectedRole == 'farmer'
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: responsive.bodyFontSize,
                          ),
                        ),
                        if (_selectedRole == 'farmer')
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: responsive.smallIconSize,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Exporter Option
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = 'exporter';
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(responsive.mediumSpacing),
                    decoration: BoxDecoration(
                      color: _selectedRole == 'exporter'
                          ? primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(11),
                        bottomRight: Radius.circular(11),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_shipping_rounded,
                          color: _selectedRole == 'exporter'
                              ? primary
                              : Colors.grey[600],
                          size: responsive.largeIconSize,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Exporter",
                          style: TextStyle(
                            color: _selectedRole == 'exporter'
                                ? primary
                                : Colors.grey[700],
                            fontWeight: _selectedRole == 'exporter'
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: responsive.bodyFontSize,
                          ),
                        ),
                        if (_selectedRole == 'exporter')
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: responsive.smallIconSize,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
