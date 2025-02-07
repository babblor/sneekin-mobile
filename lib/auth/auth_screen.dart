import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:sneekin/utils/toast.dart';
import 'package:toastification/toastification.dart';
import 'dart:developer' as dev;
import '../services/app_store.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  String selectedTab = 'User';

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();

  final TextEditingController orgNameController = TextEditingController();
  final TextEditingController orgEmailController = TextEditingController();

  final TextEditingController cinController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  RangeValues _selectedRange = const RangeValues(20, 25); // Initial range with 5-diff
  final double _fixedDifference = 5;

  String _gender = 'M'; // Default value for gender
  // double _age = 18.0; // Single age value

  bool hasEmailSent = false;
  bool hasEmailSent2 = false;

  static const platform = MethodChannel('com.example.sneekin/path');

  File? profileImage;

  final String _uploadProfileImage = 'No file chosen';

  final String _uploadPanImage = 'No file chosen';

  final String _uploadCINImage = 'No file chosen';

  // final String _uploadOrgLogoImage = 'No file chosen';

  final String _userProfileImageName = 'No file chosen';
  File? _userProfileImage;

  final String _orgProfileImageName = 'No file chosen';
  File? _orgProfileImage;

  bool hasImagePicked = false;

  bool isEmailVerifiedUser = false;
  bool isEmailVerifiedOrg = false;

  bool hasGenderSelected = false;

  bool isEmailVerified = false;

  bool isEmailVerified2 = false;

  final ImagePicker _picker = ImagePicker();
  bool isError = false;
  String? code;
  bool clearOTPFieldText = false;
  final List<FocusNode> _focusNodes = List.generate(10, (_) => FocusNode());

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
    for (var focusNode in _focusNodes) {
      focusNode.addListener(() {
        setState(() {}); // Update UI when focus changes
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    // nameController.dispose();
    // emailController.dispose();
    userEmailController.dispose();
    // userEmailController.dispose();
    orgEmailController.dispose();
    orgNameController.dispose();
    addressController.dispose();
    gstinController.dispose();
    cinController.dispose();
    panController.dispose();
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  /// Image Picker
  Future<void> _pickImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // _uploadProfileImage = await _getFileName(image.path);
      setState(() {
        _userProfileImage = File(image.path);
        // _userProfileImageName = image.name;
        hasImagePicked = true;
      });
    }
  }

  Future<void> _pickOrgLogoImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // _uploadProfileImage = await _getFileName(image.path);
      setState(() {
        _orgProfileImage = File(image.path);
        // _orgProfileImageName = image.name;
        hasImagePicked = true;
      });
    }
  }

  /// Method channel for get original image name
  Future<String> _getFileName(String filePath) async {
    try {
      final String fileName = await platform.invokeMethod('getFileName', {"path": filePath});
      dev.log('My image file path is: $fileName');
      return fileName;
    } on PlatformException catch (e) {
      dev.log("Failed to get file name: '${e.message}'.");
      return "Unknown";
    }
  }

  bool hasCinFilePicked = false;
  bool hasPanFilePicked = false;
  bool hasGstInFilePicked = false;

  File? _cinFile;
  File? _panFile;
  File? _gstInFile;

  Future<void> _pickOrgCinFileImage(setState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // Adjust as needed
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _cinFile = File(result.files.single.path!);
        hasCinFilePicked = true;
      });
    }
  }

  bool isCountdownActive = false;
  int countdownSeconds = 60;
  Timer? _countdownTimer;

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

  Future<void> _pickOrgPanFileImage(setState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // Adjust as needed
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _panFile = File(result.files.single.path!);
        hasPanFilePicked = true;
      });
    }
  }

  bool isEditable = true;

  Future<void> _pickOrgGstInFileImage(setState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // Adjust as needed
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _gstInFile = File(result.files.single.path!);
        hasGstInFilePicked = true;
      });
    }
  }

  _verifyOtp(String verificationCode, String email, BuildContext context) async {
    try {
      final auth = Provider.of<AuthServices>(context, listen: false);
      if (verificationCode.isEmpty || email.isEmpty) {
        showToast(message: "Code is empty! Request again!", type: ToastificationType.success);
        _shakeController.forward(from: 0);
        setState(() {
          // hasEmailSent = false;
          selectedTab == "User" ? hasEmailSent = false : hasEmailSent2 = false;
        });
      }
      final resp = await auth.verifyEmailOTP(email: email, otp: verificationCode);
      if (resp == true) {
        setState(() {
          isError = false;
          selectedTab == "User" ? isEmailVerified = true : isEmailVerified2 = true;
          // hasEmailSent = false;
          selectedTab == "User" ? hasEmailSent = false : hasEmailSent2 = false;
        });
        showToast(message: "Email verified successfully!", type: ToastificationType.success);
      } else {
        _shakeController.forward(from: 0);
        setState(() {
          isError = true;
          isEmailVerified2 = false;
          isEmailVerified = false;
        });
      }
    } catch (e) {
      _shakeController.forward(from: 0);
      showToast(message: e.toString(), type: ToastificationType.error);
    }
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
        child: Column(
          children: [
            const SizedBox(height: 10), // Spacer for status bar
            CustomTopBar(
              selectedTab: selectedTab,
              onTabSelected: (tab) {
                setState(() {
                  selectedTab = tab;
                });
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: selectedTab == 'User' ? _buildUserForm() : _buildOrgForm(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          selectedTab == "User" ? _buildUserSubmitButton(context) : _buildOrgSubmitButton(context),
    );
  }

  Widget _buildUserForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(
        //   height: 15,
        // ),
        Center(
          child: Text(
            "Create your account",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              textStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Name Input Field
        _buildInputField(
          controller: userNameController,
          labelText: 'Name',
          mandatory: true,
          hasEmail: false,
          inputType: "Name",
          isPicked: hasImagePicked,
          hintText: 'Enter your name',
          img: _userProfileImage,
          onTap: () {
            // _pickImage(setState);
          },
          profileIcon: false,
          imageField: false,
          hasPicked: false,
          focusNode: _focusNodes[0],
          isEditable: isEditable,
        ),
        // focusNode.hasFocus ?const SizedBox(height: 15),

        // Email Input Field
        _buildInputField(
          controller: userEmailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          mandatory: true,
          inputType: "Email",
          isPicked: hasImagePicked,
          hasEmail: true,
          profileIcon: false,
          keyboardType: TextInputType.emailAddress,
          onTap: () {},
          imageField: false,
          hasPicked: false,
          focusNode: _focusNodes[1],
          isEditable: isEditable,
        ),

        if (hasEmailSent)
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
              keyboardType: TextInputType.phone,
              clearText: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              fillColor: const Color(0xFF1F2937),
              cursorColor: Colors.red,
              borderColor: Colors.red,
              enabledBorderColor: isError ? Colors.red : Colors.white,
              textStyle: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              onSubmit: (verificationCode) {
                // if (isError) {
                //   setState(() {
                //     code = verificationCode;
                //   });
                //   return;
                // }
                final email = selectedTab == "User" ? userEmailController.text : orgEmailController.text;
                _verifyOtp(verificationCode, email, context);
              },
            ),
          ),
        // const SizedBox(height: 15),

        if (hasEmailSent) const SizedBox(height: 10),
        if (hasEmailSent)
          if (isCountdownActive)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Center(
                child: Text(
                  "Resend OTP in $countdownSeconds seconds",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () async {
                if (orgEmailController.text.isEmpty && userEmailController.text.isEmpty) {
                  showToast(message: "Please enter email.", type: ToastificationType.error);
                  return;
                }
                final resp = await Provider.of<AuthServices>(context, listen: false)
                    .sendEmailOTP(email: userEmailController.text);

                if (resp == true) {
                  setState(() {
                    hasEmailSent = true;
                  });
                  startCountdown();
                  showToast(message: "We've sent OTP to your email!", type: ToastificationType.success);
                } else {
                  setState(() {
                    hasEmailSent = false;
                  });
                }
              },
              child: Center(
                child: Text(
                  "Resend OTP",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

        // Gender Dropdown
        // _buildGenderDropdown(),

        if (hasEmailSent)
          const SizedBox(
            height: 5,
          ),
        _buildRadio(focusNode: _focusNodes[2]),
        // Row(
        //   children: [
        //     _buildRadioButton('M', 'M'),
        //     const SizedBox(width: 10),
        //     _buildRadioButton('F', 'F'),
        //     // const SizedBox(width: 10),
        //     // _buildRadioButton('Other', 'Other'),
        //   ],
        // ),
        // const SizedBox(height: 15),

        const SizedBox(height: 10),

        // Gender Dropdown
        // _buildGenderDropdown(),

        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   children: [
        //     Text(
        //       "Age",
        //       style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
        //     ),
        //     const SizedBox(
        //       width: 1,
        //     ),
        //     Text(
        //       " *",
        //       style: GoogleFonts.inter(color: Colors.red),
        //     ),
        //   ],
        // ),
        // const SizedBox(
        //   height: 15,
        // ),

        // Age Slider
        _buildAgeSlider2(focusNode: _focusNodes[3]),

        const SizedBox(
          height: 10,
        ),

        // _buildProfileImage(),

        // const SizedBox(
        //   height: 80,
        // ),

        // const SizedBox(height: 30),
        // // Spacer(),
        // selectedTab == "User"
        //     ? Align(
        //         child: Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //           _buildUserSubmitButton(context),
        //         ],
        //       ))
        //     : Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //           _buildOrgSubmitButton(context),
        //         ],
        //       )

        // // Submit Button
        // _buildUserSubmitButton(context),
      ],
    );
  }

  Widget _buildOrgForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(height: 15),
        Center(
          child: Text(
            "Create your organization",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              textStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Name Input Field
        _buildInputField(
          controller: orgNameController,
          labelText: 'Organization Name',
          mandatory: true,
          hintText: 'Enter organization name',
          profileIcon: false,
          hasEmail: false,
          img: _orgProfileImage,
          onTap: () {
            // _pickOrgLogoImage(setState);
          },
          inputType: "Name",
          isPicked: false,
          imageField: false,
          hasPicked: false,
          focusNode: _focusNodes[4],
          isEditable: isEditable,
        ),
        const SizedBox(height: 10),

        _buildInputField(
          controller: orgEmailController,
          labelText: 'Organization Email',
          mandatory: true,
          isPicked: hasImagePicked,
          onTap: () {},
          profileIcon: false,
          hasEmail: true,
          inputType: "Email",
          hintText: 'Enter organization email',
          imageField: false,
          hasPicked: false,
          focusNode: _focusNodes[5],
          isEditable: isEditable,
        ),
        const SizedBox(height: 10),
        if (hasEmailSent2)
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
              keyboardType: TextInputType.phone,
              clearText: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              fillColor: const Color(0xFF1F2937),
              cursorColor: Colors.red,
              borderColor: Colors.red,
              enabledBorderColor: isError ? Colors.red : Colors.white,
              textStyle: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              onSubmit: (verificationCode) {
                // if (isError) {
                //   setState(() {
                //     code = verificationCode;
                //   });
                //   return;
                // }
                final email = orgEmailController.text;
                _verifyOtp(verificationCode, email, context);
              },
            ),
          ),
        // const SizedBox(height: 15),

        if (hasEmailSent2) const SizedBox(height: 10),
        if (hasEmailSent2)
          if (isCountdownActive)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Center(
                child: Text(
                  "Resend OTP in $countdownSeconds seconds",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () async {
                if (orgEmailController.text.isEmpty && userEmailController.text.isEmpty) {
                  showToast(message: "Please enter email.", type: ToastificationType.error);
                  return;
                }
                final resp = await Provider.of<AuthServices>(context, listen: false).sendEmailOTP(
                    email: selectedTab == "User" ? userEmailController.text : orgEmailController.text);
                if (resp == true) {
                  setState(() {
                    hasEmailSent = true;
                  });
                  startCountdown();
                  showToast(message: "We've sent OTP to your email!", type: ToastificationType.success);
                } else {
                  setState(() {
                    hasEmailSent = false;
                  });
                }
              },
              child: Center(
                child: Text(
                  "Resend OTP",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        if (hasEmailSent2)
          const SizedBox(
            height: 20,
          ),
        _buildInputField(
          controller: addressController,
          labelText: 'Organization Address',
          mandatory: false,
          isPicked: hasImagePicked,
          profileIcon: false,
          inputType: "Address",
          hintText: 'Enter organization address',
          hasEmail: false,
          onTap: () {},
          imageField: false,
          hasPicked: false,
          focusNode: _focusNodes[6],
          isEditable: isEditable,
        ),
        const SizedBox(height: 10),

        _buildInputField(
          controller: gstinController,
          labelText: 'Organization GSTIN',
          mandatory: true,
          isPicked: false,
          profileIcon: false,
          hasEmail: false,
          inputType: "GSTIN",
          onTap: () {
            // _pickOrgGstInFileImage(setState);
          },
          hintText: 'Enter organization gstin',
          imageField: false,
          hasPicked: false,
          focusNode: _focusNodes[7],
          isEditable: isEditable,
        ),
        const SizedBox(height: 10),

        // CIN Input Field
        _buildInputField(
          controller: cinController,
          labelText: 'Organization CIN',
          mandatory: true,
          inputType: "CIN",
          hasEmail: false,
          onTap: () {
            // _pickOrgCinFileImage(setState);
          },
          profileIcon: false,
          isPicked: false,
          hintText: 'Enter CIN',
          imageField: false,
          hasPicked: false,
          focusNode: _focusNodes[8],
          isEditable: isEditable,
        ),
        const SizedBox(height: 10),

        // PAN Input Field
        _buildInputField(
          controller: panController,
          labelText: 'Organization PAN',
          onTap: () {
            // _pickOrgPanFileImage(setState);
          },
          profileIcon: false,
          isPicked: false,
          hasEmail: false,
          mandatory: true,
          hintText: 'Enter PAN',
          inputType: "PAN",
          imageField: false,
          hasPicked: false,
          focusNode: _focusNodes[9],
          isEditable: isEditable,
        ),

        // const SizedBox(
        //   height: 30,
        // ),
        // selectedTab == "User"
        //     ? Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //           _buildUserSubmitButton(context),
        //         ],
        //       )
        //     : Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //           _buildOrgSubmitButton(context),
        //         ],
        //       )
      ],
    );
  }

  Widget _buildRadio({required FocusNode focusNode}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Gender",
              style: GoogleFonts.inter(fontSize: focusNode.hasFocus ? 16 : 11, color: Colors.white),
            ),
            const SizedBox(width: 1),
            Text(
              " *",
              style: GoogleFonts.inter(color: Colors.red, fontSize: focusNode.hasFocus ? 16 : 11),
            ),
          ],
        ),
        Row(
          children: [
            _buildRadioButton('M', 'M'),
            const SizedBox(width: 10),
            _buildRadioButton('F', 'F'),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioButton(String title, String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _gender,
          activeColor: const Color(0xFFFF6500),
          onChanged: (String? newValue) {
            setState(() {
              _gender = newValue!;
              hasGenderSelected = !hasGenderSelected;
            });
          },
        ),
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: _gender == value ? 16 : 11, // Enlarged text for selected
            fontWeight: _gender == value ? FontWeight.bold : FontWeight.normal, // Bold selected text
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      dropdownColor: const Color(0xFF1F293F),
      iconEnabledColor: Theme.of(context).textTheme.headlineLarge?.color,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: GoogleFonts.inter(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      items: <String>['M', 'F'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: GoogleFonts.inter(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        dev.log("new gender value: $newValue");
        setState(() {
          _gender = newValue!;
        });
      },
    );
  }

  // Helper function to build age slider
  Widget _buildAgeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Range Slider
        RangeSlider(
          values: _selectedRange,
          min: 15,
          max: 60,
          divisions: 9,
          activeColor: Theme.of(context).textTheme.headlineLarge?.color,
          inactiveColor: Colors.white,
          labels: RangeLabels(
            _selectedRange.start.round().toString(),
            _selectedRange.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              // Determine which handle is being dragged
              if (values.start != _selectedRange.start) {
                // Start handle is being dragged
                _selectedRange = _moveStartHandle(values.start);
              } else if (values.end != _selectedRange.end) {
                // End handle is being dragged
                _selectedRange = _moveEndHandle(values.end);
              }
            });
          },
        ),
        // Ticks and Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (index) {
              int value = 15 + (index * 5);
              return Column(
                children: [
                  Container(
                    height: 10,
                    width: 2,
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value.toString(),
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeSlider2({required FocusNode focusNode}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Age",
              style: GoogleFonts.inter(fontSize: focusNode.hasFocus ? 16 : 11, color: Colors.white),
            ),
            const SizedBox(
              width: 1,
            ),
            Text(
              " *",
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Range Slider
            RangeSlider(
              values: _selectedRange,
              min: 10,
              max: 60,
              divisions: 10,
              activeColor: Theme.of(context).textTheme.headlineLarge?.color,
              inactiveColor: Colors.white,
              labels: RangeLabels(
                _selectedRange.start.round().toString(),
                _selectedRange.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  if (values.start != _selectedRange.start) {
                    _selectedRange = _moveStartHandle(values.start);
                  } else if (values.end != _selectedRange.end) {
                    _selectedRange = _moveEndHandle(values.end);
                  }
                });
              },
            ),
            // Ticks and Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(11, (index) {
                  int value = 10 + (index * 5);
                  bool isMajorTick = value % 10 == 0;
                  return Column(
                    children: [
                      Container(
                        height: isMajorTick ? 10 : 5, // Major tick: 10, Minor tick: 5
                        width: 2,
                        color: Theme.of(context).textTheme.headlineLarge?.color,
                      ),
                      if (isMajorTick) const SizedBox(height: 5),
                      if (isMajorTick)
                        Text(
                          index == 10 ? "$value <" : "$value",
                          style:
                              GoogleFonts.inter(fontSize: focusNode.hasFocus ? 16 : 11, color: Colors.white),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  RangeValues _moveEndHandle(double newEnd) {
    double newStart = newEnd - _fixedDifference;

    // Clamp values to prevent exceeding bounds
    if (newStart < 15) {
      newStart = 15;
      newEnd = newStart + _fixedDifference;
    } else if (newEnd > 60) {
      newEnd = 60;
      newStart = newEnd - _fixedDifference;
    }

    return RangeValues(newStart, newEnd);
  }

  RangeValues _moveStartHandle(double newStart) {
    double newEnd = newStart + _fixedDifference;

    // Clamp values to prevent exceeding bounds
    if (newEnd > 60) {
      newEnd = 60;
      newStart = newEnd - _fixedDifference;
    } else if (newStart < 15) {
      newStart = 15;
      newEnd = newStart + _fixedDifference;
    }

    return RangeValues(newStart, newEnd);
  }

  // Helper function to snap values to the nearest multiple of 5
  double _snapToInterval(double value, int interval) {
    return (value / interval).round() * interval.toDouble();
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required bool isPicked,
    required String labelText,
    required String hintText,
    required bool profileIcon,
    required bool mandatory,
    required bool hasEmail,
    required bool imageField,
    required String inputType,
    TextInputType keyboardType = TextInputType.text,
    required VoidCallback onTap,
    File? img,
    required bool hasPicked,
    required FocusNode focusNode,
    required bool isEditable,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labelText,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: focusNode.hasFocus ? 16 : 11,
              ),
            ),
            if (mandatory)
              Text(
                " *",
                style: GoogleFonts.inter(color: Colors.red),
              ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                enabled: isEditable,
                controller: controller,
                keyboardType: keyboardType,
                maxLength: inputType == "PAN"
                    ? 10
                    : inputType == "GSTIN"
                        ? 15
                        : inputType == "CIN"
                            ? 21
                            : null,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                focusNode: focusNode,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: focusNode.hasFocus ? 16 : 11),
                  enabledBorder: focusNode.hasFocus
                      ? UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: focusNode.hasFocus ? 1 : 0,
                            color: focusNode.hasFocus ? Colors.white : Colors.grey.shade600,
                          ),
                        )
                      : InputBorder.none,
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            if (hasEmail)
              Consumer<AuthServices>(builder: (context, auth, _) {
                return InkWell(
                  onTap: () async {
                    if (auth.isLoading || isError) return;
                    if (orgEmailController.text.isEmpty && userEmailController.text.isEmpty) {
                      showToast(message: "Please enter email.", type: ToastificationType.error);
                      return;
                    }

                    log("orgEmailController.text: ${orgEmailController.text}");
                    log("userEmailController.text: ${userEmailController.text}");
                    final emailData =
                        selectedTab == "User" ? userEmailController.text : orgEmailController.text;
                    log("emailData: $emailData");
                    if (emailData.isEmpty) {
                      return showToast(message: "Please enter email.", type: ToastificationType.error);
                    }
                    final resp = await auth.sendEmailOTP(email: emailData);
                    if (resp == true) {
                      setState(() {
                        // hasEmailSent = true;
                        selectedTab == "User" ? hasEmailSent = true : hasEmailSent2 = true;
                      });
                      startCountdown();
                      showToast(message: "We've sent OTP to your email!", type: ToastificationType.success);
                    } else {
                      setState(() {
                        selectedTab == "User" ? hasEmailSent = false : hasEmailSent2 = false;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 6),
                    child: selectedTab == "User"
                        ? (isEmailVerified
                            ? const Icon(
                                Icons.verified_outlined,
                                color: Color(0xFFFF6500),
                                size: 16,
                              )
                            : Text(
                                "Verify",
                                style: GoogleFonts.lato(fontSize: 13, color: const Color(0xFFFF6500)),
                              ))
                        : (isEmailVerified2
                            ? const Icon(
                                Icons.verified_outlined,
                                color: Color(0xFFFF6500),
                                size: 16,
                              )
                            : Text(
                                "Verify",
                                style: GoogleFonts.lato(fontSize: 13, color: const Color(0xFFFF6500)),
                              )),
                  ),
                );
              }),
            if (imageField) const SizedBox(width: 15),
            if (imageField)
              InkWell(
                onTap: onTap,
                child: CircleAvatar(
                  radius: focusNode.hasFocus ? 25 : 20,
                  backgroundColor: Theme.of(context).textTheme.headlineLarge?.color ?? Colors.grey.shade800,
                  backgroundImage: profileIcon && img != null ? FileImage(img) : null,
                  child: profileIcon && img != null
                      ? null
                      : FaIcon(
                          profileIcon ? FontAwesomeIcons.camera : FontAwesomeIcons.file,
                          size: focusNode.hasFocus ? 15 : 11,
                          color: hasPicked ? Colors.green : Colors.white,
                        ),
                ),
              ),
          ],
        ),
        focusNode.hasFocus
            ? const SizedBox(
                height: 10,
              )
            : const SizedBox(
                height: 2,
              )
        // SizedBox(
        //   height: 10,
        // )
      ],
    );
  }

  Widget _buildUserSubmitButton(BuildContext context) {
    return Consumer2<AppStore, AuthServices>(builder: (context, app, auth, _) {
      return InkWell(
        onTap: () async {
          // dev.log('Name: ${nameController.text}');
          // dev.log('Email: ${emailController.text}');

          if (userNameController.text == "" || userEmailController.text == "") {
            showToast(message: "Fill all the entries.", type: ToastificationType.error);
            return; // Stop execution if validation fails
          }
          if (!isEmailVerified) {
            return showToast(message: "Please verify the email!", type: ToastificationType.error);
          }
          final resp = await auth.createUser(
            email: userEmailController.text,
            name: userNameController.text,
            age: _selectedRange.start.toInt(),
            gender: _gender,
            isemailverified: isEmailVerified,
            // image: _userProfileImage ?? File("")
          );

          if (resp == true) {
            // context.go("root");
            if (app.app?.accessToken == null) {
              await app.initializeAppData();
            }
            final result = await auth.getProfile(accessToken: app.app?.accessToken ?? "");
            dev.log("result in user creation: $result");
            if (result == true) {
              context.go("/root");
            }
          }
          // else {
          //   setState(() {
          //     hasImagePicked = false;
          //   });
          // }

          // var random = Random();
          // int fiveDigitNumber = 10000 + random.nextInt(90000);

          // final resp = await value.storeUserData(
          //   user: User(
          //       user_id: fiveDigitNumber,
          //       name: nameController.text,
          //       email_id: emailController.text,
          //       gender: _gender,
          //       age: _selectedRange.start.round(),
          //       created_at: DateTime.now().toString(),
          //       updated_at: DateTime.now().toString(),
          //       profile_image: "",
          //       keyclock_secret: "",
          //       email_verified: false),
          // );

          // dev.log("resp: $resp");

          // if (resp == true) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text('User registered successfully.'),
          //     ),
          //   );
          //   // value.refresh();
          //   context.go("/root");
          // } else {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text('Some error occurred.'),
          //     ),
          //   );
          // }
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 15, bottom: 15),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).textTheme.headlineLarge?.color,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: auth.isLoading
                    ? const SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(),
                      )
                    : FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProfileImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Profile Image",
          style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
        ),
        const SizedBox(height: 15),
        Container(
          height: 50,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.grey,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  _pickImage(setState);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Choose File',
                    style: GoogleFonts.inter(color: Theme.of(context).textTheme.headlineLarge?.color),
                  ),
                ),
              ),
              Text(
                _userProfileImageName,
                style: GoogleFonts.inter(color: Theme.of(context).textTheme.headlineLarge?.color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPANImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "PAN Document",
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
            ),
            // SizedBox(
            //   width: 1,
            // ),
            // Text(
            //   " *",
            //   style: GoogleFonts.inter(color: Colors.red),
            // ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          height: 50,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.grey,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  _pickImage(setState);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Choose File',
                    style: GoogleFonts.inter(color: Theme.of(context).textTheme.headlineLarge?.color),
                  ),
                ),
              ),
              Text(
                _uploadPanImage,
                style: GoogleFonts.inter(color: Theme.of(context).textTheme.headlineLarge?.color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCINImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "CIN Document",
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
            ),
            // SizedBox(
            //   width: 1,
            // ),
            // Text(
            //   " *",
            //   style: GoogleFonts.inter(color: Colors.red),
            // ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          height: 50,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.grey,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  _pickImage(setState);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Choose File',
                    style: GoogleFonts.inter(color: Theme.of(context).textTheme.headlineLarge?.color),
                  ),
                ),
              ),
              Text(
                _uploadCINImage,
                style: GoogleFonts.inter(color: Theme.of(context).textTheme.headlineLarge?.color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrgLogoImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Profile Image",
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
            ),
            // SizedBox(
            //   width: 1,
            // ),
            // Text(
            //   " *",
            //   style: GoogleFonts.inter(color: Colors.red),
            // ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          height: 50,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.grey,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  _pickOrgLogoImage(setState);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Choose File',
                    style: GoogleFonts.inter(color: Theme.of(context).textTheme.headlineLarge?.color),
                  ),
                ),
              ),
              Text(
                _orgProfileImageName,
                style: GoogleFonts.inter(color: Theme.of(context).textTheme.headlineLarge?.color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper function to build submit button
  Widget _buildOrgSubmitButton(BuildContext context) {
    return Consumer2<AppStore, AuthServices>(builder: (context, app, value, _) {
      return InkWell(
        onTap: () async {
          if (orgNameController.text == "" ||
              orgEmailController.text == "" ||
              gstinController.text == "" ||
              panController.text == "" ||
              cinController.text == "") {
            showToast(message: "Fill all the entries.", type: ToastificationType.error);
            return; // Stop execution if validation fails
          }

          if (gstinController.text.length != 15) {
            return showToast(message: "GSTIN needs 15 digits", type: ToastificationType.error);
          }
          if (cinController.text.length != 21) {
            return showToast(message: "CIN needs 21 digits", type: ToastificationType.error);
          }
          if (panController.text.length != 10) {
            return showToast(message: "PAN needs 10 digits", type: ToastificationType.error);
          }

          if (!isEmailVerified2) {
            return showToast(message: "Please verify the email!", type: ToastificationType.error);
          }
          final resp = await value.createOrg(
            email: orgEmailController.text,
            name: orgNameController.text,
            cin: cinController.text,
            pan: panController.text,
            gstin: gstinController.text,
            address: addressController.text,
            // logo: _orgProfileImage ?? File(""),
            // gstnInFile: _gstInFile ?? File(""),
            // panFile: _panFile ?? File(""),
            isemailverified: isEmailVerified2,
            // cinFile: _cinFile ?? File("")
          );

          if (resp == true) {
            // context.go("root");
            if (app.app?.accessToken == null) {
              await app.initializeAppData();
            }
            final result = await value.getOrgProfile(accessToken: app.app?.accessToken ?? "");
            dev.log("result in org creation: $result");
            if (result == true) {
              context.go("/root");
            }
          }
          // var random = Random();
          // int fiveDigitNumber = 10000 + random.nextInt(90000);

          // final resp = await value.storeOrgData(
          //   org: Organization(
          //       org_id: fiveDigitNumber,
          //       org_name: nameController.text,
          //       org_email: emailController.text,
          //       org_gstin: gstinController.text,
          //       org_pan: panController.text,
          //       org_cin: cinController.text,
          //       org_cin_url: "",
          //       org_cin_verified: false,
          //       org_gstin_url: "",
          //       org_address: "",
          //       org_gstin_verified: false,
          //       org_logo_url: "",
          //       org_pan_url: "",
          //       org_pan_verified: false,
          //       org_website_name: ""),
          // );

          // dev.log("resp: $resp");

          // if (resp == true) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text('Organization registered successfully.'),
          //     ),
          //   );
          //   context.go("/root");
          // } else {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text('Some error occurred.'),
          //     ),
          //   );
          // }
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 15, bottom: 15),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).textTheme.headlineLarge?.color,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: value.isLoading
                    ? const SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(),
                      )
                    : FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// class CustomTopBar extends StatelessWidget {
//   final String selectedTab;
//   final Function(String) onTabSelected;

//   const CustomTopBar({
//     super.key,
//     required this.selectedTab,
//     required this.onTabSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF1F293F),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildTab('User'),
//           _buildTab('Organization'),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String tabName) {
//     bool isSelected = selectedTab == tabName;

//     return GestureDetector(
//       onTap: () => onTabSelected(tabName),
//       child: Column(
//         children: [
//           Text(
//             tabName,
//             style: GoogleFonts.inter(
//               color: isSelected ? Colors.orange : Colors.white.withOpacity(0.9),
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               fontSize: 16,
//             ),
//           ),
//           if (isSelected)
//             Container(
//               margin: const EdgeInsets.only(top: 4),
//               height: 3,
//               width: 50,
//               decoration: BoxDecoration(
//                 color: Colors.orange,
//                 borderRadius: BorderRadius.circular(1.5),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
class CustomTopBar extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabSelected;

  const CustomTopBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          // color: const Color(0xFF1F293F),
          // borderRadius: BorderRadius.circular(20),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.3),
          //     blurRadius: 10,
          //     offset: const Offset(0, 5),
          //   ),
          // ],
          ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'User',
            style: GoogleFonts.inter(
              color: selectedTab == 'User' ? Colors.orange : Colors.white.withOpacity(0.9),
              fontWeight: selectedTab == 'User' ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          _buildToggleSwitch(),
          Text(
            'Organization',
            style: GoogleFonts.inter(
              color: selectedTab == 'Organization' ? Colors.orange : Colors.white.withOpacity(0.9),
              fontWeight: selectedTab == 'Organization' ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    bool isUserSelected = selectedTab == 'User';

    return GestureDetector(
      onTap: () => onTabSelected(isUserSelected ? 'Organization' : 'User'),
      child: Container(
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: isUserSelected ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
