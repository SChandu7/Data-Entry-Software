import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../shared.dart';
import '../db/database.dart';
import '../db/models.dart';

class DomicileView extends StatefulWidget {
  final String domicile;
  const DomicileView({super.key, required this.domicile});
  @override
  State<DomicileView> createState() => _DomicileViewState();
}

class _DomicileViewState extends State<DomicileView> {
  final _db = AppDatabase.instance;
  List<OfficerModel> _off = [];
  List<JcoOrModel> _jco = [];
  bool _loading = true;
  String get _title => 'DOMICILE — ${widget.domicile.toUpperCase()}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(DomicileView o) {
    super.didUpdateWidget(o);
    if (o.domicile != widget.domicile) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _off = await _db.queryOfficers(domicile: widget.domicile);
    _jco = await _db.queryJco(domicile: widget.domicile);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _print() async {
    await Printing.layoutPdf(onLayout: (_) async {
      final pdf = pw.Document();
      pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (ctx) => [
                pw.Center(
                    child: pw.Text(_title,
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 4),
                pw.Center(
                    child: pw.Text(
                        DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: const pw.TextStyle(fontSize: 10))),
                pw.SizedBox(height: 10),
                pw.Text('OFFICERS',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 11)),
                pw.SizedBox(height: 4),
                pw.TableHelper.fromTextArray(
                    headers: ['S/No', 'IC No', 'Rank', 'Name'],
                    data: List.generate(_off.length, (i) {
                      final r = _off[i];
                      return [
                        '${i + 1}',
                        r.icNo ?? '-',
                        r.rank ?? '-',
                        r.name ?? '-'
                      ];
                    }),
                    headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 9),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    cellHeight: 20),
                pw.SizedBox(height: 10),
                pw.Text("JCOs/OR's",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 11)),
                pw.SizedBox(height: 4),
                pw.TableHelper.fromTextArray(
                    headers: ['S/No', 'Army No', 'Rank', 'Name', 'Coy'],
                    data: List.generate(_jco.length, (i) {
                      final r = _jco[i];
                      return [
                        '${i + 1}',
                        r.armyNo ?? '-',
                        r.rank ?? '-',
                        r.name ?? '-',
                        r.coy ?? '-'
                      ];
                    }),
                    headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 9),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    cellHeight: 20),
                pw.SizedBox(height: 8),
                pw.Text('Grand Total: ${_off.length + _jco.length}',
                    style: const pw.TextStyle(fontSize: 10)),
              ]));
      return pdf.save();
    });
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            color: kHeader,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(children: [
              Expanded(child: Text(_title, style: kSectionTitle)),
              Text('${_off.length + _jco.length} Total',
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
                                constraints:
                                    const BoxConstraints(maxWidth: 860),
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
                                                      fontSize: 16,
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
                                          _sec('Officers'),
                                          const SizedBox(height: 8),
                                          _offT(),
                                          const SizedBox(height: 20),
                                          _sec("JCOs / OR's"),
                                          const SizedBox(height: 8),
                                          _jcoT(),
                                          const SizedBox(height: 16),
                                          Text(
                                              'Grand Total: ${_off.length + _jco.length}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600)),
                                        ]))))))),
      ]);

  Widget _sec(String t) => Container(
      width: double.infinity,
      color: const Color(0xFFE8EAED),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(t.toUpperCase(),
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .5)));
  Widget _offT() {
    if (_off.isEmpty)
      return const Text('None.',
          style: TextStyle(color: kInkSoft, fontSize: 12));
    return Table(
        border: TableBorder.all(color: const Color(0xFFCCCFD4), width: .6),
        columnWidths: const {
          0: FixedColumnWidth(48),
          1: FixedColumnWidth(130),
          2: FixedColumnWidth(110),
          3: FlexColumnWidth()
        },
        children: [
          TableRow(
              decoration: const BoxDecoration(color: Color(0xFFE8EAED)),
              children: [_th('S/No'), _th('IC No'), _th('Rank'), _th('Name')]),
          for (int i = 0; i < _off.length; i++)
            TableRow(
                decoration: BoxDecoration(
                    color: i.isEven ? Colors.white : const Color(0xFFF8F9FB)),
                children: [
                  _td('${i + 1}'),
                  _td(_off[i].icNo ?? '-'),
                  _td(_off[i].rank ?? '-'),
                  _td(_off[i].name ?? '-', bold: true)
                ]),
        ]);
  }

  Widget _jcoT() {
    if (_jco.isEmpty)
      return const Text('None.',
          style: TextStyle(color: kInkSoft, fontSize: 12));
    return Table(
        border: TableBorder.all(color: const Color(0xFFCCCFD4), width: .6),
        columnWidths: const {
          0: FixedColumnWidth(48),
          1: FixedColumnWidth(130),
          2: FixedColumnWidth(110),
          3: FlexColumnWidth(),
          4: FixedColumnWidth(60)
        },
        children: [
          TableRow(
              decoration: const BoxDecoration(color: Color(0xFFE8EAED)),
              children: [
                _th('S/No'),
                _th('Army No'),
                _th('Rank'),
                _th('Name'),
                _th('Coy')
              ]),
          for (int i = 0; i < _jco.length; i++)
            TableRow(
                decoration: BoxDecoration(
                    color: i.isEven ? Colors.white : const Color(0xFFF8F9FB)),
                children: [
                  _td('${i + 1}'),
                  _td(_jco[i].armyNo ?? '-'),
                  _td(_jco[i].rank ?? '-'),
                  _td(_jco[i].name ?? '-', bold: true),
                  _td(_jco[i].coy ?? '-')
                ]),
        ]);
  }

  Widget _th(String t) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Text(t,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .3)));
  Widget _td(String t, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Text(t,
          style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: kInk)));
}
