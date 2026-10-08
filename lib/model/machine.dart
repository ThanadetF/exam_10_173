import 'package:cloud_firestore/cloud_firestore.dart';

enum RiskLevel { normal, warning, critical }

/// เหมือนคลาส Student ในใบงาน แต่เก็บข้อมูลเครื่องจักร
class Machine {
  String id;
  String assetCode;
  String motorLine;
  String engineerEmail;
  double vibration; // mm/s RMS
  double temp; // °C
  double vibLimit; // เกณฑ์เตือนภัยความสั่นสะเทือน (เริ่มต้น 7.1 mm/s)
  double tempLimit; // เกณฑ์เตือนภัยอุณหภูมิ (เริ่มต้น 90 °C)
  String note; // บันทึกการอัดจารบี / หมายเหตุ

  Machine({
    this.id = '',
    required this.assetCode,
    required this.motorLine,
    required this.engineerEmail,
    required this.vibration,
    required this.temp,
    this.vibLimit = 7.1,
    this.tempLimit = 90,
    this.note = '',
  });

  RiskLevel get vibLevel => vibration >= vibLimit
      ? RiskLevel.critical
      : vibration >= vibLimit * 0.6
          ? RiskLevel.warning
          : RiskLevel.normal;

  RiskLevel get tempLevel => temp >= tempLimit
      ? RiskLevel.critical
      : temp >= tempLimit * 0.85
          ? RiskLevel.warning
          : RiskLevel.normal;

  RiskLevel get level =>
      vibLevel.index >= tempLevel.index ? vibLevel : tempLevel;

  static String labelOf(RiskLevel l) {
    if (l == RiskLevel.critical) return 'วิกฤต';
    if (l == RiskLevel.warning) return 'เฝ้าระวัง';
    return 'ปกติ';
  }

  Map<String, dynamic> toMap() => {
        'assetCode': assetCode,
        'motorLine': motorLine,
        'engineerEmail': engineerEmail,
        'vibration': vibration,
        'temp': temp,
        'vibLimit': vibLimit,
        'tempLimit': tempLimit,
        'note': note,
      };

  factory Machine.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Machine(
      id: doc.id,
      assetCode: d['assetCode'] ?? '',
      motorLine: d['motorLine'] ?? '',
      engineerEmail: d['engineerEmail'] ?? '',
      vibration: (d['vibration'] as num? ?? 0).toDouble(),
      temp: (d['temp'] as num? ?? 0).toDouble(),
      vibLimit: (d['vibLimit'] as num? ?? 7.1).toDouble(),
      tempLimit: (d['tempLimit'] as num? ?? 90).toDouble(),
      note: d['note'] ?? '',
    );
  }
}
