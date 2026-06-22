import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../shared.dart';
import '../db/database.dart';

class FilterEngine extends StatefulWidget {
  const FilterEngine({super.key});
  @override
  State<FilterEngine> createState() => _FilterEngineState();
}

class _FilterEngineState extends State<FilterEngine> {
  final _db = AppDatabase.instance;
  final _search = TextEditingController();
  final _medCat = TextEditingController();

  bool _includeOfficers = true;
  bool _includeJco = true;
  String? _rank, _bloodGp, _domicile, _civEdn, _coy, _ageBracket, _course;
  bool _hasLeave = false,
      _hasHealth = false,
      _hasEre = false,
      _hasOutStr = false,
      _hasFiring = false,
      _hasCpt = false;

  static const _ageBrackets = ['Under 30', '30 - 40', '40 - 50', 'Over 50'];
  // All distinct army courses stored across both officers and jco_or
  static const _courseOptions = [
    'YO',
    'MMG AGL',
    'MOR (O)',
    'Sniper',
    'ADP',
    'ATGM',
    'PWT',
    'JC',
    'SC',
    'CDO/GTK',
    'QM (O)',
    'TAC',
    'RCL',
    'RSO',
    'PT',
    'DSSC',
    'BSW (O)',
    'SEC',
    'Others',
  ];

