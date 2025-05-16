import 'package:flutter/material.dart';

// 假設您有處理用戶資料更新的服務或提供者
// import 'user_service.dart';
// import '../models/user/user.dart'; // 假設您有 User model
// import 'package:image_picker/image_picker.dart'; // 如果您打算使用 image_picker

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // 用於輸入新密碼

  // 對於大頭貼，您需要一個變數來存儲圖片檔案或 URL
  // File? _avatarImage; // 如果使用 image_picker 獲取的檔案
  String? _avatarUrl; // 如果顯示網路圖片

  // 對於性別和生日，您需要相應的變數
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  // 模擬現有的用戶資料 (在實際應用中，您會從狀態管理或其他地方獲取)
  // 這裡我們創建一個模擬的 User 物件
  // final User currentUser = UserService().getCurrentUser(); // 假設有獲取當前用戶的方法
  // 使用 Map 模擬用戶資料
  final Map<String, dynamic> _currentUserData = {
    'username': '測試用戶',
    'bio': '這是一個測試帳號的簡介',
    'email': 'test@example.com',
    'phoneNumber': '0912345678',
    'gender': '男', // 模擬性別
    'dateOfBirth': DateTime(2000, 1, 15), // 模擬生日
    'avatarUrl': 'https://via.placeholder.com/150', // 模擬大頭貼 URL
  };


  @override
  void initState() {
    super.initState();
    // 在頁面初始化時，用模擬的用戶資料填充 TextField 和變數
    _nameController.text = _currentUserData['username'] ?? '';
    _bioController.text = _currentUserData['bio'] ?? '';
    _emailController.text = _currentUserData['email'] ?? '';
    _phoneController.text = _currentUserData['phoneNumber'] ?? '';
    _selectedGender = _currentUserData['gender'];
    _selectedDateOfBirth = _currentUserData['dateOfBirth'];
    _avatarUrl = _currentUserData['avatarUrl']; // 填充模擬的大頭貼 URL
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 選擇大頭貼圖片的函式
  void _pickImage() async {
    // TODO: 實現圖片選擇器邏輯 (例如使用 image_picker 套件)
    print('點擊選擇圖片');
    // 假設使用 image_picker：
    /*
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        // _avatarImage = File(image.path); // 如果保存 File
        // 如果需要上傳圖片並獲取 URL，這裡需要處理上傳邏輯
        // 假設獲取到一個臨時的檔案路徑或 base64 字符串
        // _avatarUrl = 'path/to/temp/image'; // 或者 'data:image/png;base64,...'
      });
    }
    */
  }

  // 選擇生日的函式
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(), // 初始日期為當前選取的日期或今天
      firstDate: DateTime(1900), // 可選的最早日期
      lastDate: DateTime.now(), // 可選的最晚日期為今天
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  // 保存修改的函式
  void _saveProfile() {
    // TODO: 在這裡獲取所有 TextField 和變數中的值，並發送到後端或狀態管理進行保存
    final updatedData = {
      'username': _nameController.text,
      'bio': _bioController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneController.text,
      'gender': _selectedGender,
      'dateOfBirth': _selectedDateOfBirth,
      'password': _passwordController.text, // 只有當用戶輸入了新密碼時才發送
      // 'avatarImage': _avatarImage, // 如果有新的大頭貼圖片檔案
      // 'avatarUrl': _avatarUrl, // 如果上傳後獲取了新的 URL
    };

    print('保存的個人資訊：$updatedData');

    // 執行保存邏輯，例如調用 UserService 的更新方法
    // UserService().updateUser(updatedData).then((_) {
    //   // 處理保存成功後的邏輯
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('個人資訊已更新')),
    //   );
    //   Navigator.pop(context); // 返回上一頁
    // }).catchError((error) {
    //   // 處理保存失敗後的邏輯
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('更新失敗：$error')),
    //   );
    // });

    // 這裡只是模擬保存成功
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('個人資訊已更新 (模擬)')),
    );
    // Navigator.pop(context); // 模擬返回上一頁
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('編輯個人資訊'),
        ),
        body: SingleChildScrollView( // 使用 SingleChildScrollView 防止鍵盤彈出時溢出
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center, // 使內容居中對齊
    children: [
    // 大頭貼
    GestureDetector( // 使大頭貼可點擊
    onTap: _pickImage, // 點擊時選擇圖片
    child: CircleAvatar(
    radius: 60, // 稍微大一點
    backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
    child: _avatarUrl == null
    ? const Icon(Icons.camera_alt, size: 40) // 沒有大頭貼時顯示相機圖標
        : null,
      // 如果您使用 File 來顯示本地圖片，可以使用 FileImage
      // backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null),
      // child: _avatarImage == null && _avatarUrl == null
      //     ? const Icon(Icons.camera_alt, size: 40)
      //     : null,
    ),
    ),
      const SizedBox(height: 20),

      // 姓名/暱稱
      TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: '名稱/暱稱',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 簡介
      TextField(
        controller: _bioController,
        decoration: InputDecoration(
          labelText: '簡介',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        maxLines: 3, // 可以輸入多行簡介
      ),
      const SizedBox(height: 16),

      // 電子郵件
      TextField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: '電子郵件',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        keyboardType: TextInputType.emailAddress, // 設置鍵盤類型為電子郵件
      ),
      const SizedBox(height: 16),

      // 手機號碼
      TextField(
        controller: _phoneController,
        decoration: InputDecoration(
          labelText: '手機號碼',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        keyboardType: TextInputType.phone, // 設置鍵盤類型為電話號碼
      ),
      const SizedBox(height: 16),

      // 性別選擇
      DropdownButtonFormField<String>( // 使用 DropdownButtonFormField
        decoration: InputDecoration(
          labelText: '性別',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        value: _selectedGender,
        hint: const Text('請選擇性別'),
        // 沒有選擇時顯示的提示文字
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        items: <String>['男', '女', '其他', '不公開'] // 性別選項列表
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),

      // 生日選擇
      GestureDetector( // 使 TextField 可點擊來選擇日期
        onTap: () => _selectDate(context), // 點擊時彈出日期選擇器
        child: AbsorbPointer( // 阻止 TextField 本身的鍵盤彈出
          child: TextField(
            decoration: InputDecoration(
              labelText: '生日',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              suffixIcon: const Icon(Icons.calendar_today), // 右側日曆圖標
            ),
            controller: TextEditingController( // 使用一個臨時控制器顯示選取的日期
              text: _selectedDateOfBirth != null
                  ? "${_selectedDateOfBirth!.toLocal()}".split(' ')[0] // 格式化日期
                  : '',
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 密碼更改 (只提供輸入新密碼的選項)
      TextField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: '新密碼 (留空則不更改)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        obscureText: true, // 隱藏輸入的文字
        // 可以添加確認密碼的 TextField
      ),
      // 如果需要確認密碼，可以添加另一個 TextField：
      // const SizedBox(height: 16),
      // TextField(
      //   decoration: InputDecoration(
      //     labelText: '確認新密碼',
      //     border: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(8.0),
      //     ),
      //   ),
      //   obscureText: true,
      // ),
      const SizedBox(height: 30),

      // 保存按鈕
      ElevatedButton(
        onPressed: _saveProfile, // 點擊按鈕時保存修改
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          textStyle: const TextStyle(fontSize: 18.0), // 稍微大一點的字體
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          minimumSize: const Size(double.infinity, 0), // 使按鈕寬度與父容器相同
        ),
        child: const Text('保存更改'),
      ),
    ],
    ),
        ),
    );
  }
}