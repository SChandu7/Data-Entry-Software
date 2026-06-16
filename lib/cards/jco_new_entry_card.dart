import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../shared.dart';
import '../db/database.dart';
import '../db/models.dart';

/// New Entry: unique Pers fields, different Leave, no Courses/Edn/Cadres/Discipline.
class JcoNewEntryCard extends StatefulWidget {
  final JcoOrModel? record;
  final VoidCallback onSaved;
  const JcoNewEntryCard({super.key, this.record, required this.onSaved});
  @override
  State<JcoNewEntryCard> createState() => _JcoNewEntryCardState();
}

class _JcoNewEntryCardState extends State<JcoNewEntryCard> {
  final _db = AppDatabase.instance;
  bool _saving = false;

  // Pers (New Entry has extra unique fields)
  final _armyNo=TextEditingController(); final _name=TextEditingController();
  final _dob=TextEditingController(); final _doe=TextEditingController();
  final _dor=TextEditingController(); final _tos=TextEditingController();
  final _rrEre=TextEditingController(); final _duration=TextEditingController();
  final _icard=TextEditingController(); final _honours=TextEditingController();
  final _pan=TextEditingController(); final _caste=TextEditingController();
  final _civEdn=TextEditingController(); final _medCat=TextEditingController();
  final _aadhar=TextEditingController(); final _diag=TextEditingController();
  final _dueOn=TextEditingController(); final _unitAtt=TextEditingController();
  final _email=TextEditingController(); final _dtIndn=TextEditingController();
  String? _rank, _coy, _bloodGp, _svcExtn, _photoPath;
  String? _presWithUnit, _krVerify, _maritalStatus, _repAt, _presLoc;

  // Kindred
  final _father=TextEditingController(); final _mother=TextEditingController();
  final _wife=TextEditingController(); final _nok=TextEditingController();
  final List<TextEditingController> _chN=List.generate(4,(_)=>TextEditingController());
  final List<TextEditingController> _chD=List.generate(4,(_)=>TextEditingController());
  final List<String?> _chS=List.filled(4,null,growable:false);

  // Leave (New Entry specific)
  final _avCl=TextEditingController(); final _avAl=TextEditingController();
  final _repOn=TextEditingController(); // REPORTING ON (date)
  String? _repFromMov;                  // REPORTED FROM MOV (dropdown)

  // Bank (simple like Present)
  final _acct=TextEditingController(); final _bank=TextEditingController();

  // Home address
  final _hTele=TextEditingController(); final _hVill=TextEditingController();
  final _hPost=TextEditingController(); final _hToff=TextEditingController();
  final _hTeh=TextEditingController(); final _hDist=TextEditingController();
  final _hState=TextEditingController(); final _hPin=TextEditingController();
  final _hNrs=TextEditingController();

  // Promotions
  final _pLnk=TextEditingController(); final _pNaik=TextEditingController();
  final _pHav=TextEditingController(); final _pNbSub=TextEditingController();
  final _pSub=TextEditingController(); final _pSubMaj=TextEditingController();
  final _pAcp=TextEditingController();

  // ERE
  final List<TextEditingController> _ereN=List.generate(3,(_)=>TextEditingController());
  final List<TextEditingController> _ereF=List.generate(3,(_)=>TextEditingController());
  final List<TextEditingController> _ereT=List.generate(3,(_)=>TextEditingController());

  @override
  void initState() { super.initState(); if(widget.record!=null)_populate(widget.record!); }
  @override
  void didUpdateWidget(JcoNewEntryCard o) {
    super.didUpdateWidget(o);
    if(o.record!=widget.record){if(widget.record!=null)_populate(widget.record!);else _clear();}
  }
  @override
  void dispose() {
    for(final c in [_armyNo,_name,_dob,_doe,_dor,_tos,_rrEre,_duration,_icard,_honours,_pan,
        _caste,_civEdn,_medCat,_aadhar,_diag,_dueOn,_unitAtt,_email,_dtIndn,
        _father,_mother,_wife,_nok,_avCl,_avAl,_repOn,_acct,_bank,
        _hTele,_hVill,_hPost,_hToff,_hTeh,_hDist,_hState,_hPin,_hNrs,
        _pLnk,_pNaik,_pHav,_pNbSub,_pSub,_pSubMaj,_pAcp]) c.dispose();
    for(final c in [..._chN,..._chD,..._ereN,..._ereF,..._ereT]) c.dispose();
    super.dispose();
  }

