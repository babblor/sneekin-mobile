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
import 'package:sneekin/utils/toast.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:toastification/toastification.dart';
import '../widgets/custom_app_bar.dart';

class UserProfilePage extends StatefulWidget {
  // User? user;
  const UserProfilePage({super.key

      // , this.user
      });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  // final TextEditingController ageController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  // final TextEditingController newPanController = TextEditingController();
  final TextEditingController panAddressController = TextEditingController();
  final TextEditingController panNameController = TextEditingController();

  final TextEditingController panUpdateNameController = TextEditingController();
  final TextEditingController panUpdatePanController = TextEditingController();
  final TextEditingController panUpdateAddressController = TextEditingController();
  String? taxUpdateGender;

  String? profileImageUrl; // Placeholder for profile image URL

  String? _gender;

  String? _phone;

  bool canEdit = false;

  bool showTaxProfile = false;

  bool isVerified = true;

  bool hasImagePicked = false;

  bool hasTaxProfile = true;

  final _formKey = GlobalKey<FormState>();

  RangeValues? _selectedRange; // Initial range with 5-diff
  final double _fixedDifference = 5;

  String? name;
  String? address;
  String? appNumber;
  String? pan_number;

  final String _uploadOrgLogoImage = 'No file chosen';

  File? _profileImage;

  File? _updatedPanFile;

  bool hasUpdatedPanFilePicked = false;

  final ImagePicker _picker = ImagePicker();

