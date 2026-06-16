import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../shared.dart';
import '../db/database.dart';
import '../db/models.dart';

class JcoOnEreCard extends StatefulWidget {
  final JcoOrModel? record;
  final VoidCallback onSaved;
  const JcoOnEreCard({super.key, this.record, required this.onSaved});
  @override
  State<JcoOnEreCard> createState() => _JcoOnEreCardState();
}

class _JcoOnEreCardState extends State<JcoOnEreCard> {
  final _db = AppDatabase.instance;
  bool _saving = false;

  // Pers (On ERE specific: +sos, +returnDt, +personalProblem; -svcExtn, -aadhar, -email)
  final _armyNo=TextEditingController(); final _name=TextEditingController();
  final _dob=TextEditingController(); final _doe=TextEditingController();
  final _dor=TextEditingController(); final _tos=TextEditingController();
  final _sos=TextEditingController(); final _returnDt=TextEditingController();
  final _rrEre=TextEditingController(); final _icard=TextEditingController();
  final _honours=TextEditingController(); final _pan=TextEditingController();
  final _caste=TextEditingController(); final _civEdn=TextEditingController();
  final _medCat=TextEditingController(); final _persProblem=TextEditingController();
  final _diag=TextEditingController(); final _dueOn=TextEditingController();
  String? _rank, _coy, _bloodGp, _photoPath;

  // Kindred
  final _father=TextEditingController(); final _mother=TextEditingController();
  final _wife=TextEditingController(); final _nok=TextEditingController();
  final List<TextEditingController> _chN=List.generate(4,(_)=>TextEditingController());
  final List<TextEditingController> _chD=List.generate(4,(_)=>TextEditingController());
  final List<String?> _chS=List.filled(4,null,growable:false);

  // Bank (Single + Joint — no code no for On ERE)
  final _singAcct=TextEditingController(); final _singBank=TextEditingController();
  final _jntAcct=TextEditingController(); final _jntBank=TextEditingController();

  // Home address
  final _hTele=TextEditingController(); final _hVill=TextEditingController();
  final _hPost=TextEditingController(); final _hToff=TextEditingController();
  final _hTeh=TextEditingController(); final _hDist=TextEditingController();
  final _hState=TextEditingController(); final _hPin=TextEditingController();
  final _hNrs=TextEditingController();

  // Courses
  final _cSec=TextEditingController(); final _cMmg=TextEditingController();
  final _cMor=TextEditingController(); final _cSnip=TextEditingController();
  final _cAdp=TextEditingController(); final _cAtgm=TextEditingController();
  final _cDrill=TextEditingController(); final _cBmic=TextEditingController();
  final _cUei=TextEditingController(); final _cCdo=TextEditingController();
  final _cQm=TextEditingController(); final _cRsi=TextEditingController();
  final _cJlc=TextEditingController(); final _cPc=TextEditingController();
  final _cPt=TextEditingController(); final _cTpt=TextEditingController();
  final _cMisc=TextEditingController();

  // Army Edn (+TTT-I/II/III for On ERE)
  String? _eMr1,_eMr2,_eMr3,_eAce1,_eAce2,_eAce3,_eAec3,_eTtt1,_eTtt2,_eTtt3;

  // Promotion Cadres
  final _pcUmm=TextEditingController(); final _pcHav=TextEditingController(); final _pcNb=TextEditingController();

  // Promotions
  final _pLnk=TextEditingController(); final _pNaik=TextEditingController();
  final _pHav=TextEditingController(); final _pNbSub=TextEditingController();
  final _pSub=TextEditingController(); final _pSubMaj=TextEditingController();
  final _pAcp=TextEditingController();

  // ERE
  final List<TextEditingController> _ereN=List.generate(3,(_)=>TextEditingController());
  final List<TextEditingController> _ereF=List.generate(3,(_)=>TextEditingController());
  final List<TextEditingController> _ereT=List.generate(3,(_)=>TextEditingController());

