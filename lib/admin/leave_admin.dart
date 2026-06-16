import 'package:flutter/material.dart';
import '../shared.dart';
import '../db/database.dart';
import '../db/admin_models.dart';
import 'army_search.dart';

class LeaveAdmin extends StatefulWidget {
  const LeaveAdmin({super.key});
  @override
  State<LeaveAdmin> createState() => _LeaveAdminState();
}

class _LeaveAdminState extends State<LeaveAdmin> {
  final _db = AppDatabase.instance;
  String? _armyNo, _soldierName, _soldierRank, _soldierCoy;
  bool _saving = false;

  String? _leaveType;
  final _fromDt=TextEditingController(); final _toDt=TextEditingController();
  final _days=TextEditingController(); final _repDt=TextEditingController();
  final _remarks=TextEditingController();
  List<LeaveRecord> _history = [];

  @override
  void dispose(){
    for(final c in [_fromDt,_toDt,_days,_repDt,_remarks]) c.dispose();
    super.dispose();
  }

  Future<void> _onSoldierSelected(String an, String nm, String rk, String cy) async {
    setState((){_armyNo=an;_soldierName=nm;_soldierRank=rk;_soldierCoy=cy;});
    _history = await _db.getLeaveByArmyNo(an);
    setState((){});
  }

  Future<void> _submit() async {
    if(_armyNo==null){showSnack(context,'Select a soldier first.',error:true);return;}
    if(_leaveType==null){showSnack(context,'Select leave type.',error:true);return;}
    if(_fromDt.text.isEmpty||_toDt.text.isEmpty){showSnack(context,'From/To dates required.',error:true);return;}
    setState(()=>_saving=true);
    final rec=LeaveRecord(armyNo:_armyNo!)
      ..leaveType=_leaveType..fromDt=_fromDt.text..toDt=_toDt.text
      ..days=_days.text..reportingDt=_repDt.text..remarks=_remarks.text;
    await _db.insertLeave(rec);
    _history = await _db.getLeaveByArmyNo(_armyNo!);
    _clearForm();
    if(mounted){showSnack(context,'Leave record added.');setState(()=>_saving=false);}
  }

  void _clearForm(){_leaveType=null;for(final c in [_fromDt,_toDt,_days,_repDt,_remarks])c.clear();}

  Future<void> _pd(TextEditingController c)=>pickDate(context,c).then((_)=>setState((){}));

  @override
  Widget build(BuildContext context){
    return Column(children:[
      Container(color:kHeader,padding:const EdgeInsets.symmetric(horizontal:16,vertical:10),
        child:const Text('LEAVE MANAGEMENT',style:kSectionTitle)),
      Expanded(child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        // Left: form
        SizedBox(width:480,child:SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
            ArmySearchBox(onSelected:_onSoldierSelected),
            if(_armyNo!=null)...[
              const SizedBox(height:10),
              Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFFE8EAF0),borderRadius:BorderRadius.circular(6)),
                child:Text('$_soldierRank $_soldierName — $_armyNo — Coy $_soldierCoy',style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13,color:kSlate))),
            ],
            const SizedBox(height:16),
            const SectionHeader('Add Leave Record'),
            const SizedBox(height:12),
            _dd('Leave Type',_leaveType,kLeaveTypes,(v)=>setState(()=>_leaveType=v)),
            const SizedBox(height:10),
            Row(children:[
              Expanded(child:_fDate('From Date',_fromDt)),
              const SizedBox(width:10),
              Expanded(child:_fDate('To Date',_toDt)),
            ]),
            const SizedBox(height:10),
            Row(children:[
              Expanded(child:_f('No of Days',_days)),
              const SizedBox(width:10),
              Expanded(child:_fDate('Reporting Date',_repDt)),
            ]),
            const SizedBox(height:10),
            _f('Remarks',_remarks),
            const SizedBox(height:16),
            SizedBox(width:double.infinity,child:FilledButton.icon(
              onPressed:_saving?null:_submit,
              icon:_saving?const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)):const Icon(Icons.save_outlined,size:18),
              label:const Text('Submit Leave Record'),
              style:FilledButton.styleFrom(backgroundColor:kSlate,padding:const EdgeInsets.symmetric(vertical:14)))),
          ]))),
        Container(width:1,color:kBorder),
        // Right: history
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Container(width:double.infinity,color:kSilver1,padding:const EdgeInsets.symmetric(horizontal:16,vertical:9),
            child:Text(_armyNo==null?'Leave History':'Leave History — $_soldierName',
                style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13,color:kInk))),
          Expanded(child:_history.isEmpty
              ? const Center(child:Text('Select a soldier to see history.',style:TextStyle(color:kInkSoft)))
              : ListView.separated(
                  itemCount:_history.length,
                  separatorBuilder:(_,__)=>const Divider(height:1,color:kBorder),
                  itemBuilder:(_,i){
                    final r=_history[i];
                    return ListTile(
                      leading:Container(width:44,height:44,decoration:BoxDecoration(color:const Color(0xFFE8EAF0),borderRadius:BorderRadius.circular(22)),
                          child:const Icon(Icons.event_note,size:22,color:kSlate)),
                      title:Text(r.leaveType??'-',style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13)),
                      subtitle:Text('${r.fromDt??'-'} → ${r.toDt??'-'}  •  ${r.days??'?'} days  •  Reporting: ${r.reportingDt??'-'}',
                          style:const TextStyle(fontSize:11)),
                      trailing:IconButton(icon:const Icon(Icons.delete_outline,size:18,color:kDanger),
                        onPressed:() async {
                          final ok=await confirmDialog(context,'Delete','Remove this leave record?');
                          if(!ok)return;
                          await _db.deleteLeave(r.id!);
                          _history=await _db.getLeaveByArmyNo(_armyNo!);
                          setState((){});
                        }));
                  })),
        ])),
      ])),
    ]);
  }

  Widget _f(String l,TextEditingController c)=>Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
    Padding(padding:const EdgeInsets.only(bottom:4),child:Text(l.toUpperCase(),style:kLabelStyle)),
    TextField(controller:c,style:kFieldStyle,decoration:kDec())]);

  Widget _fDate(String l,TextEditingController c)=>Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
    Padding(padding:const EdgeInsets.only(bottom:4),child:Text(l.toUpperCase(),style:kLabelStyle)),
    TextField(controller:c,readOnly:true,style:kFieldStyle,onTap:()=>_pd(c),
        decoration:kDec().copyWith(suffixIcon:const Icon(Icons.calendar_today_outlined,size:14)))]);

  Widget _dd(String l,String? v,List<String> opts,void Function(String?) cb)=>Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
    Padding(padding:const EdgeInsets.only(bottom:4),child:Text(l.toUpperCase(),style:kLabelStyle)),
    DropdownButtonFormField<String>(value:v,isExpanded:true,style:kFieldStyle.copyWith(color:kInk),
        items:opts.map((o)=>DropdownMenuItem(value:o,child:Text(o,style:kFieldStyle))).toList(),onChanged:cb)]);
}
