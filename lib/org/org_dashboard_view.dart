import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:toastification/toastification.dart';
import '../utils/toast.dart';
import '../widgets/custom_app_bar.dart';

class OrgDashboardView extends StatefulWidget {
  // Organization? org;
  const OrgDashboardView({super.key
      // , this.org
      });

  @override
  State<OrgDashboardView> createState() => _OrgDashboardViewState();
}

class _OrgDashboardViewState extends State<OrgDashboardView> {
  final TextEditingController orgNameController = TextEditingController();
  // final TextEditingController orgEmailController = TextEditingController();
  final TextEditingController orgWebsiteController = TextEditingController();
  final TextEditingController orgCINController = TextEditingController();
  final TextEditingController orgPANController = TextEditingController();
  final TextEditingController orgGSTINController = TextEditingController();
  // final TextEditingController orgLogoController = TextEditingController();
  // final TextEditingController orgAddressController = TextEditingController();
  // String? orgLogoUrl;

  bool canEdit = false;
  bool isVerified = true;

  String? _phone;
  final String _uploadPanImage = 'No file chosen';

  final String _uploadCINImage = 'No file chosen';

  final String _uploadOrgLogoImage = 'No file chosen';

  File? _orgLogoImage;

  bool hasImagePicked = false;

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
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _orgCinImage = File(image.path);
        hasCinPicked = true;
      });
    }
  }

  bool hasPanPicked = false;
  File? _orgPanImage;

  Future<void> _pickOrgPanImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _orgPanImage = File(image.path);
        hasPanPicked = true;
      });
    }
  }

  bool hasGstInPicked = false;
  File? _orgGstInImage;

  Future<void> _pickOrgGstInImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _orgGstInImage = File(image.path);
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
        orgWebsiteController.text = app.org?.websiteName ?? "N/A";
        orgCINController.text = app.org?.cin ?? "N/A";
        orgPANController.text = app.org?.pan ?? "N/A";
        orgGSTINController.text = app.org?.gstin ?? "N/A";
        return Container(
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
                                    height: 20,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            canEdit = !canEdit;
                                          });
                                        },
                                        child: FaIcon(
                                          canEdit ? FontAwesomeIcons.xmark : FontAwesomeIcons.penToSquare,
                                          color: theme.textTheme.headlineLarge?.color,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                ],
                              ),
                              // const SizedBox(height: 15),
                              // const SizedBox(
                              //   height: 10,
                              // ),
                              Container(
                                padding: canEdit ? const EdgeInsets.all(15) : const EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                    color:
                                        canEdit ? theme.scaffoldBackgroundColor : theme.secondaryHeaderColor,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        width: 1,
                                        color:
                                            canEdit ? const Color(0xFFFF6500) : theme.secondaryHeaderColor)),
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTextField2("Name", orgNameController, theme, app),
                                    // if (!canEdit)
                                    //   const SizedBox(
                                    //     height: 10,
                                    //   ),
                                    if (canEdit)
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    _buildTextField2("Website", orgWebsiteController, theme, app),
                                    if (!canEdit)
                                      const SizedBox(
                                        height: 2,
                                      ),
                                    if (canEdit)
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    Row(
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.place_outlined,
                                              color: theme.textTheme.bodyLarge?.color,
                                              size: 12,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              app.org?.address == ""
                                                  ? "_________"
                                                  : app.org?.address ?? "_________",
                                              style: GoogleFonts.inter(
                                                  color: theme.textTheme.bodyLarge?.color, fontSize: 11),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        // Row(
                                        //   crossAxisAlignment: CrossAxisAlignment.start,
                                        //   mainAxisAlignment: MainAxisAlignment.start,
                                        //   children: [
                                        //     Icon(
                                        //       Icons.phone_outlined,
                                        //       color: theme.textTheme.bodyLarge?.color,
                                        //       size: 12,
                                        //     ),
                                        //     const SizedBox(
                                        //       width: 5,
                                        //     ),
                                        //     Text(
                                        //       // "+91 9999999999",

                                        //       app.org?.mobileNumbers?.first.mobileNumber ?? "N/A",
                                        //       style: GoogleFonts.inter(
                                        //           color: theme.textTheme.bodyLarge?.color, fontSize: 11),
                                        //     )
                                        //   ],
                                        // ),
                                        // const SizedBox(
                                        //   width: 2,
                                        // ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.email_outlined,
                                              color: theme.textTheme.bodyLarge?.color,
                                              size: 12,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              app.org?.email ?? "N/A",
                                              style: GoogleFonts.inter(
                                                  color: theme.textTheme.bodyLarge?.color, fontSize: 11),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    // if (!canEdit)
                                    const SizedBox(
                                      height: 15,
                                    ),

                                    _buildPhoneScrollable("Mobile", theme, app),
                                    if (canEdit)
                                      const SizedBox(
                                        height: 5,
                                      ),
                                    StatefulBuilder(builder:
                                        (BuildContext context, void Function(void Function()) setState) {
                                      return _buildTextField('CIN', app.org?.cin ?? "N/A", orgCINController,
                                          theme, app.org?.isCinVerified ?? false, hasCinPicked, () {
                                        _pickOrgCinImage(setState);
                                      });
                                    }),
                                    if (canEdit) const SizedBox(height: 10),
                                    StatefulBuilder(builder:
                                        (BuildContext context, void Function(void Function()) setState) {
                                      return _buildTextField('PAN', app.org?.pan ?? "N/A", orgPANController,
                                          theme, app.org?.isPanVerified ?? false, hasPanPicked, () {
                                        _pickOrgPanImage(setState);
                                      });
                                    }),
                                    if (canEdit) const SizedBox(height: 10),
                                    StatefulBuilder(builder:
                                        (BuildContext context, void Function(void Function()) setState) {
                                      return _buildTextField(
                                          'GSTIN',
                                          app.org?.gstin ?? "N/A",
                                          orgGSTINController,
                                          theme,
                                          app.org?.isGstinVerified ?? false,
                                          hasGstInPicked, () {
                                        _pickOrgGstInImage(setState);
                                      });
                                    }),
                                    // const SizedBox(height: 30),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    if (canEdit)
                                      Consumer<AuthServices>(builder: (context, auth, _) {
                                        return InkWell(
                                          onTap: () async {
                                            log("orgCINController.text == app.org?.cin: ${orgCINController.text == app.org?.cin}");
                                            log("orgPANController.text == app.org?.pan: ${orgPANController.text == app.org?.pan}");
                                            log("orgGSTINController.text == app.org?.gstin: ${orgGSTINController.text == app.org?.gstin}");
                                            if (_orgLogoImage != null ||
                                                orgNameController.text != app.org?.name ||
                                                orgWebsiteController.text != app.org?.websiteName ||
                                                orgCINController.text != app.org?.cin ||
                                                (orgCINController.text.isNotEmpty && _orgCinImage != null) ||
                                                orgPANController.text != app.org?.pan ||
                                                (orgPANController.text.isNotEmpty && _orgPanImage != null) ||
                                                orgGSTINController.text != app.org?.gstin ||
                                                (orgGSTINController.text.isNotEmpty &&
                                                    _orgGstInImage != null)) {
                                              // Proceed with update logic
                                              final result = await auth.updateOrganization(
                                                  name: orgNameController.text,
                                                  websiteName: orgWebsiteController.text,
                                                  email: "",
                                                  cin: orgCINController.text,
                                                  pan: orgPANController.text,
                                                  gstIn: orgGSTINController.text,
                                                  address: "",
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
                                              showToast(
                                                  message: "Nothing to update!",
                                                  type: ToastificationType.warning);
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
                                                        size: 12,
                                                      ),
                                              )
                                            ],
                                          ),
                                        );
                                      }),
                                  ],
                                ),
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
                      top: -30,
                      left: 35,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 105,
                            height: 70,
                            // padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.textTheme.headlineLarge?.color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: app.org?.logo?.isNotEmpty == true
                                  ? CachedNetworkImage(
                                      imageUrl: app.org!.logo!,
                                      width: 105,
                                      height: 70,
                                      fit: BoxFit.cover, // Ensures the image is resized to fit
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
                                      errorWidget: (context, url, error) => Center(
                                        child: Text(
                                          app.org?.name?[0] ?? "N/A",
                                          style: GoogleFonts.inter(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        app.org?.name?[0] ?? "N/A",
                                        style: GoogleFonts.inter(
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          if (canEdit)
                            Positioned(
                              bottom: -10,
                              right: -10,
                              child: StatefulBuilder(
                                  builder: (BuildContext context, void Function(void Function()) setState) {
                                return GestureDetector(
                                  onTap: () {
                                    // Handle edit action for organization name
                                    log("Organization edit button tapped!");
                                    _pickOrgLogoImage(setState);
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: hasImagePicked
                                          ? Colors.green
                                          : theme.textTheme.headlineLarge?.color,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPhoneScrollable(String label, ThemeData theme, AppStore app) {
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
        if (!canEdit)
          const SizedBox(
            width: 15,
          ),
        if (canEdit) const SizedBox(width: 20), // Space between label and numbers
        // Right-aligned horizontal scrollable numbers
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: app.org?.mobileNumbers.map((mobile) {
                    return GestureDetector(
                      onTap: canEdit
                          ? () {
                              setState(() {
                                _phone = mobile.mobileNumber;
                              });
                            }
                          : null, // Disable tap when canEdit is false
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(right: 8), // Space between chips
                        decoration: BoxDecoration(
                          // color: mobile.mobileNumber == _phone
                          //     ? theme.textTheme.headlineLarge?.color
                          //     : theme.secondaryHeaderColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: mobile.mobileNumber == _phone
                                ? const Color(0xFFFF6500)
                                : theme.secondaryHeaderColor,
                          ),
                        ),
                        child: Text(
                          mobile.mobileNumber,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: mobile.mobileNumber == _phone
                                ? theme.textTheme.headlineLarge?.color
                                : theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList() ??
                  [],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField2(String label, TextEditingController controller, ThemeData theme, AppStore app) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
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
                fontSize: canEdit ? 16 : 14, // Smaller font size when canEdit is false
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        if (canEdit)
          const SizedBox(
            width: 10,
          ),
        // if (!canEdit) const SizedBox(width: 2), // Space between label and text field
        // Form Field on the right
        Expanded(
          child: TextFormField(
            enabled: canEdit,
            controller: controller,
            style: GoogleFonts.inter(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: canEdit ? 16 : 14, // Smaller font size when canEdit is false
            ),
            decoration: InputDecoration(
              // contentPadding: canEdit ? EdgeInsets.all(5) : EdgeInsets.zero,
              filled: true,
              fillColor: canEdit ? theme.scaffoldBackgroundColor : theme.secondaryHeaderColor,
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

  // Widget _buildOrganizationLogoSection(BuildContext context) {
  //   final theme = Theme.of(context);
  //   return Center(
  //     child: Column(
  //       children: [
  //         CircleAvatar(
  //           radius: 50,
  //           backgroundColor: theme.secondaryHeaderColor,
  //           backgroundImage: orgLogoUrl != null ? NetworkImage(orgLogoUrl!) : null,
  //           child: orgLogoUrl == null
  //               ? Icon(Icons.business, size: 50, color: theme.colorScheme.onSurface)
  //               : null,
  //         ),
  //         const SizedBox(height: 10),
  //         IconButton(
  //           onPressed: () {
  //             // Implement image picker logic here
  //           },
  //           icon: Icon(
  //             Icons.camera_alt, // Change to a camera icon for logo update
  //             color: theme.textTheme.bodyLarge?.color,
  //             size: 30,
  //           ),
  //           padding: EdgeInsets.zero,
  //           constraints: const BoxConstraints(),
  //           splashRadius: 25,
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  Widget _buildTextField(String label, String value, TextEditingController controller, ThemeData theme,
      bool isVerified, bool hasPickedFile, onTap) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
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
              const SizedBox(width: 15), // Space between label and TextFormField
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
                    fillColor: canEdit ? theme.scaffoldBackgroundColor : theme.secondaryHeaderColor,
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
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        if (canEdit)
          InkWell(
            onTap: () {
              // _pickImage("");
              onTap();
            },
            child: CircleAvatar(
              backgroundColor:
                  hasPickedFile ? Colors.green : Theme.of(context).textTheme.headlineLarge?.color,
              child: const FaIcon(
                FontAwesomeIcons.fileUpload,
                size: 15,
                color: Colors.white,
              ),
            ),
          )
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
