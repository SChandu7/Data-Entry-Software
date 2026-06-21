import 'dart:io';
import 'package:flutter/material.dart';
import 'shared.dart';
import 'db/models.dart';
import 'filter_panel.dart';
import 'cards/officer_card.dart';
import 'cards/jco_present_card.dart';
import 'cards/jco_on_ere_card.dart';
import 'cards/jco_retired_card.dart';
import 'views/nominal_view.dart';
import 'views/courses_view.dart';
import 'views/education_view.dart';
import 'views/domicile_view.dart';
import 'views/parade_state_view.dart';
import 'admin/admin_shell.dart';
import 'views/leave_view.dart';
import 'views/health_view.dart';
import 'views/ere_view.dart';
import 'views/out_strength_view.dart';
import 'views/firing_view.dart';
import 'views/cpt_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _cat = 'officers';
  String _sub = SubCat.offPresent;
  int _refresh = 0;
  OfficerModel? _editOfficer;
  JcoOrModel? _editJco;
  CardController?
      _activeCard; // whichever data-entry card is currently on screen

  void _registerCard(CardController c) {
    // Cards call this from their own initState(), which runs while HomeScreen
    // is still mid-build — calling setState() synchronously here would throw
    // "setState() called during build". Deferring to the next frame avoids it,
    // since by then HomeScreen's build phase has fully finished.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _activeCard = c);
    });
  }

  static const Map<String, String> _catLabels = {
    'admin': 'Admin',
    'officers': 'Officers',
    'jco': "JCOs / OR's",
    'nominal': 'Nominal',
    'courses': 'Courses',
    'education': 'Education',
    'domicile': 'Domicile',
    'parade': 'Parade State',
    'leave': 'Leave',
    'health': 'Health',
    'ere': 'ERE',
    'out_str': 'Out Strength',
    'misc': 'Miscellaneous',
  };

  static Map<String, List<String>> get _subs => {
        'admin': AdminSub.all,
        'officers': [
          SubCat.offPresent,
          SubCat.offExCos,
          SubCat.offOtherUnit,
          SubCat.offRetired
        ],
        'jco': [
          SubCat.jcoPresentJco,
          SubCat.jcoPresentOr,
          SubCat.jcoOnEre,
          SubCat.jcoRetired
        ],
        'nominal': [
          NomSub.officers,
          NomSub.aCoy,
          NomSub.bCoy,
          NomSub.cCoy,
          NomSub.dCoy,
          NomSub.spCoy,
          NomSub.hqCoy,
          NomSub.jcos,
          NomSub.u30,
          NomSub.o30,
          NomSub.o40,
          NomSub.o50,
          NomSub.bloodGroup
        ],
        'courses': CrsSub.all,
        'education': kEducation,
        'domicile': kDomicile,
        'parade': [],
        'leave': LeaveSub.allSubs,
        'health': HealthSub.allSubs,
        'ere': EreSub.allSubs,
        'out_str': OutStrSub.allSubs,
        'misc': MiscSub.allSubs,
      };

  static String _subLabel(String cat, String s) {
    if (cat == 'admin') return AdminSub.label(s);
    if (cat == 'nominal') return NomSub.label(s);
    if (cat == 'courses') return CrsSub.label(s);
    if (cat == 'education') return s;
    if (cat == 'domicile') return s;
    if (cat == 'leave') return LeaveSub.label(s);
    if (cat == 'health') return HealthSub.label(s);
    if (cat == 'ere') return EreSub.label(s);
    if (cat == 'out_str') return OutStrSub.label(s);
    if (cat == 'misc') return MiscSub.label(s);
    return SubCat.label(s);
  }

  // ── Only officers/jco use the data-entry card layout ─────────────────────
  bool get _isDataCard => _cat == 'officers' || _cat == 'jco';

  List<String> get _currentSubs => _subs[_cat] ?? [];

  void _setCategory(String c) {
    final subs = _subs[c] ?? [];
    setState(() {
      _cat = c;
      _sub = subs.isNotEmpty ? subs.first : '';
      _editOfficer = null;
      _editJco = null;
      _activeCard = null;
    });
  }

  void _setSub(String s) => setState(() {
        _sub = s;
        _editOfficer = null;
        _editJco = null;
        _activeCard = null;
      });

  void _onSaved() => setState(() {
        _editOfficer = null;
        _editJco = null;
        _refresh++;
        _activeCard = null;
      });

  void _onOfficerSelected(OfficerModel r) => setState(() {
        _cat = 'officers';
        _sub = r.subCategory;
        _editOfficer = r;
        _editJco = null;
        _activeCard = null;
      });

  void _onJcoSelected(JcoOrModel r) => setState(() {
        _cat = 'jco';
        _sub = r.subCategory;
        _editJco = r;
        _editOfficer = null;
        _activeCard = null;
      });

  Future<void> _confirmExit() async {
    final ok = await confirmDialog(context, 'Exit', 'Close the application?');
    if (ok) exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      _appBar(),
      _catNav(), // full-width stretched tabs
      if (_currentSubs.isNotEmpty) _subNav(), // left-aligned, natural width
      Expanded(child: _isDataCard ? _cardLayout() : _reportLayout()),
    ]));
  }

  // ── Data-entry card layout (70/30 with filter panel) ─────────────────────
  Widget _cardLayout() {
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(
          flex: 70,
          child: Container(
            color: kBg,
            child: Column(children: [
              Expanded(
                  child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: _activeView(),
              )),
              BipFooter(
                isEditing: _activeCard?.isEditing ?? false,
                isSaving: _activeCard?.isSaving ?? false,
                onSave: () => _activeCard?.doSave(),
                onDelete: () => _activeCard?.doDelete(),
                onClear: () => _activeCard?.doClear(),
                onFind: () =>
                    showSnack(context, 'Use the filter panel on the right.'),
                onPrint: () => showSnack(context, 'Print: coming soon.'),
                onExit: _confirmExit,
              ),
            ]),
          )),
      Container(width: 1, color: kBorder),
      SizedBox(
          width: 390,
          child: FilterPanel(
            category: _cat,
            subCat: _sub,
            refreshKey: _refresh,
            onOfficerSelected: _onOfficerSelected,
            onJcoSelected: _onJcoSelected,
          )),
    ]);
  }

  // ── Report / admin / parade layout (full width, views own their scroll) ──
  Widget _reportLayout() => _activeView();

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _appBar() => Container(
      width: double.infinity,
      height: 54,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kNavyDeep, Color(0xFF13243C)]),
        border: Border(bottom: BorderSide(color: kGold, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Stack(alignment: Alignment.center, children: [
        // Centred logo + title
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: kGoldSoft,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kGold.withOpacity(.5))),
              child: const Icon(Icons.military_tech_outlined,
                  color: kGold, size: 18)),
          const SizedBox(width: 10),
          const Text('BIP',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2)),
          const SizedBox(width: 8),
          const Text('· Bn Information Package',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
        // Editing chip pinned to the right
        if (_editOfficer != null || _editJco != null)
          Positioned(
              right: 0,
              child: Chip(
                  label: Text(
                      'Editing: ${_editOfficer?.name ?? _editJco?.name ?? ''}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: kGold,
                          fontWeight: FontWeight.w700)),
                  backgroundColor: kGoldSoft,
                  side: BorderSide(color: kGold.withOpacity(.4)),
                  labelStyle: const TextStyle(color: Colors.white))),
      ]));

  // ── Category nav — FULL WIDTH stretched tabs ──────────────────────────────
  Widget _catNav() => Container(
      decoration: const BoxDecoration(
          color: kSurface, border: Border(bottom: BorderSide(color: kBorder))),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
          children: _catLabels.keys.map((cat) {
        final sel = _cat == cat;
        return Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                    onTap: () => _setCategory(cat),
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: sel ? kGold : kField,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: sel ? kGold : kBorder),
                            boxShadow: sel
                                ? const [
                                    BoxShadow(
                                        color: Color(0x33C9962E),
                                        blurRadius: 6,
                                        offset: Offset(0, 2))
                                  ]
                                : null),
                        child: Text(_catLabels[cat]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: sel ? kInk : kInk))))));
      }).toList()));

  // ── Sub-heading nav — left-aligned, natural width ─────────────────────────
  Widget _subNav() => Container(
      decoration: const BoxDecoration(
          color: kSurface, border: Border(bottom: BorderSide(color: kBorder))),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: _currentSubs.map((s) {
                final sel = _sub == s;
                return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                        onTap: () => _setSub(s),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                                color:
                                    sel ? kAccentBlueSoft : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: sel ? kAccentBlue : kBorder,
                                    width: sel ? 1.4 : 1)),
                            child: Text(_subLabel(_cat, s),
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight:
                                        sel ? FontWeight.w700 : FontWeight.w500,
                                    color: sel ? kAccentBlue : kInk)))));
              }).toList())));

  // ── Active view switcher ──────────────────────────────────────────────────
  Widget _activeView() {
    if (_cat == 'admin') return AdminShell(key: ValueKey(_sub), subKey: _sub);
    if (_cat == 'nominal')
      return NominalView(key: ValueKey(_sub), subKey: _sub);
    if (_cat == 'courses')
      return CoursesView(key: ValueKey(_sub), courseKey: _sub);
    if (_cat == 'education')
      return EducationView(key: ValueKey(_sub), eduLevel: _sub);
    if (_cat == 'domicile')
      return DomicileView(key: ValueKey(_sub), domicile: _sub);
    if (_cat == 'parade') return const ParadeStateView();
    if (_cat == 'leave') return LeaveView(key: ValueKey(_sub), subKey: _sub);
    if (_cat == 'health') return HealthView(key: ValueKey(_sub), subKey: _sub);
    if (_cat == 'ere') return EreView(key: ValueKey(_sub), subKey: _sub);
    if (_cat == 'out_str') return OutStrView(key: ValueKey(_sub), subKey: _sub);
    if (_cat == 'misc') {
      if (_sub == MiscSub.cpt) return const CptView();
      return const FiringView(); // default / MiscSub.firing
    }

    // Officers
    if (_cat == 'officers')
      return OfficerCard(
          key: ValueKey(_sub + (_editOfficer?.id?.toString() ?? 'new')),
          subCategory: _sub,
          record: _editOfficer,
          onSaved: _onSaved,
          onReady: _registerCard);

    // JCO/OR
    switch (_sub) {
      case SubCat.jcoPresentJco:
        return JcoPresentCard(
            key: ValueKey(_sub + (_editJco?.id?.toString() ?? 'new')),
            record: _editJco,
            onSaved: _onSaved,
            onReady: _registerCard,
            subCategory: SubCat.jcoPresentJco,
            ranks: kJcoOnlyRanks);
      case SubCat.jcoPresentOr:
        return JcoPresentCard(
            key: ValueKey(_sub + (_editJco?.id?.toString() ?? 'new')),
            record: _editJco,
            onSaved: _onSaved,
            onReady: _registerCard,
            subCategory: SubCat.jcoPresentOr,
            ranks: kOrOnlyRanks);
      case SubCat.jcoOnEre:
        return JcoOnEreCard(
            key: ValueKey(_sub + (_editJco?.id?.toString() ?? 'new')),
            record: _editJco,
            onSaved: _onSaved,
            onReady: _registerCard);
      case SubCat.jcoRetired:
        return JcoRetiredCard(
            key: ValueKey(_sub + (_editJco?.id?.toString() ?? 'new')),
            record: _editJco,
            onSaved: _onSaved,
            onReady: _registerCard);
    }
    return ComingSoon(label: _sub);
  }
}
