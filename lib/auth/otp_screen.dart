import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:sneekin/services/auth_services.dart';
import '../../widgets/onboarding_widget.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final PageController _pageController = PageController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    phoneNumberController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // SfRangeValues _values = const SfRangeValues(15, 25);

  final _phoneNumberKey = GlobalKey<FormFieldState>();

  final List _otp = List.filled(6, null);
  final String _verificationId = "";
  bool isPhoneLoading = false;
  bool isOtpLoading = false;
  bool isSent = false;

  final int _radioValue = 0;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Scaffold(
      // backgroundColor: Colors.black,
      // backgroundColor: theme.scaffoldBackgroundColor,
      backgroundColor: const Color(0xFF1F293F),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                const OnboardingWidget(),
                const SizedBox(
                  height: 15,
                ),
                // isSent
                //     ? Container()
                //     : Padding(
                //         padding: const EdgeInsets.only(left: 12),
                //         child: Row(
                //           // mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Radio(
                //               value: 0,
                //               groupValue: _radioValue,
                //               // activeColor: Theme.of(context).textTheme.headlineLarge?.color,
                //               activeColor: Theme.of(context).textTheme.headlineLarge?.color,
                //               onChanged: (value) {
                //                 setState(() {
                //                   _radioValue = value as int;
                //                 });
                //               },
                //             ),
                //             const Text(
                //               'User',
                //               style: TextStyle(
                //                   // color: Theme.of(context).textTheme.bodyLarge?.color
                //                   color: Colors.white),
                //             ),
                //             Radio(
                //               value: 1,
                //               groupValue: _radioValue,
                //               // activeColor: Theme.of(context).textTheme.headlineLarge?.color,
                //               activeColor: Theme.of(context).textTheme.headlineLarge?.color,
                //               onChanged: (value) {
                //                 setState(() {
                //                   _radioValue = value as int;
                //                 });
                //               },
                //             ),
                //             const Text(
                //               'Organisation',
                //               style: TextStyle(
                //                   // color: Theme.of(context).textTheme.bodyLarge?.color
                //                   color: Colors.white),
                //             ),
                //           ],
                //         ),
                //       ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        phoneNumberWidget(),
                        otpAuthWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  phoneNumberWidget() {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          key: _phoneNumberKey,
          controller: phoneNumberController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              // color: theme.textTheme.bodyLarge?.color,
              color: Colors.white),
          onChanged: (value) {
            // onPhoneNumberSubmit();
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your phone number';
            }

            if (value.length != 10) {
              return 'Please enter a valid phone number';
            }

            return null;
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
              borderRadius: BorderRadius.all(
                Radius.circular(44.0),
              ),
            ),
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            fillColor: theme.secondaryHeaderColor,
            hintStyle: GoogleFonts.inter(
                // color: theme.textTheme.bodyLarge?.color
                color: Colors.white),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            suffix: isPhoneLoading
                ? const SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ))
                : null,
          ),
        ),
        const SizedBox(
          height: 10,
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            // backgroundColor: theme.textTheme.headlineLarge?.color,
            backgroundColor: theme.textTheme.headlineLarge?.color,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: GoogleFonts.inter(
                // color: theme.textTheme.bodyLarge?.color
                color: Colors.white),
          ),
          onPressed: () async {
            if (!_phoneNumberKey.currentState!.validate()) {
              return;
            }
            setState(() {
              isSent = true;
            });
            _pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: Row(
            children: [
              const Spacer(),
              Text(
                'Sent OTP',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              const Spacer(),
            ],
          ),
        ),
        // }),
      ],
    );
  }

  otpAuthWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const SizedBox(
          height: 0,
        ),
        // --------------- edit Phone number--------------------
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "+91-${phoneNumberController.text}",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Wrong number? ",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        // color: Theme.of(context).colorScheme.primary,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // --------------- OTP number--------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 50,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 1,
                onChanged: (value) {
                  if (value.length == 1) {
                    _otp[0] = value;
                    FocusScope.of(context).nextFocus();
                    // onOtpSubmit();
                  }
                },
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 1,
                onChanged: (value) {
                  if (value.isEmpty) {
                    FocusScope.of(context).previousFocus();
                  }

                  if (value.length == 1) {
                    _otp[1] = value;
                    FocusScope.of(context).nextFocus();
                    // onOtpSubmit();
                  }
                },
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 1,
                onChanged: (value) {
                  if (value.isEmpty) {
                    FocusScope.of(context).previousFocus();
                  }

                  if (value.length == 1) {
                    _otp[2] = value;
                    FocusScope.of(context).nextFocus();
                    // onOtpSubmit();
                  }
                },
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 1,
                onChanged: (value) {
                  if (value.isEmpty) {
                    FocusScope.of(context).previousFocus();
                  }

                  if (value.length == 1) {
                    _otp[3] = value;
                    FocusScope.of(context).nextFocus();
                    // onOtpSubmit();
                  }
                },
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 1,
                onChanged: (value) {
                  if (value.isEmpty) {
                    FocusScope.of(context).previousFocus();
                  }

                  if (value.length == 1) {
                    _otp[4] = value;
                    debugPrint("otp: $_otp");
                    FocusScope.of(context).nextFocus();
                    // onOtpSubmit();
                  }
                },
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 1,
                onChanged: (value) async {
                  if (value.isEmpty) {
                    FocusScope.of(context).previousFocus();
                  }

                  if (value.length == 1) {
                    _otp[5] = value;
                    if (_otp.join().length == 6) {
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('OTP verified successfully'),
                        ),
                      );
                      context.go("/creation");
                    }
                  }
                },
                style: const TextStyle(
                  color: Colors.white,
                ),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),
            ),
          ],
        ),
        // --------------- Resend OTP number--------------------

        TextButton(
          onPressed: () async {
            setState(() {
              isSent = false;
            });
            _pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: Text(
            "Resend OTP",
            style: GoogleFonts.inter(
                // color: Theme.of(context).textTheme.bodyLarge?.color
                color: Colors.white),
          ),
        ),
        isOtpLoading
            ? Center(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), child: const LinearProgressIndicator()),
              )
            : const SizedBox(),
      ],
    );
  }
}
