import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:sneekin/services/auth_services.dart';
import 'package:sneekin/services/data_services.dart';
import 'package:sneekin/utils/toast.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:toastification/toastification.dart';

class CustomDrawerWidget extends StatefulWidget {
  // AppStore app;
  const CustomDrawerWidget({super.key
      // , required this.app
      });

  @override
  _CustomDrawerWidgetState createState() => _CustomDrawerWidgetState();
}

class _CustomDrawerWidgetState extends State<CustomDrawerWidget> {
  String name = "N/A"; // Placeholder for user name
  double _age = 21; // Placeholder for age
  String sneakId = "Sneak123"; // Placeholder for Sneak ID

  String address = "N/A";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  RangeValues? _selectedRange; // Initial range with 5-diff
  final double _fixedDifference = 5;

  bool canEdit = false;
  bool isVerified = true;

  File? _userProfileImage;
  bool userImagePicked = false;

  final ImagePicker _picker = ImagePicker();

  /// Image Picker
  Future<void> _pickUserImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _userProfileImage = File(image.path);
        userImagePicked = true;
      });
    }
  }

  File? _orgProfileImage;
  bool orgImagePicked = false;

  /// Image Picker
  Future<void> _pickOrgImage(setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _orgProfileImage = File(image.path);
        orgImagePicked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    log("custom drawer has rebuilt");

    return SafeArea(
      child: Drawer(
        // shape: ShapeBorder.lerp(StarBorder(), b, t),
        backgroundColor: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: Consumer<AppStore>(builder: (context, app, _) {
              if (app.isLoading) {
                return Center(
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      color: theme.textTheme.headlineLarge?.color,
                    ),
                  ),
                );
              }
              name = app.isSignedIn
                  ? (app.user?.name.isNotEmpty == true ? app.user!.name : name)
                  : (app.org?.name?.isNotEmpty == true ? app.org!.name! : name);

              _emailController.text = app.isSignedIn
                  ? (app.user?.email.isNotEmpty == true ? app.user!.email : "N/A")
                  : (app.org?.email?.isNotEmpty == true ? app.org!.email! : "N/A");

              if (app.isOrgSignedIn) {
                address = (app.org?.address?.isNotEmpty == true ? app.org!.address! : "______");
              }

              if (app.isSignedIn) {
                _selectedRange = RangeValues((app.user!.age).toDouble(), ((app.user!.age + 5)).toDouble());
                _age = app.user?.age.toDouble() ?? 0.0;
              }

              if (app.isSignedIn) {
                _phoneController.text = app.user?.mobileNumbers.isNotEmpty == true
                    ? app.user!.mobileNumbers.first.mobileNumber
                    : "N/A";
              }

              if (app.isOrgSignedIn) {
                _phoneController.text = app.org?.mobileNumbers?.isNotEmpty == true
                    ? app.org!.mobileNumbers!.first.mobileNumber
                    : "N/A";
              }

              log("_selectedRange: $_selectedRange");

              final double verticalSpacing = canEdit ? 20.0 : 22.0;
              const double horizontalSpacing = 10.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Profile",
                        // style: theme.textTheme.headlineLarge,
                        style: GoogleFonts.poppins(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.headlineLarge?.color),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: theme.iconTheme.color),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the drawer
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.secondaryHeaderColor,
                          child: app.isSignedIn
                              ? (app.user?.profileImageUrl?.isNotEmpty == true
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: app.user!.profileImageUrl!,
                                        fit: BoxFit.contain,
                                        width: 100,
                                        height: 100,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                            color: theme.textTheme.headlineLarge?.color,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Center(
                                          child: Text(
                                            app.user?.name.isNotEmpty == true ? app.user!.name[0] : "N/A",
                                            style: GoogleFonts.inter(
                                              fontSize: 35,
                                              color: theme.textTheme.headlineLarge?.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        app.user?.name.isNotEmpty == true ? app.user!.name[0] : "N/A",
                                        style: GoogleFonts.inter(
                                          fontSize: 35,
                                          color: theme.textTheme.headlineLarge?.color,
                                        ),
                                      ),
                                    ))
                              : (app.org?.logo?.isNotEmpty == true
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: app.org!.logo!,
                                        fit: BoxFit.contain,
                                        width: 100,
                                        height: 100,
                                        placeholder: (context, url) => Center(
                                          child: SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: theme.textTheme.headlineLarge?.color,
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Center(
                                          child: Text(
                                            app.org?.name?.isNotEmpty == true ? app.org!.name![0] : "N/A",
                                            style: GoogleFonts.inter(
                                              fontSize: 35,
                                              color: theme.textTheme.headlineLarge?.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        app.org?.name?.isNotEmpty == true ? app.org!.name![0] : "N/A",
                                        style: GoogleFonts.inter(
                                          fontSize: 35,
                                          color: theme.textTheme.headlineLarge?.color,
                                        ),
                                      ),
                                    )),
                        ),
                        if (canEdit)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: StatefulBuilder(
                                builder: (BuildContext context, void Function(void Function()) setState) {
                              return GestureDetector(
                                onTap: () {
                                  // Handle edit action here
                                  log("Edit button tapped!");
                                  if (app.isSignedIn) _pickUserImage(setState);
                                  if (app.isOrgSignedIn) _pickOrgImage(setState);
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
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.penToSquare,
                                      color: userImagePicked || orgImagePicked ? Colors.green : Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          log("canEdit: $canEdit");
                          setState(() {
                            canEdit = !canEdit;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FaIcon(
                            canEdit ? FontAwesomeIcons.xmark : FontAwesomeIcons.penToSquare,
                            color: theme.textTheme.headlineLarge?.color,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: canEdit ? theme.secondaryHeaderColor : theme.scaffoldBackgroundColor,
                        border: Border.all(
                            color: canEdit ? const Color(0xFFFF6500) : theme.scaffoldBackgroundColor),
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Consumer<DataServices>(builder: (context, data, _) {
                          return _buildTextField(false, '', name, _nameController, theme, data);
                        }),
                        if (canEdit)
                          SizedBox(
                            height: verticalSpacing,
                          ),
                        // SizedBox(height: verticalSpacing),
                        if (!canEdit)
                          const SizedBox(
                            height: 7,
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone,
                              size: canEdit ? 15 : 13,
                            ),
                            const SizedBox(width: horizontalSpacing),
                            Text(
                              app.isSignedIn
                                  ? app.user?.mobileNumbers.first.mobileNumber.toString() ?? "N/A"
                                  : app.org?.mobileNumbers?.first.mobileNumber.toString() ?? "N/A",
                              style: GoogleFonts.inter(fontSize: canEdit ? 14 : 12),
                            ),
                          ],
                        ),
                        SizedBox(height: verticalSpacing),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: canEdit ? 15 : 13,
                            ),
                            const SizedBox(width: horizontalSpacing),
                            Text(
                              app.isSignedIn
                                  ? app.user?.email.toString() ?? "N/A"
                                  : app.org?.email.toString() ?? "N/A",
                              style: GoogleFonts.inter(fontSize: canEdit ? 14 : 12),
                            ),
                          ],
                        ),
                        if (canEdit) SizedBox(height: verticalSpacing),
                        if (!canEdit)
                          const SizedBox(
                            height: 11,
                          ),
                        app.isSignedIn
                            ? Consumer<DataServices>(builder: (context, data, _) {
                                return _buildAgeSlider2(context, theme, data);
                              })
                            : Consumer<DataServices>(builder: (context, data, _) {
                                return _buildIconField(
                                    Icons.place, address, _addressController, theme, false, data);
                              }),
                        if (canEdit)
                          const SizedBox(
                            height: 30,
                          ),
                        if (canEdit)
                          Consumer2<AuthServices, DataServices>(builder: (context, auth, data, _) {
                            return InkWell(
                              onTap: () async {
                                if (app.isSignedIn) {
                                  if (_userProfileImage == null &&
                                      _nameController.text == app.user?.name &&
                                      _selectedRange?.start == app.user?.age) {
                                    showToast(message: "Nothing to update!", type: ToastificationType.error);
                                    return;
                                  }
                                  final result = await auth.updateUser(
                                      name: data.newName ?? "",
                                      email: "",
                                      age: _selectedRange!.start.toInt(),
                                      gender: "",
                                      profileImage: _userProfileImage ?? File(""));

                                  if (result == true) {
                                    setState(() {
                                      userImagePicked = false;
                                    });
                                    showToast(
                                        message: "User profile has updated successfully",
                                        type: ToastificationType.success);
                                    // context.go("/root");
                                    await app.initializeUserData();
                                    Scaffold.of(context).closeDrawer();
                                  }
                                }
                                if (app.isOrgSignedIn) {
                                  if (_orgProfileImage == null &&
                                      data.newName == app.org?.name &&
                                      _addressController.text == app.org?.address) {
                                    showToast(message: "Nothing to update!", type: ToastificationType.error);
                                    return;
                                  }

                                  log("Updating name: ${data.newName}");
                                  final result = await auth.updateOrganization(
                                      name: data.newName ?? "",
                                      websiteName: "",
                                      email: "",
                                      cin: "",
                                      pan: "",
                                      gstIn: "",
                                      address: data.newAddress ?? "",
                                      logoFile: _orgProfileImage ?? File(""),
                                      cinFile: File(""),
                                      panFile: File(""),
                                      gstInFile: File(""));
                                  if (result == true) {
                                    setState(() {
                                      orgImagePicked = false;
                                    });
                                    showToast(
                                        message: "Organization profile has updated successfully",
                                        type: ToastificationType.success);
                                    // context.go("/root");
                                    await app.initializeOrgData();
                                    Scaffold.of(context).closeDrawer();
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
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
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  // Spacer(),
                  if (canEdit)
                    const SizedBox(
                      height: 70,
                    ),
                  // const Spacer(),
                  if (!canEdit)
                    const SizedBox(
                      height: 90,
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildLogoutButton(
                        theme: theme,
                      ),
                    ],
                  ),
                  if (!canEdit) SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  if (canEdit) const Spacer(),
                  // Spacer(),
                  // SizedBox(
                  //   height: 32,
                  // ),

                  _buildPoweredBy(theme),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTextWithText(String label, String value, ThemeData theme) {
    return Container(
      // margin: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: canEdit ? 15 : 14, fontWeight: FontWeight.bold)),
          const SizedBox(
            width: 10,
          ),
          Text(value,
              style: GoogleFonts.inter(
                fontSize: canEdit ? 15 : 14,
              )),
        ],
      ),
    );
  }

  Widget _buildAgeSlider(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Age", style: GoogleFonts.inter(fontSize: canEdit ? 15 : 14, fontWeight: FontWeight.bold)),
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

  Widget _buildLogoutButton({required ThemeData theme}) {
    return Center(
      child: Consumer<AppStore>(builder: (context, app, value) {
        return GestureDetector(
          onTap: () async {
            log("logging out...");
            final resp = await app.signOut(context);
            if (resp == true) {
              context.go("/auth");
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text("Logged out successfully")),
              // );
              showToast(message: "Logged out successfully", type: ToastificationType.success);
            } else {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text("Error in logging out.")),
              // );
              showToast(message: "Error in logging out.", type: ToastificationType.error);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_outlined,
                color: theme.textTheme.headlineLarge?.color,
                size: 21,
              ),
              const SizedBox(
                width: 5,
              ),
              app.isLoading
                  ? SizedBox(
                      height: 30,
                      width: 30,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.textTheme.headlineLarge?.color,
                        ),
                      ),
                    )
                  : Text(
                      "Logout",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: theme.textTheme.headlineLarge?.color,
                          fontWeight: FontWeight.bold),
                    ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPoweredBy(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Powered by",
              style: theme.textTheme.bodySmall!
                  .copyWith(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset("assets/images/logo.png", height: 40, width: 40),
              const SizedBox(width: 10),
              Text(
                "Abblor",
                style: theme.textTheme.headlineLarge!
                    .copyWith(fontStyle: FontStyle.italic, color: theme.textTheme.bodyLarge?.color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSlider2(BuildContext context, ThemeData theme, DataServices data) {
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
                        data.changeAge(values.start);
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

  // RangeValues _moveEndHandle(double newEnd) {
  //   double newStart = newEnd - _fixedDifference;

  //   // Clamp values to prevent exceeding bounds
  //   if (newStart < 15) {
  //     newStart = 15;
  //     newEnd = newStart + _fixedDifference;
  //   } else if (newEnd > 60) {
  //     newEnd = 60;
  //     newStart = newEnd - _fixedDifference;
  //   }

  //   return RangeValues(newStart, newEnd);
  // }
  RangeValues _moveEndHandle(double newEnd) {
    double newStart = newEnd - _fixedDifference;

    if (newEnd == 60 && _selectedRange!.start == 60) {
      // Both handles are at 60, keep the range valid
      newStart = 60 - _fixedDifference;
      newEnd = 60;
    } else if (newStart < 15) {
      // Clamp values to prevent exceeding bounds
      newStart = 15;
      newEnd = newStart + _fixedDifference;
    } else if (newEnd > 60) {
      // Ensure end does not exceed 60
      newEnd = 60;
      newStart = newEnd - _fixedDifference;
    }

    return RangeValues(newStart, newEnd);
  }

  RangeValues _moveStartHandle(double newStart) {
    double newEnd = newStart + _fixedDifference;

    if (newStart == 60) {
      // If the user sets the start to 60, set end to 60 as well
      newEnd = 60;
      newStart = 60;
    } else if (newEnd > 60) {
      // Clamp values to prevent exceeding bounds
      newEnd = 60;
      newStart = newEnd - _fixedDifference;
    } else if (newStart < 15) {
      // Ensure start does not go below 15
      newStart = 15;
      newEnd = newStart + _fixedDifference;
    }

    return RangeValues(newStart, newEnd);
  }

  Widget _buildTextField(bool showLabel, String label, String value, TextEditingController controller,
      ThemeData theme, DataServices data) {
    return Focus(
      // onFocusChange: (value) {
      //   if (!value) {
      //     data.changeProfileName(controller.text);
      //   }
      // },
      child: TextFormField(
        enabled: canEdit,
        controller: controller,
        style: GoogleFonts.inter(
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.bold,
          fontSize: canEdit ? 14 : 14, // Smaller font size when canEdit is false
        ),
        onChanged: (value) {
          data.changeProfileName(value);
        },
        decoration: InputDecoration(
          contentPadding: canEdit ? const EdgeInsets.only(left: 10) : const EdgeInsets.only(left: 0),
          filled: true,
          fillColor: canEdit ? theme.secondaryHeaderColor : theme.scaffoldBackgroundColor,
          hintText: value, // Remove hintText since label is outside
          hintStyle: GoogleFonts.inter(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: canEdit ? 14 : 14, // Smaller font size when canEdit is false
          ),
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
    );
  }

  Widget _buildIconField(IconData label, String value, TextEditingController controller, ThemeData theme,
      bool showVerify, DataServices data) {
    return
        // Container(
        // child:
        Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Label on the left
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FaIcon(
              label,
              size: canEdit ? 20 : 16,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ],
        ),
        // const SizedBox(width: 10), // Space between label and text field
        // Form Field on the right
        if (canEdit)
          const SizedBox(
            width: 10,
          ),
        if (!canEdit)
          const SizedBox(
            width: 0,
          ),
        Expanded(
          child: TextFormField(
            enabled: canEdit,
            controller: controller,
            style: GoogleFonts.inter(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: canEdit ? 15 : 14, // Smaller font size when canEdit is false
            ),
            onChanged: (value) {
              data.changeAddress(value);
            },
            decoration: InputDecoration(
              suffix: showVerify
                  ? !canEdit
                      ? isVerified
                          ? const FaIcon(
                              FontAwesomeIcons.circleCheck,
                              color: Colors.green,
                              size: 17,
                            )
                          : const FaIcon(
                              FontAwesomeIcons.xmark,
                              color: Colors.red,
                              size: 17,
                            )
                      : null
                  : null,
              filled: true,
              fillColor: canEdit ? theme.secondaryHeaderColor : theme.scaffoldBackgroundColor,
              hintText: value, // Remove hintText since label is outside
              hintStyle: GoogleFonts.inter(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: canEdit ? 15 : 14, // Smaller font size when canEdit is false
              ),
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
    // );
  }
}
