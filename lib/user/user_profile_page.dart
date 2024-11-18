import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  // final TextEditingController ageController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController newPanController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? profileImageUrl; // Placeholder for profile image URL

  String _gender = "Male";

  String _phone = "+918537841568";

  bool canEdit = false;

  bool showTaxProfile = false;

  bool isVerified = true;

  bool hasTaxProfile = true;

  final _formKey = GlobalKey<FormState>();

  String? _name;
  String? _appEmail;
  String? _appNumber;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController.text = "admin@meta.org";
    panController.text = "##00ABCD98";
    newPanController.text = "00ABCD98";
  }

  void _showAddPanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add Tax Profile',
            style: theme.textTheme.headlineSmall?.copyWith(color: theme.textTheme.bodyLarge?.color),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name Field
                  Row(
                    children: [
                      Text(
                        'PAN NUMBER',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: 'Enter your pan number',
                        hintStyle: GoogleFonts.inter(fontSize: 13)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'PAN Number is required';
                      }
                      return null;
                    },
                    onSaved: (value) => _name = value,
                  ),
                  const SizedBox(height: 16),

                  // App Number Field
                  Row(
                    children: [
                      Text(
                        'ADDRESS',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: 'Enter your address',
                        hintStyle: GoogleFonts.inter(fontSize: 13)),
                    onSaved: (value) => _appNumber = value,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.error)),
            ),
            ElevatedButton(
              style: const ButtonStyle(
                  // backgroundColor:
                  ),
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  _formKey.currentState?.save();
                  log('Name: $_name, App Number: $_appNumber, App Email: $_appEmail');
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Website Name Heading
              CustomAppBar(
                onDrawerButtonPressed: () {
                  log("Button pressed");
                  Scaffold.of(context).openDrawer();
                },
              ),
              const SizedBox(height: 70),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40, // Adjust the vertical offset as needed
                    right: 0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Notch background shape

                        CustomPaint(
                          size: const Size(80, 70), // Adjust the size to best match your design
                          painter: NotchPainter(context: context),
                        ),
                        // Icon on top of the notch
                      ],
                    ),
                  ),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.secondaryHeaderColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 25,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        canEdit = !canEdit;
                                      });
                                    },
                                    child: FaIcon(
                                      FontAwesomeIcons.penToSquare,
                                      color: theme.textTheme.headlineLarge?.color,
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Alexa Rawles",
                                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.place_outlined,
                                            color: theme.textTheme.headlineLarge?.color,
                                            size: 13,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "Bengalore",
                                            style:
                                                GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              _buildTextField('Email', emailController, theme),
                              const SizedBox(height: 10),
                              _buildGenderDropdown(_gender, theme),
                              const SizedBox(
                                height: 10,
                              ),
                              _buildPhoneDropdown(_phone, theme),
                              const SizedBox(height: 10),

                              _buildTextField('PAN', panController, theme),
                              // const SizedBox(height: 20),
                              const SizedBox(height: 30),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Tax Profile",
                                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showTaxProfile = !showTaxProfile;
                                          });
                                        },
                                        child: FaIcon(
                                          showTaxProfile
                                              ? FontAwesomeIcons.eyeLowVision
                                              : FontAwesomeIcons.eye,
                                          size: 20,
                                          color: theme.textTheme.headlineLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return _createTaxProfile(context);
                                              });
                                        },
                                        child: FaIcon(
                                          FontAwesomeIcons.plus,
                                          size: 20,
                                          color: theme.textTheme.headlineLarge?.color,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              if (showTaxProfile && hasTaxProfile)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // _buildTextField("PAN", newPanController, theme),
                                    _buildText("PAN", "####1234AB", context, theme),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    // _buildTextField("ADDRESS", newPanController, theme),
                                    _buildText("ADDRESS", "TAMLUK, WEST BENGAL, INDIA", context, theme),
                                  ],
                                ),
                              if (!hasTaxProfile && showTaxProfile)
                                Center(
                                  child: Text(
                                    "No tax profile has found!",
                                    style: GoogleFonts.inter(
                                        fontSize: 16, color: theme.textTheme.headlineLarge?.color),
                                  ),
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                              if (canEdit)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: theme.textTheme.headlineLarge?.color,
                                      child: FaIcon(
                                        FontAwesomeIcons.chevronRight,
                                        color: theme.textTheme.bodyLarge?.color,
                                        size: 16,
                                      ),
                                    )
                                  ],
                                ),
                            ],
                          ),
                        ),
                      )),
                  Positioned(
                    top: -35,
                    left: 35,
                    child: Container(
                      width: 110,
                      height: 70,
                      decoration: BoxDecoration(
                        color: theme.textTheme.headlineLarge?.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "A",
                          style: GoogleFonts.inter(
                              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createTaxProfile(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Create Tax Profile",
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.close,
                size: 24,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ))
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextField("PAN", panController, Theme.of(context)),
          SizedBox(
            height: 5,
          ),
          _buildTextField("ADDRESS", addressController, Theme.of(context)),
          SizedBox(
            height: 30,
          ),
          Center(
            child: FaIcon(FontAwesomeIcons.add,
                size: 18, color: Theme.of(context).textTheme.headlineLarge?.color),
          )
        ],
      ),
    );
  }

  Widget _buildText(String label, String value, BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: canEdit ? 14 : 12, // Smaller font size when canEdit is false
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            // fontWeight: FontWeight.bold,
            fontSize: canEdit ? 14 : 12, // Smaller font size when canEdit is false
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Label on the left
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: canEdit ? 14 : 12, // Smaller font size when canEdit is false
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            // const SizedBox(
            //   width: 2,
            // ),
            // const Text(
            //   ' *',
            //   style: TextStyle(color: Colors.red),
            // ),
          ],
        ),
        const SizedBox(width: 10), // Space between label and text field
        // Form Field on the right
        Expanded(
          child: TextFormField(
            enabled: canEdit,
            controller: controller,
            style: GoogleFonts.inter(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: canEdit ? 14 : 12, // Smaller font size when canEdit is false
            ),
            decoration: InputDecoration(
              suffixIcon: canEdit
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: isVerified
                          ? const FaIcon(
                              FontAwesomeIcons.circleCheck,
                              color: Colors.green,
                              size: 20,
                            )
                          : const FaIcon(
                              FontAwesomeIcons.xmark,
                              color: Colors.red,
                              size: 20,
                            ),
                    )
                  : null,
              filled: true,
              fillColor: theme.secondaryHeaderColor,
              hintText: null, // Remove hintText since label is outside
              border: canEdit
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400), // Border when editable
                    )
                  : InputBorder.none, // No border when not editable
              enabledBorder: canEdit
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400), // Border when enabled
                    )
                  : InputBorder.none,
              focusedBorder: canEdit
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 2), // Border on focus
                    )
                  : InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(String label, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Gender",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: canEdit ? 14 : 12, // Smaller font size when canEdit is false
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _gender, // Default value for gender
            dropdownColor: theme.secondaryHeaderColor, // Dropdown background color
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.secondaryHeaderColor,
              border: canEdit
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400), // Border when editable
                    )
                  : InputBorder.none, // No border when not editable
              enabledBorder: canEdit
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400), // Border when enabled
                    )
                  : InputBorder.none,
              focusedBorder: canEdit
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 2), // Border on focus
                    )
                  : InputBorder.none,
            ),
            items: ['Male', 'Female', 'Other']
                .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: GoogleFonts.inter(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: canEdit ? 13 : 11, // Adjust font size based on canEdit
                        ),
                      ),
                    ))
                .toList(),
            onChanged: canEdit
                ? (String? newValue) {
                    setState(() {
                      _gender = newValue ?? _gender;
                    });
                  }
                : null, // Disable dropdown when canEdit is false
            icon: Icon(
              Icons.arrow_drop_down,
              color: theme.textTheme.bodyLarge?.color, // Icon color
              size: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneDropdown(String label, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left-aligned label
        Text(
          "Mobile",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: canEdit ? 14 : 12, // Smaller font size when canEdit is false
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(width: 10), // Space between label and dropdown
        // Right-aligned Dropdown
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _phone, // Default value for phone
            dropdownColor: theme.secondaryHeaderColor, // Dropdown background color
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.secondaryHeaderColor,
              border: canEdit
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400), // Border when editable
                    )
                  : InputBorder.none, // No border when not editable
              enabledBorder: canEdit
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400), // Border when enabled
                    )
                  : InputBorder.none,
              focusedBorder: canEdit
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 2), // Border on focus
                    )
                  : InputBorder.none,
            ),
            items: ['+918537841568', '+911234567890', '+910987654321']
                .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: GoogleFonts.inter(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: canEdit ? 13 : 11, // Adjust font size based on canEdit
                        ),
                      ),
                    ))
                .toList(),
            onChanged: canEdit
                ? (String? newValue) {
                    setState(() {
                      _phone = newValue ?? _phone;
                    });
                  }
                : null, // Disable dropdown when canEdit is false
            icon: Icon(
              Icons.arrow_drop_down,
              size: 15,
              color: theme.textTheme.bodyLarge?.color, // Icon color
            ),
            disabledHint: Text(
              _phone, // Show current value when disabled
              style: GoogleFonts.inter(
                fontSize: 12, // Smaller font size for disabled state
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotchPainter extends CustomPainter {
  final BuildContext context;

  NotchPainter({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    // Define the shadow paint
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Define the main shape paint
    final paint = Paint()..color = Theme.of(context).secondaryHeaderColor;

    // Define the path for the main shape
    final path = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height * 0.6)
      ..lineTo(size.width * 0.6, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    // Create an outer shadow path by slightly inflating the path
    final shadowPath = Path()
      ..moveTo(size.width + 4, size.height + 4) // Start a little outside bottom-right
      ..lineTo(-4, size.height + 4) // Bottom-left outside
      ..lineTo(-4, size.height * 0.6 - 4) // Slightly outside the corner notch
      ..lineTo(size.width * 0.6 + 4, -4) // Top-left outside
      ..lineTo(size.width + 4, -4) // Top-right outside
      ..lineTo(size.width + 4, size.height + 4) // Close the path outside bottom-right
      ..close();

    // Draw the shadow path
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw the main shape path on top
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
