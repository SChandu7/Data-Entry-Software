import 'package:flutter/material.dart';
import '../shared.dart';
import '../db/database.dart';
import '../db/admin_models.dart';
import 'army_search.dart';

class CptAdmin extends StatefulWidget {
  const CptAdmin({super.key});
  @override
  State<CptAdmin> createState() => _CptAdminState();
}

class _CptAdminState extends State<CptAdmin> {
  final _db = AppDatabase.instance;
  String? _armyNo, _soldierName, _soldierRank, _soldierCoy;
  bool _saving = false;
  String? _result;
  List<CptRecord> _history = [];

  Future<void> _onSoldierSelected(
      String an, String nm, String rk, String cy) async {
    setState(() {
      _armyNo = an;
      _soldierName = nm;
      _soldierRank = rk;
      _soldierCoy = cy;
    });
    _history = await _db.getCptByArmyNo(an);
    setState(() {});
  }

  Future<void> _submit() async {
    if (_armyNo == null) {
      showSnack(context, 'Select a soldier first.', error: true);
      return;
    }
    if (_result == null) {
      showSnack(context, 'Select a result.', error: true);
      return;
    }
    setState(() => _saving = true);
    final rec = CptRecord(armyNo: _armyNo!)..result = _result;
    await _db.insertCpt(rec);
    _history = await _db.getCptByArmyNo(_armyNo!);
    setState(() {
      _result = null;
    });
    if (mounted) {
      showSnack(context, 'CPT result added.');
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          color: kHeader,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Text('CPT RESULTS', style: kSectionTitle)),
      Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 480,
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ArmySearchBox(onSelected: _onSoldierSelected),
                      if (_armyNo != null) ...[
                        const SizedBox(height: 10),
                        Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: kAccentBlueSoft,
                                borderRadius: BorderRadius.circular(kRadius),
                                border: Border.all(
                                    color: kAccentBlue.withOpacity(.35))),
                            child: Text(
                                '$_soldierRank $_soldierName — $_armyNo — Coy $_soldierCoy',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: kSlate))),
                      ],
                      const SizedBox(height: 16),
                      const SectionHeader('Add CPT Result'),
                      const SizedBox(height: 12),
                      _dd('Result', _result, kCptResults,
                          (v) => setState(() => _result = v)),
                      const SizedBox(height: 16),
                      SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                              onPressed: _saving ? null : _submit,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: kInk))
                                  : const Icon(Icons.save_outlined,
                                      size: 18, color: kInk),
                              label: const Text('Submit Result',
                                  style: TextStyle(
                                      color: kInk,
                                      fontWeight: FontWeight.w800)),
                              style: FilledButton.styleFrom(
                                  backgroundColor: kGold,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(kRadius))))),
                    ]))),
        Container(width: 1, color: kBorder),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: double.infinity,
              color: kSilver1,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text(
                  _armyNo == null
                      ? 'CPT History'
                      : 'CPT History — $_soldierName',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13, color: kInk))),
          Expanded(
              child: _history.isEmpty
                  ? const Center(
                      child: Text('Select a soldier to see history.',
                          style: TextStyle(color: kInkSoft)))
                  : ListView.separated(
                      itemCount: _history.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: kBorder),
                      itemBuilder: (_, i) {
                        final r = _history[i];
                        return ListTile(
                            leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                    color: kAccentBlueSoft,
                                    borderRadius: BorderRadius.circular(22)),
                                child: const Icon(Icons.fitness_center_outlined,
                                    size: 22, color: kAccentBlue)),
                            title: Text(r.result ?? '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                            subtitle: Text(
                                r.createdAt != null
                                    ? r.createdAt!.substring(0, 10)
                                    : '-',
                                style: const TextStyle(fontSize: 11)),
                            trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: kDanger),
                                onPressed: () async {
                                  final ok = await confirmDialog(context,
                                      'Delete', 'Remove this CPT result?');
                                  if (!ok) return;
                                  await _db.deleteCpt(r.id!);
                                  _history = await _db.getCptByArmyNo(_armyNo!);
                                  setState(() {});
                                }));
                      })),
        ])),
      ])),
    ]);
  }

  Widget _dd(
          String l, String? v, List<String> opts, void Function(String?) cb) =>
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(l.toUpperCase(), style: kLabelStyle)),
            DropdownButtonFormField<String>(
                value: v,
                isExpanded: true,
                style: kFieldStyle.copyWith(color: kInk),
                items: opts
                    .map((o) => DropdownMenuItem(
                        value: o, child: Text(o, style: kFieldStyle)))
                    .toList(),
                onChanged: cb)
          ]);
}