  void _populate(JcoOrModel r) {
    _armyNo.text=r.armyNo??'';_name.text=r.name??'';_dob.text=r.dob??'';
    _doe.text=r.doe??'';_dor.text=r.dor??'';_tos.text=r.tos??'';
    _rrEre.text=r.rrEreFmn??'';_duration.text=r.duration??'';_icard.text=r.icardNo??'';
    _honours.text=r.honoursAwards??'';_pan.text=r.panCardNo??'';_caste.text=r.caste??'';
    _civEdn.text=r.civEdn??'';_medCat.text=r.medCat??'';_aadhar.text=r.aadharCard??'';
    _diag.text=r.diag??'';_dueOn.text=r.dueOn??'';_unitAtt.text=r.unitAttPers??'';
    _email.text=r.emailId??'';_dtIndn.text=r.dtOfIndn??'';
    _father.text=r.father??'';_mother.text=r.mother??'';_wife.text=r.wife??'';_nok.text=r.nextOfKin??'';
    _avCl.text=r.availedCl??'';_avAl.text=r.availedAl??'';_repOn.text=r.reportingOn??'';
    _acct.text=r.acctNo??'';_bank.text=r.bankName??'';
    _hTele.text=r.homeTele??'';_hVill.text=r.homeVillage??'';_hPost.text=r.homePost??'';
    _hToff.text=r.homeTOff??'';_hTeh.text=r.homeTehsil??'';_hDist.text=r.homeDistrict??'';
    _hState.text=r.homeState??'';_hPin.text=r.homePin??'';_hNrs.text=r.homeNrs??'';
    _pLnk.text=r.pLnk??'';_pNaik.text=r.pNaik??'';_pHav.text=r.pHav??'';
    _pNbSub.text=r.pNbSub??'';_pSub.text=r.pSub??'';_pSubMaj.text=r.pSubMaj??'';_pAcp.text=r.pAcp??'';
    for(int i=0;i<3;i++){_ereN[i].text=[r.ere1Name,r.ere2Name,r.ere3Name][i]??'';
      _ereF[i].text=[r.ere1From,r.ere2From,r.ere3From][i]??'';
      _ereT[i].text=[r.ere1To,r.ere2To,r.ere3To][i]??'';}
    for(int i=0;i<4;i++){_chN[i].text=[r.ch1Name,r.ch2Name,r.ch3Name,r.ch4Name][i]??'';
      _chD[i].text=[r.ch1Dob,r.ch2Dob,r.ch3Dob,r.ch4Dob][i]??'';}
    setState((){_rank=r.rank;_coy=r.coy;_bloodGp=r.bloodGp;_svcExtn=r.serviceExtn;_photoPath=r.photoPath;
      _presWithUnit=r.presentWithUnit;_krVerify=r.kindredRollVerify;
      _maritalStatus=r.maritalStatus;_repAt=r.reportingAt;_presLoc=r.presentLoc;
      _repFromMov=r.reportedFromMov;
      _chS[0]=r.ch1Sex;_chS[1]=r.ch2Sex;_chS[2]=r.ch3Sex;_chS[3]=r.ch4Sex;});
  }

  void _clear() {
    for(final c in [_armyNo,_name,_dob,_doe,_dor,_tos,_rrEre,_duration,_icard,_honours,_pan,
        _caste,_civEdn,_medCat,_aadhar,_diag,_dueOn,_unitAtt,_email,_dtIndn,
        _father,_mother,_wife,_nok,_avCl,_avAl,_repOn,_acct,_bank,
        _hTele,_hVill,_hPost,_hToff,_hTeh,_hDist,_hState,_hPin,_hNrs,
        _pLnk,_pNaik,_pHav,_pNbSub,_pSub,_pSubMaj,_pAcp]) c.clear();
    for(final c in [..._chN,..._chD,..._ereN,..._ereF,..._ereT]) c.clear();
    setState((){_rank=null;_coy=null;_bloodGp=null;_svcExtn=null;_photoPath=null;
      _presWithUnit=null;_krVerify=null;_maritalStatus=null;_repAt=null;_presLoc=null;_repFromMov=null;
      for(int i=0;i<4;i++) _chS[i]=null;});
  }

