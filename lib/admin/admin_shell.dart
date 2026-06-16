import 'package:flutter/material.dart';
import '../shared.dart';
import 'leave_admin.dart';
import 'ere_admin.dart';
import 'health_admin.dart';
import 'out_strength_admin.dart';

class AdminShell extends StatelessWidget {
  final String subKey;
  const AdminShell({super.key, required this.subKey});

  @override
  Widget build(BuildContext context) {
    return switch(subKey){
      AdminSub.leave    => const LeaveAdmin(),
      AdminSub.health   => const HealthAdmin(),
      AdminSub.ere      => const EreAdmin(),
      AdminSub.outStr   => const OutStrengthAdmin(),
      _ => ComingSoon(label: AdminSub.label(subKey)),
    };
  }
}
