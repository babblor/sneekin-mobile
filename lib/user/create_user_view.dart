import 'package:flutter/material.dart';
import 'package:sneekin/auth/custom_top_bar.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart'; // Import Syncfusion slider package
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import '../../services/auth_services.dart'; // Import provider for AuthServices

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController(text: "eg: John Doe");
  final TextEditingController emailController = TextEditingController(text: "eg: johndoe@gmail.com");
  String _gender = 'Male'; // Default value for gender
  double _age = 18.0; // Single age value

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF1F293F),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomTopBar(),
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
                  hintText: 'Enter your name',
                ),
                const SizedBox(height: 20),

                // Email Input Field
                _buildInputField(
                  controller: emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Gender Dropdown
                // _buildGenderDropdown(),
                Row(
                  children: [
                    _buildRadioButton('Male', 'Male'),
                    const SizedBox(width: 10),
                    _buildRadioButton('Female', 'Female'),
                    const SizedBox(width: 10),
                    _buildRadioButton('Other', 'Other'),
                  ],
                ),
                const SizedBox(height: 30),

                // Age Slider
                _buildAgeSlider(),

                const SizedBox(height: 40),

                // Submit Button
                _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build text input fields
  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.inter(color: Colors.white),
        hintText: hintText,
        hintStyle: GoogleFonts.inter(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  // Helper function to build gender dropdown
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

  // Helper function to build age slider
  Widget _buildAgeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Age: ",
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                "${_age.toInt()}",
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
        SfSlider(
          value: _age,
          min: 15.0,
          max: 95.0,
          stepSize: 1,
          activeColor: const Color(0xFFFF6500),
          inactiveColor: Colors.white,
          onChanged: (dynamic value) {
            setState(() {
              _age = value;
            });
          },
        ),
      ],
    );
  }

  // Helper function to build submit button
  Widget _buildSubmitButton(BuildContext context) {
    // return
    // Consumer<AuthServices>(
    // builder: (context, authService, _) {
    return Consumer<AppStore>(builder: (context, value, _) {
      return ElevatedButton(
        onPressed: () async {
          // dev.log('Name: ${nameController.text}');
          // dev.log('Email: ${emailController.text}');

          // if (!_formKey.currentState!.validate()) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text('Fill all the fields.'),
          //     ),
          //   );
          //   return; // Stop execution if validation fails
          // }

          // var random = Random();
          // int fiveDigitNumber = 10000 + random.nextInt(90000);

          // final resp = await value.storeUserData(
          //   user: User(
          //       // user_id: fiveDigitNumber,
          //       // name: nameController.text,
          //       // email_id: emailController.text,
          //       // gender: _gender,
          //       // age: _age.toInt(),
          //       // created_at: DateTime.now().toString(),
          //       // updated_at: DateTime.now().toString(),
          //       // profile_image: "",
          //       // keyclock_secret: "",
          //       // email_verified: false),
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
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6500),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          minimumSize: const Size.fromHeight(50), // Full-width button
        ),
        child: value.isLoading
            ? const SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(),
              )
            : Text(
                'Register User',
                style: GoogleFonts.inter(
                  textStyle: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
      );
    });
  }
  // );
}
