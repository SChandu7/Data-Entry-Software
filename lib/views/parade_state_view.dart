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
  Map<String,dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(()=>_loading=true);
    final d = await _db.getParadeState();
    if(mounted) setState((){_data=d;_loading=false;});
  }

  int _v(String k) => (_data[k] ?? 0) as int;

  @override
  Widget build(BuildContext context) {
    return Column(children:[
      Container(color:kHeader, padding:const EdgeInsets.symmetric(horizontal:16,vertical:10),
        child:Row(children:[
          const Expanded(child:Text('PARADE STATE', style:kSectionTitle)),
          IconButton(onPressed:_load, icon:const Icon(Icons.refresh,color:Colors.white,size:20),
              tooltip:'Refresh'),
        ])),
      Expanded(child: _loading
          ? const Center(child:CircularProgressIndicator())
          : SingleChildScrollView(padding:const EdgeInsets.all(20),
              child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Expanded(child:_officersBlock()),
                const SizedBox(width:20),
                Expanded(child:Column(children:[_jcoBlock(),const SizedBox(height:16),_adminBlock()])),
                const SizedBox(width:20),
                Expanded(child:_grandTotal()),
              ]))),
    ]);
  }

  Widget _officersBlock() => _block('OFFICERS', [
    _row('Present',         _v('off_present'),      false),
    _row('Ex COs',          _v('off_ex_cos'),        false),
    _row('Serving Other Unit', _v('off_other_unit'), false),
    _row('Retired',         _v('off_retired'),       false),
    _divider(),
    _row('TOTAL OFFICERS',  _v('off_total'),         true),
  ]);

  Widget _jcoBlock() => _block("JCOs / OR's", [
    _row('Present',         _v('jco_present'),   false),
    _row('On ERE',          _v('jco_on_ere'),    false),
    _row('Retired',         _v('jco_retired'),   false),
    _row('Short',           _v('jco_short'),     false),
    _row('New Entry',       _v('jco_new_entry'), false),
    _divider(),
    _row('TOTAL JCOs/OR',   _v('jco_total'),     true),
  ]);

  Widget _adminBlock() => _block('ADMIN RECORDS', [
    _row('Leave Records',   _v('leave_today'),  false),
    _row('ERE Records',     _v('ere_total'),    false),
    _row('Health Records',  _v('health_total'), false),
    _row('Out Strength',    _v('out_str_total'),false),
  ]);

  Widget _grandTotal() => Container(
    decoration:BoxDecoration(color:kSlate,borderRadius:BorderRadius.circular(8)),
    padding:const EdgeInsets.all(20),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('GRAND TOTAL', style:TextStyle(color:Colors.white70,fontSize:11,fontWeight:FontWeight.w800,letterSpacing:.5)),
      const SizedBox(height:20),
      _bigNum('Officers', _v('off_total')),
      const SizedBox(height:16),
      _bigNum("JCOs/OR's", _v('jco_total')),
      const SizedBox(height:24),
      Container(height:1, color:Colors.white24),
      const SizedBox(height:16),
      _bigNum('ALL STRENGTH', _v('off_total')+_v('jco_total'), big:true),
    ]));

  Widget _bigNum(String label, int val, {bool big=false}) => Column(
    crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(label, style:const TextStyle(color:Colors.white60, fontSize:12)),
    Text('$val', style:TextStyle(color:Colors.white,
        fontSize: big?52:36, fontWeight:FontWeight.w900, height:1.1)),
  ]);

  Widget _block(String title, List<Widget> rows) => Container(
    decoration:BoxDecoration(color:kSurface,border:Border.all(color:kBorder),borderRadius:BorderRadius.circular(8)),
    clipBehavior:Clip.antiAlias,
    child:Column(children:[
      SectionHeader(title),
      ...rows,
    ]));

  Widget _row(String label, int val, bool bold) => Container(
    padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),
    decoration:BoxDecoration(border:Border(bottom:BorderSide(color:kBorder,width:.5)),
        color: bold ? const Color(0xFFF0F1F4) : kSurface),
    child:Row(children:[
      Expanded(child:Text(label, style:TextStyle(fontSize:13,
          fontWeight: bold?FontWeight.w800:FontWeight.w500, color:kInk))),
      Container(
        padding:const EdgeInsets.symmetric(horizontal:12,vertical:4),
        decoration:BoxDecoration(
          color: bold ? kSlate : const Color(0xFFE8EAF0),
          borderRadius:BorderRadius.circular(20)),
        child:Text('$val', style:TextStyle(
          fontSize: bold?15:13, fontWeight:FontWeight.w800,
          color: bold ? Colors.white : kInk))),
    ]));

  Widget _divider() => Container(height:1, color:const Color(0xFFB0B6C0));
}
