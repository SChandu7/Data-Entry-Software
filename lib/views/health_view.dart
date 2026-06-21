import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../shared.dart';
import '../db/database.dart';

class HealthView extends StatefulWidget {
  final String subKey;
  const HealthView({super.key, required this.subKey});
  @override
  State<HealthView> createState() => _HealthViewState();
}

class _HealthViewState extends State<HealthView> {
  final _db = AppDatabase.instance;
  List<Map<String, dynamic>> _rawRows = [];
  List<Map<String, dynamic>> _pivotRows =
      []; // one row per soldier, for Weight Record mode
  bool _loading = true;

  String get _catVal => HealthSub.dbVal(widget.subKey);
  bool get _isWeight => isWeightCategory(_catVal);
  String get _title => _isWeight
      ? 'WEIGHT RECORD : ${HealthSub.label(widget.subKey).toUpperCase()}'
      : 'HEALTH RECORDS — ${HealthSub.label(widget.subKey).toUpperCase()}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(HealthView o) {
    super.didUpdateWidget(o);
    if (o.subKey != widget.subKey) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _rawRows = await _db.getHealthReport(category: _catVal);
    if (_isWeight) _pivotRows = _pivotByArmyNo(_rawRows);
    if (mounted) setState(() => _loading = false);
  }

  /// Combines multiple monthly Weight-Record submissions per soldier into
  /// one row: latest static fields (HT/IBW/ABW/etc) + a map of all months.
  List<Map<String, dynamic>> _pivotByArmyNo(List<Map<String, dynamic>> rows) {
    final byArmy = <String, Map<String, dynamic>>{};
    for (final r in rows) {
      final an = (r['army_no'] ?? '').toString();
      if (an.isEmpty) continue;
      final entry = byArmy.putIfAbsent(
          an,
          () => {
                'army_no': an,
                'name': r['name'],
                'rank': r['rank'],
                'coy': r['coy'],
                'ht': '-',
                'ibw': '-',
                'abw': '-',
                'pct10': '-',
                'bmi': '-',
                'weight_class': '-',
                'age': '-',
                'months': <String, String>{},
              });
      // rows are ordered by created_at DESC, so first time we see a field, it's the latest
      for (final f in [
        'ht',
        'ibw',
        'abw',
        'pct10',
        'bmi',
        'weight_class',
        'age'
      ]) {
        if ((entry[f] == '-') && _s(r, f) != '-') entry[f] = _s(r, f);
      }
      final month = (r['w_month'] ?? '').toString();
      final value = _s(r, 'w_value');
      if (month.isNotEmpty && !(entry['months'] as Map).containsKey(month)) {
        (entry['months'] as Map<String, String>)[month] = value;
      }
    }
    final list = byArmy.values.toList();
    list.sort(
        (a, b) => (a['army_no'] as String).compareTo(b['army_no'] as String));
    return list;
  }

  String _s(Map m, String k) =>
      (m[k] ?? '').toString().trim().isEmpty ? '-' : m[k].toString();

  Future<void> _print() async {
    try {
      await Printing.layoutPdf(onLayout: (_) async {
        final pdf = pw.Document();
        pdf.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (ctx) => [
                  pw.Center(
                      child: pw.Text(_title,
                          style: pw.TextStyle(
                              fontSize: 13, fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(height: 4),
                  pw.Center(
                      child: pw.Text(
                          DateFormat('dd MMM yyyy').format(DateTime.now()),
                          style: const pw.TextStyle(fontSize: 10))),
                  pw.SizedBox(height: 12),
                  if (_isWeight)
                    pw.TableHelper.fromTextArray(
                        headers: [
                          'S/No',
                          'Army No',
                          'Rank',
                          'Name',
                          'Coy',
                          'HT',
                          'IBW',
                          'ABW',
                          '+/-10%',
                          'BMI',
                          'Class',
                          'Age',
                          ...kMonths
                        ],
                        data: List.generate(_pivotRows.length, (i) {
                          final r = _pivotRows[i];
                          final months = r['months'] as Map<String, String>;
                          return [
                            '${i + 1}',
                            _s(r, 'army_no'),
                            _s(r, 'rank'),
                            _s(r, 'name'),
                            _s(r, 'coy'),
                            _s(r, 'ht'),
                            _s(r, 'ibw'),
                            _s(r, 'abw'),
                            _s(r, 'pct10'),
                            _s(r, 'bmi'),
                            _s(r, 'weight_class'),
                            _s(r, 'age'),
                            ...kMonths.map((m) => months[m] ?? '-')
                          ];
                        }),
                        headerStyle: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 6.5),
                        cellStyle: const pw.TextStyle(fontSize: 6.5),
                        headerDecoration:
                            const pw.BoxDecoration(color: PdfColors.grey300),
                        cellHeight: 18)
                  else
                    pw.TableHelper.fromTextArray(
                        headers: [
                          'S/No',
                          'Army No',
                          'Name',
                          'Rank',
                          'Coy',
                          'Category',
                          'Diagnosis',
                          'Hospital',
                          'Board Dt',
                          'Due On'
                        ],
                        data: List.generate(_rawRows.length, (i) {
                          final r = _rawRows[i];
                          return [
                            '${i + 1}',
                            _s(r, 'army_no'),
                            _s(r, 'name'),
                            _s(r, 'rank'),
                            _s(r, 'coy'),
                            healthCategoryLabel(_s(r, 'category')),
                            _s(r, 'diag'),
                            _s(r, 'hospital'),
                            _s(r, 'board_dt'),
                            _s(r, 'due_on')
                          ];
                        }),
                        headerStyle: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 8),
                        cellStyle: const pw.TextStyle(fontSize: 8),
                        headerDecoration:
                            const pw.BoxDecoration(color: PdfColors.grey300),
                        cellHeight: 20),
                  pw.SizedBox(height: 8),
                  pw.Text(
                      'Total: ${_isWeight ? _pivotRows.length : _rawRows.length}',
                      style: const pw.TextStyle(fontSize: 10)),
                ]));
        return pdf.save();
      });
    } catch (e) {
      if (mounted) showSnack(context, 'Print failed: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _isWeight ? _pivotRows.length : _rawRows.length;
    return Column(children: [
      Container(
          decoration: const BoxDecoration(
              color: kHeader,
              border: Border(bottom: BorderSide(color: kGold, width: 2.5))),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(children: [
            Expanded(child: Text(_title, style: kSectionTitle)),
            Text('$total Record${total != 1 ? "s" : ""}',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(width: 16),
            OutlinedButton.icon(
                onPressed: _print,
                icon: const Icon(Icons.print_outlined,
                    size: 16, color: Colors.white),
                label: const Text('Print / PDF',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8))),
          ])),
      Expanded(
          child: Container(
              color: const Color(0xFFD6D8DB),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 40),
                      child: Center(
                          child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: _isWeight ? 1400 : 920),
                              child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                            child: Text(_title,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w900))),
                                        const SizedBox(height: 4),
                                        Center(
                                            child: Text(
                                                DateFormat('dd MMM yyyy')
                                                    .format(DateTime.now()),
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: kInkSoft))),
                                        const SizedBox(height: 20),
                                        total == 0
                                            ? const Center(
                                                child: Padding(
                                                    padding: EdgeInsets.all(20),
                                                    child: Text(
                                                        'No records found.',
                                                        style: TextStyle(
                                                            color: kInkSoft,
                                                            fontSize: 13))))
                                            : (_isWeight
                                                ? SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: _weightTable())
                                                : _lmcTable()),
                                        const SizedBox(height: 16),
                                        Text('Total: $total',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ]))))))),
    ]);
  }

  Widget _lmcTable() => Table(
          border: TableBorder.all(color: const Color(0xFFCCCFD4), width: .6),
          columnWidths: const {
            0: FixedColumnWidth(40),
            1: FixedColumnWidth(95),
            2: FlexColumnWidth(2),
            3: FixedColumnWidth(70),
            4: FixedColumnWidth(45),
            5: FixedColumnWidth(75),
            6: FlexColumnWidth(2),
            7: FixedColumnWidth(85),
            8: FixedColumnWidth(85)
          },
          children: [
            TableRow(
                decoration: const BoxDecoration(color: Color(0xFFE8EAED)),
                children: [
                  'S/No',
                  'Army No',
                  'Name',
                  'Rank',
                  'Coy',
                  'Category',
                  'Diagnosis',
                  'Board Dt',
                  'Due On'
                ].map((h) => _th(h)).toList()),
            for (int i = 0; i < _rawRows.length; i++)
              TableRow(
                  decoration: BoxDecoration(
                      color: i.isEven ? Colors.white : const Color(0xFFF8F9FB)),
                  children: [
                    _td('${i + 1}'),
                    _td(_s(_rawRows[i], 'army_no'), bold: true),
                    _td(_s(_rawRows[i], 'name'), bold: true),
                    _td(_s(_rawRows[i], 'rank')),
                    _td(_s(_rawRows[i], 'coy')),
                    _tdBadge(healthCategoryLabel(_s(_rawRows[i], 'category'))),
                    _td(_s(_rawRows[i], 'diag')),
                    _td(_s(_rawRows[i], 'board_dt')),
                    _td(_s(_rawRows[i], 'due_on'))
                  ]),
          ]);

  Widget _weightTable() {
    final headers = [
      'S/No',
      'Army No',
      'Rank',
      'Name',
      'Coy',
      'HT',
      'IBW',
      'ABW',
      '+/-10%',
      'BMI',
      'Class',
      'Age',
      'Chart',
      ...kMonths
    ];
    return Table(
        border: TableBorder.all(color: const Color(0xFFCCCFD4), width: .6),
        defaultColumnWidth: const FixedColumnWidth(56),
        columnWidths: {
          0: const FixedColumnWidth(40),
          1: const FixedColumnWidth(85),
          2: const FixedColumnWidth(60),
          3: const FixedColumnWidth(130),
          4: const FixedColumnWidth(45),
          12: const FixedColumnWidth(56)
        },
        children: [
          TableRow(
              decoration: const BoxDecoration(color: Color(0xFFE8EAED)),
              children: headers.map((h) => _th(h)).toList()),
          for (int i = 0; i < _pivotRows.length; i++)
            TableRow(
                decoration: BoxDecoration(
                    color: i.isEven ? Colors.white : const Color(0xFFF8F9FB)),
                children: [
                  _td('${i + 1}'),
                  _td(_s(_pivotRows[i], 'army_no'), bold: true),
                  _td(_s(_pivotRows[i], 'rank')),
                  _td(_s(_pivotRows[i], 'name'), bold: true),
                  _td(_s(_pivotRows[i], 'coy')),
                  _td(_s(_pivotRows[i], 'ht')),
                  _td(_s(_pivotRows[i], 'ibw')),
                  _td(_s(_pivotRows[i], 'abw')),
                  _td(_s(_pivotRows[i], 'pct10')),
                  _td(_s(_pivotRows[i], 'bmi')),
                  _td(_s(_pivotRows[i], 'weight_class')),
                  _td(_s(_pivotRows[i], 'age')),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Center(
                          child: IconButton(
                              icon: const Icon(Icons.bar_chart_rounded,
                                  size: 19, color: kAccentBlue),
                              tooltip: 'View weight chart',
                              onPressed: () =>
                                  _showWeightChart(_pivotRows[i])))),
                  ...kMonths.map((m) => _td(
                      (_pivotRows[i]['months'] as Map<String, String>)[m] ??
                          '-')),
                ]),
        ]);
  }

  // ── Per-soldier monthly weight bar-chart popup ────────────────────────────
  void _showWeightChart(Map<String, dynamic> row) {
    final months = row['months'] as Map<String, String>;
    final name = _s(row, 'name');
    final armyNo = _s(row, 'army_no');
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kRadius)),
              child: Container(
                width: 640,
                padding: const EdgeInsets.all(20),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.bar_chart_rounded,
                            color: kAccentBlue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text('Weight Chart — $name ($armyNo)',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: kInk))),
                      ]),
                      const SizedBox(height: 4),
                      const Text('Monthly weight record (Jan – Dec)',
                          style: TextStyle(fontSize: 12, color: kInkSoft)),
                      const SizedBox(height: 18),
                      _monthlyBarChart(months),
                      const SizedBox(height: 20),
                      Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: FilledButton.styleFrom(
                                  backgroundColor: kSlate,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(kRadius))),
                              child: const Text('Close'))),
                    ]),
              ),
            ));
  }

  Widget _monthlyBarChart(Map<String, String> months) {
    const chartHeight = 190.0;
    final values = <double>[];
    for (final m in kMonths) {
      values.add(double.tryParse((months[m] ?? '').trim()) ?? 0);
    }
    final maxVal = values.fold<double>(0, (p, e) => e > p ? e : p);
    final scaleMax = maxVal <= 0 ? 1.0 : maxVal * 1.25;

    final bars = <Widget>[];
    for (int i = 0; i < kMonths.length; i++) {
      final v = values[i];
      final h =
          (v / scaleMax * (chartHeight - 44)).clamp(0.0, chartHeight - 44);
      final hasVal = v > 0;
      bars.add(Expanded(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
              hasVal
                  ? v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1)
                  : '-',
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w800, color: kInk)),
          const SizedBox(height: 4),
          Container(
            height: hasVal ? h : 2,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: hasVal ? kAccentBlue : kBorder,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(3)),
              boxShadow: hasVal
                  ? [
                      BoxShadow(
                          color: kAccentBlue.withOpacity(.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2))
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(kMonths[i],
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: kInkSoft)),
        ],
      )));
    }

    return Container(
      height: chartHeight,
      padding: const EdgeInsets.only(left: 8, right: 8, top: 6),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Color(0xFF8A8F99), width: 1.2),
          bottom: BorderSide(color: Color(0xFF8A8F99), width: 1.2),
        ),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: bars),
    );
  }

  Widget _th(String t) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      child: Text(t,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .3)));
  Widget _td(String t, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      child: Text(t,
          style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: kInk)));
  Widget _tdBadge(String t) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: const Color(0xFF1A3A1A).withOpacity(.12),
              borderRadius: BorderRadius.circular(4)),
          child: Text(t,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A3A1A)))));
}
