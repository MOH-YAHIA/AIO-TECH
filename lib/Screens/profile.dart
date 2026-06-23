import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../services/auth_services.dart';
import '../utils/validations.dart';

class Profile extends StatefulWidget {
  final VoidCallback onBackPressed;
  const Profile({super.key, required this.onBackPressed});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _authService = AuthService();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // List of ages for the dropdown
  final List<int> ages = List.generate(93, (index) => index + 8);

  // Function to pick and crop the image
  Future<void> _pickAndCropImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

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

  // Dialog to Edit Profile Data
  void _showEditProfileDialog(Map<String, dynamic> currentData) {
    final TextEditingController nameController =
    TextEditingController(text: currentData['fullName']);
    final TextEditingController emailController =
    TextEditingController(text: currentData['email']);

    String? selectedGender = currentData['gender'] != 'Not specified' ? currentData['gender'] : null;
    int? selectedAge = currentData['age'] != 0 ? currentData['age'] : null;

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder is used to update the dropdowns inside the dialog
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
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: const [
                        DropdownMenuItem(value: "Man", child: Text("Man")),
                        DropdownMenuItem(value: "Woman", child: Text("Woman")),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedGender = value;
                        });
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
                      onChanged: (value) {
                        setDialogState(() {
                          selectedAge = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Update the local storage with new data
                    await _authService.updateProfileLocal(
                      fullName: nameController.text.trim(),
                      email: emailController.text.trim(),
                      age: selectedAge,
                      gender: selectedGender,
                    );

                    if (context.mounted) {
                      Navigator.pop(context); // Close dialog
                      setState(() {}); // Refresh the profile screen to show new data
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
// Import your validations file at the top of profile.dart
  // import '../utils/validations.dart';

  void _showChangePasswordDialog() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: SingleChildScrollView(
                // Wrap the Column in a Form to enable validation
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        // Validate that the field is not empty
                        validator: (value) => value == null || value.isEmpty ? 'Current password is required' : null,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          suffixIcon: IconButton(
                            icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        // Apply your custom validation logic here
                        validator: Validators.validatePassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          suffixIcon: IconButton(
                            icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureNew,
                        validator: (value) {
                          // First check if it passes standard validation
                          final passwordError = Validators.validatePassword(value);
                          if (passwordError != null) {
                            return passwordError;
                          }
                          // Then check if it matches the new password
                          if (value != newPasswordController.text) {
                            return "Passwords do not match";
                          }
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Trigger the validation check
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password updated successfully!')),
                      );
                    }
                  },
                  child: const Text('Confirm'),
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            widget.onBackPressed();
          },
          icon: const Icon(Icons.arrow_back_outlined),
          iconSize: 30,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _authService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? const Icon(Icons.person, size: 70, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFF19A1E6),
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: _pickAndCropImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Profile Information Cards
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildProfileRow(Icons.person, 'Name', userData['fullName']),
                          const Divider(),
                          _buildProfileRow(Icons.email, 'Email', userData['email']),
                          const Divider(),
                          _buildProfileRow(Icons.cake, 'Age', userData['age'] != 0 ? userData['age'].toString() : 'Not set'),
                          const Divider(),
                          _buildProfileRow(Icons.wc, 'Gender', userData['gender']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditProfileDialog(userData),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF19A1E6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _showChangePasswordDialog,
                      icon: const Icon(Icons.lock_reset, color: Color(0xFF19A1E6)),
                      label: const Text('Change Password', style: TextStyle(color: Color(0xFF19A1E6), fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF19A1E6), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
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
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}