  JcoOrModel _buildModel(){
    final m=JcoOrModel(subCategory:SubCat.jcoNewEntry,id:widget.record?.id);
    m.armyNo=_armyNo.text.trim();m.rank=_rank;m.name=_name.text.trim();
    m.coy=_coy;m.dob=_dob.text;m.doe=_doe.text;m.dor=_dor.text;
    m.tos=_tos.text;m.rrEreFmn=_rrEre.text.trim();m.duration=_duration.text.trim();
    m.serviceExtn=_svcExtn;m.icardNo=_icard.text.trim();
    m.honoursAwards=_honours.text.trim();m.panCardNo=_pan.text.trim();
    m.bloodGp=_bloodGp;m.caste=_caste.text.trim();m.civEdn=_civEdn.text.trim();
    m.medCat=_medCat.text.trim();m.aadharCard=_aadhar.text.trim();
    m.diag=_diag.text.trim();m.dueOn=_dueOn.text;
    m.presentWithUnit=_presWithUnit;m.kindredRollVerify=_krVerify;
    m.maritalStatus=_maritalStatus;m.unitAttPers=_unitAtt.text.trim();
    m.emailId=_email.text.trim();m.reportingAt=_repAt;m.presentLoc=_presLoc;
    m.dtOfIndn=_dtIndn.text;m.photoPath=_photoPath;
    m.father=_father.text.trim();m.mother=_mother.text.trim();
    m.wife=_wife.text.trim();m.nextOfKin=_nok.text.trim();
    m.ch1Name=_chN[0].text;m.ch1Sex=_chS[0];m.ch1Dob=_chD[0].text;
    m.ch2Name=_chN[1].text;m.ch2Sex=_chS[1];m.ch2Dob=_chD[1].text;
    m.ch3Name=_chN[2].text;m.ch3Sex=_chS[2];m.ch3Dob=_chD[2].text;
    m.ch4Name=_chN[3].text;m.ch4Sex=_chS[3];m.ch4Dob=_chD[3].text;
    m.availedCl=_avCl.text;m.availedAl=_avAl.text;
    m.reportingOn=_repOn.text;m.reportedFromMov=_repFromMov;
    m.acctNo=_acct.text.trim();m.bankName=_bank.text.trim();
    m.homeTele=_hTele.text;m.homeVillage=_hVill.text;m.homePost=_hPost.text;
    m.homeTOff=_hToff.text;m.homeTehsil=_hTeh.text;m.homeDistrict=_hDist.text;
    m.homeState=_hState.text;m.homePin=_hPin.text;m.homeNrs=_hNrs.text;
    m.pLnk=_pLnk.text;m.pNaik=_pNaik.text;m.pHav=_pHav.text;
    m.pNbSub=_pNbSub.text;m.pSub=_pSub.text;m.pSubMaj=_pSubMaj.text;m.pAcp=_pAcp.text;
    m.ere1Name=_ereN[0].text;m.ere1From=_ereF[0].text;m.ere1To=_ereT[0].text;
    m.ere2Name=_ereN[1].text;m.ere2From=_ereF[1].text;m.ere2To=_ereT[1].text;
    m.ere3Name=_ereN[2].text;m.ere3From=_ereF[2].text;m.ere3To=_ereT[2].text;
    return m;
  }