  // Discipline (2 initial rows for On ERE)
  final List<TextEditingController> _dOff=List.generate(5,(_)=>TextEditingController());
  final List<TextEditingController> _dAwd=List.generate(5,(_)=>TextEditingController());
  final List<TextEditingController> _dDt=List.generate(5,(_)=>TextEditingController());
  final List<String?> _dEnt=List.filled(5,null,growable:false);
  int _discRows = 2; // On ERE starts with 2 rows

  @override
  void initState() { super.initState(); if(widget.record!=null) _populate(widget.record!); }

  @override
  void didUpdateWidget(JcoOnEreCard o) {
    super.didUpdateWidget(o);
    if(o.record!=widget.record){if(widget.record!=null)_populate(widget.record!);else _clear();}
  }

  @override
  void dispose() {
    for(final c in [_armyNo,_name,_dob,_doe,_dor,_tos,_sos,_returnDt,_rrEre,_icard,
        _honours,_pan,_caste,_civEdn,_medCat,_persProblem,_diag,_dueOn,
        _father,_mother,_wife,_nok,_singAcct,_singBank,_jntAcct,_jntBank,
        _hTele,_hVill,_hPost,_hToff,_hTeh,_hDist,_hState,_hPin,_hNrs,
        _cSec,_cMmg,_cMor,_cSnip,_cAdp,_cAtgm,_cDrill,_cBmic,_cUei,
        _cCdo,_cQm,_cRsi,_cJlc,_cPc,_cPt,_cTpt,_cMisc,
        _pcUmm,_pcHav,_pcNb,_pLnk,_pNaik,_pHav,_pNbSub,_pSub,_pSubMaj,_pAcp]) c.dispose();
    for(final c in [..._chN,..._chD,..._ereN,..._ereF,..._ereT,..._dOff,..._dAwd,..._dDt]) c.dispose();
    super.dispose();
  }

