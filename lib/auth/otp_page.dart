import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:sneekin/utils/toast.dart';
import 'package:toastification/toastification.dart';

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

  _verifyOtp(String verificationCode, BuildContext context) async {
    final auth = Provider.of<AuthServices>(context, listen: false);
    final app = Provider.of<AppStore>(context, listen: false);
    setState(() {
      isOtpLoading = true;
    });

    if (_phoneController.text.isEmpty && verificationCode == "") {
      showToast(message: "Details missing.", type: ToastificationType.error);
      return;
    }
    final result = await auth.verifyOTP(phone: _phoneController.text, otp: verificationCode);

    log("result in OtpPage: $result");
    setState(() {
      isError = false;
      isOtpLoading = false;
    });

    if (result == "NEW_USER") {
      setState(() {
        _countdownTimer?.cancel();
        countdownSeconds = 60;
        isCountdownActive = false;
      });
      context.go("/creation");
    } else if (result == "EXISTING_USER") {
      setState(() {
        _countdownTimer?.cancel();
        countdownSeconds = 60;
        isCountdownActive = false;
      });

      log("accessToken in OTPPage: ${app.app?.accessToken}");
      if (app.app?.accessToken == null) {
        log("appData is null so reinitializing it...");
        await app.initializeAppData();
      }

      final resp = await auth.getProfile(accessToken: app.app?.accessToken ?? "");

      if (resp == true) {
        context.go("/root");
      } else {
        showToast(message: "Some error occurred. Try again later.", type: ToastificationType.error);
      }
    } else if (result == "EXISTING_ORGANIZATION") {
      setState(() {
        _countdownTimer?.cancel();
        countdownSeconds = 60;
        isCountdownActive = false;
      });

      log("accessToken in OTPPage: ${app.app?.accessToken}");
      if (app.app?.accessToken == null) {
        log("appData is null so reinitializing it...");
        await app.initializeAppData();
      }

      final resp = await auth.getOrgProfile(accessToken: app.app?.accessToken ?? "");

      if (resp == true) {
        context.go("/root");
      } else {
        showToast(message: "Some error occurred. Try again later.", type: ToastificationType.error);
      }
    } else if (result == false) {
      setState(() {
        isError = true;
        isOtpLoading = false;
      });
      _shakeController.forward(from: 0);
    }

    log('OTP Verified');
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
            const SizedBox(width: 8),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner Image Section with Controlled Height
                SvgPicture.asset(
                  "assets/images/otpbg.svg",
                  width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
                  fit: BoxFit.cover,
                ),
                // Title Section
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Secure Access Made \nSimple",
                        style: GoogleFonts.inter(
                          fontSize: 27,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Sharing is caring, but not when it comes to personal info. Protect your privacy.",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 20), // Add consistent spacing
                // const Spacer(),
                // Main PageView Section
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      phoneNumberWidget(),
                      otpAuthWidget(context),
                    ],
                  ),
                ),
                // const SizedBox(height: 20), // Bottom spacing
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isError
          ? GestureDetector(
              onTap: () {
                if (code != null) {
                  _verifyOtp(code!, context);
                } else {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Invalid OTP!')),
                  // );
                  showToast(message: "Invalid OTP!", type: ToastificationType.info);
                }
              },
              child: Consumer<AuthServices>(builder: (context, auth, _) {
                return CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).textTheme.headlineLarge?.color,
                  child: auth.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        )
                      : const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 25,
                        ),
                );
              }),
            )
          : null,
    );
  }

  Widget otpAuthWidget(BuildContext context) {
    return Consumer<AuthServices>(
      builder: (context, value, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(width: 5),
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
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).textTheme.headlineLarge?.color,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                  fillColor: const Color(0xFF1F2937),
                  cursorColor: Colors.red,
                  borderColor: Colors.red,
                  enabledBorderColor: isError ? Colors.red : Colors.white,
                  textStyle: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onSubmit: (verificationCode) {
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
              if (isCountdownActive)
                Text(
                  "Resend OTP in $countdownSeconds seconds",
                  style: GoogleFonts.inter(color: Colors.white),
                )
              else
                TextButton(
                  onPressed: () {
                    startCountdown();
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('OTP has been sent successfully!')),
                    // );
                    showToast(message: "OTP has been sent successfully!", type: ToastificationType.info);
                  },
                  child: Text(
                    "Resend OTP",
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                ),
              if (value.isLoading)
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                  child: const LinearProgressIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget phoneNumberWidget() {
    return Consumer<AuthServices>(
      builder: (context, auth, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                key: _phoneNumberKey,
                controller: _phoneController,
                enabled: !isSent,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your phone number...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFFFF6500)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFFFF6500)),
                  ),
                ),
                onChanged: (value) async {
                  if (value.length == 10) {
                    setState(() {
                      isSent = true;
                    });
                    final result = await auth.sendOTP(phone: value);
                    if (result == true) {
                      startCountdown();
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                },
              ),
              const SizedBox(
                height: 75,
              )
            ],
          ),
        );
      },
    );
  }

  // Simulate sending OTP
  void _sendOtp({required String phone}) {
    // Simulating API call
    Future.delayed(const Duration(seconds: 1), () {});
  }
}