  Future<void> _save() async {
    if(_name.text.trim().isEmpty){showSnack(context,'Name is required.',error:true);return;}
    if(_armyNo.text.trim().isEmpty){showSnack(context,'Army No is required.',error:true);return;}
    setState(()=>_saving=true);
    try{final m=_buildModel();if(m.id==null)await _db.insertJco(m);else await _db.updateJco(m);
      if(mounted){showSnack(context,m.id==null?'Record added.':'Record updated.');widget.onSaved();}}
    catch(e){if(mounted)showSnack(context,'Error: $e',error:true);}
    if(mounted)setState(()=>_saving=false);
  }
  Future<void> _delete() async {
    if(widget.record?.id==null)return;
    final ok=await confirmDialog(context,'Delete Record','Permanently delete "${widget.record!.name}"?');
    if(!ok)return;await _db.deleteJco(widget.record!.id!);
    if(mounted){showSnack(context,'Record deleted.');widget.onSaved();}
  }
  Future<void> _pickPhoto() async {
    final r=await FilePicker.platform.pickFiles(type:FileType.image);if(r==null)return;
    final src=File(r.files.single.path!);final dir=await _db.photosDirectory;
    final fn='${DateTime.now().millisecondsSinceEpoch}.jpg';
    await src.copy(p.join(dir,fn));setState(()=>_photoPath=p.join(dir,fn));
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
      DropdownButtonFormField<String>(value:val,isExpanded:true,style:kFieldStyle.copyWith(color:kInk),
          items:opts.map((o)=>DropdownMenuItem(value:o,child:Text(o,style:kFieldStyle))).toList(),onChanged:cb)]));
  Widget _tHdr(String t)=>Padding(padding:const EdgeInsets.only(bottom:6,left:2),child:Text(t.toUpperCase(),style:kLabelStyle));
  Widget _childTable()=>Table(columnWidths:const{0:FlexColumnWidth(3),1:FlexColumnWidth(1),2:FlexColumnWidth(2)},
    children:[TableRow(children:[_tHdr('Name'),_tHdr('Sex'),_tHdr('DOB')]),
      for(int i=0;i<4;i++) TableRow(children:[
        Padding(padding:const EdgeInsets.only(bottom:8,right:10),child:TextField(controller:_chN[i],style:kFieldStyle,decoration:kDec())),
        Padding(padding:const EdgeInsets.only(bottom:8,right:10),child:DropdownButtonFormField<String>(value:_chS[i],isExpanded:true,
            style:kFieldStyle.copyWith(color:kInk),items:kSex.map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),
            onChanged:(v)=>setState(()=>_chS[i]=v))),
        Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(controller:_chD[i],readOnly:true,style:kFieldStyle,onTap:()=>_pd(_chD[i]),
            decoration:kDec().copyWith(suffixIcon:const Icon(Icons.calendar_today_outlined,size:14)))),
      ])]);
  Widget _ereTable()=>Table(columnWidths:const{0:FlexColumnWidth(4),1:FlexColumnWidth(2),2:FlexColumnWidth(2)},
    children:[TableRow(children:[_tHdr('ERE Name'),_tHdr('From'),_tHdr('To')]),
      for(int i=0;i<3;i++) TableRow(children:[
        Padding(padding:const EdgeInsets.only(bottom:8,right:10),child:TextField(controller:_ereN[i],style:kFieldStyle,decoration:kDec())),
        Padding(padding:const EdgeInsets.only(bottom:8,right:10),child:TextField(controller:_ereF[i],readOnly:true,style:kFieldStyle,onTap:()=>_pd(_ereF[i]),
            decoration:kDec().copyWith(suffixIcon:const Icon(Icons.calendar_today_outlined,size:14)))),
        Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(controller:_ereT[i],readOnly:true,style:kFieldStyle,onTap:()=>_pd(_ereT[i]),
            decoration:kDec().copyWith(suffixIcon:const Icon(Icons.calendar_today_outlined,size:14)))),
      ])]);

  @override
  Widget build(BuildContext context){
    return Column(children:[
      Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:10,horizontal:14),
        color:const Color(0xFFE8E9EC),
        child:const Text('JCOs/OR : DATA CARD (NEW ENTRY)',style:TextStyle(fontSize:15,fontWeight:FontWeight.w900,letterSpacing:.4,color:kSlate))),
      const SizedBox(height:14),
      // Pers Details (New Entry unique fields)
      CardSection(title:'Pers Details',child:Column(children:[Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Expanded(child:Wrap(spacing:14,runSpacing:14,children:[
          _f('Army No',_armyNo,w:170),_dd('Rank',_rank,kJcoRanks,(v)=>setState(()=>_rank=v),w:140),
          _f('Name',_name,w:290),_fDate('DOB',_dob,w:150),_fDate('DOE',_doe,w:150),
          _fDate('DOR',_dor,w:150),_fDate('TOS',_tos,w:150),
          _dd('Coy',_coy,kCoys,(v)=>setState(()=>_coy=v),w:100),
          _f('RR/ERE/FMN',_rrEre,w:220),_f('Duration',_duration,w:180),
          _f('ICard No',_icard,w:160),_f('PAN Card No',_pan,w:180),
          _dd('Blood GP',_bloodGp,kBlood,(v)=>setState(()=>_bloodGp=v),w:120),
          _f('Caste',_caste,w:150),_f('Civ Edn',_civEdn,w:160),_f('Med Cat',_medCat,w:140),
          _f('Aadhar Card',_aadhar,w:210),_f('Diag',_diag,w:200),_fDate('Due On',_dueOn,w:150),
          _dd('Present With Unit',_presWithUnit,kYesNo,(v)=>setState(()=>_presWithUnit=v),w:190),
          _dd('Kindred Roll Verify',_krVerify,kYesNo,(v)=>setState(()=>_krVerify=v),w:190),
          _dd('Marital Status',_maritalStatus,kMaritalStatus,(v)=>setState(()=>_maritalStatus=v),w:180),
          _dd('Service Extn',_svcExtn,kYesNo,(v)=>setState(()=>_svcExtn=v),w:160),
          _f('Unit Att Pers',_unitAtt,w:220),_f('E Mail Id',_email,w:270),
          _dd('Reporting at Giagong',_repAt,kYesNo,(v)=>setState(()=>_repAt=v),w:200),
          _dd('Present Loc',_presLoc,['Unit','ERE','Leave','Course','Attached'],(v)=>setState(()=>_presLoc=v),w:180),
          _fDate('Dt of Indn',_dtIndn,w:160),
          _f('Honours and Awards',_honours,w:440),
        ])),const SizedBox(width:16),PhotoBox(photoPath:_photoPath,onTap:_pickPhoto),
      ])])),
      // Kindred Roll
      CardSection(title:'Kindred Roll',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Wrap(spacing:14,runSpacing:14,children:[_f('Father',_father,w:230),_f('Mother',_mother,w:230),_f('Wife',_wife,w:230),_f('Next of Kin',_nok,w:230)]),
        const SizedBox(height:14),const SubLabel('Children'),_childTable(),
      ])),
      // Leave (New Entry specific)
      CardSection(title:'Leave Details',child:Wrap(spacing:14,runSpacing:14,children:[
        _f('Availed CL (Days)',_avCl,w:190),_f('Availed AL (Days)',_avAl,w:190),
        _fDate('Reporting On',_repOn,w:170),
        _dd('Reported From Mov',_repFromMov,['Yes','No','N/A'],(v)=>setState(()=>_repFromMov=v),w:200),
      ])),
      // Bank
      CardSection(title:'Bank Details',child:Wrap(spacing:14,runSpacing:14,children:[
        _f('Acct No',_acct,w:240),_f('Bank Name',_bank,w:310),
      ])),
      // Home Address
      CardSection(title:'Home Address',child:Wrap(spacing:14,runSpacing:14,children:[
        _f('Tele No',_hTele,w:180),_f('Village',_hVill,w:180),_f('Post',_hPost,w:180),_f('T Off',_hToff,w:160),
        _f('Tehsil',_hTeh,w:180),_f('District',_hDist,w:180),_f('State',_hState,w:150),_f('Pin',_hPin,w:120),_f('NRS',_hNrs,w:120),
      ])),
      // Promotions
      CardSection(title:'Promotions',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Wrap(spacing:14,runSpacing:14,children:[
          _fDate('L/Nk',_pLnk,w:150),_fDate('Naik',_pNaik,w:150),_fDate('Hav',_pHav,w:150),
          _fDate('Nb/Sub',_pNbSub,w:150),_fDate('Sub',_pSub,w:150),_fDate('Sub Maj',_pSubMaj,w:150),_fDate('ACP',_pAcp,w:150),
        ]),
        const SizedBox(height:10),
        Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:8,horizontal:12),
          color:const Color(0xFFF0F1F3),
          child:const Text('— FOR PERMT POSTING ONLY —',textAlign:TextAlign.center,
              style:TextStyle(fontSize:12,fontWeight:FontWeight.w800,letterSpacing:1.5,color:kInkSoft))),
      ])),
      // ERE Details
      CardSection(title:'ERE Details',child:_ereTable()),
      // Signature line
      CardSection(title:'Verification',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const SubLabel('SIG OF INDL (with date)'),
        Container(height:60,width:double.infinity,
          decoration:BoxDecoration(color:kField,border:Border.all(color:kBorder),borderRadius:BorderRadius.circular(5)),
          child:const Center(child:Text('...............................................................................  Date: ___________',
              style:TextStyle(fontSize:13,color:Color(0xFFBFC4CC))))),
      ])),
      const SizedBox(height:8),
      BipFooter(isEditing:widget.record!=null,isSaving:_saving,onSave:_save,onDelete:_delete,onClear:_clear,
        onFind:()=>showSnack(context,'Use the filter panel on the right.'),
        onPrint:()=>showSnack(context,'Print: coming soon.'),onExit:(){}),
    ]);
  }
}
