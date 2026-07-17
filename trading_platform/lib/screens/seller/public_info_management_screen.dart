import 'package:flutter/material.dart';
import '../../models/user/user.dart';
// 假設您的自定義組件路徑
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../widgets/BottomConvexArcWidget.dart';
import '../../theme/app_theme.dart';


class PublicInfoManagementScreen extends StatefulWidget {
  final User currentUser;

  const PublicInfoManagementScreen({Key? key, required this.currentUser})
      : super(key: key);

  @override
  State<PublicInfoManagementScreen> createState() =>
      _PublicInfoManagementScreenState();
}

class _PublicInfoManagementScreenState
    extends State<PublicInfoManagementScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late bool _isSchoolPublic;
  String? _avatarUrl;

  final _formKey = GlobalKey<FormState>();

  final double _bottomBarActualHeight = 60.0;
  final double _bottomBarCurveHeight = 25.0;
  final double _avatarRadius = 50.0; // 頭像半徑
  final double _avatarOverlap = 15.0; // 頭像底部嵌入到背景凹形曲線的量

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
        text: widget.currentUser.publicDisplayName ??
            widget.currentUser.username);
    _bioController =
        TextEditingController(text: widget.currentUser.publicBio);
    _isSchoolPublic = widget.currentUser.isSchoolPublic;
    _avatarUrl = widget.currentUser.avatarUrl;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    _formKey.currentState?.save();
    Map<String, dynamic> updatedUserData = {
      'publicDisplayName': _displayNameController.text.trim(),
      'publicBio': _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      'isSchoolPublic': _isSchoolPublic,
      'avatarUrl': _avatarUrl,
    };
    print('Saving changes: $updatedUserData');
    // 模擬保存操作
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('公開資訊已更新！'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _pickImage(Function(String?) onImagePicked) async {
    // 實際應用中，這裡會調用 image_picker 或類似插件
    await Future.delayed(const Duration(milliseconds: 500));
    // 使用一個隨機的 picsum URL 作為模擬
    String mockUrl = 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/200/200';
    setState(() {
      onImagePicked(mockUrl);
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double appBarStandardHeight = kToolbarHeight + 30;
    final double appBarBottomCurveHeight = 40.0;
    final double avatarOuterRadius = _avatarRadius + 5;

    // 頭像在屏幕上期望的視覺頂部 Y 座標
    final double avatarDesiredVisualTop = appBarStandardHeight - appBarBottomCurveHeight + 80;

    // 延伸背景的高度計算
    final double extendedAppBarBgHeight = avatarDesiredVisualTop + (avatarOuterRadius * 2) + appBarBottomCurveHeight - _avatarOverlap;

    // 估算頭像 + 其下的文字標籤 + 標籤與頭像間距 的總高度
    final double avatarLabelHeight = 20.0; // "點擊更改頭貼" 標籤的估計高度
    final double avatarToLabelSpacing = 8.0; // 頭像和標籤之間的間距
    final double avatarAndLabelTotalHeight = avatarOuterRadius;

    // 第一個 SliverToBoxAdapter (佔位SizedBox) 的高度
    // 確保後續內容 (SliverList) 從頭像和標籤下方開始
    final double firstSizedBoxHeight = avatarDesiredVisualTop + avatarAndLabelTotalHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(""), // AppBar 標題為空
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: extendedAppBarBgHeight,
              decoration: ShapeDecoration(
                color: colorScheme.primary, // 使用主題的主顏色
                shape: FullBottomConcaveAppBarShape(curveHeight: appBarBottomCurveHeight),
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: <Widget>[
                // Sliver 1: 佔位符，確保滾動內容從頭像和標籤下方開始
                SliverToBoxAdapter(
                  child: SizedBox(height: firstSizedBoxHeight),
                ),

                // Sliver 2: 實際的頭像和標籤，通過 Transform 向上移動以疊加
                SliverToBoxAdapter(
                  child: Transform.translate(
                    // 向上移動的距離 = -(第一個SizedBox的高度) + 頭像期望的視覺頂部
                    offset: Offset(0, -firstSizedBoxHeight + avatarDesiredVisualTop),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector( // 使頭像圖片可點擊
                            onTap: () => _pickImage((url) {
                              setState(() { _avatarUrl = url; });
                            }),
                            child: CircleAvatar(
                              radius: avatarOuterRadius,
                              backgroundColor: Colors.white, // 外圈白色邊框
                              child: CircleAvatar(
                                radius: _avatarRadius,
                                backgroundColor: colorScheme.secondaryContainer, // 頭像背景色
                                backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                    ? NetworkImage(_avatarUrl!)
                                    : null,
                                child: _avatarUrl == null || _avatarUrl!.isEmpty
                                    ? Icon(Icons.person_outline, size: _avatarRadius, color: colorScheme.onSecondaryContainer)
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(height: avatarToLabelSpacing), // 頭像和標籤之間的間距
                          GestureDetector( // 使文字標籤也可點擊
                            onTap: () => _pickImage((url) {
                              setState(() { _avatarUrl = url; });
                            }),
                            child: Text(
                              '點擊更改頭貼',
                              style: TextStyle(
                                color: colorScheme.onPrimary.withOpacity(0.9), // 標籤文字顏色
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sliver 3: 後續的所有內容 (表單項)
                SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    _buildSectionTitle('基本公開資料'),
                    _buildTextField(
                      controller: _displayNameController,
                      label: '公開顯示名稱',
                      hint: '其他用戶看到的您的稱呼 (默認為用戶名)',
                    ),
                    _buildTextField(
                      controller: _bioController,
                      label: '公開個人簡介',
                      hint: '向大家介紹一下您自己^^',
                      maxLines: 3,
                    ),
                    _buildSectionTitle('其他公開資訊'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SwitchListTile(
                        title: const Text('公開我的學校資訊'),
                        subtitle: Text(widget.currentUser.schoolName?.isNotEmpty == true
                            ? widget.currentUser.schoolName!
                            : '您尚未在個人資料中設置學校信息'),
                        value: _isSchoolPublic,
                        onChanged: (widget.currentUser.schoolName?.isNotEmpty == true)
                            ? (bool value) {
                          setState(() { _isSchoolPublic = value; });
                        }
                            : null,
                        activeColor: colorScheme.primary,
                        secondary: const Icon(Icons.school_outlined),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        tileColor: colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                    ),
                    if (widget.currentUser.schoolName == null ||
                        widget.currentUser.schoolName!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0, right: 16.0, top: 4.0, bottom: 16.0),
                        child: Text(
                          '請先在您的個人資料中設置學校信息，才能選擇是否公開。',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.orange[700]),
                        ),
                      ),
                    // 為底部按鈕預留一些空間，避免內容太貼近底部按鈕 (如果SliverFillRemaining的child直接是按鈕)
                    // 或者這個空間由SliverFillRemaining內部Padding的top屬性提供
                    const SizedBox(height: 20),
                  ]),
                ),

                // Sliver 4: 底部保存按鈕
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      // bottom: 0.0 使 BottomConvexArcWidget 的底部貼合屏幕底部
                      // 如果 BottomConvexArcWidget 本身有內邊距，則這裡設為 0
                      // 可以在這裡加 top padding 來控制按鈕與上方內容的距離，或者保留SliverList最後的SizedBox
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: BottomConvexArcWidget(
                        barHeight: _bottomBarActualHeight,
                        curveHeight: _bottomBarCurveHeight,
                        backgroundColor: colorScheme.primary,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _saveChanges,
                            child: SizedBox(
                              height: _bottomBarActualHeight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.save_alt_outlined, color: colorScheme.onPrimary, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    '保存所有更改',
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
