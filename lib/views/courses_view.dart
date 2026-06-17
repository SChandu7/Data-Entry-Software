import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../shared.dart';
import '../db/database.dart';
import '../db/models.dart';

class CoursesView extends StatefulWidget {
  final String courseKey;
  const CoursesView({super.key, required this.courseKey});
  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final _db = AppDatabase.instance;
  // Unified row representation so BSW (Officers + JCO/OR) and other
  // courses (JCO/OR only) can share the same table/print logic.
  List<Map<String, String>> _rows = [];
  bool _loading = true;

  String get _dbCol => CrsSub.dbCol(widget.courseKey);
  String get _gradeCol => '${_dbCol}_g';
  String get _title => 'COURSE : ${CrsSub.label(widget.courseKey).toUpperCase()}';
  bool get _isBsw => widget.courseKey == CrsSub.bsw;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void didUpdateWidget(CoursesView o) {
    super.didUpdateWidget(o);
    if (o.courseKey != widget.courseKey) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = <Map<String, String>>[];

    if (_isBsw) {
      // BSW exists on both Officers and JCO/OR — pull from both, combine.
      final offs = await _db.queryOfficers(courseField: _dbCol);
      for (final r in offs) {
        final m = r.toMap();
        rows.add({
          'no': r.icNo ?? '-', 'rank': r.rank ?? '-', 'name': r.name ?? '-',
          'coy': '-', 'date': m[_dbCol]?.toString() ?? '-',
          'grade': m[_gradeCol]?.toString() ?? '-', 'type': 'Officer',
        });
      }
      final jcos = await _db.queryJco(courseField: _dbCol);
      for (final r in jcos) {
        final m = r.toMap();
        rows.add({
          'no': r.armyNo ?? '-', 'rank': r.rank ?? '-', 'name': r.name ?? '-',
          'coy': r.coy ?? '-', 'date': m[_dbCol]?.toString() ?? '-',
          'grade': m[_gradeCol]?.toString() ?? '-', 'type': 'JCO/OR',
        });
      }
    } else {
      final jcos = await _db.queryJco(courseField: _dbCol);
      for (final r in jcos) {
        final m = r.toMap();
        rows.add({
          'no': r.armyNo ?? '-', 'rank': r.rank ?? '-', 'name': r.name ?? '-',
          'coy': r.coy ?? '-', 'date': m[_dbCol]?.toString() ?? '-',
          'grade': m[_gradeCol]?.toString() ?? '-', 'type': 'JCO/OR',
        });
      }
    }

    if (mounted) setState(() { _rows = rows; _loading = false; });
  }

