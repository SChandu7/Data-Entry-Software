import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../shared.dart';
import '../db/database.dart';
import '../db/models.dart';

/// Reusable for ALL 4 officer sub-categories.
/// Pass [subCategory] (SubCat.offPresent / offExCos / offOtherUnit / offRetired).
class OfficerCard extends StatefulWidget {
  final String subCategory;
  final OfficerModel? record;
  final VoidCallback onSaved;
  final void Function(CardController) onReady;

  const OfficerCard({
    super.key,
    required this.subCategory,
    required this.onSaved,
    required this.onReady,
    this.record,
  });

  @override
  State<OfficerCard> createState() => _OfficerCardState();
}

class _OfficerCardState extends State<OfficerCard> implements CardController {
  final _db = AppDatabase.instance;
  bool _saving = false;
  int? _savedId; // captures the new row id after first successful insert, so a
  // second Save click updates that row instead of duplicating it

  // ── Pers controllers ──────────────────────────────────────────────────────
  final _icNo = TextEditingController();
  final _name = TextEditingController();
  final _cdaAc = TextEditingController();
  final _iCard = TextEditingController();
  final _bDay = TextEditingController();
  final _mAnn = TextEditingController();
  final _honours = TextEditingController();
  final _medCat = TextEditingController();
  final _diag = TextEditingController();
  final _dueOn = TextEditingController();
  final _presAddr = TextEditingController();
  final _permtAddr = TextEditingController();
  final _teleNos = TextEditingController();
  final _emailIds = TextEditingController();
  final _dob = TextEditingController();
  final _doc = TextEditingController();
  final _dor = TextEditingController();
  final _dom = TextEditingController();
  String? _domicile;
  String? _rank, _bloodGp, _status;
  String? _photoPath;

  // ── Kindred controllers ───────────────────────────────────────────────────
  final _wife = TextEditingController();
  final _wifeBday = TextEditingController();
  final List<TextEditingController> _chName =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _chDob =
      List.generate(4, (_) => TextEditingController());
  final List<String?> _chSex = List.filled(4, null, growable: false);

  // ── Courses ───────────────────────────────────────────────────────────────
  final _cYo = TextEditingController();
  final _cMmg = TextEditingController();
  final _cMor = TextEditingController();
  final _cSnip = TextEditingController();
  final _cAdp = TextEditingController();
  final _cAtgm = TextEditingController();
  final _cPwt = TextEditingController();
  final _cJc = TextEditingController();
  final _cSc = TextEditingController();
  final _cCdo = TextEditingController();
  final _cQm = TextEditingController();
  final _cTac = TextEditingController();
  final _cRcl = TextEditingController();
  final _cRso = TextEditingController();
  final _cPt = TextEditingController();
  final _cDssc = TextEditingController();
  final _cBsw = TextEditingController();
  final _cOth = TextEditingController();

  // ── Promotions ────────────────────────────────────────────────────────────
  final _pLt = TextEditingController();
  final _pCapt = TextEditingController();
  final _pMaj = TextEditingController();
  final _pLtCol = TextEditingController();
  final _pCol = TextEditingController();
  final _pBrig = TextEditingController();
  final _pMajGen = TextEditingController();
  final _pLtGen = TextEditingController();

