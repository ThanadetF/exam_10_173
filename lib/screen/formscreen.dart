import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../model/app_user.dart';
import '../model/machine.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/profile_menu.dart';

class FormScreen extends StatefulWidget {
  final AppUser user;
  const FormScreen({super.key, required this.user});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen>
    with AutomaticKeepAliveClientMixin {
  final formKey = GlobalKey<FormState>();
  Machine myMachine = Machine(
      assetCode: '',
      motorLine: '',
      engineerEmail: '',
      vibration: 0,
      temp: 0);
  final CollectionReference _machineCollection =
      FirebaseFirestore.instance.collection('machine');
  bool _saving = false;

  @override
  bool get wantKeepAlive => true; // ไม่ให้ข้อมูลในฟอร์มหายเมื่อสลับแท็บ

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    setState(() => _saving = true);
    try {
      await _machineCollection.add({
        ...myMachine.toMap(),
        'createdBy': widget.user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      formKey.currentState!.reset();
      if (!mounted) return;
      final level = Machine.labelOf(myMachine.level);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.of(myMachine.level),
          content: Text('บันทึก ${myMachine.assetCode} แล้ว สถานะ: $level'),
        ));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
        content: Text('บันทึกไม่สำเร็จ: ${e.message}'),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink)),
          ]),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกผลวินิจฉัยเครื่องจักร'),
        actions: [ProfileMenu(user: widget.user), const SizedBox(width: 8)],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('ข้อมูลเครื่องจักร', Icons.precision_manufacturing_outlined, [
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                      labelText: 'หมายเลขเครื่องจักร (Machine Asset Code)',
                      hintText: 'เช่น PUMP-HEAVY-01'),
                  validator: RequiredValidator(
                      errorText: 'กรุณาป้อนหมายเลขเครื่องจักรด้วยครับ'),
                  onSaved: (v) => myMachine.assetCode = v!.trim(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'รุ่นมอเตอร์และตำแหน่งไลน์ผลิต',
                      hintText: 'เช่น ABB M3BP 315, ไลน์ผลิต 2'),
                  validator: RequiredValidator(
                      errorText: 'กรุณาป้อนรุ่นมอเตอร์และตำแหน่งไลน์ด้วยครับ'),
                  onSaved: (v) => myMachine.motorLine = v!.trim(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'อีเมลวิศวกรซ่อมบำรุง (Reliability Engineer)'),
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'กรุณาป้อนอีเมลด้วยครับ'),
                    EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
                  ]),
                  onSaved: (v) => myMachine.engineerEmail = v!.trim(),
                ),
              ]),
              _section('ค่าตรวจวัด', Icons.vibration, [
                TextFormField(
                  keyboardType: decimalKeyboard,
                  inputFormatters: decimalFormatters,
                  decoration: const InputDecoration(
                      labelText: 'ค่าความสั่นสะเทือนรวม (Vibration Velocity)',
                      suffixText: 'mm/s RMS'),
                  validator: numberValidator('กรุณาป้อนค่าความสั่นสะเทือนด้วยครับ'),
                  onSaved: (v) => myMachine.vibration = double.parse(v!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  keyboardType: decimalKeyboard,
                  inputFormatters: decimalFormatters,
                  decoration: const InputDecoration(
                      labelText: 'อุณหภูมิผิวตลับลูกปืน (Bearing Temp)',
                      suffixText: '°C'),
                  validator: numberValidator('กรุณาป้อนอุณหภูมิด้วยครับ'),
                  onSaved: (v) => myMachine.temp = double.parse(v!),
                ),
                const SizedBox(height: 10),
                const Text(
                    'เกณฑ์เริ่มต้น: วิกฤตที่ 7.1 mm/s หรือ 90 °C, เฝ้าระวังเมื่อถึงประมาณ 60% และ 85% ของเกณฑ์ Admin ปรับเกณฑ์ได้ที่แท็บรายการ',
                    style: TextStyle(fontSize: 12, color: AppColors.steel)),
              ]),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : const Icon(Icons.save_outlined),
                label: const Text('บันทึกข้อมูล'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
