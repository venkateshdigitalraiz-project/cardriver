import 'package:cardriver/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isOtpSentLocal = false;

  @override
  void dispose() {
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onSendOtp() {
    final phone = _phoneController.text.trim();
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (phone.isEmpty) {
      AppSnackBar.showError(context, 'Please enter a mobile number.');
      return;
    }

    if (digits.length != 10) {
      AppSnackBar.showError(
        context,
        'Mobile number must be exactly 10 digits.',
      );
      return;
    }

    if (_phoneFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isOtpSentLocal = true;
      });
      context.read<AuthBloc>().add(SendOtpEvent(phone: phone));
    }
  }

  void _onVerifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      AppSnackBar.showError(context, 'Please enter exactly 4 digits for OTP.');
      return;
    }
    context.read<AuthBloc>().add(
      VerifyOtpEvent(phone: _phoneController.text.trim(), otp: otp),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    //final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error && state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
        } else if (state.status == AuthStatus.otpSent &&
            state.pendingPhoneNumber != null) {
          if (!_isOtpSentLocal) {
            setState(() {
              _isOtpSentLocal = true;
            });
          }
          AppSnackBar.showSuccess(
            context,
            'OTP code sent to ${state.pendingPhoneNumber}!',
          );
          // No longer navigating to OtpVerificationPage! We stay on the same page.
        } else if (state.status == AuthStatus.authenticated &&
            state.customer != null) {
          AppSnackBar.showSuccess(
            context,
            'Welcome back, ${state.customer!.name}!',
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => WelcomePage(customer: state.customer!),
            ),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final isOtpSent = _isOtpSentLocal || state.status == AuthStatus.otpSent;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Stack(
              children: [
                Container(
                  height: size.height * 0.5,
                  width: double.infinity,
                  child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/car_driver.jpg'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 60,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE94E34),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Positioned(
                                  left: 8,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFF2A33A,
                                      ).withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Ready to Drive?",
                          style:
                              const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ).copyWith(
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

                Container(
                  margin: EdgeInsets.only(top: size.height * 0.4),
                  constraints: BoxConstraints(
                    minHeight: size.height * 0.6,
                  ),
                  width: double.infinity,
                  child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 100 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, -10),
                          ),
                        ],
                      ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Driver Login',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Positioned(
                                          left: 10,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary
                                                  .withValues(alpha: 0.8),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Form(
                              key: _phoneFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Enter your mobile number to continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                    maxLength: 10,
                                    readOnly: isOtpSent,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Mobile Number',
                                      labelStyle: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                      hintText: '1234567890',
                                      hintStyle: const TextStyle(
                                        color: Colors.black38,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.phone,
                                        color: AppColors.primary,
                                      ),
                                      suffixIcon: isOtpSent
                                          ? IconButton(
                                              icon: const Icon(Icons.edit, color: AppColors.primary),
                                              onPressed: () {
                                                setState(() {
                                                  _isOtpSentLocal = false;
                                                  for (var c in _otpControllers) {
                                                    c.clear();
                                                  }
                                                });
                                                context.read<AuthBloc>().add(ResetAuthEvent());
                                              },
                                            )
                                          : null,
                                      filled: true,
                                      fillColor: isOtpSent
                                          ? Colors.grey[200]
                                          : Colors.grey[100],
                                      counterText: '',
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.error,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter a valid mobile number';
                                      }
                                      final digits = value.replaceAll(
                                        RegExp(r'\D'),
                                        '',
                                      );
                                      if (digits.length != 10) {
                                        return 'Mobile number must be exactly 10 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (isOtpSent) ...[
                                    const SizedBox(height: 32),
                                    const Text(
                                      'Enter 4-digit OTP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(4, (index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: TextFormField(
                                              controller:
                                                  _otpControllers[index],
                                              focusNode: _focusNodes[index],
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(
                                                  1,
                                                ),
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.grey[100],
                                                contentPadding: EdgeInsets.zero,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                    ),
                                              ),
                                              onChanged: (value) {
                                                if (value.isNotEmpty &&
                                                    index < 3) {
                                                  _focusNodes[index + 1]
                                                      .requestFocus();
                                                } else if (value.isEmpty &&
                                                    index > 0) {
                                                  _focusNodes[index - 1]
                                                      .requestFocus();
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                  const SizedBox(height: 32),
                                  ElevatedButton(
                                    onPressed: state.isLoading
                                        ? null
                                        : (isOtpSent
                                              ? _onVerifyOtp
                                              : _onSendOtp),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: state.isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            isOtpSent
                                                ? 'Verify OTP'
                                                : 'Send OTP',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
