import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/app_user.dart';
import '../model/machine.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/profile_menu.dart';

class DisplayScreen extends StatefulWidget {
  final AppUser user;
  const DisplayScreen({super.key, required this.user});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  final _firestore = FirebaseFirestore.instance;
  RiskLevel? _filter;

  // ทุกสิทธิ์อ่านรายการได้แบบ Real-time (Read)
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream =
      _firestore.collection('machine').snapshots();

  // ---------- ลบ (เฉพาะ admin) ----------
  Future<void> _confirmDelete(Machine m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบข้อมูล'),
        content: Text(
            'ต้องการลบ ${m.assetCode} ออกจากรายการเฝ้าระวัง (ซ่อมเสร็จแล้ว) จริงๆ ใช่ไหม'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ลบ',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _firestore.collection('machine').doc(m.id).delete();
    } on FirebaseException catch (e) {
      _toast('ลบไม่สำเร็จ: ${e.message}');
    }
  }

  // ---------- แก้ไข ----------
  Future<void> _showEditSheet(Machine m) async {
    final editKey = GlobalKey<FormState>();
    final isAdmin = widget.user.isAdmin; // หน้านี้เปิดได้เฉพาะ Admin
    double vib = m.vibration, temp = m.temp;
    double vibLimit = m.vibLimit, tempLimit = m.tempLimit;
    String note = m.note;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Form(
          key: editKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('แก้ไข ${m.assetCode}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink)),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: m.vibration.toString(),
                  keyboardType: decimalKeyboard,
                  inputFormatters: decimalFormatters,
                  decoration: const InputDecoration(
                      labelText: 'ค่าความสั่นสะเทือน', suffixText: 'mm/s RMS'),
                  validator: numberValidator('กรุณาป้อนค่าความสั่นสะเทือน'),
                  onSaved: (v) => vib = double.parse(v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: m.temp.toString(),
                  keyboardType: decimalKeyboard,
                  inputFormatters: decimalFormatters,
                  decoration: const InputDecoration(
                      labelText: 'อุณหภูมิตลับลูกปืน', suffixText: '°C'),
                  validator: numberValidator('กรุณาป้อนอุณหภูมิ'),
                  onSaved: (v) => temp = double.parse(v!),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: m.vibLimit.toString(),
                    keyboardType: decimalKeyboard,
                    inputFormatters: decimalFormatters,
                    decoration: const InputDecoration(
                        labelText: 'เกณฑ์เตือนภัยความสั่นสะเทือน',
                        suffixText: 'mm/s'),
                    validator: numberValidator('ป้อนเกณฑ์ความสั่นสะเทือน'),
                    onSaved: (v) => vibLimit = double.parse(v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: m.tempLimit.toString(),
                    keyboardType: decimalKeyboard,
                    inputFormatters: decimalFormatters,
                    decoration: const InputDecoration(
                        labelText: 'เกณฑ์เตือนภัยอุณหภูมิ', suffixText: '°C'),
                    validator: numberValidator('ป้อนเกณฑ์อุณหภูมิ'),
                    onSaved: (v) => tempLimit = double.parse(v!),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: m.note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'บันทึกการอัดจารบี / หมายเหตุ',
                      hintText: 'เช่น อัดจารบี 25 g วันที่ 7 ต.ค.'),
                  onSaved: (v) => note = (v ?? '').trim(),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () async {
                    if (!editKey.currentState!.validate()) return;
                    editKey.currentState!.save();
                    final data = <String, dynamic>{
                      'vibration': vib,
                      'temp': temp,
                      'note': note,
                      'updatedAt': FieldValue.serverTimestamp(),
                      'updatedBy': widget.user.email,
                      if (isAdmin) 'vibLimit': vibLimit,
                      if (isAdmin) 'tempLimit': tempLimit,
                    };
                    try {
                      await _firestore
                          .collection('machine')
                          .doc(m.id)
                          .update(data);
                      if (ctx.mounted) Navigator.pop(ctx);
                    } on FirebaseException catch (e) {
                      _toast('แก้ไขไม่สำเร็จ: ${e.message}');
                    }
                  },
                  child: const Text('บันทึกการแก้ไข'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
        content: Text(msg)));
  }

  // ---------- UI ----------
  Widget _card(Machine m) {
    final color = AppColors.of(m.vibLevel);
    final tempColor =
        m.tempLevel == RiskLevel.normal ? AppColors.ink : AppColors.of(m.tempLevel);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: m.level == RiskLevel.normal ? AppColors.line : AppColors.of(m.level).withAlpha(140),
            width: m.level == RiskLevel.critical ? 1.6 : 1),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            leading: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2.5),
              ),
              child: CircleAvatar(
                radius: 27,
                backgroundColor: color.withAlpha(28),
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(m.vibration.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: color)),
                      Text('mm/s',
                          style: TextStyle(fontSize: 9, color: color)),
                    ]),
                  ),
                ),
              ),
            ),
            title: Text(m.assetCode,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.ink)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.motorLine,
                      style: const TextStyle(color: AppColors.steel)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.thermostat, size: 16, color: tempColor),
                        const SizedBox(width: 2),
                        Text('${m.temp.toStringAsFixed(1)} °C',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, color: tempColor)),
                      ]),
                      _LevelChip(level: m.level),
                    ],
                  ),
                  if (m.note.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.build_circle_outlined,
                            size: 16, color: AppColors.steel),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(m.note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.steel))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (widget.user.isAdmin)
            Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.user.isAdmin) ...[
                  TextButton.icon(
                    onPressed: () => _showEditSheet(m),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('แก้ไข'),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(m),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('ลบ'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เฝ้าระวังเครื่องจักรเสี่ยง'),
        actions: [ProfileMenu(user: widget.user), const SizedBox(width: 8)],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _Notice(
                icon: Icons.error_outline,
                text: 'โหลดข้อมูลไม่สำเร็จ: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data!.docs.map(Machine.fromDoc).toList()
            ..sort((a, b) => b.vibration.compareTo(a.vibration));
          int count(RiskLevel l) => all.where((m) => m.level == l).length;
          final shown =
              _filter == null ? all : all.where((m) => m.level == _filter).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(children: [
                  for (final l in [
                    RiskLevel.critical,
                    RiskLevel.warning,
                    RiskLevel.normal
                  ]) ...[
                    Expanded(
                      child: _SummaryTile(
                        level: l,
                        count: count(l),
                        selected: _filter == l,
                        onTap: () =>
                            setState(() => _filter = _filter == l ? null : l),
                      ),
                    ),
                    if (l != RiskLevel.normal) const SizedBox(width: 10),
                  ]
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Row(children: [
                  const Icon(Icons.sort, size: 16, color: AppColors.steel),
                  const SizedBox(width: 6),
                  const Text('เรียงจากความสั่นสะเทือนสูงสุด',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.steel)),
                ]),
              ),
              Expanded(
                child: shown.isEmpty
                    ? const _Notice(
                        icon: Icons.check_circle_outline,
                        text: 'ยังไม่มีรายการในสถานะนี้\nบันทึกผลวินิจฉัยได้ที่แท็บแรก')
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: shown.length,
                        itemBuilder: (context, i) => _card(shown[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final RiskLevel level;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  const _SummaryTile(
      {required this.level,
      required this.count,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(level);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? c.withAlpha(32) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? c : AppColors.line, width: selected ? 2 : 1),
        ),
        child: Column(children: [
          Text('$count',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: c)),
          Text(Machine.labelOf(level),
              style: const TextStyle(fontSize: 12, color: AppColors.steel)),
        ]),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final RiskLevel level;
  const _LevelChip({required this.level});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: c.withAlpha(30), borderRadius: BorderRadius.circular(20)),
      child: Text(Machine.labelOf(level),
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: c)),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Notice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 48, color: AppColors.steel),
          const SizedBox(height: 12),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.steel, height: 1.4)),
        ]),
      ),
    );
  }
}
