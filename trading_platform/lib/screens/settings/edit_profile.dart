// --- FILE: lib/screens/settings/edit_profile.dart ---
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/user/user.dart';
// 1. 引入新的地址管理頁面
import 'address_management_screen.dart';

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
  // --- [BUG 修正] ---
  // 2. 移除 _addressController
  // late TextEditingController _addressController;

  XFile? _newAvatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _bioController = TextEditingController();
    _schoolNameController = TextEditingController();
    _phoneController = TextEditingController();
    // 3. 移除 _addressController 的初始化

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser != null) {
      _nicknameController.text = currentUser.username;
      _bioController.text = currentUser.bio ?? '';
      _schoolNameController.text = currentUser.schoolName ?? '';
      _phoneController.text = currentUser.phoneNumber ?? '';
      // 4. 移除 _addressController 的載入
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _schoolNameController.dispose();
    _phoneController.dispose();
    // 5. 移除 _addressController 的 dispose
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
        // 6. 移除 'address' 參數 (你需要一併修改 AuthProvider 中的 updateUserProfile 函式)
        // address: _addressController.text.trim(),
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
                    // ... (頭像選擇的程式碼保持不變) ...
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
                    const SizedBox(height: 24), // 加大間距

                    // --- [新功能] ---
                    // 7. 移除地址輸入框，改為 "管理地址" 按鈕
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('管理我的地址'),
                      subtitle: const Text('新增、編輯或刪除您的收貨地址'),
                      trailing: const Icon(Icons.chevron_right),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!)
                      ),
                      onTap: () {
                        // 導航到新的地址管理頁面
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddressManagementScreen()),
                        );
                      },
                    ),
                    // --- [新功能結束] ---

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