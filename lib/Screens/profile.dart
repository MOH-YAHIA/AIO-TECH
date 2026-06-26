import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../services/auth_services.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';
import '../utils/validations.dart';

class Profile extends StatefulWidget {
  final VoidCallback onBackPressed;
  // refreshTrigger: passed from MainWrapper. Every time this int changes
  // (login, logout, navigate-to-profile, after edit), Profile re-fetches
  // SharedPreferences so it never shows stale or empty data.
  final int refreshTrigger;

  const Profile({
    super.key,
    required this.onBackPressed,
    required this.refreshTrigger,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final List<int> ages = List.generate(93, (index) => index + 8);

  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _authService.getUserProfile();
  }

  // didUpdateWidget fires whenever the parent rebuilds this widget with new
  // props. When MainWrapper increments refreshTrigger, this runs and replaces
  // _profileFuture with a fresh read — fixing the "empty profile after login"
  // issue caused by IndexedStack building Profile before _saveSession ran.
  @override
  void didUpdateWidget(covariant Profile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      setState(() {
        _profileFuture = _authService.getUserProfile();
      });
    }
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _authService.getUserProfile();
    });
  }

  Future<void> _pickAndCropImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _profileImage = File(croppedFile.path);
        });
      }
    }
  }

  void _showEditProfileDialog(Map<String, dynamic> currentData) {
    final TextEditingController nameController = TextEditingController(
      text: currentData['fullName'],
    );
    final TextEditingController emailController = TextEditingController(
      text: currentData['email'],
    );

    String? selectedGender = currentData['gender'] != 'Not specified'
        ? currentData['gender']
        : null;
    int? selectedAge = (currentData['age'] as int?) != 0
        ? currentData['age'] as int?
        : null;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: const [
                        DropdownMenuItem(value: "Man", child: Text("Man")),
                        DropdownMenuItem(value: "Woman", child: Text("Woman")),
                      ],
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setDialogState(() => selectedGender = value);
                            },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedAge,
                      decoration: const InputDecoration(labelText: 'Age'),
                      items: ages.map((age) {
                        return DropdownMenuItem<int>(
                          value: age,
                          child: Text(age.toString()),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setDialogState(() => selectedAge = value);
                            },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setDialogState(() => isLoading = true);

                          final response = await _userService.updateProfile(
                            fullName: nameController.text.trim(),
                            email: emailController.text.trim(),
                            age: selectedAge,
                            gender: selectedGender,
                          );

                          if (!context.mounted) return;

                          if (response['success']) {
                            Navigator.pop(context);
                            _refreshProfile();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully!'),
                              ),
                            );
                          } else {
                            setDialogState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  response['message'] ?? 'Update failed',
                                ),
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        enabled: !isLoading,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Current password is required'
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setDialogState(
                              () => obscureCurrent = !obscureCurrent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        enabled: !isLoading,
                        validator: Validators.validatePassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setDialogState(() => obscureNew = !obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureNew,
                        enabled: !isLoading,
                        validator: (value) {
                          final passwordError = Validators.validatePassword(
                            value,
                          );
                          if (passwordError != null) return passwordError;
                          if (value != newPasswordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Confirm New Password',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => isLoading = true);

                          final response = await _userService.changePassword(
                            currentPassword: currentPasswordController.text,
                            newPassword: newPasswordController.text,
                          );

                          if (!context.mounted) return;

                          if (response['success']) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password updated successfully!'),
                              ),
                            );
                          } else {
                            setDialogState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  response['message'] ??
                                      'Failed to change password',
                                ),
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.secondarySurface.withOpacity(0.2),
        leading: IconButton(
          onPressed: widget.onBackPressed,
          icon: const Icon(Icons.arrow_back_outlined),
          iconSize: 30,
          color: AppColors.secondaryText,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            // 1. Replaced SizedBox(width: double.infinity) with Center
            child: Center(
              // 2. Added ConstrainedBox to limit the maximum width on web/landscape
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: AppColors.secondarySurface,
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _pickAndCropImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Card(
                      color: AppColors.secondaryText.withOpacity(0.7),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildProfileRow(
                              Icons.person,
                              'Name',
                              userData['fullName'] ?? '',
                            ),
                            const Divider(),
                            _buildProfileRow(
                              Icons.email,
                              'Email',
                              userData['email'] ?? '',
                            ),
                            const Divider(),
                            _buildProfileRow(
                              Icons.cake,
                              'Age',
                              (userData['age'] as int? ?? 0) != 0
                                  ? userData['age'].toString()
                                  : 'Not set',
                            ),
                            const Divider(),
                            _buildProfileRow(
                              Icons.wc,
                              'Gender',
                              userData['gender'] ?? '',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditProfileDialog(userData),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondarySurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _showChangePasswordDialog,
                        icon: Icon(
                          Icons.lock_reset,
                          color: AppColors.secondarySurface,
                        ),
                        label: Text(
                          'Change Password',
                          style: TextStyle(
                            color: AppColors.secondarySurface,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.buttonGlowShadow,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.glowLayer1.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mainBackground),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: AppColors.mainBackground),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.drawerBackground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
