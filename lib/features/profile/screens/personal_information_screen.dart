import 'package:flutter/material.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/services/profile_service.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/models/user.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _editing = false;
  late final ProfileService _profileService;
  User? _user;
  bool _isLoading = true;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(ApiService());
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _profileService.getCurrentUser();

      if (mounted) {
        setState(() {
          _user = user;
          _firstNameCtrl.text = user?.firstName ?? '';
          _lastNameCtrl.text = user?.lastName ?? '';
          _emailCtrl.text = user?.email ?? '';
          _phoneCtrl.text = user?.phoneNumber ?? '';
          _dobCtrl.text = user?.dateOfBirth ?? '';
          _countryCtrl.text = user?.country ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _dobCtrl,
      _countryCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final updated = await _profileService.updateProfile({
          'displayName':
              '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'
                  .trim(),
          'email': _emailCtrl.text.trim(),
          'country': _countryCtrl.text.trim(),
          'dateOfBirth': _dobCtrl.text.trim(),
          'phoneNumber': _phoneCtrl.text.trim(),
        });

        if (!mounted) return;

        setState(() {
          _user = updated ?? _user;
          _editing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update profile'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1F2E),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Personal Information',
            style: AppTextStyles.h4.copyWith(color: AppColors.textWhite)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              if (_editing) {
                await _save();
              } else {
                setState(() => _editing = true);
              }
            },
            child: Text(
              _editing ? 'Save' : 'Edit',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.accentGreen,
                      fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar row
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.accentGreen, Color(0xFF00CC6E)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _user?.initials ?? '?',
                        style: AppTextStyles.h2.copyWith(
                          color: const Color(0xFF0B1220),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_editing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF0B1220), width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 14, color: Color(0xFF0B1220)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _SectionLabel('Basic Info'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoField(
                      label: 'First Name',
                      controller: _firstNameCtrl,
                      enabled: _editing,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoField(
                      label: 'Last Name',
                      controller: _lastNameCtrl,
                      enabled: _editing,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoField(
                label: 'Email Address',
                controller: _emailCtrl,
                enabled: _editing,
                keyboardType: TextInputType.emailAddress,
                trailingIcon: const Icon(Icons.verified_rounded,
                    color: AppColors.accentGreen, size: 18),
              ),
              const SizedBox(height: 16),
              _InfoField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                enabled: _editing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              _SectionLabel('Details'),
              const SizedBox(height: 12),
              _InfoField(
                label: 'Date of Birth',
                controller: _dobCtrl,
                enabled: _editing,
              ),
              const SizedBox(height: 16),
              _InfoField(
                label: 'Country',
                controller: _countryCtrl,
                enabled: _editing,
              ),
              const SizedBox(height: 24),
              _SectionLabel('Account'),
              const SizedBox(height: 12),
              _ReadOnlyRow(
                label: 'Username',
                value: '@${(_user?.email ?? '').split('@').first}',
              ),
              const SizedBox(height: 12),
              _ReadOnlyRow(
                label: 'Member Since',
                value: _user == null ? '-' : 'Active Member',
              ),
              const SizedBox(height: 12),
              _ReadOnlyRow(
                label: 'Account Level',
                value: (_user?.role ?? 'player').toUpperCase(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── helpers ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTextStyles.overline.copyWith(
          color: const Color(0xFFA0A4B8),
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.controller,
    required this.enabled,
    this.keyboardType,
    this.trailingIcon,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final Widget? trailingIcon;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: const Color(0xFFA0A4B8))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textWhite),
          decoration: InputDecoration(
            suffixIcon: trailingIcon,
            filled: true,
            fillColor: enabled
                ? const Color(0xFF252B3D)
                : const Color(0xFF1A1F2E),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF252B3D)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.accentGreen),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A1F2E)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252B3D)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: const Color(0xFFA0A4B8))),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textWhite,
                      fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

