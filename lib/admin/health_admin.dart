import 'package:flutter/material.dart';
import '../shared.dart';
import '../db/database.dart';
import '../db/admin_models.dart';
import 'army_search.dart';

class HealthAdmin extends StatefulWidget {
  const HealthAdmin({super.key});
  @override State<HealthAdmin> createState() => _HealthAdminState();
}
class _HealthAdminState extends State<HealthAdmin> {
  final _db=AppDatabase.instance;
  String? _armyNo,_name,_rank,_coy,_medCat; bool _saving=false;
  final _diag=TextEditingController(); final _hospital=TextEditingController();
  final _boardDt=TextEditingController(); final _dueOn=TextEditingController();
  final _remarks=TextEditingController();
  List<HealthRecord> _history=[];

  @override void dispose(){for(final c in[_diag,_hospital,_boardDt,_dueOn,_remarks])c.dispose();super.dispose();}

  Future<void> _onSel(String an,String nm,String rk,String cy) async {
    setState((){_armyNo=an;_name=nm;_rank=rk;_coy=cy;});
    _history=await _db.getHealthByArmyNo(an);setState((){});
  }
  Future<void> _submit() async {
    if(_armyNo==null){showSnack(context,'Select a soldier.',error:true);return;}
    if(_medCat==null){showSnack(context,'Select Med Cat.',error:true);return;}
    setState(()=>_saving=true);
    final r=HealthRecord(armyNo:_armyNo!)..medCat=_medCat..diag=_diag.text
      ..hospital=_hospital.text..boardDt=_boardDt.text..dueOn=_dueOn.text..remarks=_remarks.text;
    await _db.insertHealth(r);
    _history=await _db.getHealthByArmyNo(_armyNo!);
    setState((){_medCat=null;});
    for(final c in[_diag,_hospital,_boardDt,_dueOn,_remarks])c.clear();
    if(mounted){showSnack(context,'Health record added.');setState(()=>_saving=false);}
  }
  Future<void> _pd(TextEditingController c)=>pickDate(context,c).then((_)=>setState((){}));
  Widget _f(String l,TextEditingController c)=>Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
    Padding(padding:const EdgeInsets.only(bottom:4),child:Text(l.toUpperCase(),style:kLabelStyle)),TextField(controller:c,style:kFieldStyle,decoration:kDec())]);
  Widget _fDate(String l,TextEditingController c)=>Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
    Padding(padding:const EdgeInsets.only(bottom:4),child:Text(l.toUpperCase(),style:kLabelStyle)),
    TextField(controller:c,readOnly:true,style:kFieldStyle,onTap:()=>_pd(c),decoration:kDec().copyWith(suffixIcon:const Icon(Icons.calendar_today_outlined,size:14)))]);
  Widget _dd(String l,String? v,List<String> opts,void Function(String?) cb)=>Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
    Padding(padding:const EdgeInsets.only(bottom:4),child:Text(l.toUpperCase(),style:kLabelStyle)),
    DropdownButtonFormField<String>(value:v,isExpanded:true,style:kFieldStyle.copyWith(color:kInk),
        items:opts.map((o)=>DropdownMenuItem(value:o,child:Text(o,style:kFieldStyle))).toList(),onChanged:cb)]);

  @override Widget build(BuildContext context){
    return Column(children:[
      Container(color:kHeader,padding:const EdgeInsets.symmetric(horizontal:16,vertical:10),child:const Text('HEALTH RECORDS',style:kSectionTitle)),
      Expanded(child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        SizedBox(width:480,child:SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          ArmySearchBox(onSelected:_onSel),
          if(_armyNo!=null)...[const SizedBox(height:10),Container(padding:const EdgeInsets.all(12),
            decoration:BoxDecoration(color:const Color(0xFFE8EAF0),borderRadius:BorderRadius.circular(6)),
            child:Text('$_rank $_name — $_armyNo',style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13,color:kSlate)))],
          const SizedBox(height:16),const SectionHeader('Add Health Record'),const SizedBox(height:12),
          _dd('Med Cat',_medCat,['A1','A2','A3','B1','B2','C1','C2','CEE'],(v)=>setState(()=>_medCat=v)),
          const SizedBox(height:10),_f('Diagnosis',_diag),const SizedBox(height:10),
          _f('Hospital / MH',_hospital),const SizedBox(height:10),
          Row(children:[Expanded(child:_fDate('Board Date',_boardDt)),const SizedBox(width:10),Expanded(child:_fDate('Due On',_dueOn))]),
          const SizedBox(height:10),_f('Remarks',_remarks),const SizedBox(height:16),
          SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:_saving?null:_submit,
            icon:const Icon(Icons.save_outlined,size:18),label:const Text('Submit Health Record'),
            style:FilledButton.styleFrom(backgroundColor:kSlate,padding:const EdgeInsets.symmetric(vertical:14)))),
        ]))),
        Container(width:1,color:kBorder),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Container(width:double.infinity,color:kSilver1,padding:const EdgeInsets.symmetric(horizontal:16,vertical:9),
            child:Text(_armyNo==null?'Health History':'Health History — $_name',style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13))),
          Expanded(child:_history.isEmpty?const Center(child:Text('Select a soldier.',style:TextStyle(color:kInkSoft)))
              :ListView.separated(itemCount:_history.length,separatorBuilder:(_,__)=>const Divider(height:1,color:kBorder),
                itemBuilder:(_,i){final r=_history[i];return ListTile(
                  leading:Container(width:44,height:44,decoration:BoxDecoration(color:const Color(0xFFE8EAF0),borderRadius:BorderRadius.circular(22)),
                      child:const Icon(Icons.health_and_safety_outlined,size:22,color:kSlate)),
                  title:Text('Med Cat: ${r.medCat??'-'}',style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13)),
                  subtitle:Text('${r.diag??'-'}  •  ${r.hospital??'-'}  •  Board: ${r.boardDt??'-'}  •  Due: ${r.dueOn??'-'}',style:const TextStyle(fontSize:11)),
                  trailing:IconButton(icon:const Icon(Icons.delete_outline,size:18,color:kDanger),onPressed:() async {
                    final ok=await confirmDialog(context,'Delete','Remove this health record?');if(!ok)return;
                    await _db.deleteHealth(r.id!);_history=await _db.getHealthByArmyNo(_armyNo!);setState((){});
                  }));})),
        ])),
      ])),
    ]);
  }
}
