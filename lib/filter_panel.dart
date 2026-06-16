import 'package:flutter/material.dart';
import 'shared.dart';
import 'db/database.dart';
import 'db/models.dart';

class FilterPanel extends StatefulWidget {
  final String category;
  final String subCat;
  final int refreshKey;
  final ValueChanged<OfficerModel> onOfficerSelected;
  final ValueChanged<JcoOrModel> onJcoSelected;

  const FilterPanel({
    super.key,
    required this.category,
    required this.subCat,
    required this.refreshKey,
    required this.onOfficerSelected,
    required this.onJcoSelected,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  final _db = AppDatabase.instance;
  final _search = TextEditingController();

  // ── Shared ────────────────────────────────────────────────────────────────
  String? _filterSubCat;

  // ── Officers-only filters ─────────────────────────────────────────────────
  String? _offRank, _offBlood, _offStatus, _offMedCat, _offCourse;

  // ── JCO/OR-only filters ───────────────────────────────────────────────────
  String? _jcoRank, _jcoCoy, _jcoBlood, _jcoSvcExtn;
  String? _jcoAge, _jcoCourse, _jcoMedCat;

  List<OfficerModel> _officers = [];
  List<JcoOrModel> _jcos = [];
  bool _loading = false;

  // Officer course column → display name
  static const _offCourses = {
    'c_yo': 'YO',
    'c_mmg': 'MMG AGL',
    'c_mor': 'MOR (O)',
    'c_snip': 'Sniper',
    'c_adp': 'ADP',
    'c_atgm': 'ATGM',
    'c_pwt': 'PWT',
    'c_jc': 'JC',
    'c_sc': 'SC',
    'c_cdo': 'CDO/GTK',
    'c_qm': 'QM (O)',
    'c_tac': 'TAC',
    'c_rcl': 'RCL',
    'c_rso': 'RSO',
    'c_pt': 'PT',
    'c_dssc': 'DSSC',
    'c_bsw': 'BSW (O)',
  };

  // JCO course column → display name
  static const _jcoCourses = {
    'c_sec': 'Sec Cdr',
    'c_mmg': 'MMG AGL',
    'c_mor': 'Mor Jn',
    'c_snip': 'Sniper',
    'c_adp': 'ADP',
    'c_atgm': 'ATGM',
    'c_drill': 'Drill',
    'c_bmic': 'BMIC',
    'c_uei': 'UEI',
    'c_cdo': 'CDO',
    'c_qm': 'QM',
    'c_rsi': 'RSI',
    'c_jlc': 'JLC',
    'c_pc': 'PC',
    'c_pt': 'PT',
    'c_tpt': 'TPT',
    'c_misc': 'Misc',
  };

  static const _medCats = ['A1', 'A2', 'A3', 'B1', 'B2', 'C1', 'C2', 'CEE'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(FilterPanel o) {
    super.didUpdateWidget(o);
    if (o.refreshKey != widget.refreshKey || o.category != widget.category) {
      _clearFilters(reload: true);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      if (widget.category == 'officers') {
        _officers = await _db.queryOfficers(
          subCat: _filterSubCat,
          name: _search.text,
          rank: _offRank,
          status: _offStatus,
          bloodGp: _offBlood,
          medCat: _offMedCat,
          courseField: _offCourse,
        );
      } else {
        _jcos = await _db.queryJco(
          subCat: _filterSubCat,
          name: _search.text,
          rank: _jcoRank,
          coy: _jcoCoy,
          bloodGp: _jcoBlood,
          ageFilter: _jcoAge,
          serviceExtn: _jcoSvcExtn,
          courseField: _jcoCourse,
        );
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Query error: $e', error: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _clearFilters({bool reload = false}) {
    setState(() {
      _filterSubCat = null;
      _offRank = null;
      _offBlood = null;
      _offStatus = null;
      _offMedCat = null;
      _offCourse = null;
      _jcoRank = null;
      _jcoCoy = null;
      _jcoBlood = null;
      _jcoSvcExtn = null;
      _jcoAge = null;
      _jcoCourse = null;
      _jcoMedCat = null;
    });
    _search.clear();
    if (reload) _load();
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kSurface,
      child: Column(children: [
        _header(),
        _filterRows(),
        _tableHeader(),
        Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _table()),
      ]),
    );
  }

  // ── Header bar ────────────────────────────────────────────────────────────
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
          color: kHeader,
          border: Border(bottom: BorderSide(color: Colors.black26))),
      child: Row(children: [
        const Icon(Icons.filter_alt_outlined, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        const Text('FILTER & RECORDS', style: kSectionTitle),
        const Spacer(),
        TextButton(
          onPressed: () => _clearFilters(reload: true),
          style: TextButton.styleFrom(
              foregroundColor: Colors.white54, padding: EdgeInsets.zero),
          child: const Text('Clear', style: TextStyle(fontSize: 12)),
        ),
      ]),
    );
  }

  // ── Filter rows (different per category) ─────────────────────────────────
  Widget _filterRows() {
    return Container(
      decoration: const BoxDecoration(
          color: Color(0xFFF8F9FB),
          border: Border(bottom: BorderSide(color: kBorder))),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: widget.category == 'officers' ? _officerFilters() : _jcoFilters(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OFFICERS — filters
  // ─────────────────────────────────────────────────────────────────────────
  Widget _officerFilters() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Row 1: search + sub-category
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: _labelSearch('IC No / Name')),
        const SizedBox(width: 8),
        _dd('Sub-Category', _filterSubCat, [
          SubCat.offPresent,
          SubCat.offExCos,
          SubCat.offOtherUnit,
          SubCat.offRetired
        ], (v) {
          setState(() => _filterSubCat = v);
          _load();
        }, width: 138, labelFn: SubCat.label),
      ]),
      const SizedBox(height: 10),
      // Row 2: rank + blood group
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _dd('Rank', _offRank, kOfficerRanks, (v) {
          setState(() => _offRank = v);
          _load();
        }, width: 120),
        const SizedBox(width: 8),
        _dd('Blood Group', _offBlood, kBlood, (v) {
          setState(() => _offBlood = v);
          _load();
        }, width: 110),
        const SizedBox(width: 8),
        _dd('Med Cat', _offMedCat, _medCats, (v) {
          setState(() => _offMedCat = v);
          _load();
        }, width: 90),
      ]),
      const SizedBox(height: 10),
      // Row 3: status + course
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _dd('Status', _offStatus, kOfficerStatus, (v) {
          setState(() => _offStatus = v);
          _load();
        }, width: 150),
        const SizedBox(width: 8),
        _dd('Has Course', _offCourse, _offCourses.keys.toList(), (v) {
          setState(() => _offCourse = v);
          _load();
        }, width: 160, labelFn: (k) => _offCourses[k] ?? k),
      ]),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // JCO/OR — filters
  // ─────────────────────────────────────────────────────────────────────────
  Widget _jcoFilters() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Row 1: search + sub-category
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: _labelSearch('Army No / Name')),
        const SizedBox(width: 8),
        _dd('Sub-Category', _filterSubCat, [
          SubCat.jcoPresent,
          SubCat.jcoOnEre,
          SubCat.jcoRetired,
          SubCat.jcoShort,
          SubCat.jcoNewEntry
        ], (v) {
          setState(() => _filterSubCat = v);
          _load();
        }, width: 138, labelFn: SubCat.label),
      ]),
      const SizedBox(height: 10),
      // Row 2: rank + company + blood group
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _dd('Rank', _jcoRank, kJcoRanks, (v) {
          setState(() => _jcoRank = v);
          _load();
        }, width: 108),
        const SizedBox(width: 6),
        _dd('Company', _jcoCoy, kCoys, (v) {
          setState(() => _jcoCoy = v);
          _load();
        }, width: 86),
        const SizedBox(width: 6),
        _dd('Blood Group', _jcoBlood, kBlood, (v) {
          setState(() => _jcoBlood = v);
          _load();
        }, width: 108),
      ]),
      const SizedBox(height: 10),
      // Row 3: svc extn + med cat + over age
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _dd('Svc Extn', _jcoSvcExtn, kYesNo, (v) {
          setState(() => _jcoSvcExtn = v);
          _load();
        }, width: 90),
        const SizedBox(width: 6),
        _dd('Med Cat', _jcoMedCat, _medCats, (v) {
          setState(() => _jcoMedCat = v);
          _load();
        }, width: 90),
        const SizedBox(width: 6),
        _dd('Over Age (Yrs)', _jcoAge, ['30', '40', '45'], (v) {
          setState(() => _jcoAge = v);
          _load();
        }, width: 110),
      ]),
      const SizedBox(height: 10),
      // Row 4: has course (full width)
      _dd('Has Course', _jcoCourse, _jcoCourses.keys.toList(), (v) {
        setState(() => _jcoCourse = v);
        _load();
      }, width: double.infinity, labelFn: (k) => _jcoCourses[k] ?? k),
    ]);
  }

  // ── Search field with label ───────────────────────────────────────────────
  Widget _labelSearch(String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _lbl('Search ($hint)'),
      TextField(
        controller: _search,
        style: const TextStyle(fontSize: 12),
        decoration: kDec('Type to search...').copyWith(
            prefixIcon: const Icon(Icons.search, size: 16),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 9)),
        onChanged: (_) => _load(),
      ),
    ]);
  }

  // ── Labelled dropdown ─────────────────────────────────────────────────────
  Widget _dd(
      String label, String? value, List<String> opts, ValueChanged<String?> cb,
      {double width = 110, String Function(String)? labelFn}) {
    final w = width == double.infinity ? null : width;
    Widget dropdown = DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      style: const TextStyle(fontSize: 12, color: kInk),
      decoration: kDec().copyWith(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 9)),
      items: [
        const DropdownMenuItem(
            value: null, child: Text('All', style: TextStyle(fontSize: 12))),
        ...opts.map((o) => DropdownMenuItem(
            value: o,
            child: Text(labelFn != null ? labelFn(o) : o,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis))),
      ],
      onChanged: cb,
    );

    final col = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_lbl(label), dropdown]);

    return w != null ? SizedBox(width: w, child: col) : col;
  }

  // ── Small label ───────────────────────────────────────────────────────────
  Widget _lbl(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: .4,
                color: kInkSoft),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      );

  // ── Table header ──────────────────────────────────────────────────────────
  Widget _tableHeader() {
    final isJco = widget.category == 'jco';
    final count = isJco ? _jcos.length : _officers.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: const BoxDecoration(
          color: kSilver1, border: Border(bottom: BorderSide(color: kBorder))),
      child: Row(children: [
        Text('$count Record${count != 1 ? "s" : ""}',
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: kInk)),
        const Spacer(),
        Text(isJco ? 'Army No · Rank · Name · Coy' : 'IC No · Rank · Name',
            style: const TextStyle(fontSize: 10.5, color: kInkSoft)),
      ]),
    );
  }

  // ── Records list ──────────────────────────────────────────────────────────
  Widget _table() {
    final isJco = widget.category == 'jco';
    if (isJco ? _jcos.isEmpty : _officers.isEmpty) {
      return const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox_outlined, size: 40, color: Color(0xFFBFC4CC)),
        SizedBox(height: 8),
        Text('No records', style: TextStyle(color: kInkSoft, fontSize: 13)),
      ]));
    }
    return ListView.separated(
      itemCount: isJco ? _jcos.length : _officers.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: kBorder),
      itemBuilder: (_, i) => isJco ? _jcoRow(_jcos[i]) : _offRow(_officers[i]),
    );
  }

  Widget _offRow(OfficerModel r) {
    return InkWell(
      onTap: () => widget.onOfficerSelected(r),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(r.name ?? '—',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: kInk),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                    '${r.rank ?? ''} · ${r.icNo ?? ''} · ${SubCat.label(r.subCategory)}',
                    style: const TextStyle(fontSize: 11, color: kInkSoft)),
              ])),
          const Icon(Icons.edit_outlined, size: 16, color: kInkSoft),
        ]),
      ),
    );
  }

  Widget _jcoRow(JcoOrModel r) {
    return InkWell(
      onTap: () => widget.onJcoSelected(r),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(r.name ?? '—',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: kInk),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                    '${r.rank ?? ''} · ${r.armyNo ?? ''} · Coy ${r.coy ?? '—'} · ${SubCat.label(r.subCategory)}',
                    style: const TextStyle(fontSize: 11, color: kInkSoft)),
              ])),
          const Icon(Icons.edit_outlined, size: 16, color: kInkSoft),
        ]),
      ),
    );
  }
}
