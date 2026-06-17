import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../shared.dart';
import '../db/database.dart';
import '../db/models.dart';

class NominalView extends StatefulWidget {
  final String subKey;
  const NominalView({super.key, required this.subKey});
  @override
  State<NominalView> createState() => _NominalViewState();
}

class _NominalViewState extends State<NominalView> {
  final _db = AppDatabase.instance;
  List<Map<String, String>> _rows = [];
  bool _loading = true;
  String? _selectedBlood; // used only when subKey == NomSub.bloodGroup

  bool get _isOfficerType => widget.subKey == NomSub.officers;
  bool get _isAgeBased =>
      [NomSub.u30, NomSub.o30, NomSub.o40, NomSub.o50].contains(widget.subKey);
  bool get _isJcoType => widget.subKey == NomSub.jcos;
  bool get _isBloodGroup => widget.subKey == NomSub.bloodGroup;

  String get _title => _isBloodGroup
      ? 'NOMINAL ROLL — BLOOD GROUP${_selectedBlood != null ? " : $_selectedBlood" : ""}'
      : 'NOMINAL ROLL — ${NomSub.label(widget.subKey).toUpperCase()}';

  @override
  void initState() { super.initState(); _load(); }

  @override
  void didUpdateWidget(NominalView o) {
    super.didUpdateWidget(o);
    if (o.subKey != widget.subKey) {
      _selectedBlood = null;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    List<Map<String, String>> rows = [];
    int sno = 1;

    if (_isBloodGroup) {
      // JCO/OR only, filtered by selected blood group (if any chosen)
      if (_selectedBlood != null) {
        final list = await _db.queryJco(bloodGp: _selectedBlood);
        for (final r in list) {
          rows.add({'S/No': '$sno', 'Army No': r.armyNo ?? '-',
            'Rank': r.rank ?? '-', 'Name': r.name ?? '-',
            'Coy': r.coy ?? '-', 'Blood Gp': r.bloodGp ?? '-', 'Remarks': ''});
          sno++;
        }
      }
    } else if (_isOfficerType) {
      final list = await _db.queryOfficers();
      for (final r in list) {
        rows.add({'S/No': '$sno', 'IC No': r.icNo ?? '-',
          'Rank': r.rank ?? '-', 'Name': r.name ?? '-',
          'Status': r.status ?? '-', 'Remarks': ''});
        sno++;
      }
    } else if (_isJcoType) {
      final list = await _db.queryJco();
      for (final r in list) {
        rows.add({'S/No': '$sno', 'Army No': r.armyNo ?? '-',
          'Rank': r.rank ?? '-', 'Name': r.name ?? '-',
          'Sub-Cat': SubCat.label(r.subCategory), 'Remarks': ''});
        sno++;
      }
    } else if (_isAgeBased) {
      final now = DateTime.now();
      int? minAge, maxAge;
      if (widget.subKey == NomSub.u30)      { maxAge = 30; }
      else if (widget.subKey == NomSub.o30) { minAge = 30; maxAge = 40; }
      else if (widget.subKey == NomSub.o40) { minAge = 40; maxAge = 50; }
      else                                  { minAge = 50; }

      final list = await _db.queryJco();
      for (final r in list) {
        if ((r.dob ?? '').length < 10) continue;
        int age = 0;
        try {
          final p = r.dob!.split('-');
          if (p.length == 3) {
            final dob = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
            age = now.difference(dob).inDays ~/ 365;
          }
        } catch (_) { continue; }
        final ok = (minAge == null || age >= minAge) && (maxAge == null || age < maxAge);
        if (!ok) continue;
        rows.add({'S/No': '$sno', 'Army No': r.armyNo ?? '-',
          'Rank': r.rank ?? '-', 'Name': r.name ?? '-',
          'Coy': r.coy ?? '-', 'Age': '$age yrs', 'Remarks': ''});
        sno++;
      }
    } else {
      // Coy-based
      const coyMap = {
        'nom_a_coy': 'A', 'nom_b_coy': 'B', 'nom_c_coy': 'C',
        'nom_d_coy': 'D', 'nom_sp_coy': 'SP', 'nom_hq_coy': 'HQ',
      };
      final coy = coyMap[widget.subKey];
      final list = await _db.queryJco(coy: coy);
      for (final r in list) {
        rows.add({'S/No': '$sno', 'Army No': r.armyNo ?? '-',
          'Rank': r.rank ?? '-', 'Name': r.name ?? '-',
          'Coy': r.coy ?? '-', 'Remarks': ''});
        sno++;
      }
    }

    if (mounted) setState(() { _rows = rows; _loading = false; });
  }

  void _onBloodSelected(String? b) {
    setState(() => _selectedBlood = b);
    _load();
  }

  List<String> get _headers =>
      _rows.isEmpty ? [] : _rows.first.keys.toList();

  Future<void> _print() async {
    try {
      await Printing.layoutPdf(onLayout: (_) async {
        final pdf = pw.Document();
        pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (ctx) => [
            pw.Center(child: pw.Text(_title,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 4),
            pw.Center(child: pw.Text(
                DateFormat('dd MMM yyyy').format(DateTime.now()),
                style: const pw.TextStyle(fontSize: 10))),
            pw.SizedBox(height: 12),
            if (_rows.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headers: _headers,
                data: _rows.map((r) => _headers.map((h) => r[h] ?? '').toList()).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 22,
              ),
            pw.SizedBox(height: 10),
            pw.Text('Total: ${_rows.length}',
                style: const pw.TextStyle(fontSize: 10)),
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
      // ── Header bar ──────────────────────────────────────────────────────
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
            icon: const Icon(Icons.print_outlined, size: 16, color: Colors.white),
            label: const Text('Print / PDF',
                style: TextStyle(color: Colors.white, fontSize: 12)),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
          ),
        ]),
      ),
      // ── Blood Group internal selector ─────────────────────────────────────
      if (_isBloodGroup) Container(
        width: double.infinity, color: kSurface,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: kBorder))),
        child: Row(children: [
          const Text('SELECT BLOOD GROUP', style: kLabelStyle),
          const SizedBox(width: 12),
          SizedBox(width: 160, child: DropdownButtonFormField<String>(
            value: _selectedBlood, isExpanded: true,
            style: kFieldStyle.copyWith(color: kInk),
            decoration: kDec('Choose...'),
            items: kBlood.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: _onBloodSelected,
          )),
          const SizedBox(width: 8),
          const Text('(JCOs / OR only)', style: TextStyle(fontSize: 11, color: kInkSoft)),
        ]),
      ),
      // ── Document-page body ───────────────────────────────────────────────
      Expanded(child: Container(
        color: const Color(0xFFD6D8DB), // grey "desktop" background
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_isBloodGroup && _selectedBlood == null)
                ? const Center(child: Text('Select a blood group above to view records.',
                    style: TextStyle(color: kInkSoft, fontSize: 13)))
                : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
                child: Center(child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Document title
                        Center(child: Text(_title,
                            style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w900, letterSpacing: .5))),
                        const SizedBox(height: 4),
                        Center(child: Text(
                            DateFormat('dd MMM yyyy').format(DateTime.now()),
                            style: const TextStyle(fontSize: 11, color: kInkSoft))),
                        const SizedBox(height: 20),
                        // Records table or empty message
                        _rows.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text('No records found.',
                                      style: TextStyle(color: kInkSoft, fontSize: 13))))
                            : _docTable(),
                        const SizedBox(height: 16),
                        Text('Total: ${_rows.length}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ))),
      )),
    ]);
  }

  /// Renders records as a document-style table (not ListView — shows all rows)
  Widget _docTable() {
    final headers = _headers;
    // Column flex widths based on header type
    Map<int, TableColumnWidth> colWidths = {};
    for (int i = 0; i < headers.length; i++) {
      switch (headers[i]) {
        case 'S/No':   colWidths[i] = const FixedColumnWidth(48); break;
        case 'IC No':
        case 'Army No': colWidths[i] = const FixedColumnWidth(130); break;
        case 'Rank':   colWidths[i] = const FixedColumnWidth(110); break;
        case 'Coy':    colWidths[i] = const FixedColumnWidth(60); break;
        case 'Age':    colWidths[i] = const FixedColumnWidth(70); break;
        case 'Status': colWidths[i] = const FixedColumnWidth(120); break;
        case 'Sub-Cat':colWidths[i] = const FixedColumnWidth(140); break;
        case 'Blood Gp':colWidths[i] = const FixedColumnWidth(90); break;
        case 'Remarks':colWidths[i] = const FlexColumnWidth(); break;
        default:       colWidths[i] = const FlexColumnWidth(); break;
      }
    }
    return Table(
      border: TableBorder.all(color: const Color(0xFFCCCFD4), width: .6),
      columnWidths: colWidths,
      children: [
        // Header row
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFE8EAED)),
          children: headers.map((h) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Text(h, style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800,
                letterSpacing: .3)))).toList()),
        // Data rows
        for (int i = 0; i < _rows.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: i.isEven ? Colors.white : const Color(0xFFF8F9FB)),
            children: headers.map((h) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: Text(_rows[i][h] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: h == 'Name' ? FontWeight.w600 : FontWeight.normal,
                    color: kInk)))).toList()),
      ],
    );
  }
}