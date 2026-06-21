import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../shared.dart';
import '../db/database.dart';

class CptView extends StatefulWidget {
  const CptView({super.key});
  @override
  State<CptView> createState() => _CptViewState();
}

class _CptViewState extends State<CptView> {
  final _db = AppDatabase.instance;
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  final _search = TextEditingController();
  String _filterResult = 'All';

  static const _title = 'MISCELLANEOUS — CPT RESULTS';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _rows = await _db.getCptReport();
    if (mounted) setState(() => _loading = false);
  }

  String _s(Map m, String k) =>
      (m[k] ?? '').toString().trim().isEmpty ? '-' : m[k].toString();

  List<Map<String, dynamic>> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return _rows.where((r) {
      final matchesResult =
          _filterResult == 'All' || _s(r, 'result') == _filterResult;
      final matchesSearch = q.isEmpty ||
          _s(r, 'name').toLowerCase().contains(q) ||
          _s(r, 'army_no').toLowerCase().contains(q);
      return matchesResult && matchesSearch;
    }).toList();
  }

  Future<void> _print() async {
    final rows = _filtered;
    try {
      await Printing.layoutPdf(onLayout: (_) async {
        final pdf = pw.Document();
        pdf.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(28),
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
                  pw.TableHelper.fromTextArray(
                      headers: [
                        'S/No',
                        'Army No',
                        'Name',
                        'Rank',
                        'Coy',
                        'Result'
                      ],
                      data: List.generate(rows.length, (i) {
                        final r = rows[i];
                        return [
                          '${i + 1}',
                          _s(r, 'army_no'),
                          _s(r, 'name'),
                          _s(r, 'rank'),
                          _s(r, 'coy'),
                          _s(r, 'result')
                        ];
                      }),
                      headerStyle: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 9),
                      cellStyle: const pw.TextStyle(fontSize: 9),
                      headerDecoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      cellHeight: 20),
                  pw.SizedBox(height: 8),
                  pw.Text('Total Records: ${rows.length}',
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
    final rows = _filtered;
    return Column(children: [
      Container(
          color: kHeader,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(children: [
            Expanded(child: Text(_title, style: kSectionTitle)),
            Text('${rows.length} Record${rows.length != 1 ? "s" : ""}',
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
                              constraints: const BoxConstraints(maxWidth: 920),
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
                                        // Search + result filter
                                        Row(children: [
                                          Expanded(
                                              child: TextField(
                                                  controller: _search,
                                                  onChanged: (_) =>
                                                      setState(() {}),
                                                  style: kFieldStyle,
                                                  decoration: kDec(
                                                          'Search by name or army no...')
                                                      .copyWith(
                                                          prefixIcon: const Icon(
                                                              Icons.search,
                                                              size: 18,
                                                              color:
                                                                  kInkSoft)))),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                              width: 170,
                                              child: DropdownButtonFormField<
                                                      String>(
                                                  value: _filterResult,
                                                  isExpanded: true,
                                                  style: kFieldStyle.copyWith(
                                                      color: kInk),
                                                  items: ['All', ...kCptResults]
                                                      .map((o) => DropdownMenuItem(
                                                          value: o,
                                                          child: Text(o,
                                                              style:
                                                                  kFieldStyle)))
                                                      .toList(),
                                                  onChanged: (v) => setState(
                                                      () => _filterResult =
                                                          v ?? 'All'))),
                                        ]),
                                        const SizedBox(height: 20),
                                        rows.isEmpty
                                            ? const Center(
                                                child: Padding(
                                                    padding: EdgeInsets.all(20),
                                                    child: Text(
                                                        'No CPT records found.',
                                                        style: TextStyle(
                                                            color: kInkSoft,
                                                            fontSize: 13))))
                                            : Table(
                                                border: TableBorder.all(
                                                    color:
                                                        const Color(0xFFCCCFD4),
                                                    width: .6),
                                                columnWidths: const {
                                                    0: FixedColumnWidth(40),
                                                    1: FixedColumnWidth(100),
                                                    2: FlexColumnWidth(2),
                                                    3: FixedColumnWidth(80),
                                                    4: FixedColumnWidth(60),
                                                    5: FixedColumnWidth(100)
                                                  },
                                                children: [
                                                    TableRow(
                                                        decoration:
                                                            const BoxDecoration(
                                                                color: Color(
                                                                    0xFFE8EAED)),
                                                        children: [
                                                          'S/No',
                                                          'Army No',
                                                          'Name',
                                                          'Rank',
                                                          'Coy',
                                                          'Result'
                                                        ]
                                                            .map((h) => _th(h))
                                                            .toList()),
                                                    for (int i = 0;
                                                        i < rows.length;
                                                        i++)
                                                      TableRow(
                                                          decoration: BoxDecoration(
                                                              color: i.isEven
                                                                  ? Colors.white
                                                                  : const Color(
                                                                      0xFFF8F9FB)),
                                                          children: [
                                                            _td('${i + 1}'),
                                                            _td(
                                                                _s(rows[i],
                                                                    'army_no'),
                                                                bold: true),
                                                            _td(
                                                                _s(rows[i],
                                                                    'name'),
                                                                bold: true),
                                                            _td(_s(rows[i],
                                                                'rank')),
                                                            _td(_s(rows[i],
                                                                'coy')),
                                                            _tdBadge(_s(rows[i],
                                                                'result')),
                                                          ]),
                                                  ]),
                                        const SizedBox(height: 16),
                                        Text('Total: ${rows.length}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ]))))))),
    ]);
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
              color: kAccentBlueSoft,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: kAccentBlue.withOpacity(.35))),
          child: Text(t,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kAccentBlue))));
}
