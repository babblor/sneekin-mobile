import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/models/organization.dart';
import 'package:sneekin/services/app_store.dart';
import '../widgets/custom_app_bar.dart';

class OrgDashboardView extends StatefulWidget {
  // Organization? org;
  OrgDashboardView({super.key
      // , this.org
      });

  @override
  State<OrgDashboardView> createState() => _OrgDashboardViewState();
}

class _OrgDashboardViewState extends State<OrgDashboardView> {
  // final TextEditingController orgNameController = TextEditingController();
  // final TextEditingController orgEmailController = TextEditingController();
  // final TextEditingController orgWebsiteController = TextEditingController();
  final TextEditingController orgCINController = TextEditingController();
  final TextEditingController orgPANController = TextEditingController();
  final TextEditingController orgGSTINController = TextEditingController();
  // final TextEditingController orgLogoController = TextEditingController();
  // final TextEditingController orgAddressController = TextEditingController();
  String? orgLogoUrl;

  bool canEdit = false;
  bool isVerified = true;
  String _uploadPanImage = 'No file chosen';

  String _uploadCINImage = 'No file chosen';

  String _uploadOrgLogoImage = 'No file chosen';

  final ImagePicker _picker = ImagePicker();

  /// Image Picker
  Future<void> _pickImage(String isProfileOrAdharPan) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // _imageFile = File(image.path);
      // _uploadProfileImage = await _getFileName(image.path);
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final app = Provider.of<AppStore>(context, listen: false);
    orgCINController.text = app.org?.org_cin ?? "N/A";
    orgPANController.text = app.org?.org_pan ?? "N/A";
    orgGSTINController.text = app.org?.org_gstin ?? "N/A";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = Provider.of<AppStore>(context, listen: false);
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16),
        // margin: EdgeInsets.only(top: 48),
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(
                onDrawerButtonPressed: () {
                  log("Button pressed");
                  Scaffold.of(context).openDrawer();
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              // Expanded(child: SizedBox()),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40, // Adjust the vertical offset as needed
                    right: 0,
                    child: Stack(
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.secondaryHeaderColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
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
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Column(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      app.org?.org_name ?? "N/A",
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.place_outlined,
                                              color: theme.textTheme.bodyLarge?.color,
                                              size: 12,
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              app.org?.org_address == ""
                                                  ? "N/A"
                                                  : app.org?.org_address ?? "N/A",
                                              style: GoogleFonts.inter(
                                                  color: theme.textTheme.bodyLarge?.color, fontSize: 11),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone_outlined,
                                              color: theme.textTheme.bodyLarge?.color,
                                              size: 12,
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              "+91 9999999999",
                                              style: GoogleFonts.inter(
                                                  color: theme.textTheme.bodyLarge?.color, fontSize: 11),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.email_outlined,
                                              color: theme.textTheme.bodyLarge?.color,
                                              size: 12,
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              app.org?.org_email ?? "N/A",
                                              style: GoogleFonts.inter(
                                                  color: theme.textTheme.bodyLarge?.color, fontSize: 11),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            const SizedBox(
                              height: 10,
                            ),
                            _buildTextField('CIN', '29ABCDE1234F1Z5', orgCINController, theme),
                            const SizedBox(height: 10),
                            _buildTextField('PAN', '29ABCDE1234F1Z5', orgPANController, theme),
                            const SizedBox(height: 10),
                            _buildTextField('GSTIN', '29ABCDE1234F1Z5', orgGSTINController, theme),
                            const SizedBox(height: 30),
                            _buildCINImage(),
                            SizedBox(
                              height: 20,
                            ),
                            // _buildOrgLogoImage(),
                            // SizedBox(
                            //   height: 20,
                            // ),
                            _buildPANImage(),
                            SizedBox(
                              height: 20,
                            ),
                            if (canEdit)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.floppyDisk,
                                    color: theme.textTheme.headlineLarge?.color,
                                    size: 25,
                                  )
                                ],
                              ),
                            const SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                    ), // Placeholder height
                  ),
                  // Overflowing Orange Container

                  // Right-top notch
                  Positioned(
                    top: -40,
                    left: 35,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 120,
                          height: 75,
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: theme.textTheme.headlineLarge?.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              app.org?.org_name?[0] ?? "N/A",
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (canEdit)
                          Positioned(
                            bottom: -10,
                            right: -10,
                            child: GestureDetector(
                              onTap: () {
                                // Handle edit action for organization name
                                log("Organization edit button tapped!");
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: theme.textTheme.headlineLarge?.color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.penToSquare,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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

  Widget _buildPANImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Update PAN Document",
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, fontSize: canEdit ? 14 : 12, color: Colors.white),
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
        Text(
          "Update CIN Document",
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, fontSize: canEdit ? 14 : 12, color: Colors.white),
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
        Text(
          "Update Profile Image",
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, fontSize: canEdit ? 14 : 12, color: Colors.white),
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

  Widget _buildOrganizationLogoSection(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.secondaryHeaderColor,
            backgroundImage: orgLogoUrl != null ? NetworkImage(orgLogoUrl!) : null,
            child: orgLogoUrl == null
                ? Icon(Icons.business, size: 50, color: theme.colorScheme.onSurface)
                : null,
          ),
          const SizedBox(height: 10),
          IconButton(
            onPressed: () {
              // Implement image picker logic here
            },
            icon: Icon(
              Icons.camera_alt, // Change to a camera icon for logo update
              color: theme.textTheme.bodyLarge?.color,
              size: 30,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 25,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateInfoButton(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.textTheme.headlineLarge?.color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () {
        // Logic to save organization information
      },
      icon: Icon(
        Icons.edit, // Edit icon for update info button
        color: theme.textTheme.bodyLarge?.color,
      ),
      label: Text(
        'Update Info',
        style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
      ),
    );
  }

  Widget _buildTextField(String label, String value, TextEditingController controller, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label on the left
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: canEdit ? 14 : 12, // Smaller font size when canEdit is false
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(width: 10), // Space between label and TextFormField
        // Form Field on the right
        Expanded(
          child: TextFormField(
            enabled: canEdit,
            controller: controller,
            // initialValue: value,
            style: GoogleFonts.inter(
              fontSize: canEdit ? 14 : 12, // Smaller font size when canEdit is false
              color: theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              suffix: !canEdit
                  ? (isVerified
                      ? const Icon(
                          Icons.check_circle_outline_outlined,
                          color: Colors.green,
                          size: 18,
                        )
                      : const Icon(
                          Icons.close_outlined,
                          color: Colors.red,
                          size: 18,
                        ))
                  : null,
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