  /// Image Picker
  Future<void> _pickUpdatedPanImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // _imageFile = File(image.path);
      // _uploadProfileImage = await _getFileName(image.path);
      setState(() {
        _updatedPanFile = File(image.path);
        hasUpdatedPanFilePicked = true;
      });
    }
  }

  Future<void> _pickImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // _imageFile = File(image.path);
      // _uploadProfileImage = await _getFileName(image.path);
      setState(() {
        _profileImage = File(image.path);
        hasImagePicked = true;
      });
    }
  }

  double _age = 35;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      Provider.of<AppStore>(context, listen: false).initializeUserData();
      Provider.of<AuthServices>(context, listen: false).getUserTaxProfile();
    });
  }

  _showAddPanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        String taxGender = 'M';

        return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
          return AlertDialog(
            backgroundColor: theme.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Add Tax Profile',
                  style: theme.textTheme.headlineSmall?.copyWith(color: theme.textTheme.bodyLarge?.color),
                ),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 22,
                    ))
              ],
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
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
                            onSaved: (value) => pan_number = value,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        // CircleAvatar(
                        //     backgroundColor: theme.textTheme.headlineLarge?.color,
                        //     child: const Icon(
                        //       Icons.upload_file,
                        //       color: Colors.white,
                        //     ))
                        InkWell(
                          onTap: () {
                            _pickUpdatedPanImage(setState);
                          },
                          child: CircleAvatar(
                              backgroundColor: theme.textTheme.headlineLarge?.color,
                              child: Icon(
                                Icons.upload_file,
                                color: hasUpdatedPanFilePicked ? Colors.green : Colors.white,
                              )),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'GENDER',
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
                    // const SizedBox(height: 8),
                    // Row(
                    //   children: [
                    //     _buildRadioButton('M', 'M'),
                    //     const SizedBox(width: 10),
                    //     _buildRadioButton('F', 'F'),
                    //   ],
                    // ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'M',
                          groupValue: taxGender,
                          activeColor: const Color(0xFFFF6500),
                          onChanged: (String? newValue) {
                            setState(() {
                              log("new gender value: $newValue");
                              taxGender = newValue!;
                            });
                          },
                        ),
                        Text(
                          'M',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                          ),
                        ),
                        Radio<String>(
                          value: 'F',
                          groupValue: taxGender,
                          activeColor: const Color(0xFFFF6500),
                          onChanged: (String? newValue) {
                            setState(() {
                              // log("new gender value: ${newValue}");
                              taxGender = newValue!;
                            });
                          },
                        ),
                        Text(
                          'F',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text(
                          'NAME',
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
                          hintText: 'Enter your name',
                          hintStyle: GoogleFonts.inter(fontSize: 13)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                      onSaved: (value) => name = value,
                    ),
                    const SizedBox(
                      height: 12,
                    ),

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
                      onSaved: (value) => address = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Address is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: theme.textTheme.headlineLarge?.color,
                child: Consumer<AuthServices>(builder: (context, auth, _) {
                  return InkWell(
                      onTap: () async {
                        if (_formKey.currentState?.validate() == true) {
                          _formKey.currentState?.save();
                          log('Name: $name, PAN Number: $pan_number, Address: $address, Gender: $taxGender');
                          final result = await auth.createUserTaxProfile(
                            file: _updatedPanFile ?? File(""),
                            pan_number: pan_number!,
                            name: name!,
                            address: address!,
                            gender: taxGender,
                          );
                          if (result == true) {
                            await auth.getUserTaxProfile();
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: CircleAvatar(
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
                            : FaIcon(
                                FontAwesomeIcons.chevronRight,
                                color: theme.textTheme.bodyLarge?.color,
                                size: 12,
                              ),
                      ));
                }),
              ),
            ],
          );
        });
      },
    );
  }

  _showUpdatePanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        String taxGender = 'M';

        return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
          return AlertDialog(
            backgroundColor: theme.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Update Tax Profile',
                  style: theme.textTheme.headlineSmall?.copyWith(color: theme.textTheme.bodyLarge?.color),
                ),
                InkWell(
                    onTap: () {
                      setState() {
                        hasUpdatedPanFilePicked = false;
                        _updatedPanFile = null;
                      }

                      Navigator.pop(context);
                      // showTaxProfile = false;
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 22,
                    ))
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    Text(
                      'PAN NUMBER',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: panUpdatePanController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                hintText: 'Enter your pan number',
                                hintStyle: GoogleFonts.inter(fontSize: 13)),
                            onSaved: (value) => pan_number = value,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            _pickUpdatedPanImage(setState);
                          },
                          child: CircleAvatar(
                              backgroundColor: theme.textTheme.headlineLarge?.color,
                              child: Icon(
                                Icons.upload_file,
                                color: hasUpdatedPanFilePicked ? Colors.green : Colors.white,
                              )),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'GENDER',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    // const SizedBox(height: 8),
                    // Row(
                    //   children: [
                    //     _buildRadioButton('M', 'M'),
                    //     const SizedBox(width: 10),
                    //     _buildRadioButton('F', 'F'),
                    //   ],
                    // ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'M',
                          groupValue: taxGender,
                          activeColor: const Color(0xFFFF6500),
                          onChanged: (String? newValue) {
                            setState(() {
                              log("new gender value: $newValue");
                              taxUpdateGender = newValue!;
                            });
                          },
                        ),
                        Text(
                          'M',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                          ),
                        ),
                        Radio<String>(
                          value: 'F',
                          groupValue: taxGender,
                          activeColor: const Color(0xFFFF6500),
                          onChanged: (String? newValue) {
                            setState(() {
                              log("new gender value: $newValue");
                              taxGender = newValue!;
                            });
                          },
                        ),
                        Text(
                          'F',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'NAME',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: panUpdateNameController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          hintText: 'Enter your name',
                          hintStyle: GoogleFonts.inter(fontSize: 13)),
                      onSaved: (value) => name = value,
                    ),
                    const SizedBox(
                      height: 12,
                    ),

                    // App Number Field
                    Text(
                      'ADDRESS',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: panUpdateAddressController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          hintText: 'Enter your address',
                          hintStyle: GoogleFonts.inter(fontSize: 13)),
                      onSaved: (value) => address = value,
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: theme.textTheme.headlineLarge?.color,
                child: Consumer<AuthServices>(builder: (context, auth, _) {
                  return InkWell(
                      onTap: () async {
                        log("panUpdateAddressController.text: ${panUpdateAddressController.text}");
                        log("panUpdateNameController.text: ${panUpdateNameController.text}");
                        log("panUpdatePanController.text: ${panUpdatePanController.text}");
                        log("taxUpdateGender: $taxUpdateGender");
                        if (_updatedPanFile == null || _updatedPanFile!.path.isEmpty) {
                          showToast(message: "Please upload pan file", type: ToastificationType.warning);
                          return;
                        }
                        if (panUpdateAddressController.text.isEmpty &&
                            panUpdateNameController.text.isEmpty &&
                            panUpdatePanController.text.isEmpty &&
                            taxUpdateGender == null) {
                          showToast(message: "Nothing to update!", type: ToastificationType.error);
                          return;
                        }
                        final result = await auth.updateUserTaxProfile(
                            file: _updatedPanFile ?? File(""),
                            pan_number: panUpdatePanController.text ?? "",
                            name: panUpdateNameController.text ?? "",
                            address: panUpdateAddressController.text ?? "",
                            gender: taxUpdateGender ?? "");
                        if (result == true) {
                          await auth.getUserTaxProfile();
                          Navigator.pop(context);
                          setState() {
                            _updatedPanFile = null;
                            panUpdateAddressController.clear();
                            panUpdateNameController.clear();
                            panUpdatePanController.clear();
                          }

                          showToast(
                              message: "Your tax profile has updated.", type: ToastificationType.success);
                        }
                      },
                      child: auth.isLoading
                          ? SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            )
                          : const Icon(
                              Icons.chevron_right_outlined,
                              color: Colors.white,
                              size: 24,
                            ));
                }),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    log("user_profile_page.dart rebuilds");
    final theme = Theme.of(context);
    // final app = Provider.of<AppStore>(context, listen: false);
    // final auth = Provider.of<AuthServices>(context, listen: false);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Consumer2<AuthServices, AppStore>(builder: (context, auth, app, _) {
            if (app.isSignedIn) {
              nameController.text = app.user?.name ?? "Alex Reyn";
              _age = app.user?.age.toDouble() ?? 0.0;
              _gender = app.user?.gender ?? "M";
              _phone = app.user?.mobileNumbers.first.mobileNumber ?? "N/A";
              _selectedRange = RangeValues((app.user!.age).toDouble(), ((app.user!.age + 5)).toDouble());
              emailController.text = app.user?.email ?? "N/A";
            }
            panController.text = auth.userTaxProfile["panNumber"] ?? "";
            panNameController.text = auth.userTaxProfile["name"] ?? "";
            panAddressController.text = auth.userTaxProfile["address"] ?? "";
            log("app.user?.profileImageUrl:${app.user?.profileImageUrl}");
            return Column(
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
                                        canEdit ? FontAwesomeIcons.xmark : FontAwesomeIcons.penToSquare,
                                        color: theme.textTheme.headlineLarge?.color,
                                        size: 25,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                // Column(
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                //     Column(
                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                //       mainAxisAlignment: MainAxisAlignment.start,
                                //       children: [
                                //         // Text(
                                //         //   app.user?.name ?? "Alexa Rawles",
                                //         //   style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                                //         // ),
                                //         // _buildTextField("Name", nameController, theme, app, false),
                                //         // if (canEdit)
                                //         //   const SizedBox(
                                //         //     height: 10,
                                //         //   ),
                                //         // Row(
                                //         //   crossAxisAlignment: CrossAxisAlignment.center,
                                //         //   mainAxisAlignment: MainAxisAlignment.start,
                                //         //   children: [
                                //         //     Icon(
                                //         //       Icons.place_outlined,
                                //         //       color: theme.textTheme.headlineLarge?.color,
                                //         //       size: 13,
                                //         //     ),
                                //         //     const SizedBox(
                                //         //       width: 5,
                                //         //     ),
                                //         //     Text(
                                //         //       auth.userTaxProfile["address"] ?? "-",
                                //         //       style: GoogleFonts.inter(
                                //         //           color: Colors.grey.shade600, fontSize: 12),
                                //         //     )
                                //         //   ],
                                //         // )
                                //       ],
                                //     )
                                //   ],
                                // ),
                                // const SizedBox(
                                //   height: 20,
                                // ),
                                // _buildTextField('Email', emailController, theme, app),
                                Container(
                                  padding: canEdit ? const EdgeInsets.all(15) : const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                      color: canEdit
                                          ? theme.scaffoldBackgroundColor
                                          : theme.secondaryHeaderColor,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          width: 1,
                                          color: canEdit
                                              ? const Color(0xFFFF6500)
                                              : theme.secondaryHeaderColor)),
                                  child: Column(
                                    children: [
                                      _buildTextField("Name", nameController, theme, app, false),
                                      if (canEdit)
                                        const SizedBox(
                                          height: 15,
                                        ),
                                      if (!canEdit)
                                        const SizedBox(
                                          height: 5,
                                        ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Email",
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: canEdit
                                                      ? 14
                                                      : 12, // Smaller font size when canEdit is false
                                                  color: theme.textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 10),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(app.user?.email ?? "N/A",
                                                  style: GoogleFonts.inter(
                                                    // fontWeight: FontWeight.bold,
                                                    fontSize: canEdit
                                                        ? 14
                                                        : 12, // Smaller font size when canEdit is false
                                                    color: theme.textTheme.bodyLarge?.color,
                                                  )),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              app.user!.isEmailVerified
                                                  ? FaIcon(
                                                      FontAwesomeIcons.circleCheck,
                                                      size: canEdit ? 15 : 13,
                                                      color: Colors.green,
                                                    )
                                                  : FaIcon(FontAwesomeIcons.close,
                                                      size: canEdit ? 15 : 13, color: Colors.red),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (canEdit)
                                        const SizedBox(
                                          height: 15,
                                        ),
                                      if (!canEdit)
                                        const SizedBox(
                                          height: 5,
                                        ),
                                      StatefulBuilder(builder:
                                          (BuildContext context, void Function(void Function()) setState) {
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Gender",
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontSize: canEdit
                                                    ? 14
                                                    : 12, // Smaller font size when canEdit is false
                                                color: theme.textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Radio<String>(
                                                      value: 'M',
                                                      groupValue: _gender,
                                                      activeColor: const Color(0xFFFF6500),
                                                      onChanged: (String? newValue) {
                                                        setState(() {
                                                          if (!canEdit) return;
                                                          log("newValue: $newValue");
                                                          _gender = newValue!;
                                                        });
                                                      },
                                                    ),
                                                    Text(
                                                      'M',
                                                      style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Radio<String>(
                                                      value: 'F',
                                                      groupValue: _gender,
                                                      activeColor: const Color(0xFFFF6500),
                                                      onChanged: (String? newValue) {
                                                        setState(() {
                                                          if (!canEdit) return;
                                                          log("newValue: $newValue");
                                                          _gender = newValue!;
                                                        });
                                                      },
                                                    ),
                                                    Text(
                                                      'F',
                                                      style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
                                      // if (canEdit)
                                      //   SizedBox(
                                      //     height: 15,
                                      //   ),
                                      // if (!canEdit)
                                      //   SizedBox(
                                      //     height: 5,
                                      //   ),
                                      // _buildAgeSlider(label: "Age", theme: theme),
                                      _buildAgeSlider2(context, theme),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      if (canEdit)
                                        Consumer<AuthServices>(builder: (context, auth, _) {
                                          return InkWell(
                                            onTap: () async {
                                              log("_profileImage: $_profileImage");
                                              log("nameController.text == app.user?.name: ${nameController.text == app.user?.name}");
                                              log("_selectedRange!.start == app.user?.age: ${_selectedRange!.start == app.user?.age}");
                                              log(" _gender == app.user?.gender: ${_gender == app.user?.gender}");
                                              if ((_profileImage == null &&
                                                  nameController.text == app.user?.name &&
                                                  _selectedRange!.start == app.user?.age &&
                                                  _gender == app.user?.gender)) {
                                                showToast(
                                                    message: "Nothing to update",
                                                    type: ToastificationType.warning);
                                                return;
                                              }

                                              final result = await auth.updateUser(
                                                  name: nameController.text,
                                                  profileImage: _profileImage ?? File(""),
                                                  email: "",
                                                  age: _selectedRange!.start.toInt(),
                                                  gender: _gender!);

                                              if (result == true) {
                                                await app.initializeUserData();
                                                setState(() {
                                                  hasImagePicked = false;
                                                  canEdit = false;
                                                });
                                                showToast(
                                                    message: "User updated successfully!",
                                                    type: ToastificationType.success);
                                                // context.go('root');
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
                                                      : FaIcon(
                                                          FontAwesomeIcons.chevronRight,
                                                          color: theme.textTheme.bodyLarge?.color,
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
                                  height: 10,
                                ),
                                if (canEdit)
                                  const SizedBox(
                                    height: 15,
                                  ),
                                _buildPhoneScrollable(_phone!, theme, app),
                                const SizedBox(height: 10),
                                // if (canEdit)
                                //   const SizedBox(
                                //     height: 15,
                                //   ),
                                // _buildTextField('PAN', panController, theme),
                                const SizedBox(height: 30),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Tax Profile",
                                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    if (auth.userTaxProfile["panNumber"] != null)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (showTaxProfile)
                                            GestureDetector(
                                              onTap: () {
                                                _showUpdatePanDialog(context);
                                              },
                                              child: FaIcon(
                                                FontAwesomeIcons.penToSquare,
                                                size: 20,
                                                color: theme.textTheme.headlineLarge?.color,
                                              ),
                                            ),
                                          const SizedBox(
                                            width: 20,
                                          ),
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
                                        ],
                                      )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                if (auth.userTaxProfile["panNumber"] != null && showTaxProfile)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // _buildTextField("PAN", panController, theme, app, showTaxProfile),
                                      _buildText("PAN", auth.userTaxProfile["panNumber"], context, theme, app,
                                          showTaxProfile, true, auth.userTaxProfile["isPanVerified"]),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      _buildText("NAME", auth.userTaxProfile["name"], context, theme, app,
                                          showTaxProfile, false, auth.userTaxProfile["isPanVerified"]),
                                      // _buildTextField("NAME", panNameController, theme, app, showTaxProfile),
                                      // _buildTextIconField(FontAwesomeIcons.locationDot, panAddressController,
                                      //     theme, app, showTaxProfile),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      _buildIcon(FontAwesomeIcons.locationDot, auth.userTaxProfile["address"],
                                          context, theme, app, showTaxProfile),
                                    ],
                                  ),
                                if (auth.userTaxProfile["panNumber"] == null)
                                  // Center(
                                  //   child: Text(
                                  //     "No tax profile has found!",
                                  //     style: GoogleFonts.inter(
                                  //         fontSize: 16, color: theme.textTheme.headlineLarge?.color),
                                  //   ),
                                  // ),
                                  _buildCreateTaxSection(app, theme),
                              ],
                            ),
                          ),
                        )),
                    Positioned(
                      top: -35,
                      left: 35,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 110,
                            height: 70,
                            decoration: BoxDecoration(
                              color: theme.textTheme.headlineLarge?.color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: app.user?.profileImageUrl?.isNotEmpty == true
                                  ? CachedNetworkImage(
                                      imageUrl: app.user!.profileImageUrl!,
                                      width: 110,
                                      height: 70,
                                      fit: BoxFit.cover,
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
                                      errorWidget: (context, url, error) => Text(
                                        app.user?.name[0] ?? "N/A",
                                        style: GoogleFonts.inter(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      app.user?.name[0] ?? "N/A",
                                      style: GoogleFonts.inter(
                                        fontSize: 24,
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
                              child: StatefulBuilder(
                                  builder: (BuildContext context, void Function(void Function()) setState) {
                                return GestureDetector(
                                  onTap: () {
                                    // Handle edit button action here
                                    log("Edit button tapped!");
                                    _pickImage(setState);
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
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCreateTaxSection(AppStore app, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
            onTap: () {
              _showAddPanDialog(context);
            },
            child: CircleAvatar(
              radius: 15,
              backgroundColor: theme.textTheme.headlineLarge?.color,
              child: const Icon(Icons.upload_file, size: 17, color: Colors.white),
            ))
      ],
    );
  }

  Widget _buildText(String label, String value, BuildContext context, ThemeData theme, AppStore app,
      bool show, bool showVerified, bool isPanVerified) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 13, // Smaller font size when canEdit is false
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        Text(
          show ? value : "**********",
          style: GoogleFonts.inter(
            // fontWeight: FontWeight.bold,
            fontSize: 13, // Smaller font size when canEdit is false
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        if (showVerified)
          SizedBox(
            width: 10,
          ),
        if (showVerified)
          isPanVerified
              ? FaIcon(
                  FontAwesomeIcons.circleCheck,
                  size: canEdit ? 15 : 13,
                  color: Colors.green,
                )
              : FaIcon(FontAwesomeIcons.close, size: canEdit ? 15 : 13, color: Colors.red)
      ],
    );
  }

  Widget _buildIcon(
      IconData label, String value, BuildContext context, ThemeData theme, AppStore app, bool show) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FaIcon(
          label,
          size: 14,
          color: theme.textTheme.bodyLarge?.color,
        ),
        const SizedBox(
          width: 15,
        ),
        Text(
          show ? value : "**********",
          style: GoogleFonts.inter(
            // fontWeight: FontWeight.bold,
            fontSize: 13, // Smaller font size when canEdit is false
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, ThemeData theme, AppStore app, bool show) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Label on the left
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 12, // Smaller font size when canEdit is false
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        if (canEdit)
          const SizedBox(
            width: 10,
          ),
        // if (!canEdit) const SizedBox(width: 2), // Space between label and text field
        // Form Field on the right
        Expanded(
          child: TextFormField(
            // obscureText: show,
            enabled: canEdit,
            controller: controller,
            style: GoogleFonts.inter(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 12, // Smaller font size when canEdit is false
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: canEdit ? theme.scaffoldBackgroundColor : theme.secondaryHeaderColor,
              hintText: null, // Remove hintText since label is outside
              border: InputBorder.none, // No border when not editable
              enabledBorder: canEdit
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF6500), width: 1))
                  : InputBorder.none,
              focusedBorder: canEdit
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF6500), width: 1))
                  : InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextIconField(
      IconData label, TextEditingController controller, ThemeData theme, AppStore app, bool show) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Label on the left
        FaIcon(
          label,
          size: 12, // Smaller font size when canEdit is false
          color: theme.textTheme.bodyLarge?.color,
        ),
        if (canEdit)
          const SizedBox(
            width: 10,
          ),
        // if (!canEdit) const SizedBox(width: 2), // Space between label and text field
        // Form Field on the right
        Expanded(
          child: TextFormField(
            // obscureText: show,
            enabled: canEdit,
            controller: controller,
            style: GoogleFonts.inter(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 12, // Smaller font size when canEdit is false
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.secondaryHeaderColor,
              hintText: null, // Remove hintText since label is outside
              border: InputBorder.none, // No border when not editable
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
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
            // value: _gender, // Default value for gender
            value: Provider.of<AppStore>(context, listen: false).user?.gender,
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
            items: ['M', 'F']
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
                  // _pickImage('Org Profile Image');
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

  // Widget _buildPhoneDropdown(String label, ThemeData theme, AppStore app) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       // Left-aligned label
  //       Text(
  //         "Mobile",
  //         style: GoogleFonts.inter(
  //           fontWeight: FontWeight.bold,
  //           fontSize: canEdit ? 14 : 12, // Smaller font size when canEdit is false
  //           color: theme.textTheme.bodyLarge?.color,
  //         ),
  //       ),
  //       const SizedBox(width: 10), // Space between label and dropdown
  //       // Right-aligned Dropdown
  //       Expanded(
  //         child: DropdownButtonFormField<String>(
  //           value: app.user?.mobileNumbers[0].mobileNumber, // Default value for phone
  //           dropdownColor: theme.secondaryHeaderColor, // Dropdown background color
  //           decoration: InputDecoration(
  //             filled: true,
  //             fillColor: theme.secondaryHeaderColor,
  //             border: canEdit
  //                 ? OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                     borderSide: BorderSide(color: Colors.grey.shade400), // Border when editable
  //                   )
  //                 : InputBorder.none, // No border when not editable
  //             enabledBorder: canEdit
  //                 ? OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                     borderSide: BorderSide(color: Colors.grey.shade400), // Border when enabled
  //                   )
  //                 : InputBorder.none,
  //             focusedBorder: canEdit
  //                 ? OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                     borderSide: BorderSide(color: Colors.grey.shade400, width: 2), // Border on focus
  //                   )
  //                 : InputBorder.none,
  //           ),
  //           items: app.user?.mobileNumbers
  //               .map((MobileNumber mobile) => DropdownMenuItem<String>(
  //                     value: mobile.mobileNumber,
  //                     child: Text(
  //                       mobile.mobileNumber,
  //                     ),
  //                   ))
  //               .toList(),

  //           onChanged: canEdit
  //               ? (String? newValue) {
  //                   setState(() {
  //                     _phone = newValue ?? _phone;
  //                   });
  //                 }
  //               : null, // Disable dropdown when canEdit is false
  //           icon: Icon(
  //             Icons.arrow_drop_down,
  //             size: 15,
  //             color: theme.textTheme.bodyLarge?.color, // Icon color
  //           ),
  //           disabledHint: Text(
  //             _phone, // Show current value when disabled
  //             style: GoogleFonts.inter(
  //               fontSize: 12, // Smaller font size for disabled state
  //               color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
              children: app.user?.mobileNumbers.map((mobile) {
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

  Widget _buildRadioButton(String title, String value, BuildContext context) {
    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
      // String _gender = 'M';
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
    });
  }

  // Helper function to build age slider
  // Widget _buildAgeSlider({required String label, required ThemeData theme}) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Text(
  //             label,
  //             style: GoogleFonts.inter(
  //               fontWeight: FontWeight.bold,
  //               fontSize: canEdit ? 14 : 12, // Smaller font size when canEdit is false
  //               color: theme.textTheme.bodyLarge?.color,
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(width: 10), // Space between label and text field
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Range Slider
  //             RangeSlider(
  //               values: _selectedRange,
  //               min: 15,
  //               max: 60,
  //               divisions: 9,
  //               activeColor: Theme.of(context).textTheme.headlineLarge?.color,
  //               inactiveColor: Colors.white,
  //               labels: RangeLabels(
  //                 _selectedRange.start.round().toString(),
  //                 _selectedRange.end.round().toString(),
  //               ),
  //               onChanged: (RangeValues values) {
  //                 setState(() {
  //                   // Determine which handle is being dragged
  //                   if (values.start != _selectedRange.start) {
  //                     // Start handle is being dragged
  //                     _selectedRange = _moveStartHandle(values.start);
  //                   } else if (values.end != _selectedRange.end) {
  //                     // End handle is being dragged
  //                     _selectedRange = _moveEndHandle(values.end);
  //                   }
  //                 });
  //               },
  //             ),
  //             // Ticks and Labels
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: List.generate(10, (index) {
  //                   int value = 15 + (index * 5);
  //                   return Column(
  //                     children: [
  //                       Container(
  //                         height: 10,
  //                         width: 2,
  //                         color: Theme.of(context).textTheme.headlineLarge?.color,
  //                       ),
  //                       const SizedBox(height: 5),
  //                       Text(
  //                         value.toString(),
  //                         style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
  //                       ),
  //                     ],
  //                   );
  //                 }),
  //               ),
  //             ),
  //             // const SizedBox(height: 20),
  //             // // Selected Range Text
  //             // Padding(
  //             //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //             //   child: Text(
  //             //     "Selected Age Range: ${_selectedRange.start.round()} - ${_selectedRange.end.round()}",
  //             //     style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
  //             //   ),
  //             // ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildAgeSlider(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Age", style: GoogleFonts.inter(fontSize: canEdit ? 14 : 12, fontWeight: FontWeight.bold)),
        const SizedBox(
          width: 5,
        ),
        SfSlider(
          value: _age,
          min: 15.0,
          max: 95.0,
          stepSize: 1,
          activeColor: const Color(0xFFFF6500),
          inactiveColor: Colors.grey,
          onChanged: canEdit
              ? (dynamic value) {
                  setState(() {
                    _age = value;
                  });
                }
              : null,
        ),
      ],
    );
  }

  // Widget _buildAgeSlider2(BuildContext context, ThemeData theme) {
  //   return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
  //     return Row(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Text("Age", style: GoogleFonts.inter(fontSize: canEdit ? 14 : 12, fontWeight: FontWeight.bold)),
  //         const SizedBox(
  //           width: 5,
  //         ),
  //         Consumer<AppStore>(builder: (context, value, _) {
  //           return Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Range Slider
  //                 RangeSlider(
  //                   values: _selectedRange!,
  //                   min: 15,
  //                   max: 60,
  //                   divisions: 9,
  //                   activeColor: Theme.of(context).textTheme.headlineLarge?.color,
  //                   inactiveColor: Colors.white,
  //                   labels: RangeLabels(
  //                     _selectedRange!.start.round().toString(),
  //                     _selectedRange!.end.round().toString(),
  //                   ),
  //                   onChanged: (RangeValues values) {
  //                     log("age values: ${values}");
  //                     setState(() {
  //                       // Determine which handle is being dragged
  //                       if (canEdit) if (values.start != _selectedRange?.start) {
  //                         // Start handle is being dragged
  //                         _selectedRange = _moveStartHandle(values.start);
  //                       } else if (values.end != _selectedRange?.end) {
  //                         // End handle is being dragged
  //                         _selectedRange = _moveEndHandle(values.end);
  //                       }
  //                       log("_selectedRange age inter: ${_selectedRange}");
  //                       _age = _selectedRange?.start ?? 0;
  //                     });
  //                   },
  //                 ),
  //                 // Ticks and Labels
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: List.generate(10, (index) {
  //                       int value = 15 + (index * 5);
  //                       return Column(
  //                         children: [
  //                           Container(
  //                             height: 10,
  //                             width: 2,
  //                             color: Theme.of(context).textTheme.headlineLarge?.color,
  //                           ),
  //                           const SizedBox(height: 5),
  //                           Text(
  //                             index == 0
  //                                 ? "< $value"
  //                                 : index == 9
  //                                     ? "$value >"
  //                                     : "$value",
  //                             style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
  //                           ),
  //                         ],
  //                       );
  //                     }),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 15,
  //                 )
  //               ],
  //             ),
  //           );
  //         }),
  //       ],
  //     );
  //   });
  // }
  Widget _buildAgeSlider2(BuildContext context, ThemeData theme) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Age", style: GoogleFonts.inter(fontSize: canEdit ? 14 : 12, fontWeight: FontWeight.bold)),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Range Slider
                  RangeSlider(
                    values: _selectedRange!,
                    min: 10,
                    max: 60,
                    divisions: 10,
                    activeColor: Theme.of(context).textTheme.headlineLarge?.color,
                    inactiveColor: theme.textTheme.bodyLarge?.color,
                    labels: RangeLabels(
                      _selectedRange!.start.round().toString(),
                      _selectedRange!.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        if (canEdit) {
                          // Update slider handles
                          if (values.start != _selectedRange!.start) {
                            _selectedRange = _moveStartHandle(values.start);
                          } else if (values.end != _selectedRange!.end) {
                            _selectedRange = _moveEndHandle(values.end);
                          }
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
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