  void _populate(JcoOrModel r) {
    _armyNo.text=r.armyNo??''; _name.text=r.name??'';
    _dob.text=r.dob??''; _doe.text=r.doe??''; _dor.text=r.dor??'';
    _tos.text=r.tos??''; _sos.text=r.sos??''; _returnDt.text=r.returnDt??'';
    _rrEre.text=r.rrEreFmn??''; _icard.text=r.icardNo??'';
    _honours.text=r.honoursAwards??''; _pan.text=r.panCardNo??'';
    _caste.text=r.caste??''; _civEdn.text=r.civEdn??''; _medCat.text=r.medCat??'';
    _persProblem.text=r.personalProblem??''; _diag.text=r.diag??''; _dueOn.text=r.dueOn??'';
    _father.text=r.father??''; _mother.text=r.mother??'';
    _wife.text=r.wife??''; _nok.text=r.nextOfKin??'';
    _singAcct.text=r.singleAcctNo??''; _singBank.text=r.singleBankName??'';
    _jntAcct.text=r.jointAcctNo??''; _jntBank.text=r.jointBankName??'';
    _hTele.text=r.homeTele??'';_hVill.text=r.homeVillage??'';_hPost.text=r.homePost??'';
    _hToff.text=r.homeTOff??'';_hTeh.text=r.homeTehsil??'';_hDist.text=r.homeDistrict??'';
    _hState.text=r.homeState??'';_hPin.text=r.homePin??'';_hNrs.text=r.homeNrs??'';
    _cSec.text=r.cSecCdr??'';_cMmg.text=r.cMmgAgl??'';_cMor.text=r.cMorJn??'';
    _cSnip.text=r.cSniper??'';_cAdp.text=r.cAdp??'';_cAtgm.text=r.cAtgm??'';
    _cDrill.text=r.cDrill??'';_cBmic.text=r.cBmic??'';_cUei.text=r.cUei??'';
    _cCdo.text=r.cCdo??'';_cQm.text=r.cQm??'';_cRsi.text=r.cRsi??'';
    _cJlc.text=r.cJlc??'';_cPc.text=r.cPc??'';_cPt.text=r.cPt??'';
    _cTpt.text=r.cTpt??'';_cMisc.text=r.cMisc??'';
    _pcUmm.text=r.pcUmmedwar??'';_pcHav.text=r.pcHav??'';_pcNb.text=r.pcNbSub??'';
    _pLnk.text=r.pLnk??'';_pNaik.text=r.pNaik??'';_pHav.text=r.pHav??'';
    _pNbSub.text=r.pNbSub??'';_pSub.text=r.pSub??'';_pSubMaj.text=r.pSubMaj??'';_pAcp.text=r.pAcp??'';
    for(int i=0;i<3;i++){_ereN[i].text=[r.ere1Name,r.ere2Name,r.ere3Name][i]??'';
      _ereF[i].text=[r.ere1From,r.ere2From,r.ere3From][i]??'';
      _ereT[i].text=[r.ere1To,r.ere2To,r.ere3To][i]??'';}
    for(int i=0;i<4;i++){_chN[i].text=[r.ch1Name,r.ch2Name,r.ch3Name,r.ch4Name][i]??'';
      _chD[i].text=[r.ch1Dob,r.ch2Dob,r.ch3Dob,r.ch4Dob][i]??'';}
    final do_=[r.d1Off,r.d2Off,r.d3Off,r.d4Off,r.d5Off];
    final da=[r.d1Awd,r.d2Awd,r.d3Awd,r.d4Awd,r.d5Awd];
    final dd=[r.d1Dt,r.d2Dt,r.d3Dt,r.d4Dt,r.d5Dt];
    final de=[r.d1Ent,r.d2Ent,r.d3Ent,r.d4Ent,r.d5Ent];
    for(int i=0;i<5;i++){_dOff[i].text=do_[i]??'';_dAwd[i].text=da[i]??'';_dDt[i].text=dd[i]??'';}
    setState((){
      _rank=r.rank;_coy=r.coy;_bloodGp=r.bloodGp;_photoPath=r.photoPath;
      _chS[0]=r.ch1Sex;_chS[1]=r.ch2Sex;_chS[2]=r.ch3Sex;_chS[3]=r.ch4Sex;
      _eMr1=r.eMr1;_eMr2=r.eMr2;_eMr3=r.eMr3;
      _eAce1=r.eAce1;_eAce2=r.eAce2;_eAce3=r.eAce3;_eAec3=r.eAec3;
      _eTtt1=r.eTtt1;_eTtt2=r.eTtt2;_eTtt3=r.eTtt3;
      for(int i=0;i<5;i++) _dEnt[i]=de[i];
      _discRows = de.where((e)=>e!=null&&e.isNotEmpty).length.clamp(2,5);
    });
  }

  void _clear() {
    for(final c in [_armyNo,_name,_dob,_doe,_dor,_tos,_sos,_returnDt,_rrEre,_icard,
        _honours,_pan,_caste,_civEdn,_medCat,_persProblem,_diag,_dueOn,
        _father,_mother,_wife,_nok,_singAcct,_singBank,_jntAcct,_jntBank,
        _hTele,_hVill,_hPost,_hToff,_hTeh,_hDist,_hState,_hPin,_hNrs,
        _cSec,_cMmg,_cMor,_cSnip,_cAdp,_cAtgm,_cDrill,_cBmic,_cUei,
        _cCdo,_cQm,_cRsi,_cJlc,_cPc,_cPt,_cTpt,_cMisc,
        _pcUmm,_pcHav,_pcNb,_pLnk,_pNaik,_pHav,_pNbSub,_pSub,_pSubMaj,_pAcp]) c.clear();
    for(final c in [..._chN,..._chD,..._ereN,..._ereF,..._ereT,..._dOff,..._dAwd,..._dDt]) c.clear();
    setState((){
      _rank=null;_coy=null;_bloodGp=null;_photoPath=null;
      for(int i=0;i<4;i++) _chS[i]=null;
      _eMr1=null;_eMr2=null;_eMr3=null;_eAce1=null;_eAce2=null;_eAce3=null;_eAec3=null;
      _eTtt1=null;_eTtt2=null;_eTtt3=null;
      for(int i=0;i<5;i++) _dEnt[i]=null;
      _discRows=2;
    });
  }

