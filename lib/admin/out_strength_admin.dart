import 'package:flutter/material.dart';
import '../shared.dart';
import '../db/database.dart';
import '../db/admin_models.dart';
import 'army_search.dart';

class OutStrengthAdmin extends StatefulWidget {
  const OutStrengthAdmin({super.key});
  @override State<OutStrengthAdmin> createState() => _OutStrengthAdminState();
}
class _OutStrengthAdminState extends State<OutStrengthAdmin> {
  final _db=AppDatabase.instance;
  String? _armyNo,_name,_rank,_coy,_reason; bool _saving=false;
  final _location=TextEditingController(); final _fromDt=TextEditingController();
  final _expRet=TextEditingController(); final _remarks=TextEditingController();
  List<OutStrengthRecord> _history=[];

  @override void dispose(){for(final c in[_location,_fromDt,_expRet,_remarks])c.dispose();super.dispose();}

  Future<void> _onSel(String an,String nm,String rk,String cy) async {
    setState((){_armyNo=an;_name=nm;_rank=rk;_coy=cy;});
    _history=await _db.getOutStrByArmyNo(an);setState((){});
  }
  Future<void> _submit() async {
    if(_armyNo==null){showSnack(context,'Select a soldier.',error:true);return;}
    if(_reason==null){showSnack(context,'Select reason.',error:true);return;}
    setState(()=>_saving=true);
    final r=OutStrengthRecord(armyNo:_armyNo!)..reason=_reason..location=_location.text
      ..fromDt=_fromDt.text..expectedReturn=_expRet.text..remarks=_remarks.text;
    await _db.insertOutStr(r);
    _history=await _db.getOutStrByArmyNo(_armyNo!);
    setState((){_reason=null;});for(final c in[_location,_fromDt,_expRet,_remarks])c.clear();
    if(mounted){showSnack(context,'Out Strength record added.');setState(()=>_saving=false);}
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
      Container(color:kHeader,padding:const EdgeInsets.symmetric(horizontal:16,vertical:10),child:const Text('OUT STRENGTH',style:kSectionTitle)),
      Expanded(child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        SizedBox(width:480,child:SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          ArmySearchBox(onSelected:_onSel),
          if(_armyNo!=null)...[const SizedBox(height:10),Container(padding:const EdgeInsets.all(12),
            decoration:BoxDecoration(color:const Color(0xFFE8EAF0),borderRadius:BorderRadius.circular(6)),
            child:Text('$_rank $_name — $_armyNo — Coy $_coy',style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13,color:kSlate)))],
          const SizedBox(height:16),const SectionHeader('Add Out Strength Record'),const SizedBox(height:12),
          _dd('Reason',_reason,kOutReasons,(v)=>setState(()=>_reason=v)),const SizedBox(height:10),
          _f('Location / Station',_location),const SizedBox(height:10),
          Row(children:[Expanded(child:_fDate('From Date',_fromDt)),const SizedBox(width:10),Expanded(child:_fDate('Expected Return',_expRet))]),
          const SizedBox(height:10),_f('Remarks',_remarks),const SizedBox(height:16),
          SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:_saving?null:_submit,
            icon:const Icon(Icons.save_outlined,size:18),label:const Text('Submit Record'),
            style:FilledButton.styleFrom(backgroundColor:kSlate,padding:const EdgeInsets.symmetric(vertical:14)))),
        ]))),
        Container(width:1,color:kBorder),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Container(width:double.infinity,color:kSilver1,padding:const EdgeInsets.symmetric(horizontal:16,vertical:9),
            child:Text(_armyNo==null?'Out Strength History':'History — $_name',style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13))),
          Expanded(child:_history.isEmpty?const Center(child:Text('Select a soldier.',style:TextStyle(color:kInkSoft)))
              :ListView.separated(itemCount:_history.length,separatorBuilder:(_,__)=>const Divider(height:1,color:kBorder),
                itemBuilder:(_,i){final r=_history[i];return ListTile(
                  leading:Container(width:44,height:44,decoration:BoxDecoration(color:const Color(0xFFE8EAF0),borderRadius:BorderRadius.circular(22)),
                      child:const Icon(Icons.directions_walk,size:22,color:kSlate)),
                  title:Text(r.reason??'-',style:const TextStyle(fontWeight:FontWeight.w700,fontSize:13)),
                  subtitle:Text('${r.location??'-'}  •  From: ${r.fromDt??'-'}  •  Return: ${r.expectedReturn??'-'}',style:const TextStyle(fontSize:11)),
                  trailing:IconButton(icon:const Icon(Icons.delete_outline,size:18,color:kDanger),onPressed:() async {
                    final ok=await confirmDialog(context,'Delete','Remove this record?');if(!ok)return;
                    await _db.deleteOutStr(r.id!);_history=await _db.getOutStrByArmyNo(_armyNo!);setState((){});
                  }));})),
        ])),
      ])),
    ]);
  }
}
