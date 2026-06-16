import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../shared.dart';
import '../db/database.dart';

class LeaveView extends StatefulWidget {
  final String subKey;
  const LeaveView({super.key, required this.subKey});
  @override
  State<LeaveView> createState() => _LeaveViewState();
}

class _LeaveViewState extends State<LeaveView> {
  final _db = AppDatabase.instance;
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  String get _title =>
      'LEAVE RECORDS — ${LeaveSub.label(widget.subKey).toUpperCase()}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(LeaveView o) {
    super.didUpdateWidget(o);
    if (o.subKey != widget.subKey) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final leaveType = LeaveSub.dbVal(widget.subKey);
    _rows = await _db.getLeaveReport(leaveType: leaveType);
    if (mounted) setState(() => _loading = false);
  }

  String _s(Map m, String k) =>
      (m[k] ?? '').toString().trim().isEmpty ? '-' : m[k].toString();

  Future<void> _print() async {
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
                        'Leave Type',
                        'From',
                        'To',
                        'Days',
                        'Reporting',
                        'Remarks'
                      ],
                      data: List.generate(_rows.length, (i) {
                        final r = _rows[i];
                        return [
                          '${i + 1}',
                          _s(r, 'army_no'),
                          _s(r, 'name'),
                          _s(r, 'rank'),
                          _s(r, 'leave_type'),
                          _s(r, 'from_dt'),
                          _s(r, 'to_dt'),
                          _s(r, 'days'),
                          _s(r, 'reporting_dt'),
                          _s(r, 'remarks')
                        ];
                      }),
                      headerStyle: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 8),
                      cellStyle: const pw.TextStyle(fontSize: 8),
                      headerDecoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      cellHeight: 20),
                  pw.SizedBox(height: 8),
                  pw.Text('Total Records: ${_rows.length}',
                      style: const pw.TextStyle(fontSize: 10)),
                ]));
        return pdf.save();
      });
    } catch (e) {
      if (mounted) showSnack(context, 'Print failed: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            color: kHeader,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(children: [
              Expanded(child: Text(_title, style: kSectionTitle)),
              Text('${_rows.length} Record${_rows.length != 1 ? "s" : ""}',
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
                                    const BoxConstraints(maxWidth: 920),
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
                                          _rows.isEmpty
                                              ? const Center(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(20),
                                                      child: Text(
                                                          'No leave records found.',
                                                          style: TextStyle(
                                                              color: kInkSoft,
                                                              fontSize: 13))))
                                              : Table(
                                                  border: TableBorder.all(
                                                      color: const Color(
                                                          0xFFCCCFD4),
                                                      width: .6),
                                                  columnWidths: const {
                                                      0: FixedColumnWidth(40),
                                                      1: FixedColumnWidth(100),
                                                      2: FlexColumnWidth(2),
                                                      3: FixedColumnWidth(80),
                                                      4: FixedColumnWidth(110),
                                                      5: FixedColumnWidth(95),
                                                      6: FixedColumnWidth(95),
                                                      7: FixedColumnWidth(50),
                                                      8: FixedColumnWidth(95)
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
                                                            'Leave Type',
                                                            'From',
                                                            'To',
                                                            'Days',
                                                            'Reporting'
                                                          ]
                                                              .map(
                                                                  (h) => _th(h))
                                                              .toList()),
                                                      for (int i = 0;
                                                          i < _rows.length;
                                                          i++)
                                                        TableRow(
                                                            decoration: BoxDecoration(
                                                                color: i.isEven
                                                                    ? Colors
                                                                        .white
                                                                    : const Color(
                                                                        0xFFF8F9FB)),
                                                            children: [
                                                              _td('${i + 1}'),
                                                              _td(
                                                                  _s(_rows[i],
                                                                      'army_no'),
                                                                  bold: true),
                                                              _td(
                                                                  _s(_rows[i],
                                                                      'name'),
                                                                  bold: true),
                                                              _td(_s(_rows[i],
                                                                  'rank')),
                                                              _tdBadge(_s(
                                                                  _rows[i],
                                                                  'leave_type')),
                                                              _td(_s(_rows[i],
                                                                  'from_dt')),
                                                              _td(_s(_rows[i],
                                                                  'to_dt')),
                                                              _td(_s(_rows[i],
                                                                  'days')),
                                                              _td(_s(_rows[i],
                                                                  'reporting_dt')),
                                                            ]),
                                                    ]),
                                          const SizedBox(height: 16),
                                          Text('Total: ${_rows.length}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600)),
                                        ])))))))
      ]);

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
              color: const Color(0xFF2E3440).withOpacity(.1),
              borderRadius: BorderRadius.circular(4)),
          child: Text(t,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: kSlate))));
}