  JcoOrModel _buildModel() {
    final m=JcoOrModel(subCategory:SubCat.jcoOnEre,id:widget.record?.id);
    m.armyNo=_armyNo.text.trim();m.rank=_rank;m.name=_name.text.trim();
    m.coy=_coy;m.dob=_dob.text;m.doe=_doe.text;m.dor=_dor.text;
    m.tos=_tos.text;m.sos=_sos.text;m.returnDt=_returnDt.text;
    m.rrEreFmn=_rrEre.text.trim();m.icardNo=_icard.text.trim();
    m.honoursAwards=_honours.text.trim();m.panCardNo=_pan.text.trim();
    m.bloodGp=_bloodGp;m.caste=_caste.text.trim();m.civEdn=_civEdn.text.trim();
    m.medCat=_medCat.text.trim();m.personalProblem=_persProblem.text.trim();
    m.diag=_diag.text.trim();m.dueOn=_dueOn.text;m.photoPath=_photoPath;
    m.father=_father.text.trim();m.mother=_mother.text.trim();
    m.wife=_wife.text.trim();m.nextOfKin=_nok.text.trim();
    m.ch1Name=_chN[0].text;m.ch1Sex=_chS[0];m.ch1Dob=_chD[0].text;
    m.ch2Name=_chN[1].text;m.ch2Sex=_chS[1];m.ch2Dob=_chD[1].text;
    m.ch3Name=_chN[2].text;m.ch3Sex=_chS[2];m.ch3Dob=_chD[2].text;
    m.ch4Name=_chN[3].text;m.ch4Sex=_chS[3];m.ch4Dob=_chD[3].text;
    m.singleAcctNo=_singAcct.text.trim();m.singleBankName=_singBank.text.trim();
    m.jointAcctNo=_jntAcct.text.trim();m.jointBankName=_jntBank.text.trim();
    m.homeTele=_hTele.text;m.homeVillage=_hVill.text;m.homePost=_hPost.text;
    m.homeTOff=_hToff.text;m.homeTehsil=_hTeh.text;m.homeDistrict=_hDist.text;
    m.homeState=_hState.text;m.homePin=_hPin.text;m.homeNrs=_hNrs.text;
    m.cSecCdr=_cSec.text;m.cMmgAgl=_cMmg.text;m.cMorJn=_cMor.text;
    m.cSniper=_cSnip.text;m.cAdp=_cAdp.text;m.cAtgm=_cAtgm.text;
    m.cDrill=_cDrill.text;m.cBmic=_cBmic.text;m.cUei=_cUei.text;
    m.cCdo=_cCdo.text;m.cQm=_cQm.text;m.cRsi=_cRsi.text;
    m.cJlc=_cJlc.text;m.cPc=_cPc.text;m.cPt=_cPt.text;m.cTpt=_cTpt.text;m.cMisc=_cMisc.text;
    m.eMr1=_eMr1;m.eMr2=_eMr2;m.eMr3=_eMr3;
    m.eAce1=_eAce1;m.eAce2=_eAce2;m.eAce3=_eAce3;m.eAec3=_eAec3;
    m.eTtt1=_eTtt1;m.eTtt2=_eTtt2;m.eTtt3=_eTtt3;
    m.pcUmmedwar=_pcUmm.text;m.pcHav=_pcHav.text;m.pcNbSub=_pcNb.text;
    m.pLnk=_pLnk.text;m.pNaik=_pNaik.text;m.pHav=_pHav.text;
    m.pNbSub=_pNbSub.text;m.pSub=_pSub.text;m.pSubMaj=_pSubMaj.text;m.pAcp=_pAcp.text;
    m.ere1Name=_ereN[0].text;m.ere1From=_ereF[0].text;m.ere1To=_ereT[0].text;
    m.ere2Name=_ereN[1].text;m.ere2From=_ereF[1].text;m.ere2To=_ereT[1].text;
    m.ere3Name=_ereN[2].text;m.ere3From=_ereF[2].text;m.ere3To=_ereT[2].text;
    m.d1Off=_dOff[0].text;m.d1Awd=_dAwd[0].text;m.d1Dt=_dDt[0].text;m.d1Ent=_dEnt[0];
    m.d2Off=_dOff[1].text;m.d2Awd=_dAwd[1].text;m.d2Dt=_dDt[1].text;m.d2Ent=_dEnt[1];
    m.d3Off=_dOff[2].text;m.d3Awd=_dAwd[2].text;m.d3Dt=_dDt[2].text;m.d3Ent=_dEnt[2];
    m.d4Off=_dOff[3].text;m.d4Awd=_dAwd[3].text;m.d4Dt=_dDt[3].text;m.d4Ent=_dEnt[3];
    m.d5Off=_dOff[4].text;m.d5Awd=_dAwd[4].text;m.d5Dt=_dDt[4].text;m.d5Ent=_dEnt[4];
    return m;
  }

