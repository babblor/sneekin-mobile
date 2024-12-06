import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _AuthScreenState extends State<AuthScreen> {
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

  bool hasGenderSelected = false;

  final ImagePicker _picker = ImagePicker();

  final List<FocusNode> _focusNodes = List.generate(10, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Add listeners to all focus nodes
    for (var focusNode in _focusNodes) {
      focusNode.addListener(() {
        setState(() {}); // Update UI when focus changes
      });
    }
  }

  @override
  void dispose() {
    // nameController.dispose();
    // emailController.dispose();
    userEmailController.dispose();
    userEmailController.dispose();
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
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // _uploadProfileImage = await _getFileName(image.path);
      setState(() {
        _cinFile = File(image.path);
        hasCinFilePicked = true;
      });
    }
  }

  Future<void> _pickOrgPanFileImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // _uploadProfileImage = await _getFileName(image.path);
      setState(() {
        _panFile = File(image.path);
        hasPanFilePicked = true;
      });
    }
  }

  bool isEditable = true;

  Future<void> _pickOrgGstInFileImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // _uploadProfileImage = await _getFileName(image.path);
      setState(() {
        _gstInFile = File(image.path);
        hasGstInFilePicked = true;
      });
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
        Text(
          "Create your account",
          style: GoogleFonts.inter(
            textStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Name Input Field
        _buildInputField(
          controller: userNameController,
          labelText: 'Name',
          mandatory: true,
          isPicked: hasImagePicked,
          hintText: 'Enter your name',
          img: _userProfileImage,
          onTap: () {
            _pickImage(setState);
          },
          profileIcon: true,
          imageField: true,
          hasPicked: hasImagePicked,
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
          isPicked: hasImagePicked,
          profileIcon: false,
          keyboardType: TextInputType.emailAddress,
          onTap: () {},
          imageField: false,
          hasPicked: false,
          focusNode: _focusNodes[1],
          isEditable: isEditable,
        ),
        // const SizedBox(height: 15),

        // Gender Dropdown
        // _buildGenderDropdown(),

        // const SizedBox(
        //   height: 15,
        // ),
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
        Text(
          "Create your organization",
          style: GoogleFonts.inter(
            textStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Name Input Field
        _buildInputField(
          controller: orgNameController,
          labelText: 'Organization Name',
          mandatory: true,
          hintText: 'Enter organization name',
          profileIcon: true,
          img: _orgProfileImage,
          onTap: () {
            _pickOrgLogoImage(setState);
          },
          isPicked: hasImagePicked,
          imageField: true,
          hasPicked: hasImagePicked,
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
          hintText: 'Enter organization email',
          imageField: false,
          hasPicked: false,
          focusNode: _focusNodes[5],
          isEditable: isEditable,
        ),
        const SizedBox(height: 10),

        _buildInputField(
          controller: addressController,
          labelText: 'Organization Address',
          mandatory: false,
          isPicked: hasImagePicked,
          profileIcon: false,
          hintText: 'Enter organization address',
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
          isPicked: hasImagePicked,
          profileIcon: false,
          onTap: () {
            _pickOrgGstInFileImage(setState);
          },
          hintText: 'Enter organization gstin',
          imageField: true,
          hasPicked: hasGstInFilePicked,
          focusNode: _focusNodes[7],
          isEditable: isEditable,
        ),
        const SizedBox(height: 10),

        // CIN Input Field
        _buildInputField(
          controller: cinController,
          labelText: 'Organization CIN',
          mandatory: true,
          onTap: () {
            _pickOrgCinFileImage(setState);
          },
          profileIcon: false,
          isPicked: hasImagePicked,
          hintText: 'Enter CIN',
          imageField: true,
          hasPicked: hasCinFilePicked,
          focusNode: _focusNodes[8],
          isEditable: isEditable,
        ),
        const SizedBox(height: 10),

        // PAN Input Field
        _buildInputField(
          controller: panController,
          labelText: 'Organization PAN',
          onTap: () {
            _pickOrgPanFileImage(setState);
          },
          profileIcon: false,
          isPicked: hasImagePicked,
          mandatory: true,
          hintText: 'Enter PAN',
          imageField: true,
          hasPicked: hasPanFilePicked,
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
    required bool imageField,
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
          final resp = await auth.createUser(
              email: userEmailController.text,
              name: userNameController.text,
              age: _selectedRange.start.toInt(),
              gender: _gender,
              image: _userProfileImage ?? File(""));

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
          final resp = await value.createOrg(
              email: orgEmailController.text,
              name: orgNameController.text,
              cin: cinController.text,
              pan: panController.text,
              gstin: gstinController.text,
              address: addressController.text,
              logo: _orgProfileImage ?? File(""),
              gstnInFile: _gstInFile ?? File(""),
              panFile: _panFile ?? File(""),
              cinFile: _cinFile ?? File(""));

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
      decoration: BoxDecoration(
        color: const Color(0xFF1F293F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTab('User'),
          _buildTab('Organization'),
        ],
      ),
    );
  }

  Widget _buildTab(String tabName) {
    bool isSelected = selectedTab == tabName;

    return GestureDetector(
      onTap: () => onTabSelected(tabName),
      child: Column(
        children: [
          Text(
            tabName,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.orange : Colors.white.withOpacity(0.9),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
        ],
      ),
    );
  }
}