  List<Map<String, dynamic>> _results = [];
  List<(String, String)> _activeExtraCols = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    // Auto-load all records when the tab opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSearch());
  }

  @override
  void dispose() {
    _search.dispose();
    _medCat.dispose();
    super.dispose();
  }

  int? _ageOf(String? dob) {
    if (dob == null || dob.length < 8) return null;
    try {
      final p = dob.split('-');
      if (p.length != 3) return null;
      final d = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      return DateTime.now().difference(d).inDays ~/ 365;
    } catch (_) {
      return null;
    }
  }

  bool _matchesAgeBracket(int? age) {
    if (_ageBracket == null) return true;
    if (age == null) return false;
    switch (_ageBracket) {
      case 'Under 30':
        return age < 30;
      case '30 - 40':
        return age >= 30 && age < 40;
      case '40 - 50':
        return age >= 40 && age < 50;
      case 'Over 50':
        return age >= 50;
      default:
        return true;
    }
  }

  Future<void> _runSearch() async {
    setState(() => _loading = true);
    var rows = await _db.getFilterEngineResults(
      search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      includeOfficers: _includeOfficers,
      includeJco: _includeJco,
      rank: _rank,
      bloodGp: _bloodGp,
      domicile: _domicile,
      civEdn: _civEdn,
      coy: _coy,
      medCatContains: _medCat.text,
      course: _course,
      hasLeave: _hasLeave,
      hasHealth: _hasHealth,
      hasEre: _hasEre,
      hasOutStr: _hasOutStr,
      hasFiring: _hasFiring,
      hasCpt: _hasCpt,
    );
    if (_ageBracket != null) {
      rows = rows
          .where((r) => _matchesAgeBracket(_ageOf(r['dob'] as String?)))
          .toList();
    }
    _results = rows;
    _activeExtraCols = [
      if (_hasLeave) ...[
        ('Leave Type', 'leave_type'),
        ('Leave From', 'leave_from'),
        ('Leave To', 'leave_to')
      ],
      if (_hasHealth) ...[
        ('Health Cat', 'health_category'),
        ('BMI', 'health_bmi'),
        ('Wt Class', 'health_class')
      ],
      if (_hasEre) ...[
        ('ERE Unit', 'ere_unit'),
        ('Appt', 'ere_appt'),
        ('ERE From', 'ere_from')
      ],
      if (_hasOutStr) ...[
        ('Out Str Reason', 'outstr_reason'),
        ('Location', 'outstr_loc')
      ],
      if (_hasFiring) ...[('Firing Result', 'firing_result')],
      if (_hasCpt) ...[('CPT Result', 'cpt_result')],
    ];
    if (mounted)
      setState(() {
        _loading = false;
        _searched = true;
      });
  }

  void _clearAll() {
    setState(() {
      _search.clear();
      _medCat.clear();
      _includeOfficers = true;
      _includeJco = true;
      _rank = null;
      _bloodGp = null;
      _domicile = null;
      _civEdn = null;
      _coy = null;
      _ageBracket = null;
      _course = null;
      _hasLeave = false;
      _hasHealth = false;
      _hasEre = false;
      _hasOutStr = false;
      _hasFiring = false;
      _hasCpt = false;
      _results = [];
      _activeExtraCols = [];
      _searched = false;
    });
    _runSearch();
  }

  String _s(Map m, String k) =>
      (m[k] ?? '').toString().trim().isEmpty ? '-' : m[k].toString();

  Future<void> _print() async {
    final headers = [
      'S/No',
      'Type',
      'Army No',
      'Rank',
      'Name',
      'Coy',
      'Blood Gp',
      'Domicile',
      'Civ Edn',
      ..._activeExtraCols.map((c) => c.$1)
    ];
    try {
      await Printing.layoutPdf(onLayout: (_) async {
        final pdf = pw.Document();
        pdf.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(28),
            build: (ctx) => [
                  pw.Center(
                      child: pw.Text('FILTER ENGINE — RESULTS',
                          style: pw.TextStyle(
                              fontSize: 13, fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(height: 4),
                  pw.Center(
                      child: pw.Text(
                          DateFormat('dd MMM yyyy').format(DateTime.now()),
                          style: const pw.TextStyle(fontSize: 10))),
                  pw.SizedBox(height: 12),
                  pw.TableHelper.fromTextArray(
                      headers: headers,
                      data: List.generate(_results.length, (i) {
                        final r = _results[i];
                        return [
                          '${i + 1}',
                          _s(r, 'ptype'),
                          _s(r, 'army_no'),
                          _s(r, 'rank'),
                          _s(r, 'name'),
                          _s(r, 'coy'),
                          _s(r, 'blood_gp'),
                          _s(r, 'domicile'),
                          _s(r, 'civ_edn'),
                          ..._activeExtraCols.map((c) => _s(r, c.$2)),
                        ];
                      }),
                      headerStyle: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 8),
                      cellStyle: const pw.TextStyle(fontSize: 8),
                      headerDecoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      cellHeight: 20),
                  pw.SizedBox(height: 8),
                  pw.Text('Total Records: ${_results.length}',
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
    return Column(children: [
      // ── Top header bar ───────────────────────────────────────────────────
      Container(
          color: kHeader,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            const Expanded(
                child: Text('FILTER ENGINE — SEARCH ALL RECORDS',
                    style: kSectionTitle)),
            if (_searched)
              Text(
                  '${_results.length} Result${_results.length != 1 ? "s" : ""}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
      Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Left filter panel ─────────────────────────────────────────────
        SizedBox(
            width: 320,
            child: Container(
                color: kSurface,
                child: Column(children: [
                  // Scrollable filters area
                  Expanded(
                      child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionHeader('Search',
                                    icon: Icons.search),
                                const SizedBox(height: 10),
                                TextField(
                                    controller: _search,
                                    style: kFieldStyle,
                                    decoration:
                                        kDec('Name or Army No / IC No...')),

                                const SizedBox(height: 14),
                                const SectionHeader('Personnel Type',
                                    icon: Icons.groups_outlined),
                                const SizedBox(height: 6),
                                CheckboxListTile(
                                    value: _includeOfficers,
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text('Officers',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    activeColor: kGold,
                                    checkColor: kInk,
                                    onChanged: (v) => setState(
                                        () => _includeOfficers = v ?? true)),
                                CheckboxListTile(
                                    value: _includeJco,
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text("JCOs / OR's",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    activeColor: kGold,
                                    checkColor: kInk,
                                    onChanged: (v) => setState(
                                        () => _includeJco = v ?? true)),

                                const SizedBox(height: 14),
                                const SectionHeader('Personnel Filters',
                                    icon: Icons.filter_alt_outlined),
                                const SizedBox(height: 10),
                                _dd('Rank', _rank, kAllRanks,
                                    (v) => setState(() => _rank = v)),
                                const SizedBox(height: 10),
                                _dd('Blood Group', _bloodGp, kBlood,
                                    (v) => setState(() => _bloodGp = v)),
                                const SizedBox(height: 10),
                                _dd('Age', _ageBracket, _ageBrackets,
                                    (v) => setState(() => _ageBracket = v)),
                                const SizedBox(height: 10),
                                _dd('Domicile', _domicile, kDomicile,
                                    (v) => setState(() => _domicile = v)),
                                const SizedBox(height: 10),
                                _dd('Civ Education', _civEdn, kEducation,
                                    (v) => setState(() => _civEdn = v)),
                                const SizedBox(height: 10),
                                _dd('Army Course', _course, _courseOptions,
                                    (v) => setState(() => _course = v)),
                                const SizedBox(height: 10),
                                _dd('Coy', _coy, kCoys,
                                    (v) => setState(() => _coy = v)),
                                const SizedBox(height: 10),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Text('MED CAT CONTAINS',
                                              style: kLabelStyle)),
                                      TextField(
                                          controller: _medCat,
                                          style: kFieldStyle,
                                          decoration: kDec('e.g. SHAPE 1')),
                                    ]),

                                const SizedBox(height: 14),
                                const SectionHeader('Has Admin Record',
                                    icon: Icons.fact_check_outlined,
                                    accentColor: kAccentBlue),
                                const SizedBox(height: 4),
                                const Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text(
                                        'Tick to filter — matching fields added as extra columns',
                                        style: TextStyle(
                                            fontSize: 10.5,
                                            color: kInkSoft,
                                            fontStyle: FontStyle.italic))),
                                _chk(
                                    'Leave Record',
                                    _hasLeave,
                                    (v) =>
                                        setState(() => _hasLeave = v ?? false)),
                                _chk(
                                    'Health Record',
                                    _hasHealth,
                                    (v) => setState(
                                        () => _hasHealth = v ?? false)),
                                _chk(
                                    'ERE Record',
                                    _hasEre,
                                    (v) =>
                                        setState(() => _hasEre = v ?? false)),
                                _chk(
                                    'Out Strength Record',
                                    _hasOutStr,
                                    (v) => setState(
                                        () => _hasOutStr = v ?? false)),
                                _chk(
                                    'Firing Record',
                                    _hasFiring,
                                    (v) => setState(
                                        () => _hasFiring = v ?? false)),
                                _chk(
                                    'CPT Record',
                                    _hasCpt,
                                    (v) =>
                                        setState(() => _hasCpt = v ?? false)),
                                const SizedBox(
                                    height:
                                        80), // space so last item isn't hidden behind buttons
                              ]))),

                  // ── Floating Search/Clear pinned at bottom ─────────────────
                  Container(
                    decoration: const BoxDecoration(
                        color: kSurface,
                        border: Border(top: BorderSide(color: kBorder))),
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                    child: Row(children: [
                      Expanded(
                          child: OutlinedButton.icon(
                              onPressed: _clearAll,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Clear'),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: kSlate,
                                  side: const BorderSide(color: kSlate),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(kRadius))))),
                      const SizedBox(width: 10),
                      Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                              onPressed: _loading ? null : _runSearch,
                              icon: _loading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: kInk))
                                  : const Icon(Icons.search,
                                      size: 18, color: kInk),
                              label: const Text('Search',
                                  style: TextStyle(
                                      color: kInk,
                                      fontWeight: FontWeight.w800)),
                              style: FilledButton.styleFrom(
                                  backgroundColor: kGold,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(kRadius))))),
                    ]),
                  ),
                ]))),

        Container(width: 1, color: kBorder),

        // ── Right results pane ────────────────────────────────────────────
        Expanded(
            child: Container(
                color: const Color(0xFFD6D8DB), child: _buildResults())),
      ])),
    ]);
  }

  Widget _buildResults() {
    if (!_searched || _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No records match these filters.',
                  style: TextStyle(color: kInkSoft, fontSize: 13))));
    }
    final baseWidths = <int, TableColumnWidth>{
      0: const FixedColumnWidth(40),
      1: const FixedColumnWidth(70),
      2: const FixedColumnWidth(95),
      3: const FixedColumnWidth(80),
      4: const FixedColumnWidth(180),
      5: const FixedColumnWidth(50),
      6: const FixedColumnWidth(70),
      7: const FixedColumnWidth(80),
      8: const FixedColumnWidth(100),
    };
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(28),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('FILTER ENGINE — RESULTS',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                const Spacer(),
                OutlinedButton.icon(
                    onPressed: _print,
                    icon: const Icon(Icons.print_outlined,
                        size: 16, color: kSlate),
                    label: const Text('Print / PDF',
                        style: TextStyle(color: kSlate, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kSlate),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8))),
              ]),
              if (_activeExtraCols.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                        'Extra columns: ${_activeExtraCols.map((c) => c.$1).join(", ")}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: kAccentBlue,
                            fontStyle: FontStyle.italic))),
              const SizedBox(height: 18),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                      border: TableBorder.all(
                          color: const Color(0xFFCCCFD4), width: .6),
                      defaultColumnWidth: const FixedColumnWidth(130),
                      columnWidths: baseWidths,
                      children: [
                        TableRow(
                            decoration:
                                const BoxDecoration(color: Color(0xFFE8EAED)),
                            children: [
                              'S/No',
                              'Type',
                              'Army No',
                              'Rank',
                              'Name',
                              'Coy',
                              'Blood Gp',
                              'Domicile',
                              'Civ Edn',
                              ..._activeExtraCols.map((c) => c.$1)
                            ].map((h) => _th(h)).toList()),
                        for (int i = 0; i < _results.length; i++)
                          TableRow(
                              decoration: BoxDecoration(
                                  color: i.isEven
                                      ? Colors.white
                                      : const Color(0xFFF8F9FB)),
                              children: [
                                _td('${i + 1}'),
                                _typeBadge(_s(_results[i], 'ptype')),
                                _td(_s(_results[i], 'army_no'), bold: true),
                                _td(_s(_results[i], 'rank')),
                                _td(_s(_results[i], 'name'), bold: true),
                                _td(_s(_results[i], 'coy')),
                                _td(_s(_results[i], 'blood_gp')),
                                _td(_s(_results[i], 'domicile')),
                                _td(_s(_results[i], 'civ_edn')),
                                ..._activeExtraCols
                                    .map((c) => _td(_s(_results[i], c.$2))),
                              ]),
                      ])),
              const SizedBox(height: 16),
              Text('Total: ${_results.length}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ])));
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
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All', style: kFieldStyle)),
                  ...opts.map((o) => DropdownMenuItem(
                      value: o, child: Text(o, style: kFieldStyle)))
                ],
                onChanged: cb)
          ]);

  Widget _chk(String label, bool v, void Function(bool?) cb) =>
      CheckboxListTile(
          value: v,
          dense: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(label, style: const TextStyle(fontSize: 13)),
          activeColor: kAccentBlue,
          checkColor: Colors.white,
          onChanged: cb);

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

  Widget _typeBadge(String t) {
    final isOfficer = t == 'Officer';
    final c = isOfficer ? kGold : kAccentBlue;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: c.withOpacity(.14),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: c.withOpacity(.4))),
            child: Text(t,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color:
                        isOfficer ? const Color(0xFF8A6310) : kAccentBlue))));
  }
}
