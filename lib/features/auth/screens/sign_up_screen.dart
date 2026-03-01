import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/theme_context.dart';
import '../../../core/models/user.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  String _selectedRole = 'bettor'; // Default role
  final _clubNameController = TextEditingController();
  final _teamCategoryController = TextEditingController();
  bool _isAgeConfirmed = false;
  bool _isTermsAccepted = false;
  bool _isLoading = false;
  late final AuthService _authService;

  final List<String> _teamCategories = [
    'U13',
    'U15',
    'U17',
    'U18',
    'U21',
    'Senior',
    'Women',
  ];

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiService());
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateOfBirthController.dispose();
    _clubNameController.dispose();
    _teamCategoryController.dispose();
    super.dispose();
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required';
    }
    if (value.length < 2) {
      return 'Display name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
    }
    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: context.isDark
                ? ColorScheme.dark(
                    primary: context.accent,
                    onPrimary: AppColors.primaryDark,
                    surface: context.inputBg,
                    onSurface: context.textPrimary,
                  )
                : ColorScheme.light(
                    primary: context.accent,
                    onPrimary: Colors.white,
                    surface: context.inputBg,
                    onSurface: context.textPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _dateOfBirthController.text = formattedDate;
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isAgeConfirmed) {
      _showSnackBar('Please confirm you are 18 years or older');
      return;
    }

    if (!_isTermsAccepted) {
      _showSnackBar('Please accept the Terms of Service and Privacy Policy');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final registerRequest = RegisterRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
        dateOfBirth: _dateOfBirthController.text, // Format: YYYY-MM-DD
        role: _selectedRole,
      );

      final authResponse = await _authService.register(registerRequest);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${authResponse.user.displayName}!'),
            backgroundColor: context.accent,
          ),
        );

        // Navigate based on role
        if (_selectedRole == 'coach') {
          Navigator.pushReplacementNamed(context, AppRoutes.coachHome);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        String errorMessage = 'Registration failed. Please try again.';

        if (e.toString().contains('409') ||
            e.toString().contains('already exists')) {
          errorMessage = 'An account with this email already exists';
        } else if (e.toString().contains('400')) {
          errorMessage = 'Invalid registration data. Please check your inputs.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Logo and header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(24, 24),
                          painter: _ConcentricCirclesPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Create Account',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Join FootSmart Pro and start betting smarter',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // Display Name field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Display Name',
                        style: AppTextStyles.inputLabel.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _displayNameController,
                      keyboardType: TextInputType.name,
                      validator: _validateDisplayName,
                      style: AppTextStyles.inputText.copyWith(
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'John Doe',
                        hintStyle: AppTextStyles.inputHint.copyWith(
                          color: context.textHint,
                        ),
                        filled: true,
                        fillColor: context.inputBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Email field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Email Address',
                        style: AppTextStyles.inputLabel.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      style: AppTextStyles.inputText.copyWith(
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'your@email.com',
                        hintStyle: AppTextStyles.inputHint.copyWith(
                          color: context.textHint,
                        ),
                        filled: true,
                        fillColor: context.inputBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Password field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Password',
                        style: AppTextStyles.inputLabel.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      validator: _validatePassword,
                      style: AppTextStyles.inputText.copyWith(
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Create a strong password',
                        hintStyle: AppTextStyles.inputHint.copyWith(
                          color: context.textHint,
                        ),
                        filled: true,
                        fillColor: context.inputBg,
                        suffixIcon: Icon(
                          Icons.visibility_off_outlined,
                          color: context.iconInactive,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Confirm password field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Confirm Password',
                        style: AppTextStyles.inputLabel.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      validator: _validateConfirmPassword,
                      style: AppTextStyles.inputText.copyWith(
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Re-enter your password',
                        hintStyle: AppTextStyles.inputHint.copyWith(
                          color: context.textHint,
                        ),
                        filled: true,
                        fillColor: context.inputBg,
                        suffixIcon: Icon(
                          Icons.visibility_off_outlined,
                          color: context.iconInactive,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Date of Birth field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Date of Birth',
                        style: AppTextStyles.inputLabel.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _dateOfBirthController,
                      readOnly: true,
                      onTap: _selectDate,
                      validator: _validateDateOfBirth,
                      style: AppTextStyles.inputText.copyWith(
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Select your date of birth',
                        hintStyle: AppTextStyles.inputHint.copyWith(
                          color: context.textHint,
                        ),
                        filled: true,
                        fillColor: context.inputBg,
                        suffixIcon: Icon(
                          Icons.calendar_today_outlined,
                          color: context.iconInactive,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.borderColor,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Role selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'I am a',
                        style: AppTextStyles.inputLabel.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'bettor';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'bettor'
                                    ? context.accent.withValues(alpha: 0.15)
                                    : context.inputBg,
                                border: Border.all(
                                  color: _selectedRole == 'bettor'
                                      ? context.accent
                                      : context.borderColor,
                                  width: _selectedRole == 'bettor' ? 2 : 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.sports_soccer,
                                    color: _selectedRole == 'bettor'
                                        ? context.accent
                                        : context.textSecondary,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Bettor',
                                    style: AppTextStyles.buttonMedium.copyWith(
                                      color: _selectedRole == 'bettor'
                                          ? context.accent
                                          : context.textSecondary,
                                      fontWeight: _selectedRole == 'bettor'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'coach';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'coach'
                                    ? context.accentOrange
                                        .withValues(alpha: 0.15)
                                    : context.inputBg,
                                border: Border.all(
                                  color: _selectedRole == 'coach'
                                      ? context.accentOrange
                                      : context.borderColor,
                                  width: _selectedRole == 'coach' ? 2 : 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.sports,
                                    color: _selectedRole == 'coach'
                                        ? context.accentOrange
                                        : context.textSecondary,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Coach',
                                    style: AppTextStyles.buttonMedium.copyWith(
                                      color: _selectedRole == 'coach'
                                          ? context.accentOrange
                                          : context.textSecondary,
                                      fontWeight: _selectedRole == 'coach'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Coach-specific fields
                if (_selectedRole == 'coach') ...[
                  const SizedBox(height: 20),

                  // Club Name field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Club / Team Name',
                          style: AppTextStyles.inputLabel.copyWith(
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _clubNameController,
                        keyboardType: TextInputType.text,
                        validator: _selectedRole == 'coach'
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Club name is required for coaches';
                                }
                                return null;
                              }
                            : null,
                        style: AppTextStyles.inputText.copyWith(
                          color: context.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. FC Barcelona Youth',
                          hintStyle: AppTextStyles.inputHint.copyWith(
                            color: context.textHint,
                          ),
                          prefixIcon: Icon(
                            Icons.shield_outlined,
                            color: context.iconInactive,
                          ),
                          filled: true,
                          fillColor: context.inputBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: context.borderColor,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: context.borderColor,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: context.accentOrange,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Team Category
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Team Category',
                          style: AppTextStyles.inputLabel.copyWith(
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _teamCategories.map((cat) {
                          final isSelected =
                              _teamCategoryController.text == cat;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _teamCategoryController.text = cat;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.accentOrange
                                        .withValues(alpha: 0.15)
                                    : context.inputBg,
                                border: Border.all(
                                  color: isSelected
                                      ? context.accentOrange
                                      : context.borderColor,
                                  width: isSelected ? 2 : 1.5,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cat,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isSelected
                                      ? context.accentOrange
                                      : context.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Age confirmation checkbox
                InkWell(
                  onTap: () {
                    setState(() {
                      _isAgeConfirmed = !_isAgeConfirmed;
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _isAgeConfirmed
                              ? AppColors.accentGreen
                              : Colors.transparent,
                          border: Border.all(
                            color: _isAgeConfirmed
                                ? AppColors.accentGreen
                                : context.iconInactive,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _isAgeConfirmed
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.primaryDark,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'I confirm that I am 18 years or older and legally allowed to gamble in my jurisdiction',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Terms checkbox
                InkWell(
                  onTap: () {
                    setState(() {
                      _isTermsAccepted = !_isTermsAccepted;
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _isTermsAccepted
                              ? AppColors.accentGreen
                              : Colors.transparent,
                          border: Border.all(
                            color: _isTermsAccepted
                                ? AppColors.accentGreen
                                : context.iconInactive,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _isTermsAccepted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.primaryDark,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodySmall.copyWith(
                              color: context.textSecondary,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: context.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: context.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Create account button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor:
                          context.isDark ? AppColors.primaryDark : Colors.white,
                      disabledBackgroundColor:
                          context.accent.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.isDark
                                    ? AppColors.primaryDark
                                    : Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: AppTextStyles.buttonLarge.copyWith(
                              color: context.isDark
                                  ? AppColors.primaryDark
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.signIn);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: context.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, size.width * 0.45, paint);
    canvas.drawCircle(center, size.width * 0.30, paint);

    final fillPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size.width * 0.15, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
