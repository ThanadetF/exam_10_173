import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  bool _isRegister = false;
  bool _loading = false;
  bool _hidePass = true;
  String _name = '';
  String _email = '';
  String _password = '';

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      if (_isRegister) {
        await AuthController.register(
            name: _name, email: _email, password: _password);
      } else {
        await AuthController.login(_email, _password);
      }
    } on FirebaseAuthException catch (e) {
      _toast(AuthController.message(e));
    } on FirebaseException catch (e) {
      _toast('บันทึกโปรไฟล์ไม่สำเร็จ: ${e.message}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // หัวหน้า: คลื่นสัญญาณเป็นพื้นหลัง
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 36, 24, 36),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.ink, AppColors.inkSoft],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(child: CustomPaint(painter: WavePainter())),
                  Column(
                    children: [
                      const BrandLogo(size: 84),
                      const SizedBox(height: 18),
                      const Text('PredictIQ',
                          style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      Text(
                        'ตรวจจับความสั่นสะเทือนและความร้อนของมอเตอร์\nก่อนเกิดความเสียหาย',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withAlpha(190), height: 1.4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isRegister ? 'สร้างบัญชีผู้ใช้' : 'เข้าสู่ระบบ',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink)),
                        const SizedBox(height: 18),
                        if (_isRegister) ...[
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'ชื่อ-นามสกุล',
                                prefixIcon: Icon(Icons.badge_outlined)),
                            validator: RequiredValidator(
                                errorText: 'กรุณาป้อนชื่อด้วยครับ'),
                            onSaved: (v) => _name = v!.trim(),
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              labelText: 'อีเมล',
                              prefixIcon: Icon(Icons.mail_outline)),
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'กรุณาป้อนอีเมลด้วยครับ'),
                            EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
                          ]),
                          onSaved: (v) => _email = v!,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          obscureText: _hidePass,
                          decoration: InputDecoration(
                            labelText: 'รหัสผ่าน',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_hidePass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () =>
                                  setState(() => _hidePass = !_hidePass),
                            ),
                          ),
                          validator: MultiValidator([
                            RequiredValidator(
                                errorText: 'กรุณาป้อนรหัสผ่านด้วยครับ'),
                            MinLengthValidator(6,
                                errorText: 'รหัสผ่านอย่างน้อย 6 ตัวอักษร'),
                          ]),
                          onSaved: (v) => _password = v!,
                        ),
                        if (_isRegister) ...[
                          const SizedBox(height: 8),
                          const Text(
                              'บัญชีที่สมัครใหม่เป็น Operator เสมอ สิทธิ์ Admin กำหนดโดยผู้ดูแลระบบ',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.steel)),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white))
                              : Text(_isRegister ? 'สร้างบัญชี' : 'เข้าสู่ระบบ'),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              formKey.currentState?.reset();
                              setState(() => _isRegister = !_isRegister);
                            },
                            child: Text(_isRegister
                                ? 'มีบัญชีแล้ว? เข้าสู่ระบบ'
                                : 'ยังไม่มีบัญชี? สมัครใช้งาน'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