  Future<void> _print() async {
    try {
      await Printing.layoutPdf(onLayout: (_) async {
        final pdf = pw.Document();
        final headers = _isBsw
            ? ['S/No', 'No', 'Rank', 'Name', 'Coy', 'Type', 'Date', 'Grading']
            : ['S/No', 'Army No', 'Rank', 'Name', 'Coy', 'Date', 'Grading'];
        pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (ctx) => [
            pw.Center(child: pw.Text(_title,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 4),
            pw.Center(child: pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now()),
                style: const pw.TextStyle(fontSize: 10))),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: List.generate(_rows.length, (i) {
                final r = _rows[i];
                return _isBsw
                    ? ['${i+1}', r['no'], r['rank'], r['name'], r['coy'], r['type'], r['date'], r['grade']]
                    : ['${i+1}', r['no'], r['rank'], r['name'], r['coy'], r['date'], r['grade']];
              }),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 22,
            ),
            pw.SizedBox(height: 8),
            pw.Text('Total: ${_rows.length}', style: const pw.TextStyle(fontSize: 10)),
          ],
        ));
        return pdf.save();
      });
    } catch (e) {
      if (mounted) showSnack(context, 'Print failed: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(color: kHeader, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(children: [
          Expanded(child: Text(_title, style: kSectionTitle)),
          Text('${_rows.length} Record${_rows.length != 1 ? "s" : ""}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(width: 16),
          OutlinedButton.icon(onPressed: _print,
            icon: const Icon(Icons.print_outlined, size: 16, color: Colors.white),
            label: const Text('Print / PDF', style: TextStyle(color: Colors.white, fontSize: 12)),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8))),
        ])),
      Expanded(child: Container(
        color: const Color(0xFFD6D8DB),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
                child: Center(child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Container(
                    color: Colors.white, padding: const EdgeInsets.all(32),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Center(child: Text(_title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
                      const SizedBox(height: 4),
                      Center(child: Text(DateFormat('dd MMM yyyy').format(DateTime.now()),
                          style: const TextStyle(fontSize: 11, color: kInkSoft))),
                      if (_isBsw) ...[
                        const SizedBox(height: 6),
                        const Center(child: Text('(Combined — Officers + JCOs/OR)',
                            style: TextStyle(fontSize: 10, color: kInkSoft, fontStyle: FontStyle.italic))),
                      ],
                      const SizedBox(height: 20),
                      _rows.isEmpty
                          ? const Center(child: Padding(padding: EdgeInsets.all(20),
                              child: Text('No records.', style: TextStyle(color: kInkSoft))))
                          : _isBsw ? _bswTable() : _stdTable(),
                      const SizedBox(height: 16),
                      Text('Total: ${_rows.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ))),
      )),
    ]);
  }

  Widget _stdTable() => Table(
      border: TableBorder.all(color: const Color(0xFFCCCFD4), width: .6),
      columnWidths: const {
        0: FixedColumnWidth(48), 1: FixedColumnWidth(120), 2: FixedColumnWidth(100),
        3: FlexColumnWidth(), 4: FixedColumnWidth(60), 5: FixedColumnWidth(110),
        6: FixedColumnWidth(80),
      },
      children: [
        TableRow(decoration: const BoxDecoration(color: Color(0xFFE8EAED)),
          children: ['S/No','Army No','Rank','Name','Coy','Date','Grading'].map((h) => _th(h)).toList()),
        for (int i = 0; i < _rows.length; i++)
          TableRow(
            decoration: BoxDecoration(color: i.isEven ? Colors.white : const Color(0xFFF8F9FB)),
            children: [
              _td('${i+1}'), _td(_rows[i]['no']!, bold: true), _td(_rows[i]['rank']!),
              _td(_rows[i]['name']!, bold: true), _td(_rows[i]['coy']!),
              _td(_rows[i]['date']!), _tdGrade(_rows[i]['grade']!),
            ]),
      ]);

  Widget _bswTable() => Table(
      border: TableBorder.all(color: const Color(0xFFCCCFD4), width: .6),
      columnWidths: const {
        0: FixedColumnWidth(48), 1: FixedColumnWidth(110), 2: FixedColumnWidth(90),
        3: FlexColumnWidth(), 4: FixedColumnWidth(55), 5: FixedColumnWidth(75),
        6: FixedColumnWidth(100), 7: FixedColumnWidth(80),
      },
      children: [
        TableRow(decoration: const BoxDecoration(color: Color(0xFFE8EAED)),
          children: ['S/No','No','Rank','Name','Coy','Type','Date','Grading'].map((h) => _th(h)).toList()),
        for (int i = 0; i < _rows.length; i++)
          TableRow(
            decoration: BoxDecoration(color: i.isEven ? Colors.white : const Color(0xFFF8F9FB)),
            children: [
              _td('${i+1}'), _td(_rows[i]['no']!, bold: true), _td(_rows[i]['rank']!),
              _td(_rows[i]['name']!, bold: true), _td(_rows[i]['coy']!),
              _tdType(_rows[i]['type']!), _td(_rows[i]['date']!), _tdGrade(_rows[i]['grade']!),
            ]),
      ]);

  Widget _th(String t) => Padding(padding: const EdgeInsets.symmetric(horizontal:8,vertical:7),
      child: Text(t, style: const TextStyle(fontSize:11, fontWeight: FontWeight.w800, letterSpacing:.3)));
  Widget _td(String t, {bool bold=false}) => Padding(padding: const EdgeInsets.symmetric(horizontal:8,vertical:7),
      child: Text(t, style: TextStyle(fontSize:12, fontWeight: bold?FontWeight.w600:FontWeight.normal, color:kInk)));
  Widget _tdGrade(String g) => Padding(padding: const EdgeInsets.symmetric(horizontal:8,vertical:5),
      child: g == '-' ? Text(g, style: const TextStyle(fontSize:12,color:kInkSoft))
          : Container(padding: const EdgeInsets.symmetric(horizontal:6,vertical:2),
              decoration: BoxDecoration(color: const Color(0xFF1A3A1A), borderRadius: BorderRadius.circular(4)),
              child: Text(g, style: const TextStyle(fontSize:11, fontWeight:FontWeight.w700, color:Colors.white))));
  Widget _tdType(String t) => Padding(padding: const EdgeInsets.symmetric(horizontal:8,vertical:5),
      child: Container(padding: const EdgeInsets.symmetric(horizontal:6,vertical:2),
          decoration: BoxDecoration(color: kSlate.withOpacity(.12), borderRadius: BorderRadius.circular(4)),
          child: Text(t, style: const TextStyle(fontSize:10, fontWeight:FontWeight.w700, color:kSlate))));
}