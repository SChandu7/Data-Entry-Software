import 'package:flutter/material.dart';
import '../shared.dart';
import '../db/database.dart';

class ArmySearchBox extends StatefulWidget {
  final void Function(String armyNo, String name, String rank, String coy)
      onSelected;
  const ArmySearchBox({super.key, required this.onSelected});
  @override
  State<ArmySearchBox> createState() => _ArmySearchBoxState();
}

class _ArmySearchBoxState extends State<ArmySearchBox> {
  final _db = AppDatabase.instance;
  final _ctrl = TextEditingController();
  List<Map<String, String>> _suggestions = [];
  bool _showSugg = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _query(String q) async {
    if (q.length < 2) {
      setState(() {
        _suggestions = [];
        _showSugg = false;
      });
      return;
    }
    final res = await _db.searchArmyNo(q);
    if (mounted)
      setState(() {
        _suggestions = res;
        _showSugg = res.isNotEmpty;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: const Text('SELECT SOLDIER (ARMY NO / NAME)',
                  style: kLabelStyle)),
          TextField(
              controller: _ctrl,
              style: kFieldStyle,
              decoration: kDec('Type Army No or Name...')
                  .copyWith(prefixIcon: const Icon(Icons.search, size: 18)),
              onChanged: _query),
          if (_showSugg)
            Container(
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                    color: kSurface,
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(6)),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _suggestions
                        .map((s) => InkWell(
                            onTap: () {
                              _ctrl.text = '${s['army_no']} — ${s['name']}';
                              setState(() => _showSugg = false);
                              widget.onSelected(s['army_no']!, s['name']!,
                                  s['rank']!, s['coy']!);
                            },
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 9),
                                child: Row(children: [
                                  Text(s['army_no'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: kInk)),
                                  const SizedBox(width: 10),
                                  Text('${s['rank']} ${s['name']}',
                                      style: const TextStyle(
                                          fontSize: 12, color: kInk)),
                                  const Spacer(),
                                  Text('Coy ${s['coy']}',
                                      style: const TextStyle(
                                          fontSize: 11, color: kInkSoft)),
                                ]))))
                        .toList())),
        ]);
  }
}
