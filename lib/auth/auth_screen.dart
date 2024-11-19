import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/models/user.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'dart:developer' as dev;
import '../models/organization.dart';
import '../services/app_store.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String selectedTab = 'User';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cinController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  RangeValues _selectedRange = RangeValues(20, 25); // Initial range with 5-diff
  final double _fixedDifference = 5;

  String _gender = 'Male'; // Default value for gender
  double _age = 18.0; // Single age value

  static const platform = MethodChannel('com.example.sneekin/path');

  File? profileImage;

  String _uploadProfileImage = 'No file chosen';

  String _uploadPanImage = 'No file chosen';

  String _uploadCINImage = 'No file chosen';

  String _uploadOrgLogoImage = 'No file chosen';

  final String _imageName = '';
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  /// Image Picker
  Future<void> _pickImage(String isProfileOrAdharPan) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _imageFile = File(image.path);
      _uploadProfileImage = await _getFileName(image.path);
      setState(() {});
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
            const SizedBox(height: 20), // Spacer for status bar
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
        const SizedBox(
          height: 20,
        ),
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
        const SizedBox(height: 30),
        // Name Input Field
        _buildInputField(
          controller: nameController,
          labelText: 'Name',
          mandatory: true,
          hintText: 'Enter your name',
        ),
        const SizedBox(height: 20),

        // Email Input Field
        _buildInputField(
          controller: emailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          mandatory: true,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 35),

        // Gender Dropdown
        // _buildGenderDropdown(),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Gender",
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
            ),
            SizedBox(
              width: 1,
            ),
            Text(
              " *",
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            _buildRadioButton('Male', 'Male'),
            const SizedBox(width: 10),
            _buildRadioButton('Female', 'Female'),
            const SizedBox(width: 10),
            _buildRadioButton('Other', 'Other'),
          ],
        ),
        // const SizedBox(height: 15),

        const SizedBox(height: 25),

        // Gender Dropdown
        // _buildGenderDropdown(),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Age",
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
            ),
            SizedBox(
              width: 1,
            ),
            Text(
              " *",
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),

        // Age Slider
        _buildAgeSlider(),

        SizedBox(
          height: 20,
        ),

        _buildProfileImage(),

        SizedBox(
          height: 80,
        ),

        // const SizedBox(height: 40),

        // // Submit Button
        // _buildUserSubmitButton(context),
      ],
    );
  }

  Widget _buildOrgForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
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
        const SizedBox(height: 30),

        // Name Input Field
        _buildInputField(
          controller: nameController,
          labelText: 'Organization Name',
          mandatory: true,
          hintText: 'Enter organization name',
        ),
        const SizedBox(height: 20),

        _buildInputField(
          controller: emailController,
          labelText: 'Organization Email',
          mandatory: true,
          hintText: 'Enter organization email',
        ),
        const SizedBox(height: 20),

        _buildInputField(
          controller: gstinController,
          labelText: 'Organization GSTIN',
          mandatory: true,
          hintText: 'Enter organization gstin',
        ),
        const SizedBox(height: 20),

        _buildInputField(
          controller: addressController,
          labelText: 'Organization Address',
          mandatory: false,
          hintText: 'Enter organization address',
        ),
        const SizedBox(height: 20),

        // CIN Input Field
        _buildInputField(
          controller: cinController,
          labelText: 'Organization CIN',
          mandatory: true,
          hintText: 'Enter CIN',
        ),
        const SizedBox(height: 20),

        // PAN Input Field
        _buildInputField(
          controller: panController,
          labelText: 'Organization PAN',
          mandatory: true,
          hintText: 'Enter PAN',
        ),

        SizedBox(
          height: 20,
        ),

        _buildPANImage(),

        SizedBox(
          height: 20,
        ),

        _buildCINImage(),

        SizedBox(
          height: 20,
        ),

        _buildOrgLogoImage(),
        SizedBox(
          height: 80,
        )
        // const SizedBox(height: 70),
        // // const Spacer(),

        // // Submit Button
        // _buildOrgSubmitButton(context),
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
            });
          },
        ),
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
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
      items: <String>['Male', 'Female', 'Other'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: GoogleFonts.inter(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
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
                  SizedBox(height: 5),
                  Text(
                    value.toString(),
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                  ),
                ],
              );
            }),
          ),
        ),
        SizedBox(height: 20),
        // Selected Range Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Selected Age Range: ${_selectedRange.start.round()} - ${_selectedRange.end.round()}",
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          ),
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
    required String labelText,
    required String hintText,
    required bool mandatory,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labelText,
              style: GoogleFonts.inter(color: Colors.white),
            ),
            if (mandatory)
              Text(
                " *",
                style: GoogleFonts.inter(color: Colors.red),
              ),
          ],
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserSubmitButton(BuildContext context) {
    return Consumer<AppStore>(builder: (context, value, _) {
      return InkWell(
        onTap: () async {
          dev.log('Name: ${nameController.text}');
          dev.log('Email: ${emailController.text}');

          if (nameController.text == "" || emailController.text == "") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fill all the fields.'),
              ),
            );
            return; // Stop execution if validation fails
          }

          var random = Random();
          int fiveDigitNumber = 10000 + random.nextInt(90000);

          final resp = await value.storeUserData(
            user: User(
                user_id: fiveDigitNumber,
                name: nameController.text,
                email_id: emailController.text,
                gender: _gender,
                age: _selectedRange.start.round(),
                created_at: DateTime.now().toString(),
                updated_at: DateTime.now().toString(),
                profile_image: "",
                keyclock_secret: "",
                email_verified: false),
          );

          dev.log("resp: $resp");

          if (resp == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User registered successfully.'),
              ),
            );
            // value.refresh();
            context.go("/root");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Some error occurred.'),
              ),
            );
          }
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
                  _pickImage('Profile Image');
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
                _uploadProfileImage,
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
                  _pickImage('PAN Document');
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
                  _pickImage('CIN Document');
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
                  _pickImage('Org Profile Image');
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
                _uploadOrgLogoImage,
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
    return Consumer<AppStore>(builder: (context, value, _) {
      return InkWell(
        onTap: () async {
          if (nameController.text.isEmpty || cinController.text.isEmpty || panController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fill all fields'),
              ),
            );
            return;
          }
          var random = Random();
          int fiveDigitNumber = 10000 + random.nextInt(90000);

          final resp = await value.storeOrgData(
            org: Organization(
                org_id: fiveDigitNumber,
                org_name: nameController.text,
                org_email: emailController.text,
                org_gstin: gstinController.text,
                org_pan: panController.text,
                org_cin: cinController.text,
                org_cin_url: "",
                org_cin_verified: false,
                org_gstin_url: "",
                org_address: "",
                org_gstin_verified: false,
                org_logo_url: "",
                org_pan_url: "",
                org_pan_verified: false,
                org_website_name: ""),
          );

          dev.log("resp: $resp");

          if (resp == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Organization registered successfully.'),
              ),
            );
            context.go("/root");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Some error occurred.'),
              ),
            );
          }
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
