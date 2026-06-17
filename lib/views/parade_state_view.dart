import 'package:flutter/material.dart';
import '../shared.dart';
import '../db/database.dart';

class ParadeStateView extends StatefulWidget {
  const ParadeStateView({super.key});
  @override
  State<ParadeStateView> createState() => _ParadeStateViewState();
}

class _ParadeStateViewState extends State<ParadeStateView> {
  final _db = AppDatabase.instance;
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final d = await _db.getParadeState();
    if (mounted)
      setState(() {
        _data = d;
        _loading = false;
      });
  }

  int _v(String k) => (_data[k] ?? 0) as int;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          color: kHeader,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            const Expanded(child: Text('PARADE STATE', style: kSectionTitle)),
            IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                tooltip: 'Refresh'),
          ])),
      Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Expanded(child: _officersBlock()),
                              const SizedBox(width: 16),
                              Expanded(child: _jcoColumn()),
                              const SizedBox(width: 16),
                              Expanded(child: _orColumn()),
                              const SizedBox(width: 16),
                              Expanded(child: _adminBlock()),
                            ])),
                        const SizedBox(height: 28),
                        IntrinsicHeight(
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Expanded(
                                  child: _barChart('PRESENT STATE', [
                                _BarItem('Officers', _v('off_present'),
                                    const Color(0xFFE83E5B)),
                                _BarItem('JCO', _v('jco_present_jco'),
                                    const Color(0xFF36A2EB)),
                                _BarItem('OR', _v('jco_present_or'),
                                    const Color(0xFFFFA726)),
                              ])),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _barChart('OUT STRENGTH', [
                                _BarItem('Officer', _v('out_str_officer'),
                                    const Color(0xFF8BC34A)),
                                _BarItem('JCO', _v('out_str_jco'),
                                    const Color(0xFF36A2EB)),
                                _BarItem('OR', _v('out_str_or'),
                                    const Color(0xFFFFA726)),
                              ])),
                            ])),
                        const SizedBox(height: 12),
                      ]))),
    ]);
  }

  // ── Officers column (unchanged) ──────────────────────────────────────────
  Widget _officersBlock() => _block('OFFICERS', [
        _row('Present', _v('off_present'), false),
        _row('Ex COs', _v('off_ex_cos'), false),
        _row('Serving Other Unit', _v('off_other_unit'), false),
        _row('Retired', _v('off_retired'), false),
        _divider(),
        _row('TOTAL OFFICERS', _v('off_total'), true),
      ]);

  // ── JCO column: single container ─────────────────────────────────────────
  Widget _jcoColumn() => _block('JCOs', [
        _row('Nb Sub', _v('jco_nbsub'), false),
        _row('Sub', _v('jco_sub'), false),
        _row('Sub Maj', _v('jco_submaj'), false),
        _divider(),
        _row('Total JCOs', _v('jco_present_jco'), true),
        _divider(),
        _row('JCO On ERE', _v('jco_on_ere_jco'), false),
        _row('JCO On Retd', _v('jco_retired_jco'), false),
      ]);

  // ── OR column: single container ──────────────────────────────────────────
  Widget _orColumn() => _block("OR's", [
        _row('Sep', _v('or_sep'), false),
        _row('L/Nk', _v('or_lnk'), false),
        _row('Nk', _v('or_nk'), false),
        _row('Hav', _v('or_hav'), false),
        _divider(),
        _row('Total OR', _v('jco_present_or'), true),
        _divider(),
        _row('OR On ERE', _v('jco_on_ere_or'), false),
        _row('OR On Retd', _v('jco_retired_or'), false),
      ]);

  Widget _adminBlock() => _block('ADMIN RECORDS', [
        _row('Leave Records', _v('leave_today'), false),
        _row('ERE Records', _v('ere_total'), false),
        _row('Health Records', _v('health_total'), false),
        _row('Out Strength', _v('out_str_total'), false),
      ]);

  Widget _block(String title, List<Widget> rows) => Container(
      decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        SectionHeader(title),
        ...rows,
      ]));

  Widget _row(String label, int val, bool bold) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: kBorder, width: .5)),
          color: bold ? const Color(0xFFF0F1F4) : kSurface),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                    color: kInk))),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: bold ? kSlate : const Color(0xFFE8EAF0),
                borderRadius: BorderRadius.circular(20)),
            child: Text('$val',
                style: TextStyle(
                    fontSize: bold ? 15 : 13,
                    fontWeight: FontWeight.w800,
                    color: bold ? Colors.white : kInk))),
      ]));

  Widget _divider() => Container(height: 1, color: const Color(0xFFB0B6C0));

  // ── Bar chart ─────────────────────────────────────────────────────────────
  Widget _barChart(String title, List<_BarItem> items) {
    const chartHeight = 200.0;
    final maxVal =
        items.map((b) => b.value).fold<int>(0, (p, e) => e > p ? e : p);
    final scaleMax = maxVal == 0 ? 1 : (maxVal * 1.25).ceil();

    final bars = <Widget>[];
    for (final b in items) {
      final h = (b.value / scaleMax * (chartHeight - 34))
          .clamp(0.0, chartHeight - 34);
      bars.add(Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('${b.value}',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900, color: kInk)),
          const SizedBox(height: 4),
          Container(
            width: 54,
            height: h,
            decoration: BoxDecoration(
              color: b.color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                    color: b.color.withOpacity(.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
          ),
        ],
      ));
    }

    final chartArea = Container(
      height: chartHeight,
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Color(0xFF8A8F99), width: 1.4),
          bottom: BorderSide(color: Color(0xFF8A8F99), width: 1.4),
        ),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: bars,
      ),
    );

    final yAxisLabel = SizedBox(
      height: chartHeight,
      width: 18,
      child: RotatedBox(
        quarterTurns: 3,
        child: Center(
          child: Text('NUMBER OF PERSONNEL',
              style: TextStyle(
                  fontSize: 10,
                  color: kInkSoft,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .4)),
        ),
      ),
    );

    final labels = <Widget>[];
    for (final b in items) {
      labels.add(SizedBox(
        width: 54,
        child: Text(b.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: kInk)),
      ));
    }

    return Container(
      decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.fromLTRB(20, 16, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .5,
                  color: kSlate)),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              yAxisLabel,
              const SizedBox(width: 8),
              Expanded(child: chartArea),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 26),
              Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: labels)),
            ],
          ),
          const SizedBox(height: 4),
          const Center(
              child: Text('Personnel Type',
                  style: TextStyle(
                      fontSize: 10,
                      color: kInkSoft,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .3))),
        ],
      ),
    );
  }
}

class _BarItem {
  final String label;
  final int value;
  final Color color;
  _BarItem(this.label, this.value, this.color);
}