  Future<void> _save() async {
    if(_name.text.trim().isEmpty){showSnack(context,'Name is required.',error:true);return;}
    if(_armyNo.text.trim().isEmpty){showSnack(context,'Army No is required.',error:true);return;}
    setState(()=>_saving=true);
    try {
      final m=_buildModel();
      if(m.id==null)await _db.insertJco(m);else await _db.updateJco(m);
      if(mounted){showSnack(context,m.id==null?'Record saved.':'Record updated.');widget.onSaved();}
    }catch(e){if(mounted)showSnack(context,'Error: $e',error:true);}
    if(mounted)setState(()=>_saving=false);
  }

  Future<void> _delete() async {
    if(widget.record?.id==null)return;
    final ok=await confirmDialog(context,'Delete Record','Permanently delete "${widget.record!.name}"?');
    if(!ok)return;
    await _db.deleteJco(widget.record!.id!);
    if(mounted){showSnack(context,'Record deleted.');widget.onSaved();}
  }

  Future<void> _pickPhoto() async {
    final r=await FilePicker.platform.pickFiles(type:FileType.image);
    if(r==null)return;
    final src=File(r.files.single.path!);
    final dir=await _db.photosDirectory;
    final fn='${DateTime.now().millisecondsSinceEpoch}.jpg';
    await src.copy(p.join(dir,fn));
    setState(()=>_photoPath=p.join(dir,fn));
  }

  Future<void> _pd(TextEditingController c)=>pickDate(context,c).then((_)=>setState((){}));