  // ── Service in unit ───────────────────────────────────────────────────────
  final List<TextEditingController> _svF =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _svT =
      List.generate(4, (_) => TextEditingController());
  final _cmdF = TextEditingController();
  final _cmdT = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.record != null) _populate(widget.record!);
    widget.onReady(this);
  }

  // ── CardController interface (drives the screen-pinned footer) ──────────
  @override
  bool get isEditing => widget.record != null;
  @override
  bool get isSaving => _saving;
  @override
  Future<void> doSave() => _save();
  @override
  Future<void> doDelete() => _delete();
  @override
  void doClear() => _clear();

  @override
  void didUpdateWidget(OfficerCard old) {
    super.didUpdateWidget(old);
    if (widget.record != old.record) {
      if (widget.record != null)
        _populate(widget.record!);
      else
        _clear();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _icNo,
      _name,
      _cdaAc,
      _iCard,
      _bDay,
      _mAnn,
      _honours,
      _medCat,
      _diag,
      _dueOn,
      _presAddr,
      _permtAddr,
      _teleNos,
      _emailIds,
      _dob,
      _doc,
      _dor,
      _dom,
      _wife,
      _wifeBday,
      _cYo,
      _cMmg,
      _cMor,
      _cSnip,
      _cAdp,
      _cAtgm,
      _cPwt,
      _cJc,
      _cSc,
      _cCdo,
      _cQm,
      _cTac,
      _cRcl,
      _cRso,
      _cPt,
      _cDssc,
      _cBsw,
      _cOth,
      _pLt,
      _pCapt,
      _pMaj,
      _pLtCol,
      _pCol,
      _pBrig,
      _pMajGen,
      _pLtGen,
      _cmdF,
      _cmdT
    ]) {
      c.dispose();
    }
    for (final c in [..._chName, ..._chDob, ..._svF, ..._svT]) c.dispose();
    super.dispose();
  }

  void _populate(OfficerModel r) {
    _icNo.text = r.icNo ?? '';
    _name.text = r.name ?? '';
    _cdaAc.text = r.cdaAcNo ?? '';
    _iCard.text = r.iCardNo ?? '';
    _bDay.text = r.bDay ?? '';
    _mAnn.text = r.mAnn ?? '';
    _honours.text = r.honoursAwards ?? '';
    _medCat.text = r.medCat ?? '';
    _diag.text = r.diag ?? '';
    _dueOn.text = r.dueOn ?? '';
    _presAddr.text = r.presentAddress ?? '';
    _permtAddr.text = r.permtAddress ?? '';
    _teleNos.text = r.teleNos ?? '';
    _emailIds.text = r.emailIds ?? '';
    _dob.text = r.dob ?? '';
    _doc.text = r.doc ?? '';
    _dor.text = r.dor ?? '';
    _dom.text = r.dom ?? '';
    _wife.text = r.wifeName ?? '';
    _wifeBday.text = r.wifeBday ?? '';
    _cYo.text = r.cYo ?? '';
    _cMmg.text = r.cMmgAgl ?? '';
    _cMor.text = r.cMorO ?? '';
    _cSnip.text = r.cSniper ?? '';
    _cAdp.text = r.cAdp ?? '';
    _cAtgm.text = r.cAtgm ?? '';
    _cPwt.text = r.cPwt ?? '';
    _cJc.text = r.cJc ?? '';
    _cSc.text = r.cSc ?? '';
    _cCdo.text = r.cCdoGtk ?? '';
    _cQm.text = r.cQmO ?? '';
    _cTac.text = r.cTac ?? '';
    _cRcl.text = r.cRcl ?? '';
    _cRso.text = r.cRso ?? '';
    _cPt.text = r.cPt ?? '';
    _cDssc.text = r.cDssc ?? '';
    _cBsw.text = r.cBswO ?? '';
    _cOth.text = r.cOthers ?? '';
    _pLt.text = r.pLt ?? '';
    _pCapt.text = r.pCapt ?? '';
    _pMaj.text = r.pMaj ?? '';
    _pLtCol.text = r.pLtCol ?? '';
    _pCol.text = r.pCol ?? '';
    _pBrig.text = r.pBrig ?? '';
    _pMajGen.text = r.pMajGen ?? '';
    _pLtGen.text = r.pLtGen ?? '';
    _cmdF.text = r.cmdF ?? '';
    _cmdT.text = r.cmdT ?? '';
    final chiN = [r.ch1Name, r.ch2Name, r.ch3Name, r.ch4Name];
    final chiD = [r.ch1Dob, r.ch2Dob, r.ch3Dob, r.ch4Dob];
    for (int i = 0; i < 4; i++) {
      _chName[i].text = chiN[i] ?? '';
      _chDob[i].text = chiD[i] ?? '';
    }
    final svf = [r.sv1F, r.sv2F, r.sv3F, r.sv4F];
    final svt = [r.sv1T, r.sv2T, r.sv3T, r.sv4T];
    for (int i = 0; i < 4; i++) {
      _svF[i].text = svf[i] ?? '';
      _svT[i].text = svt[i] ?? '';
    }
    setState(() {
      _rank = r.rank;
      _bloodGp = r.bloodGp;
      _status = r.status;
      _photoPath = r.photoPath;
      _domicile = r.domicile;
      _chSex[0] = r.ch1Sex;
      _chSex[1] = r.ch2Sex;
      _chSex[2] = r.ch3Sex;
      _chSex[3] = r.ch4Sex;
    });
  }

  void _clear() {
    for (final c in [
      _icNo,
      _name,
      _cdaAc,
      _iCard,
      _bDay,
      _mAnn,
      _honours,
      _medCat,
      _diag,
      _dueOn,
      _presAddr,
      _permtAddr,
      _teleNos,
      _emailIds,
      _dob,
      _doc,
      _dor,
      _dom,
      _wife,
      _wifeBday,
      _cYo,
      _cMmg,
      _cMor,
      _cSnip,
      _cAdp,
      _cAtgm,
      _cPwt,
      _cJc,
      _cSc,
      _cCdo,
      _cQm,
      _cTac,
      _cRcl,
      _cRso,
      _cPt,
      _cDssc,
      _cBsw,
      _cOth,
      _pLt,
      _pCapt,
      _pMaj,
      _pLtCol,
      _pCol,
      _pBrig,
      _pMajGen,
      _pLtGen,
      _cmdF,
      _cmdT
    ]) {
      c.clear();
    }
    for (final c in [..._chName, ..._chDob, ..._svF, ..._svT]) c.clear();
    setState(() {
      _rank = null;
      _bloodGp = null;
      _status = null;
      _photoPath = null;
      _domicile = null;
      for (int i = 0; i < 4; i++) _chSex[i] = null;
    });
  }

  OfficerModel _buildModel() {
    final m = OfficerModel(
        subCategory: widget.subCategory, id: widget.record?.id ?? _savedId);
    m.icNo = _icNo.text.trim();
    m.rank = _rank;
    m.name = _name.text.trim();
    m.bloodGp = _bloodGp;
    m.dob = _dob.text;
    m.doc = _doc.text;
    m.dor = _dor.text;
    m.dom = _dom.text;
    m.domicile = _domicile;
    m.cdaAcNo = _cdaAc.text.trim();
    m.iCardNo = _iCard.text.trim();
    m.bDay = _bDay.text;
    m.mAnn = _mAnn.text;
    m.honoursAwards = _honours.text.trim();
    m.medCat = _medCat.text.trim();
    m.diag = _diag.text.trim();
    m.dueOn = _dueOn.text;
    m.presentAddress = _presAddr.text.trim();
    m.permtAddress = _permtAddr.text.trim();
    m.status = _status;
    m.teleNos = _teleNos.text.trim();
    m.emailIds = _emailIds.text.trim();
    m.photoPath = _photoPath;
    m.wifeName = _wife.text.trim();
    m.wifeBday = _wifeBday.text;
    m.ch1Name = _chName[0].text;
    m.ch1Sex = _chSex[0];
    m.ch1Dob = _chDob[0].text;
    m.ch2Name = _chName[1].text;
    m.ch2Sex = _chSex[1];
    m.ch2Dob = _chDob[1].text;
    m.ch3Name = _chName[2].text;
    m.ch3Sex = _chSex[2];
    m.ch3Dob = _chDob[2].text;
    m.ch4Name = _chName[3].text;
    m.ch4Sex = _chSex[3];
    m.ch4Dob = _chDob[3].text;
    m.cYo = _cYo.text;
    m.cMmgAgl = _cMmg.text;
    m.cMorO = _cMor.text;
    m.cSniper = _cSnip.text;
    m.cAdp = _cAdp.text;
    m.cAtgm = _cAtgm.text;
    m.cPwt = _cPwt.text;
    m.cJc = _cJc.text;
    m.cSc = _cSc.text;
    m.cCdoGtk = _cCdo.text;
    m.cQmO = _cQm.text;
    m.cTac = _cTac.text;
    m.cRcl = _cRcl.text;
    m.cRso = _cRso.text;
    m.cPt = _cPt.text;
    m.cDssc = _cDssc.text;
    m.cBswO = _cBsw.text;
    m.cOthers = _cOth.text;
    m.pLt = _pLt.text;
    m.pCapt = _pCapt.text;
    m.pMaj = _pMaj.text;
    m.pLtCol = _pLtCol.text;
    m.pCol = _pCol.text;
    m.pBrig = _pBrig.text;
    m.pMajGen = _pMajGen.text;
    m.pLtGen = _pLtGen.text;
    m.sv1F = _svF[0].text;
    m.sv1T = _svT[0].text;
    m.sv2F = _svF[1].text;
    m.sv2T = _svT[1].text;
    m.sv3F = _svF[2].text;
    m.sv3T = _svT[2].text;
    m.sv4F = _svF[3].text;
    m.sv4T = _svT[3].text;
    m.cmdF = _cmdF.text;
    m.cmdT = _cmdT.text;
    return m;
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      showSnack(context, 'Name is required.', error: true);
      return;
    }
    if (_icNo.text.trim().isEmpty) {
      showSnack(context, 'IC No is required.', error: true);
      return;
    }
    setState(() => _saving = true);
    widget.onReady(this);
    try {
      final m = _buildModel();
      final dup = await _db.officerIcNoExists(m.icNo, excludeId: m.id);
      if (dup) {
        if (mounted)
          showSnack(context,
              'IC No "${m.icNo}" already exists — cannot save duplicate.',
              error: true);
        if (mounted) {
          setState(() => _saving = false);
          widget.onReady(this);
        }
        return;
      }
      if (m.id == null) {
        _savedId = await _db.insertOfficer(m);
      } else
        await _db.updateOfficer(m);
      if (mounted) {
        showSnack(context, m.id == null ? 'Record saved.' : 'Record updated.');
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Error: $e', error: true);
    }
    if (mounted) {
      setState(() => _saving = false);
      widget.onReady(this);
    }
  }

  Future<void> _delete() async {
    if (widget.record?.id == null) return;
    final ok = await confirmDialog(context, 'Delete Record',
        'Permanently delete "${widget.record!.name}"?');
    if (!ok) return;
    await _db.deleteOfficer(widget.record!.id!);
    if (mounted) {
      showSnack(context, 'Record deleted.');
      widget.onSaved();
    }
  }

  Future<void> _pickPhoto() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.image);
    if (r == null) return;
    final src = File(r.files.single.path!);
    final dir = await _db.photosDirectory;
    final fn = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    await src.copy(p.join(dir, fn));
    setState(() => _photoPath = p.join(dir, fn));
  }

  Future<void> _pd(TextEditingController c) =>
      pickDate(context, c).then((_) => setState(() {}));

  // ── helpers ───────────────────────────────────────────────────────────────
  Widget _f(String label, TextEditingController c, {double w = 210}) =>
      SizedBox(
          width: w,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(label.toUpperCase(), style: kLabelStyle)),
                TextField(
                    controller: c, style: kFieldStyle, decoration: kDec()),
              ]));

  Widget _fDate(String label, TextEditingController c, {double w = 160}) =>
      SizedBox(
          width: w,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(label.toUpperCase(), style: kLabelStyle)),
                TextField(
                    controller: c,
                    readOnly: true,
                    style: kFieldStyle,
                    onTap: () => _pd(c),
                    decoration: kDec().copyWith(
                        suffixIcon: const Icon(Icons.calendar_today_outlined,
                            size: 14))),
              ]));

  Widget _dd(String label, String? val, List<String> opts,
          void Function(String?) cb, {double w = 170}) =>
      SizedBox(
          width: w,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(label.toUpperCase(), style: kLabelStyle)),
                DropdownButtonFormField<String>(
                    value: val,
                    isExpanded: true,
                    style: kFieldStyle.copyWith(color: kInk),
                    items: opts
                        .map((o) => DropdownMenuItem(
                            value: o, child: Text(o, style: kFieldStyle)))
                        .toList(),
                    onChanged: cb),
              ]));

  // ── Flex variants (no fixed width — sized by the Expanded/Row they sit in).
  // Used for PERS DETAILS so every row fills its full width edge-to-edge
  // with no leftover gaps, regardless of window size.
  Widget _ff(String label, TextEditingController c) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(label.toUpperCase(), style: kLabelStyle)),
            TextField(controller: c, style: kFieldStyle, decoration: kDec()),
          ]);

  Widget _ffDate(String label, TextEditingController c) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(label.toUpperCase(), style: kLabelStyle)),
            TextField(
                controller: c,
                readOnly: true,
                style: kFieldStyle,
                onTap: () => _pd(c),
                decoration: kDec().copyWith(
                    suffixIcon:
                        const Icon(Icons.calendar_today_outlined, size: 14))),
          ]);

  Widget _ffDD(String label, String? val, List<String> opts,
          void Function(String?) cb) =>
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(label.toUpperCase(), style: kLabelStyle)),
            DropdownButtonFormField<String>(
                value: val,
                isExpanded: true,
                style: kFieldStyle.copyWith(color: kInk),
                items: opts
                    .map((o) => DropdownMenuItem(
                        value: o, child: Text(o, style: kFieldStyle)))
                    .toList(),
                onChanged: cb),
          ]);

  Widget _ffMulti(String label, TextEditingController c, {int lines = 2}) =>
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(label.toUpperCase(), style: kLabelStyle)),
            TextField(
                controller: c,
                maxLines: lines,
                style: kFieldStyle,
                decoration: kDec()),
          ]);

  // A full-width row of fields, each taking a proportional share (flex) of
  // the row so there's never leftover empty space at the row's end.
  Widget _fRow(List<(int flex, Widget field)> items) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            Expanded(flex: items[i].$1, child: items[i].$2),
          ],
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Card title
      Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: kGold,
              border: Border(bottom: BorderSide(color: kAccentBlue, width: 2))),
          child: Text(SubCat.cardTitle(widget.subCategory),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .6,
                  color: kSlate))),
      const SizedBox(height: 14),
      // Pers Details
      CardSection(
          title: 'Pers Details',
          icon: Icons.badge_outlined,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _fRow([
                    (2, _ff('IC No', _icNo)),
                    (
                      2,
                      _ffDD('Rank', _rank, kOfficerRanks,
                          (v) => setState(() => _rank = v))
                    ),
                    (3, _ff('Name', _name)),
                    (
                      1,
                      _ffDD('Blood Gp', _bloodGp, kBlood,
                          (v) => setState(() => _bloodGp = v))
                    )
                  ]),
                  const SizedBox(height: 14),
                  _fRow([
                    (1, _ffDate('DOB', _dob)),
                    (1, _ffDate('DOC', _doc)),
                    (1, _ffDate('DOR', _dor)),
                    (1, _ffDate('DOM', _dom)),
                    (
                      1,
                      _ffDD('Domicile', _domicile, kDomicile,
                          (v) => setState(() => _domicile = v))
                    )
                  ]),
                  const SizedBox(height: 14),
                  _fRow([
                    (2, _ff('CDA (O) A/C No', _cdaAc)),
                    (2, _ff('I Card No', _iCard)),
                    (1, _ffDate('B. Day', _bDay)),
                    (1, _ffDate('M. Ann', _mAnn)),
                    (1, _ff('Med Cat', _medCat))
                  ]),
                  const SizedBox(height: 14),
                  _fRow([
                    (2, _ff('Diag', _diag)),
                    (1, _ffDate('Due On', _dueOn)),
                    (
                      1,
                      _ffDD('Status', _status, kOfficerStatus,
                          (v) => setState(() => _status = v))
                    ),
                    (2, _ff('Tele Nos', _teleNos))
                  ]),
                  const SizedBox(height: 14),
                  _fRow([
                    (1, _ff('Email Ids', _emailIds)),
                    (2, _ffMulti('Honours and Awards', _honours, lines: 2))
                  ]),
                  const SizedBox(height: 14),
                  _fRow([
                    (1, _ffMulti('Present Address', _presAddr, lines: 2)),
                    (1, _ffMulti('Permt Address', _permtAddr, lines: 2))
                  ]),
                ])),
            const SizedBox(width: 16),
            PhotoBox(photoPath: _photoPath, onTap: _pickPhoto),
          ])),
      // Kindred Roll
      CardSection(
          title: 'Kindred Roll',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 14, runSpacing: 14, children: [
              _f('Wife', _wife, w: 280),
              _fDate('B. Day', _wifeBday, w: 150),
            ]),
            const SizedBox(height: 14),
            const SubLabel('Children'),
            _childrenTable(),
          ])),
      // Army Courses
      CardSection(
          title: 'Army Courses',
          child: Wrap(spacing: 14, runSpacing: 14, children: [
            _f('YO', _cYo, w: 140),
            _f('MMG AGL', _cMmg, w: 140),
            _f('MOR (O)', _cMor, w: 140),
            _f('Sniper', _cSnip, w: 140),
            _f('ADP', _cAdp, w: 140),
            _f('ATGM', _cAtgm, w: 140),
            _f('PWT', _cPwt, w: 140),
            _f('JC', _cJc, w: 140),
            _f('SC', _cSc, w: 140),
            _f('CDO/GTK', _cCdo, w: 140),
            _f('QM (O)', _cQm, w: 140),
            _f('TAC', _cTac, w: 140),
            _f('RCL', _cRcl, w: 140),
            _f('RSO', _cRso, w: 140),
            _f('PT', _cPt, w: 140),
            _f('DSSC', _cDssc, w: 140),
            _f('BSW (O)', _cBsw, w: 140),
            _f('Others', _cOth, w: 140),
          ])),
      // Promotions
      CardSection(
          title: 'Promotions',
          child: Wrap(spacing: 14, runSpacing: 14, children: [
            _fDate('LT', _pLt, w: 150),
            _fDate('Capt', _pCapt, w: 150),
            _fDate('Maj', _pMaj, w: 150),
            _fDate('Lt Col', _pLtCol, w: 150),
            _fDate('Col', _pCol, w: 150),
            _fDate('Brig', _pBrig, w: 150),
            _fDate('Maj Gen', _pMajGen, w: 150),
            _fDate('Lt Gen', _pLtGen, w: 150),
          ])),
      // Service in Unit
      CardSection(
          title: 'Service in Unit',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _serviceTable(),
            const SizedBox(height: 14),
            const SubLabel('Command Tenure'),
            Wrap(spacing: 14, runSpacing: 14, children: [
              _fDate('From', _cmdF, w: 170),
              _fDate('To', _cmdT, w: 170),
            ]),
          ])),
      const SizedBox(height: 20),
    ]);
  }

  Widget _childrenTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2)
      },
      children: [
        TableRow(children: [
          _tHdr('Children Name'),
          _tHdr('Gender'),
          _tHdr('DOB'),
        ]),
        for (int i = 0; i < 4; i++)
          TableRow(children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 10),
                child: TextField(
                    controller: _chName[i],
                    style: kFieldStyle,
                    decoration: kDec())),
            Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 10),
                child: DropdownButtonFormField<String>(
                  value: _chSex[i],
                  isExpanded: true,
                  style: kFieldStyle.copyWith(color: kInk),
                  items: kSex
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _chSex[i] = v),
                )),
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                    controller: _chDob[i],
                    readOnly: true,
                    style: kFieldStyle,
                    onTap: () => _pd(_chDob[i]),
                    decoration: kDec().copyWith(
                        suffixIcon: const Icon(Icons.calendar_today_outlined,
                            size: 14)))),
          ]),
      ],
    );
  }

  Widget _serviceTable() {
    return Table(
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
      children: [
        TableRow(children: [_tHdr('From'), _tHdr('To')]),
        for (int i = 0; i < 4; i++)
          TableRow(children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 10),
                child: TextField(
                    controller: _svF[i],
                    readOnly: true,
                    style: kFieldStyle,
                    onTap: () => _pd(_svF[i]),
                    decoration: kDec().copyWith(
                        suffixIcon: const Icon(Icons.calendar_today_outlined,
                            size: 14)))),
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                    controller: _svT[i],
                    readOnly: true,
                    style: kFieldStyle,
                    onTap: () => _pd(_svT[i]),
                    decoration: kDec().copyWith(
                        suffixIcon: const Icon(Icons.calendar_today_outlined,
                            size: 14)))),
          ]),
      ],
    );
  }

  Widget _tHdr(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(t.toUpperCase(), style: kLabelStyle));
}
