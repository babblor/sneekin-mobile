import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:toastification/toastification.dart';
import '../utils/toast.dart';
import '../widgets/custom_app_bar.dart';

class OrgDashboardView extends StatefulWidget {
  const OrgDashboardView({super.key});

  @override
  State<OrgDashboardView> createState() => _OrgDashboardViewState();
}

class _OrgDashboardViewState extends State<OrgDashboardView> {
  final TextEditingController orgNameController = TextEditingController();
  final TextEditingController orgEmailController = TextEditingController();
  final TextEditingController orgWebsiteController = TextEditingController();
  final TextEditingController orgCINController = TextEditingController();
  final TextEditingController orgPANController = TextEditingController();
  final TextEditingController orgGSTINController = TextEditingController();
  final TextEditingController orgAddressController = TextEditingController();

  bool canEdit = false;
  bool isVerified = true;

  String? _phone;
  final String _uploadPanImage = 'No file chosen';

  final String _uploadCINImage = 'No file chosen';

  final String _uploadOrgLogoImage = 'No file chosen';

  File? _orgLogoImage;

  final FocusNode textFocusNode = FocusNode();

  bool hasImagePicked = false;

  String selectedTab = "INFO"; // Tracks selected tab

  final ImagePicker _picker = ImagePicker();

  /// Image Picker
  Future<void> _pickOrgLogoImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _orgLogoImage = File(image.path);
        hasImagePicked = true;
      });
    }
  }

  bool hasCinPicked = false;
  File? _orgCinImage;
  Future<void> _pickOrgCinImage(setState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // Adjust as needed
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _orgCinImage = File(result.files.single.path!);
        hasCinPicked = true;
      });
    }
  }

  bool hasPanPicked = false;
  File? _orgPanImage;

  Future<void> _pickOrgPanImage(setState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // Adjust as needed
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _orgPanImage = File(result.files.single.path!);
        hasPanPicked = true;
      });
    }
  }

  bool hasGstInPicked = false;
  File? _orgGstInImage;

  Future<void> _pickOrgGstInImage(setState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // Adjust as needed
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _orgGstInImage = File(result.files.single.path!);
        hasGstInPicked = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      Provider.of<AppStore>(context, listen: false).initializeOrgData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Consumer<AppStore>(builder: (context, app, _) {
        if (app.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.textTheme.headlineLarge?.color,
            ),
          );
        }
        orgNameController.text = app.org?.name ?? "N/A";
        orgEmailController.text = app.org?.email ?? "N/A";
        orgWebsiteController.text = app.org?.websiteName ?? "N/A";
        orgCINController.text = app.org?.cin ?? "N/A";
        orgPANController.text = app.org?.pan ?? "N/A";
        orgGSTINController.text = app.org?.gstin ?? "N/A";
        orgAddressController.text = app.org?.address ?? "N/A";
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomAppBar(
                  onDrawerButtonPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                const SizedBox(height: 20),

                // Profile Picture
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFF6500), width: 3), shape: BoxShape.circle),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor:
                            app.org?.logo?.isNotEmpty == true ? null : theme.textTheme.headlineLarge?.color,
                        child: ClipOval(
                          child: app.org?.logo?.isNotEmpty == true
                              ? CachedNetworkImage(
                                  imageUrl: app.org!.logo!,
                                  fit: BoxFit
                                      .cover, // Ensures the image covers the entire circle while maintaining aspect ratio
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => const Center(
                                    child: SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => _buildFallbackWidget(app),
                                )
                              : _buildFallbackWidget(app),
                        ),
                      ),
                      if (canEdit)
                        Positioned(
                          bottom: 2,
                          right: -3,
                          child: StatefulBuilder(
                              builder: (BuildContext context, void Function(void Function()) setState) {
                            return GestureDetector(
                              onTap: () {
                                // Handle edit action for organization name
                                log("Organization edit button tapped!");
                                _pickOrgLogoImage(setState);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: hasImagePicked ? Colors.green : theme.textTheme.headlineLarge?.color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.penToSquare,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      Positioned(
                        bottom: canEdit ? MediaQuery.of(context).viewInsets.bottom - 50 : -20,
                        child: IntrinsicWidth(
                          child: Container(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                              left: 16,
                              right: 16,
                            ),
                            height: 40,
                            decoration: canEdit
                                ? null
                                : BoxDecoration(
                                    color: theme.secondaryHeaderColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                            child: Center(
                              child: !canEdit
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        app.org?.name ?? "N/A",
                                        style: GoogleFonts.inter(
                                          color: theme.textTheme.bodyLarge?.color,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                        softWrap: true, // Ensures text wraps
                                        maxLines: null, // Allows unlimited lines
                                        overflow: TextOverflow.visible, // Prevents text from being clipped
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (canEdit)
                  const SizedBox(
                    height: 15,
                  ),

                if (canEdit)
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    child: TextFormField(
                      focusNode: textFocusNode,
                      controller: orgNameController,
                      style: GoogleFonts.inter(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 6),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2.5),
                        ),
                      ),
                      onTap: () {
                        textFocusNode.requestFocus();
                      },
                    ),
                  ),

                canEdit
                    ? const SizedBox(
                        height: 25,
                      )
                    : const SizedBox(height: 40),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildButton(1, Icons.add, "App Account", () {
                      context.goNamed("org-dashboard");
                    }),
                    const SizedBox(width: 20),
                    _buildButton(2, canEdit ? FontAwesomeIcons.xmark : FontAwesomeIcons.penToSquare,
                        canEdit ? "Cancel" : "Edit", () {
                      setState(() {
                        canEdit = !canEdit;
                      });
                    }),
                  ],
                ),

                const SizedBox(height: 30),
                Opacity(
                  opacity: 0.3, // Set opacity to 50%
                  child: Divider(
                    color: theme.textTheme.bodyLarge?.color,
                    thickness: 0.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Tab Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildTabButton("INFO"),
                    const SizedBox(width: 10),
                    _buildTabButton("INC."),
                  ],
                ),

                const SizedBox(height: 10),

                // Dynamic Content
                Flexible(
                  flex: 2,
                  child: ListView(
                    children:
                        selectedTab == "INFO" ? _buildOrgDetails(theme, app) : _buildInfoDetails(theme, app),
                  ),
                ),
                // SizedBox(
                //   height: 10,
                // ),
                // if (canEdit)
                if (canEdit)
                  Flexible(
                    flex: 1,
                    child: Consumer<AuthServices>(builder: (context, auth, _) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 27, bottom: 32),
                        child: InkWell(
                          onTap: () async {
                            if (_orgLogoImage != null ||
                                orgNameController.text != app.org?.name ||
                                orgWebsiteController.text != app.org?.websiteName ||
                                orgCINController.text != app.org?.cin ||
                                (orgCINController.text.isNotEmpty && _orgCinImage != null) ||
                                orgPANController.text != app.org?.pan ||
                                (orgPANController.text.isNotEmpty && _orgPanImage != null) ||
                                orgGSTINController.text != app.org?.gstin ||
                                orgAddressController.text != app.org?.address ||
                                (orgGSTINController.text.isNotEmpty && _orgGstInImage != null)) {
                              // Proceed with update logic

                              if (orgGSTINController.text != app.org?.gstin) {
                                if (orgGSTINController.text.length != 15 &&
                                    orgGSTINController.text.isNotEmpty) {
                                  return showToast(
                                      message: "GSTIN needs 15 digits", type: ToastificationType.error);
                                }
                              }

                              if (orgCINController.text != app.org?.cin) {
                                if (orgCINController.text.length != 21 && orgCINController.text.isNotEmpty) {
                                  return showToast(
                                      message: "CIN needs 21 digits", type: ToastificationType.error);
                                }
                              }

                              if (orgPANController.text != app.org?.pan) {
                                if (orgPANController.text.length != 10 && orgPANController.text.isNotEmpty) {
                                  return showToast(
                                      message: "PAN needs 10 digits", type: ToastificationType.error);
                                }
                              }

                              final result = await auth.updateOrganization(
                                  name: orgNameController.text,
                                  websiteName: orgWebsiteController.text,
                                  email: "",
                                  cin: orgCINController.text,
                                  pan: orgPANController.text,
                                  gstIn: orgGSTINController.text,
                                  address: orgAddressController.text,
                                  logoFile: _orgLogoImage ?? File(""),
                                  cinFile: _orgCinImage ?? File(""),
                                  panFile: _orgPanImage ?? File(""),
                                  gstInFile: _orgGstInImage ?? File(""));

                              if (result == true) {
                                await app.initializeOrgData();
                                setState(() {
                                  hasImagePicked = false;
                                  hasCinPicked = false;
                                  hasGstInPicked = false;
                                  hasPanPicked = false;
                                  canEdit = false;
                                });
                                showToast(
                                    message: "Organization updated successfully!",
                                    type: ToastificationType.success);
                                // context.go('root');
                              }
                            } else {
                              showToast(message: "Nothing to update!", type: ToastificationType.warning);
                              return;
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: theme.textTheme.headlineLarge?.color,
                                child: auth.isLoading
                                    ? SizedBox(
                                        height: 14,
                                        width: 14,
                                        child: CircularProgressIndicator(
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      )
                                    : const FaIcon(
                                        FontAwesomeIcons.chevronRight,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                if (canEdit)
                  const SizedBox(
                    height: 40,
                  )
              ],
            ),
          ),
        );
      }),
    );
  }

  // Function to handle the fallback case (error case or empty logo)
  Widget _buildFallbackWidget(AppStore app) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).textTheme.headlineLarge?.color, // Default fallback color
      alignment: Alignment.center,
      child: Text(
        app.org?.name?[0] ?? "N/A",
        style: GoogleFonts.inter(
          fontSize: 25,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

// Function to create action buttons
  // Function to create action buttons
  Widget _buildButton(int pos, IconData icon, String text, VoidCallback onTap) {
    final theme = Theme.of(context);
    return IntrinsicWidth(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16), // Add padding for spacing
          height: 40,
          decoration: BoxDecoration(
            color: pos == 1 ? theme.textTheme.headlineLarge?.color : theme.secondaryHeaderColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
            borderRadius: BorderRadius.circular(8), // Rounded corners for a modern look
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: theme.textTheme.bodyLarge?.color, size: 20),
                const SizedBox(width: 8), // Space between icon and text
                Text(
                  text,
                  style: GoogleFonts.lato(color: theme.textTheme.bodyLarge?.color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Organization Details
  List<Widget> _buildOrgDetails(ThemeData theme, AppStore app) {
    return [
      const SizedBox(
        height: 5,
      ),
      _buildTextField2(Icons.web, orgWebsiteController, theme, app),
      _buildTextField2(Icons.email, orgEmailController, theme, app),
      _buildTextField2(Icons.location_on, orgAddressController, theme, app),
      _buildPhoneScrollable(Icons.mobile_friendly_outlined, theme, app),
    ];
  }

  // Info Details (PAN, GSTIN, CIN)
  List<Widget> _buildInfoDetails(ThemeData theme, AppStore app) {
    return [
      const SizedBox(
        height: 5,
      ),
      StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
        return _buildTextField(Icons.apartment, app.org?.cin ?? "N/A", orgCINController, theme,
            app.org?.isCinVerified ?? false, hasCinPicked, () {
          _pickOrgCinImage(setState);
        });
      }),
      StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
        return _buildTextField(Icons.business, app.org?.gstin ?? "N/A", orgGSTINController, theme,
            app.org?.isGstinVerified ?? false, hasGstInPicked, () {
          _pickOrgGstInImage(setState);
        });
      }),
      StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
        return _buildTextField(Icons.badge, app.org?.pan ?? "N/A", orgPANController, theme,
            app.org?.isPanVerified ?? false, hasPanPicked, () {
          _pickOrgPanImage(setState);
        });
      }),
    ];
  }

  // Function to create tab buttons
  Widget _buildTabButton(String title) {
    final isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6500) : Colors.transparent,
          border: Border.all(
            width: 1,
            color: const Color(0xFFFF6500),
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 15,
              color: isSelected ? Colors.white : const Color(0xFFFF6500),
            ),
          ),
        ),
      ),
    );
  }

  // Function to create ListTile
  Widget _buildListTile(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, size: 25),
      title: Text(
        text,
        style: GoogleFonts.lato(fontSize: 15),
      ),
    );
  }

  Widget _buildPhoneScrollable(IconData icon, ThemeData theme, AppStore app) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), // Minimal vertical space
      child: Row(
        children: [
          // Icon on the left
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // Same horizontal spacing as ListTile
            child: Icon(icon, size: 24, color: theme.iconTheme.color),
          ),
          // Right-aligned horizontal scrollable numbers
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: app.org?.mobileNumbers
                        .expand((mobile) => [
                              GestureDetector(
                                onTap: canEdit
                                    ? () {
                                        setState(() {
                                          _phone = mobile.mobileNumber;
                                        });
                                      }
                                    : null, // Disable tap when canEdit is false
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8), // Space between numbers
                                  child: Text(
                                    mobile.mobileNumber,
                                    style: GoogleFonts.inter(
                                      fontSize: 14, // Slightly bigger text when editable
                                      color: theme.textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              // Add separator except after the last item
                              if (mobile != app.org!.mobileNumbers.last)
                                Text(
                                  '|',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ])
                        .toList() ??
                    [],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField2(
    IconData icon,
    TextEditingController controller,
    ThemeData theme,
    AppStore app,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Minimal vertical space
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon on the left
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // Same horizontal spacing as ListTile
            child: Icon(icon, size: 24, color: theme.iconTheme.color),
          ),
          // Text Field on the right
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.65, // Reduce underline width to 70%
                child: TextFormField(
                  enabled: canEdit,
                  controller: controller,
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: canEdit ? 16 : 14, // Larger text when editable
                  ),
                  decoration: InputDecoration(
                    isDense: true, // Reduces overall vertical space
                    contentPadding: const EdgeInsets.only(bottom: 6), // More space between text and underline
                    filled: false, // No background fill
                    hintText: null,
                    border: canEdit
                        ? const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                          )
                        : InputBorder.none, // No border when not editable
                    enabledBorder: canEdit
                        ? const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                          )
                        : InputBorder.none,
                    focusedBorder: canEdit
                        ? const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                          )
                        : InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ],
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
                  // _pickImage('PAN Document');
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
                  // _pickImage('CIN Document');
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
              StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
                return InkWell(
                  onTap: () {
                    // _pickImage('Org Profile Image');
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
                );
              }),
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

  Widget _buildTextField(
    IconData icon,
    String value,
    TextEditingController controller,
    ThemeData theme,
    bool isVerified,
    bool hasPickedFile,
    VoidCallback onTap,
  ) {
    int? maxLength;
    if (icon == Icons.business) {
      maxLength = 21; // CIN
    } else if (icon == Icons.credit_card) {
      maxLength = 10; // PAN
    } else if (icon == Icons.store) {
      maxLength = 15; // GSTIN
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // Adjust padding for alignment
          child: Icon(icon, size: 24, color: theme.iconTheme.color),
        ),
        Flexible(
          flex: 3,
          child: FractionallySizedBox(
            widthFactor: 0.92,
            child: TextFormField(
              enabled: canEdit,
              controller: controller,
              maxLength: maxLength,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              style: GoogleFonts.inter(
                fontSize: canEdit ? 16 : 14,
                color: theme.textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                // isDense: canEdit,
                contentPadding: const EdgeInsets.only(bottom: 6),
                suffix: !canEdit
                    ? (isVerified
                        ? const Icon(Icons.check_circle_outline_outlined, color: Colors.green, size: 18)
                        : const SizedBox.shrink())
                    : null,
                border: canEdit
                    ? const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      )
                    : InputBorder.none,
                enabledBorder: canEdit
                    ? const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      )
                    : InputBorder.none,
                focusedBorder: canEdit
                    ? const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      )
                    : InputBorder.none,
              ),
            ),
          ),
        ),
        // const SizedBox(width: 30),
        const Spacer(),
        if (canEdit)
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 5, left: 8),
              child: InkWell(
                onTap: onTap,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: hasPickedFile ? Colors.green : theme.textTheme.headlineLarge?.color,
                  child: const FaIcon(
                    FontAwesomeIcons.fileUpload,
                    size: 13,
                    color: Colors.white,
                  ),
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
