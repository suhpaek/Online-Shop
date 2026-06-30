import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import '../providers/auth_service_provider.dart';
import '../providers/login_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;

  String? _selectedImagePath;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoadingProfile = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    final email = ref.read(emailProvider);

    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? email);
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _countryController = TextEditingController(text: profile?.country ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
    _postalCodeController = TextEditingController(
      text: profile?.postalCode ?? '',
    );

    if (profile != null && profile.image.startsWith('/')) {
      _selectedImagePath = profile.image;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedProfile() async {
    final user = ref.read(firebaseAuthServiceProvider).currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      _isLoadingProfile = true;
    });

    Profile? localProfile;

    try {
      localProfile = await ref
          .read(localProfileServiceProvider)
          .loadProfile(user.uid);

      if (mounted && localProfile != null) {
        _applyProfile(localProfile);
      }

      final remoteProfile = await ref
          .read(firebaseProfileServiceProvider)
          .loadProfile(user.uid);

      if (!mounted || remoteProfile == null) {
        return;
      }

      await ref
          .read(localProfileServiceProvider)
          .saveProfile(userId: user.uid, profile: remoteProfile);
      _applyProfile(remoteProfile);
    } on FirebaseException catch (e) {
      if (!mounted || localProfile != null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_profileStorageErrorMessage(e))));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _applyProfile(Profile profile) {
    ref.read(profileProvider.notifier).state = profile;

    setState(() {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _countryController.text = profile.country;
      _cityController.text = profile.city;
      _addressController.text = profile.address;
      _postalCodeController.text = profile.postalCode;
      _selectedImagePath = profile.image.startsWith('/') ? profile.image : null;
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _saveProfile() async {
    final String newEmail = _emailController.text.trim();
    final String imagePath =
        _selectedImagePath ??
        'https://api.dicebear.com/7.x/bottts/svg?seed=${_nameController.text.isNotEmpty ? _nameController.text : 'User'}';

    final user = ref.read(firebaseAuthServiceProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save your profile.')),
      );
      return;
    }

    final currentEmail = ref.read(emailProvider).trim();

    setState(() {
      _isSaving = true;
    });

    if (newEmail.isNotEmpty &&
        currentEmail.isNotEmpty &&
        newEmail != currentEmail) {
      try {
        await ref.read(firebaseAuthServiceProvider).updateEmail(newEmail);
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to update email.')),
        );
        return;
      }
    }

    final profile = Profile(
      image: imagePath,
      name: _nameController.text,
      email: newEmail,
      phone: _phoneController.text,
      country: _countryController.text,
      city: _cityController.text,
      address: _addressController.text,
      postalCode: _postalCodeController.text,
    );

    try {
      await ref
          .read(localProfileServiceProvider)
          .saveProfile(userId: user.uid, profile: profile);
      ref.read(profileProvider.notifier).state = profile;

      await ref
          .read(firebaseProfileServiceProvider)
          .saveProfile(userId: user.uid, profile: profile);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final message = _profileStorageErrorMessage(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$message Saved on this device.')));
      setState(() {
        _isSaving = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newEmail != currentEmail
              ? 'Profile saved. Check your inbox to confirm the new email.'
              : 'Profile saved successfully!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _profileStorageErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Profile storage is not available. Check Firestore rules.';
      case 'unavailable':
        return 'Profile storage is temporarily unavailable. Try again later.';
      case 'not-found':
        return 'Profile storage is not configured yet.';
      default:
        return 'Could not save profile. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isLoadingProfile) const LinearProgressIndicator(),
              if (_isLoadingProfile) const SizedBox(height: 16),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[200],
                      child: _selectedImagePath != null
                          ? Image.file(
                              File(_selectedImagePath!),
                              fit: BoxFit.cover,
                            )
                          : (profile?.image != null
                                ? (profile!.image.startsWith('/')
                                      ? Image.file(
                                          File(profile.image),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          profile.image,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.account_circle,
                                                  size: 80,
                                                  color: Colors.grey,
                                                );
                                              },
                                        ))
                                : Image.network(
                                    'https://api.dicebear.com/7.x/bottts/svg?seed=User',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.account_circle,
                                        size: 80,
                                        color: Colors.grey,
                                      );
                                    },
                                  )),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _countryController,
                        label: 'Country',
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        icon: Icons.location_city,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _postalCodeController,
                        label: 'Postal Code',
                        icon: Icons.mail_outline,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSaving ? 'Saving...' : 'Save Profile'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(firebaseAuthServiceProvider).logout();
                          if (!context.mounted) return;
                          context.go('/login');
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