  Widget _f(String l,TextEditingController c,{double w=210})=>SizedBox(width:w,
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
      Padding(padding:const EdgeInsets.only(bottom:4),child:Text(l.toUpperCase(),style:kLabelStyle)),
      TextField(controller:c,style:kFieldStyle,decoration:kDec())]));

  Widget _fDate(String l,TextEditingController c,{double w=160})=>SizedBox(width:w,
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
      Padding(padding:const EdgeInsets.only(bottom:4),child:Text(l.toUpperCase(),style:kLabelStyle)),
      TextField(controller:c,readOnly:true,style:kFieldStyle,onTap:()=>_pd(c),
          decoration:kDec().copyWith(suffixIcon:const Icon(Icons.calendar_today_outlined,size:14)))]));

  Widget _dd(String l,String? val,List<String> opts,void Function(String?) cb,{double w=170})=>
    SizedBox(width:w,child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
      Padding(padding:const EdgeInsets.only(bottom:4),child:Text(l.toUpperCase(),style:kLabelStyle)),
      DropdownButtonFormField<String>(value:val,isExpanded:true,
          style:kFieldStyle.copyWith(color:kInk),
          items:opts.map((o)=>DropdownMenuItem(value:o,child:Text(o,style:kFieldStyle))).toList(),
          onChanged:cb)]));

  Widget _ednDd(String l,String? val,void Function(String?) cb)=>SizedBox(width:118,
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
      Padding(padding:const EdgeInsets.only(bottom:4),child:Text(l.toUpperCase(),style:kLabelStyle)),
      DropdownButtonFormField<String>(value:val,isExpanded:true,
          style:kFieldStyle.copyWith(color:kInk),
          items:kPassFail.map((o)=>DropdownMenuItem(value:o,child:Text(o,style:kFieldStyle))).toList(),
          onChanged:cb)]));

  Widget _tHdr(String t)=>Padding(padding:const EdgeInsets.only(bottom:6,left:2),
      child:Text(t.toUpperCase(),style:kLabelStyle));

  Widget _childTable()=>Table(
    columnWidths:const{0:FlexColumnWidth(3),1:FlexColumnWidth(1),2:FlexColumnWidth(2)},
    children:[TableRow(children:[_tHdr('Name'),_tHdr('Sex'),_tHdr('DOB')]),
      for(int i=0;i<4;i++) TableRow(children:[
        Padding(padding:const EdgeInsets.only(bottom:8,right:10),
            child:TextField(controller:_chN[i],style:kFieldStyle,decoration:kDec())),
        Padding(padding:const EdgeInsets.only(bottom:8,right:10),
            child:DropdownButtonFormField<String>(value:_chS[i],isExpanded:true,
                style:kFieldStyle.copyWith(color:kInk),
                items:kSex.map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),
                onChanged:(v)=>setState(()=>_chS[i]=v))),
        Padding(padding:const EdgeInsets.only(bottom:8),
            child:TextField(controller:_chD[i],readOnly:true,style:kFieldStyle,onTap:()=>_pd(_chD[i]),
                decoration:kDec().copyWith(suffixIcon:const Icon(Icons.calendar_today_outlined,size:14)))),
      ])]);

  Widget _ereTable()=>Table(
    columnWidths:const{0:FlexColumnWidth(4),1:FlexColumnWidth(2),2:FlexColumnWidth(2)},
    children:[TableRow(children:[_tHdr('ERE Name'),_tHdr('From'),_tHdr('To')]),
      for(int i=0;i<3;i++) TableRow(children:[
        Padding(padding:const EdgeInsets.only(bottom:8,right:10),
            child:TextField(controller:_ereN[i],style:kFieldStyle,decoration:kDec())),
        Padding(padding:const EdgeInsets.only(bottom:8,right:10),
            child:TextField(controller:_ereF[i],readOnly:true,style:kFieldStyle,onTap:()=>_pd(_ereF[i]),
                decoration:kDec().copyWith(suffixIcon:const Icon(Icons.calendar_today_outlined,size:14)))),
        Padding(padding:const EdgeInsets.only(bottom:8),
            child:TextField(controller:_ereT[i],readOnly:true,style:kFieldStyle,onTap:()=>_pd(_ereT[i]),
                decoration:kDec().copyWith(suffixIcon:const Icon(Icons.calendar_today_outlined,size:14)))),
      ])]);

  @override
  Widget build(BuildContext context){
    return Column(children:[
      Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:10,horizontal:14),
        color:const Color(0xFFE8E9EC),
        child:const Text('JCOs OR (ON ERE) : DATA CARD',
            style:TextStyle(fontSize:15,fontWeight:FontWeight.w900,letterSpacing:.4,color:kSlate))),
      const SizedBox(height:14),
      CardSection(title:'Pers Details',child:Column(children:[
        Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Expanded(child:Wrap(spacing:14,runSpacing:14,children:[
            _f('Army No',_armyNo,w:170),
            _dd('Rank',_rank,kJcoRanks,(v)=>setState(()=>_rank=v),w:140),
            _f('Name',_name,w:290),
            _fDate('DOB',_dob,w:150),_fDate('DOE',_doe,w:150),_fDate('DOR',_dor,w:150),
            _fDate('TOS',_tos,w:150),_fDate('SOS',_sos,w:150),_fDate('Return Dt',_returnDt,w:160),
            _dd('Coy',_coy,kCoys,(v)=>setState(()=>_coy=v),w:100),
            _f('RR/ERE/FMN',_rrEre,w:220),
            _f('ICard No',_icard,w:160),_f('PAN Card No',_pan,w:180),
            _dd('Blood GP',_bloodGp,kBlood,(v)=>setState(()=>_bloodGp=v),w:120),
            _f('Caste',_caste,w:150),_f('Civ Edn',_civEdn,w:160),_f('Med Cat',_medCat,w:140),
            _f('Diag',_diag,w:200),_fDate('Due On',_dueOn,w:150),
            _f('Honours and Awards',_honours,w:440),_f('Personal Problem',_persProblem,w:440),
          ])),
          const SizedBox(width:16),
          PhotoBox(photoPath:_photoPath,onTap:_pickPhoto),
        ]),
      ])),
      CardSection(title:'Kindred Roll',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Wrap(spacing:14,runSpacing:14,children:[
          _f('Father',_father,w:230),_f('Mother',_mother,w:230),
          _f('Wife',_wife,w:230),_f('Next of Kin',_nok,w:230),
        ]),
        const SizedBox(height:14),const SubLabel('Children'),_childTable(),
      ])),
      CardSection(title:'Bank Details',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const SubLabel('Single Account'),
        Wrap(spacing:14,runSpacing:14,children:[_f('Acct No',_singAcct,w:240),_f('Bank Name',_singBank,w:310)]),
        const SizedBox(height:10),const SubLabel('Joint Account'),
        Wrap(spacing:14,runSpacing:14,children:[_f('Acct No',_jntAcct,w:240),_f('Bank Name',_jntBank,w:310)]),
      ])),
      CardSection(title:'Home Address',child:Wrap(spacing:14,runSpacing:14,children:[
        _f('Tele No',_hTele,w:180),_f('Village',_hVill,w:180),_f('Post',_hPost,w:180),_f('T Off',_hToff,w:160),
        _f('Tehsil',_hTeh,w:180),_f('District',_hDist,w:180),_f('State',_hState,w:150),_f('Pin',_hPin,w:120),_f('NRS',_hNrs,w:120),
      ])),
      CardSection(title:'Army Courses',child:Wrap(spacing:14,runSpacing:14,children:[
        _f('Sec Cdr',_cSec,w:140),_f('MMG AGL',_cMmg,w:140),_f('Mor Jn',_cMor,w:140),
        _f('Sniper',_cSnip,w:140),_f('ADP',_cAdp,w:140),_f('ATGM',_cAtgm,w:140),_f('Drill',_cDrill,w:140),
        _f('BMIC',_cBmic,w:140),_f('UEI',_cUei,w:140),_f('CDO',_cCdo,w:140),
        _f('QM',_cQm,w:140),_f('RSI',_cRsi,w:140),_f('JLC',_cJlc,w:140),_f('PC',_cPc,w:140),
        _f('PT',_cPt,w:140),_f('TPT',_cTpt,w:140),_f('Misc',_cMisc,w:140),
      ])),
      CardSection(title:'Army Edn',child:Wrap(spacing:14,runSpacing:14,children:[
        _ednDd('MR-I',_eMr1,(v)=>setState(()=>_eMr1=v)),
        _ednDd('MR-II',_eMr2,(v)=>setState(()=>_eMr2=v)),
        _ednDd('MR-III',_eMr3,(v)=>setState(()=>_eMr3=v)),
        _ednDd('ACE-I',_eAce1,(v)=>setState(()=>_eAce1=v)),
        _ednDd('ACE-II',_eAce2,(v)=>setState(()=>_eAce2=v)),
        _ednDd('ACE-III',_eAce3,(v)=>setState(()=>_eAce3=v)),
        _ednDd('AEC-III',_eAec3,(v)=>setState(()=>_eAec3=v)),
        _ednDd('TTT-I',_eTtt1,(v)=>setState(()=>_eTtt1=v)),
        _ednDd('TTT-II',_eTtt2,(v)=>setState(()=>_eTtt2=v)),
        _ednDd('TTT-III',_eTtt3,(v)=>setState(()=>_eTtt3=v)),
      ])),
      CardSection(title:'Promotion Cadres',child:Wrap(spacing:14,runSpacing:14,children:[
        _f('Ummedwar Cadre',_pcUmm,w:220),_f('Hav Cadre',_pcHav,w:220),_f('NB Sub Cadre',_pcNb,w:220),
      ])),
      CardSection(title:'Promotions',child:Wrap(spacing:14,runSpacing:14,children:[
        _fDate('L/Nk',_pLnk,w:150),_fDate('Naik',_pNaik,w:150),_fDate('Hav',_pHav,w:150),
        _fDate('Nb/Sub',_pNbSub,w:150),_fDate('Sub',_pSub,w:150),
        _fDate('Sub Maj',_pSubMaj,w:150),_fDate('ACP',_pAcp,w:150),
      ])),
      CardSection(title:'ERE Details',child:_ereTable()),
      CardSection(title:'Discipline',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Table(columnWidths:const{0:FlexColumnWidth(4),1:FlexColumnWidth(3),2:FlexColumnWidth(2),3:FlexColumnWidth(1)},
          children:[
            TableRow(children:[_tHdr('Offence'),_tHdr('Awarded'),_tHdr('Date'),_tHdr('Entry')]),
            for(int i=0;i<_discRows;i++) TableRow(children:[
              Padding(padding:const EdgeInsets.only(bottom:8,right:8),
                  child:TextField(controller:_dOff[i],style:kFieldStyle,decoration:kDec())),
              Padding(padding:const EdgeInsets.only(bottom:8,right:8),
                  child:TextField(controller:_dAwd[i],style:kFieldStyle,decoration:kDec())),
              Padding(padding:const EdgeInsets.only(bottom:8,right:8),
                  child:TextField(controller:_dDt[i],readOnly:true,style:kFieldStyle,onTap:()=>_pd(_dDt[i]),
                      decoration:kDec().copyWith(suffixIcon:const Icon(Icons.calendar_today_outlined,size:14)))),
              Padding(padding:const EdgeInsets.only(bottom:8),
                  child:DropdownButtonFormField<String>(value:_dEnt[i],isExpanded:true,
                      style:kFieldStyle.copyWith(color:kInk),
                      items:kEntryColour.map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),
                      onChanged:(v)=>setState(()=>_dEnt[i]=v))),
            ]),
          ]),
        if(_discRows<5) TextButton.icon(onPressed:()=>setState(()=>_discRows++),
            icon:const Icon(Icons.add,size:16),label:const Text('Add Row',style:TextStyle(fontSize:12))),
      ])),
      const SizedBox(height:8),
      BipFooter(isEditing:widget.record!=null,isSaving:_saving,
        onSave:_save,onDelete:_delete,onClear:_clear,
        onFind:()=>showSnack(context,'Use the filter panel on the right.'),
        onPrint:()=>showSnack(context,'Print: coming soon.'),onExit:(){}),
    ]);
  }
}
