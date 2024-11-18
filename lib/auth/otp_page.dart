import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _phoneController = TextEditingController();

  final _phoneNumberKey = GlobalKey<FormFieldState>();

  bool isSent = false;
  bool isPhoneLoading = false;
  bool isOtpLoading = false;
  bool isError = false;

  bool isCountdownActive = false;
  int countdownSeconds = 60;
  Timer? _countdownTimer;

  String? code;

  void startCountdown() {
    setState(() {
      isCountdownActive = true;
      countdownSeconds = 60;
    });

    _countdownTimer?.cancel(); // Cancel any existing timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdownSeconds > 0) {
          countdownSeconds--;
        } else {
          timer.cancel();
          isCountdownActive = false;
        }
      });
    });
  }

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation =
        Tween<double>(begin: 0, end: 10).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _phoneController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _verifyOtp(String verificationCode, BuildContext context) {
    setState(() {
      isOtpLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (verificationCode != "1234") {
        // Example: "1234" is the correct OTP
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP!')),
        );
        setState(() {
          isError = true;
          isOtpLoading = false;
        });
        _shakeController.forward(from: 0);
      } else {
        setState(() {
          isError = false;
          isOtpLoading = false;
        });

        log('OTP Verified');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verified successfully!')),
        );
        setState(() {
          _countdownTimer?.cancel();
          countdownSeconds = 60;
          isCountdownActive = false;
        });
        context.go("/creation");
        // Navigate to the next page or perform desired action
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              child: Image.asset(
                "assets/icons/launcher_icon.png",
                height: 40,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              "Sneek",
              style: GoogleFonts.inter(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top AppBar Section
                      // Padding(
                      //   padding: const EdgeInsets.all(15.0),
                      //   child: Row(
                      //     children: [
                      //       GestureDetector(
                      //         child: Image.asset(
                      //           "assets/icons/launcher_icon.png",
                      //           height: 40,
                      //         ),
                      //       ),
                      //       const SizedBox(width: 2),
                      //       Text(
                      //         "Sneek",
                      //         style: GoogleFonts.inter(
                      //           fontSize: 17,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Banner Image & Title Section
                      Flexible(
                        flex: 2,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/otp.webp',
                              height: constraints.maxHeight * 0.35,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "Secure Access Made Simple",
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 35),
                              child: Text(
                                "Log in with your mobile number and verify your OTP to proceed.",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // PageView Section
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          height: constraints.maxHeight * 0.4,
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: phoneNumberWidget(constraints),
                              ),
                              otpAuthWidget(context, constraints),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: isError
          ? Padding(
              padding: const EdgeInsets.only(bottom: 15, right: 15),
              child: GestureDetector(
                onTap: () {
                  if (code != null) {
                    _verifyOtp(code!, context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid OTP!')),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).textTheme.headlineLarge?.color,
                  child: Center(
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget otpAuthWidget(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "+91-${_phoneController.text}",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Wrong number? ",
                style: GoogleFonts.inter(color: Colors.white),
              ),
              SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSent = false;
                    isError = false;
                    countdownSeconds = 60;
                    isCountdownActive = false;
                    _countdownTimer?.cancel();
                  });
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: FaIcon(
                  FontAwesomeIcons.penToSquare,
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                  size: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              );
            },
            child: OtpTextField(
              numberOfFields: 4,
              filled: true,
              cursorColor: Colors.red,
              fillColor: Color(0xFF1F2937),
              enabledBorderColor: isError ? Colors.red : Colors.white,
              borderColor: Colors.red,
              textStyle: GoogleFonts.inter(
                color: isError ? Colors.red : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              fieldWidth: constraints.maxWidth * 0.15,
              onSubmit: (String verificationCode) {
                if (isError) {
                  setState(() {
                    code = verificationCode;
                  });
                  return;
                }
                _verifyOtp(verificationCode, context);
              },
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: isCountdownActive
                ? null
                : () {
                    startCountdown();
                    setState(() {
                      isSent = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP has been sent successfully!')),
                    );
                  },
            child: Text(
              isCountdownActive ? "Resend OTP in $countdownSeconds seconds" : "Resend OTP",
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
          if (isOtpLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget phoneNumberWidget(BoxConstraints constraints) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              "Enter 10 digit valid number",
              style: GoogleFonts.inter(
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          TextFormField(
            key: _phoneNumberKey,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            style: GoogleFonts.inter(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length != 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: GoogleFonts.inter(color: const Color(0xFFFF6500)),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF6500)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF6500)),
              ),
            ),
            onChanged: (value) {
              if (value.length == 10) {
                setState(() {
                  isSent = true;
                });
                _sendOtp();
              }
            },
          ),
        ],
      ),
    );
  }

  // Simulate sending OTP
  void _sendOtp() {
    // Simulating API call
    Future.delayed(const Duration(seconds: 1), () {
      // Move to OTP page
      // Fluttertoast.showToast(msg: "OTP has sent successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP has sent successfully!')),
      );
      // _pageController.nextPage(
      //   duration: Duration(milliseconds: 300),
      //   curve: Curves.easeIn,
      // );
      startCountdown();
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }
}
