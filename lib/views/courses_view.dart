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
  List<JcoOrModel> _records = [];
  bool _loading = true;

  String get _dbCol => CrsSub.dbCol(widget.courseKey);
  String get _gradeCol => '${_dbCol}_g';
  String get _title =>
      'COURSE : ${CrsSub.label(widget.courseKey).toUpperCase()}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CoursesView o) {
    super.didUpdateWidget(o);
    if (o.courseKey != widget.courseKey) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _db.queryJco(courseField: _dbCol);
    if (mounted)
      setState(() {
        _records = list;
        _loading = false;
      });
  }

  String _grade(JcoOrModel r) => r.toMap()[_gradeCol]?.toString() ?? '-';
  String _date(JcoOrModel r) => r.toMap()[_dbCol]?.toString() ?? '-';

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
              child: pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 10))),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: [
              'S/No',
              'Army No',
              'Rank',
              'Name',
              'Coy',
              'Date',
              'Grading',
              'Remarks'
            ],
            data: List.generate(_records.length, (i) {
              final r = _records[i];
              return [
                '${i + 1}',
                r.armyNo ?? '-',
                r.rank ?? '-',
                r.name ?? '-',
                r.coy ?? '-',
                _date(r),
                _grade(r),
                ''
              ];
            }),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 22,
          ),
          pw.SizedBox(height: 8),
          pw.Text('Total: ${_records.length}',
              style: const pw.TextStyle(fontSize: 10)),
        ],
      ));
      return pdf.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          color: kHeader,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(children: [
            Expanded(child: Text(_title, style: kSectionTitle)),
            Text('${_records.length} Record${_records.length != 1 ? "s" : ""}',
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
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
                child: Center(
                    child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                              child: Text(_title,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900))),
                          const SizedBox(height: 4),
                          Center(
                              child: Text(
                                  DateFormat('dd MMM yyyy')
                                      .format(DateTime.now()),
                                  style: const TextStyle(
                                      fontSize: 11, color: kInkSoft))),
                          const SizedBox(height: 20),
                          _records.isEmpty
                              ? const Center(
                                  child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text('No records.',
                                          style: TextStyle(color: kInkSoft))))
                              : Table(
                                  border: TableBorder.all(
                                      color: const Color(0xFFCCCFD4),
                                      width: .6),
                                  columnWidths: const {
                                      0: FixedColumnWidth(48),
                                      1: FixedColumnWidth(120),
                                      2: FixedColumnWidth(100),
                                      3: FlexColumnWidth(),
                                      4: FixedColumnWidth(60),
                                      5: FixedColumnWidth(110),
                                      6: FixedColumnWidth(80),
                                      7: FixedColumnWidth(80),
                                    },
                                  children: [
                                      TableRow(
                                          decoration: const BoxDecoration(
                                              color: Color(0xFFE8EAED)),
                                          children: [
                                            'S/No',
                                            'Army No',
                                            'Rank',
                                            'Name',
                                            'Coy',
                                            'Date',
                                            'Grading',
                                            'Remarks'
                                          ].map((h) => _th(h)).toList()),
                                      for (int i = 0; i < _records.length; i++)
                                        TableRow(
                                            decoration: BoxDecoration(
                                                color: i.isEven
                                                    ? Colors.white
                                                    : const Color(0xFFF8F9FB)),
                                            children: [
                                              _td('${i + 1}'),
                                              _td(_records[i].armyNo ?? '-',
                                                  bold: true),
                                              _td(_records[i].rank ?? '-'),
                                              _td(_records[i].name ?? '-',
                                                  bold: true),
                                              _td(_records[i].coy ?? '-'),
                                              _td(_date(_records[i])),
                                              _tdGrade(_grade(_records[i])),
                                              _td(''),
                                            ]),
                                    ]),
                          const SizedBox(height: 16),
                          Text('Total: ${_records.length}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                  ),
                ))),
      )),
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
  Widget _tdGrade(String g) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: g == '-'
          ? Text(g, style: const TextStyle(fontSize: 12, color: kInkSoft))
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: const Color(0xFF1A3A1A),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(g,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white))));
}
