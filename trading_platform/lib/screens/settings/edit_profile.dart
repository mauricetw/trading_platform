import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _schoolNameController;
  late TextEditingController _avatarUrlController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // --- 整合點 1：從 AuthProvider 初始化真實的使用者資料 ---
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _schoolNameController = TextEditingController(text: user?.schoolName ?? '');
    _avatarUrlController = TextEditingController(text: user?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _schoolNameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        // --- 整合點 2：呼叫 AuthProvider 的方法來更新資料 ---
        await authProvider.updateUserProfile(
          username: _usernameController.text,
          bio: _bioController.text,
          schoolName: _schoolNameController.text,
          avatarUrl: _avatarUrlController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('個人資料更新成功！'), backgroundColor: Colors.green),
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
  }

  @override
  Widget build(BuildContext context) {
    // --- 整合點 3：使用 Consumer 來即時顯示大頭貼預覽 ---
    return Scaffold(
      appBar: AppBar(
        title: const Text('編輯個人資訊'),
        backgroundColor: const Color(0xFF004E98),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 大頭貼預覽
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  // 優先顯示文字框中的 URL，方便預覽
                  final previewUrl = _avatarUrlController.text.isNotEmpty
                      ? _avatarUrlController.text
                      : auth.currentUser?.avatarUrl;

                  return CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: (previewUrl != null && previewUrl.isNotEmpty)
                        ? NetworkImage(previewUrl)
                        : null,
                    child: (previewUrl == null || previewUrl.isEmpty)
                        ? Icon(Icons.person, size: 60, color: Colors.grey.shade600)
                        : null,
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text('請貼上圖片網址', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              // 各項資料的輸入框
              _buildTextField(
                controller: _usernameController,
                labelText: '使用者名稱',
                icon: Icons.person_outline,
                validator: (value) => (value == null || value.isEmpty) ? '使用者名稱不能為空' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _schoolNameController,
                labelText: '學校名稱',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _bioController,
                labelText: '個人簡介',
                icon: Icons.info_outline,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _avatarUrlController,
                labelText: '大頭貼圖片網址',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 40),

              // 儲存按鈕
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? '儲存中...' : '儲存更改'),
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    backgroundColor: const Color(0xFFFF8C35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 輔助函式，建立統一風格的 TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}