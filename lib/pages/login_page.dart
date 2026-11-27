import 'package:flutter/material.dart';
import 'package:marble_and_granite/Constant/constants.dart';
import 'package:marble_and_granite/Widgets/custom_bottom.dart';
import 'package:marble_and_granite/Widgets/custom_text_feild.dart';
import 'package:marble_and_granite/Widgets/saved_bottom.dart';
import 'package:marble_and_granite/pages/home_page.dart';
import 'package:marble_and_granite/pages/offline_mode_page.dart';
import 'package:marble_and_granite/services/login_storage_service.dart';
import 'package:marble_and_granite/services/backend_api_client.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static String id = 'LoginPage';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers للتحكم في بيانات حقول تسجيل الدخول.
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  // خدمة حفظ واسترجاع البيانات بشكل آمن.
  final LoginStorageService _storageService = LoginStorageService();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // استرجاع البيانات المحفوظة بمجرد فتح صفحة Login.
    _loadSavedCredentials();
  }

  // تحميل بيانات الدخول المحفوظة.
  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await _storageService.loadCredentials();

      if (!mounted) return;

      _usernameController.text = credentials['username'] ?? '';
      _passwordController.text = credentials['password'] ?? '';
      _tokenController.text = credentials['token'] ?? '';
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }
  }

  // حفظ بيانات الدخول على الجهاز.
  Future<void> _saveCredentials() async {
    // منع الضغط المتكرر أثناء عملية الحفظ.
    if (_isSaving) return;

    // التأكد إن الحقول الثلاثة مش فاضية.
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _tokenController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields first')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _storageService.saveCredentials(
        username: _usernameController.text,
        password: _passwordController.text,
        token: _tokenController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account saved successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save account: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // تسجيل الدخول والتحقق من البيانات عن طريق الـ Backend.
  Future<void> _login() async {
    if (_isSaving) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final token = _tokenController.text.trim();

    if (username.isEmpty || password.isEmpty || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields first')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final client = BackendApiClient(baseUrl: 'http://10.53.1.108:8080');

    try {
      // إرسال بيانات الدخول والتحقق منها.
      final result = await client.login(
        username: username,
        password: password,
        token: token,
      );

      // حفظ البيانات بعد نجاح تسجيل الدخول فقط.
      await _storageService.saveCredentials(
        username: username,
        password: password,
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Login successful'),
        ),
      );

      // الانتقال للصفحة الرئيسية بعد نجاح التحقق.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      client.close();

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // تحرير الـ Controllers عند إغلاق الصفحة.
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 10,
        scrolledUnderElevation: 10,
        shadowColor: Colors.black.withValues(alpha: .5),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        title: Text(
          'Marble And Granite',
          style: TextStyle(
            fontFamily: 'Tuffy',
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Color(0xffC5A46D),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: kImage, fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),

                  Text(
                    'LogIn',
                    style: TextStyle(
                      fontFamily: 'Tuffy',
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  Center(
                    child: SizedBox(
                      height: 230,
                      width: 200,
                      child: Image.asset(
                        'assets/Images/Logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'Image Error: $error',
                            style: const TextStyle(color: Colors.red),
                          );
                        },
                      ),
                    ),
                  ),

                  // حقل اسم المستخدم.
                  CustomTextField(
                    hint: 'User Name',
                    icon: Icons.person,
                    controller: _usernameController,
                  ),

                  SizedBox(height: 3),

                  // حقل كلمة المرور.
                  CustomTextField(
                    hint: 'Password',
                    icon: Icons.password,
                    isPassword: true,
                    controller: _passwordController,
                  ),

                  SizedBox(height: 3),

                  // حقل الـ Token.
                  CustomTextField(
                    hint: 'Token',
                    icon: Icons.key,
                    controller: _tokenController,
                  ),

                  SizedBox(height: 50),

                  Center(
                    child: SavedBottom(
                      bottonName: 'Saved account',
                      containerColor: const Color.fromARGB(255, 96, 96, 96),
                      isloading: _isSaving,
                      ontap: _saveCredentials,
                    ),
                  ),

                  SizedBox(height: 10),

                  CustomBotton(
                    bottonName: 'Login',
                    containerColor: kTextColor,
                    ontap: _login,
                  ),
                  SizedBox(height: 10),

                  CustomBotton(
                    bottonName: 'Offline Mode',
                    containerColor: const Color.fromARGB(255, 96, 96, 96),
                    fontColor: Colors.white,
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OfflineModePage(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
