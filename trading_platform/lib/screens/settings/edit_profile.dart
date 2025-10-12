// --- FILE: lib/screens/settings/edit_profile.dart ---
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/user/user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  late TextEditingController _schoolNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController; // ✅ 新增

  XFile? _newAvatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _bioController = TextEditingController();
    _schoolNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController(); // ✅ 初始化

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser != null) {
      _nicknameController.text = currentUser.username;
      _bioController.text = currentUser.bio ?? '';
      _schoolNameController.text = currentUser.schoolName ?? '';
      _phoneController.text = currentUser.phoneNumber ?? '';
      _addressController.text = currentUser.address ?? ''; // ✅ 載入地址
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _schoolNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose(); // ✅ 釋放資源
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _newAvatarFile = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await context.read<AuthProvider>().updateUserProfile(
        nickname: _nicknameController.text.trim(),
        bio: _bioController.text.trim(),
        schoolName: _schoolNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(), // ✅ 傳送地址
        newAvatarFile: _newAvatarFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('個人資訊已更新'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失敗: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('編輯個人資訊'),
          ),
          body: AbsorbPointer(
            absorbing: _isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _newAvatarFile != null
                                ? FileImage(File(_newAvatarFile!.path))
                                : (currentUser?.avatarUrl != null && currentUser!.avatarUrl!.isNotEmpty)
                                ? NetworkImage(currentUser.avatarUrl!)
                                : null as ImageProvider?,
                            child: (_newAvatarFile == null && (currentUser?.avatarUrl == null || currentUser!.avatarUrl!.isEmpty))
                                ? const Icon(Icons.person, size: 60)
                                : null,
                          ),
                          const CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.black38,
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 40),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(labelText: '名稱/暱稱', border: OutlineInputBorder()),
                      validator: (value) => (value == null || value.isEmpty) ? '暱稱不能為空' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _schoolNameController,
                      decoration: const InputDecoration(labelText: '學校名稱', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: '個人簡介', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: '手機號碼', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // ✅ 地址輸入欄位
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: '地址',
                        border: OutlineInputBorder(),
                        hintText: '請輸入您的地址',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),

                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('保存更改'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}