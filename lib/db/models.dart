// ─────────────────────────────────────────────────────────────────────────────
// Sub-category constants
// ─────────────────────────────────────────────────────────────────────────────
class SubCat {
  static const offPresent = 'off_present';
  static const offExCos = 'off_ex_cos';
  static const offOtherUnit = 'off_other_unit';
  static const offRetired = 'off_retired';
  static const jcoPresentJco = 'jco_present_jco';
  static const jcoPresentOr = 'jco_present_or';
  static const jcoOnEre = 'jco_on_ere';
  static const jcoRetired = 'jco_retired';

  static String label(String s) {
    const m = {
      offPresent: 'Present Officers',
      offExCos: 'Ex COs',
      offOtherUnit: 'Serving Other Unit',
      offRetired: 'Retd Officers',
      jcoPresentJco: 'Present JCO',
      jcoPresentOr: 'Present OR',
      jcoOnEre: 'On ERE',
      jcoRetired: 'Retd JCOs/OR',
    };
    return m[s] ?? s;
  }

  static String cardTitle(String s) {
    const m = {
      offPresent: 'DATA CARD : PRESENT OFFICERS',
      offExCos: 'DATA CARD : EX COs',
      offOtherUnit: 'DATA CARD : SERVING WITH OTHER UNIT',
      offRetired: 'DATA CARD : RETD OFFICERS',
      jcoPresentJco: 'PRESENT JCO : DATA CARD',
      jcoPresentOr: 'PRESENT OR : DATA CARD',
      jcoOnEre: 'JCOs OR (ON ERE) : DATA CARD',
      jcoRetired: 'RETD JCOs OR : DATA CARD',
    };
    return m[s] ?? s;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Officer model (all 4 sub-categories share identical fields)
// ─────────────────────────────────────────────────────────────────────────────
class OfficerModel {
  int? id;
  String subCategory;
  String? icNo, rank, name, bloodGp;
  String? dob, doc, dor, dom, tos, sos, cdaAcNo;
  String? iCardNo, bDay, mAnn, honoursAwards;
  String? medCat, diag, dueOn;
  String? presentAddress, permtAddress, status;
  String? teleNos, emailIds, photoPath;
  // Kindred
  String? wifeName, wifeBday;
  String? ch1Name, ch1Sex, ch1Dob;
  String? ch2Name, ch2Sex, ch2Dob;
  String? ch3Name, ch3Sex, ch3Dob;
  String? ch4Name, ch4Sex, ch4Dob;
  // Courses
  String? cYo, cMmgAgl, cMorO, cSniper, cAdp, cAtgm, cPwt;
  String? cJc, cSc, cCdoGtk, cQmO, cTac, cRcl, cRso;
  String? cPt, cDssc, cBswO, cOthers;
  // Promotions
  String? pLt, pCapt, pMaj, pLtCol, pCol, pBrig, pMajGen, pLtGen;
  // Service in unit
  String? sv1F, sv1T, sv2F, sv2T, sv3F, sv3T, sv4F, sv4T;
  String? cmdF, cmdT;
  String? civEdn, domicile;
  String? cYoG, cMmgAglG, cMorOG, cSniperG, cAdpG, cAtgmG, cPwtG;
  String? cJcG, cScG, cCdoGtkG, cQmOG, cTacG, cRclG, cRsoG;
  String? cPtG, cDsscG, cBswOG;
  String? createdAt, updatedAt;

  OfficerModel({required this.subCategory, this.id});

  Map<String, dynamic> toMap() => {
        'id': id,
        'sub_cat': subCategory,
        'ic_no': icNo,
        'rank': rank,
        'name': name,
        'blood_gp': bloodGp,
        'dob': dob,
        'doc': doc,
        'dor': dor,
        'dom': dom,
        'tos': tos,
        'sos': sos,
        'cda_ac_no': cdaAcNo,
        'i_card_no': iCardNo,
        'b_day': bDay,
        'm_ann': mAnn,
        'honours': honoursAwards,
        'med_cat': medCat,
        'diag': diag,
        'due_on': dueOn,
        'pres_addr': presentAddress,
        'permt_addr': permtAddress,
        'status': status,
        'tele_nos': teleNos,
        'email_ids': emailIds,
        'photo': photoPath,
        'wife': wifeName,
        'wife_bday': wifeBday,
        'ch1n': ch1Name,
        'ch1s': ch1Sex,
        'ch1d': ch1Dob,
        'ch2n': ch2Name,
        'ch2s': ch2Sex,
        'ch2d': ch2Dob,
        'ch3n': ch3Name,
        'ch3s': ch3Sex,
        'ch3d': ch3Dob,
        'ch4n': ch4Name,
        'ch4s': ch4Sex,
        'ch4d': ch4Dob,
        'c_yo': cYo,
        'c_mmg': cMmgAgl,
        'c_mor': cMorO,
        'c_snip': cSniper,
        'c_adp': cAdp,
        'c_atgm': cAtgm,
        'c_pwt': cPwt,
        'c_jc': cJc,
        'c_sc': cSc,
        'c_cdo': cCdoGtk,
        'c_qm': cQmO,
        'c_tac': cTac,
        'c_rcl': cRcl,
        'c_rso': cRso,
        'c_pt': cPt,
        'c_dssc': cDssc,
        'c_bsw': cBswO,
        'c_oth': cOthers,
        'p_lt': pLt,
        'p_capt': pCapt,
        'p_maj': pMaj,
        'p_ltcol': pLtCol,
        'p_col': pCol,
        'p_brig': pBrig,
        'p_majgen': pMajGen,
        'p_ltgen': pLtGen,
        'sv1f': sv1F,
        'sv1t': sv1T,
        'sv2f': sv2F,
        'sv2t': sv2T,
        'sv3f': sv3F,
        'sv3t': sv3T,
        'sv4f': sv4F,
        'sv4t': sv4T,
        'cmd_f': cmdF,
        'cmd_t': cmdT,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'civ_edn': civEdn,
        'domicile': domicile,
        'c_yo_g': cYoG,
        'c_mmg_g': cMmgAglG,
        'c_mor_g': cMorOG,
        'c_snip_g': cSniperG,
        'c_adp_g': cAdpG,
        'c_atgm_g': cAtgmG,
        'c_pwt_g': cPwtG,
        'c_jc_g': cJcG,
        'c_sc_g': cScG,
        'c_cdo_g': cCdoGtkG,
        'c_qm_g': cQmOG,
        'c_tac_g': cTacG,
        'c_rcl_g': cRclG,
        'c_rso_g': cRsoG,
        'c_pt_g': cPtG,
        'c_dssc_g': cDsscG,
        'c_bsw_g': cBswOG,
      };

  factory OfficerModel.fromMap(Map<String, dynamic> m) {
    final o = OfficerModel(subCategory: m['sub_cat'] ?? '', id: m['id']);
    o.icNo = m['ic_no'];
    o.rank = m['rank'];
    o.name = m['name'];
    o.bloodGp = m['blood_gp'];
    o.dob = m['dob'];
    o.doc = m['doc'];
    o.dor = m['dor'];
    o.dom = m['dom'];
    o.tos = m['tos'];
    o.sos = m['sos'];
    o.cdaAcNo = m['cda_ac_no'];
    o.iCardNo = m['i_card_no'];
    o.bDay = m['b_day'];
    o.mAnn = m['m_ann'];
    o.honoursAwards = m['honours'];
    o.medCat = m['med_cat'];
    o.diag = m['diag'];
    o.dueOn = m['due_on'];
    o.presentAddress = m['pres_addr'];
    o.permtAddress = m['permt_addr'];
    o.status = m['status'];
    o.teleNos = m['tele_nos'];
    o.emailIds = m['email_ids'];
    o.photoPath = m['photo'];
    o.wifeName = m['wife'];
    o.wifeBday = m['wife_bday'];
    o.ch1Name = m['ch1n'];
    o.ch1Sex = m['ch1s'];
    o.ch1Dob = m['ch1d'];
    o.ch2Name = m['ch2n'];
    o.ch2Sex = m['ch2s'];
    o.ch2Dob = m['ch2d'];
    o.ch3Name = m['ch3n'];
    o.ch3Sex = m['ch3s'];
    o.ch3Dob = m['ch3d'];
    o.ch4Name = m['ch4n'];
    o.ch4Sex = m['ch4s'];
    o.ch4Dob = m['ch4d'];
    o.cYo = m['c_yo'];
    o.cMmgAgl = m['c_mmg'];
    o.cMorO = m['c_mor'];
    o.cSniper = m['c_snip'];
    o.cAdp = m['c_adp'];
    o.cAtgm = m['c_atgm'];
    o.cPwt = m['c_pwt'];
    o.cJc = m['c_jc'];
    o.cSc = m['c_sc'];
    o.cCdoGtk = m['c_cdo'];
    o.cQmO = m['c_qm'];
    o.cTac = m['c_tac'];
    o.cRcl = m['c_rcl'];
    o.cRso = m['c_rso'];
    o.cPt = m['c_pt'];
    o.cDssc = m['c_dssc'];
    o.cBswO = m['c_bsw'];
    o.cOthers = m['c_oth'];
    o.pLt = m['p_lt'];
    o.pCapt = m['p_capt'];
    o.pMaj = m['p_maj'];
    o.pLtCol = m['p_ltcol'];
    o.pCol = m['p_col'];
    o.pBrig = m['p_brig'];
    o.pMajGen = m['p_majgen'];
    o.pLtGen = m['p_ltgen'];
    o.sv1F = m['sv1f'];
    o.sv1T = m['sv1t'];
    o.sv2F = m['sv2f'];
    o.sv2T = m['sv2t'];
    o.sv3F = m['sv3f'];
    o.sv3T = m['sv3t'];
    o.sv4F = m['sv4f'];
    o.sv4T = m['sv4t'];
    o.cmdF = m['cmd_f'];
    o.cmdT = m['cmd_t'];
    o.createdAt = m['created_at'];
    o.updatedAt = m['updated_at'];
    o.civEdn = m['civ_edn'];
    o.domicile = m['domicile'];
    o.cYoG = m['c_yo_g'];
    o.cMmgAglG = m['c_mmg_g'];
    o.cMorOG = m['c_mor_g'];
    o.cSniperG = m['c_snip_g'];
    o.cAdpG = m['c_adp_g'];
    o.cAtgmG = m['c_atgm_g'];
    o.cPwtG = m['c_pwt_g'];
    o.cJcG = m['c_jc_g'];
    o.cScG = m['c_sc_g'];
    o.cCdoGtkG = m['c_cdo_g'];
    o.cQmOG = m['c_qm_g'];
    o.cTacG = m['c_tac_g'];
    o.cRclG = m['c_rcl_g'];
    o.cRsoG = m['c_rso_g'];
    o.cPtG = m['c_pt_g'];
    o.cDsscG = m['c_dssc_g'];
    o.cBswOG = m['c_bsw_g'];
    return o;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JCO/OR model (all 5 sub-categories merged; unused fields stay null)
// ─────────────────────────────────────────────────────────────────────────────
class JcoOrModel {
  int? id;
  String subCategory;
  String? armyNo, rank, name, coy;
  String? dob, doe, dor, tos, rrEreFmn;
  String? serviceExtn; // present, short, new_entry
  String? sos, returnDt; // on_ere, retired
  String? icardNo, honoursAwards;
  String? panCardNo, bloodGp, caste, civEdn, medCat;
  String? aadharCard; // present, new_entry
  String? diag, dueOn;
  String? emailId; // present, new_entry
  String? personalProblem; // on_ere, retired, short
  String? photoPath;
  // New Entry unique
  String? duration, presentWithUnit, kindredRollVerify;
  String? maritalStatus, unitAttPers, reportingAt, presentLoc, dtOfIndn;
  // Kindred
  String? father, mother, wife, nextOfKin;
  String? ch1Name, ch1Sex, ch1Dob;
  String? ch2Name, ch2Sex, ch2Dob;
  String? ch3Name, ch3Sex, ch3Dob;
  String? ch4Name, ch4Sex, ch4Dob;
  // Leave
  String? availedCl, availedAl;
  String? furLve, notAvailedLve; // present only
  String? reportingOn, reportedFromMov; // new_entry only
  // Bank
  String? acctNo, bankName; // present, new_entry
  String? singleAcctNo, singleBankName; // on_ere, retired
  String? jointAcctNo, jointBankName; // on_ere, retired
  String? singleCodeNo, jointCodeNo; // retired only
  // Home address
  String? homeTele, homeVillage, homePost, homeTOff;
  String? homeTehsil, homeDistrict, homeState, homePin, homeNrs;
  // Courses
  String? cSecCdr, cMmgAgl, cMorJn, cSniper, cAdp, cAtgm, cDrill;
  String? cBmic, cUei, cCdo, cQm, cRsi, cJlc, cPc, cPt, cTpt, cMisc, cBsw;
  // Army Edn
  String? eMr1, eMr2, eMr3, eAce1, eAce2, eAce3, eAec3;
  String? eTtt1, eTtt2, eTtt3; // on_ere, retired
  // Promo Cadres
  String? pcUmmedwar, pcHav, pcNbSub;
  // Promotions
  String? pLnk, pNaik, pHav, pNbSub, pSub, pSubMaj, pAcp;
  // ERE Details
  String? ere1Name, ere1From, ere1To;
  String? ere2Name, ere2From, ere2To;
  String? ere3Name, ere3From, ere3To;
  // Discipline
  String? d1Off, d1Awd, d1Dt, d1Ent;
  String? d2Off, d2Awd, d2Dt, d2Ent;
  String? d3Off, d3Awd, d3Dt, d3Ent;
  String? d4Off, d4Awd, d4Dt, d4Ent;
  String? d5Off, d5Awd, d5Dt, d5Ent;
  String? domicile;
  String? cSecCdrG, cMmgAglG, cMorJnG, cSniperG, cAdpG, cAtgmG, cDrillG;
  String? cBmicG,
      cUeiG,
      cCdoG,
      cQmG,
      cRsiG,
      cJlcG,
      cPcG,
      cPtG,
      cTptG,
      cMiscG,
      cBswG;
  String? createdAt, updatedAt;

  JcoOrModel({required this.subCategory, this.id});

  Map<String, dynamic> toMap() => {
        'id': id,
        'sub_cat': subCategory,
        'army_no': armyNo,
        'rank': rank,
        'name': name,
        'coy': coy,
        'dob': dob,
        'doe': doe,
        'dor': dor,
        'tos': tos,
        'rr_ere_fmn': rrEreFmn,
        'svc_extn': serviceExtn,
        'sos': sos,
        'return_dt': returnDt,
        'icard_no': icardNo,
        'honours': honoursAwards,
        'pan': panCardNo,
        'blood_gp': bloodGp,
        'caste': caste,
        'civ_edn': civEdn,
        'med_cat': medCat,
        'aadhar': aadharCard,
        'diag': diag,
        'due_on': dueOn,
        'email': emailId,
        'pers_prob': personalProblem,
        'photo': photoPath,
        'duration': duration,
        'pres_unit': presentWithUnit,
        'kr_verify': kindredRollVerify,
        'marital': maritalStatus,
        'unit_att': unitAttPers,
        'rep_at': reportingAt,
        'pres_loc': presentLoc,
        'dt_indn': dtOfIndn,
        'father': father,
        'mother': mother,
        'wife': wife,
        'nok': nextOfKin,
        'ch1n': ch1Name,
        'ch1s': ch1Sex,
        'ch1d': ch1Dob,
        'ch2n': ch2Name,
        'ch2s': ch2Sex,
        'ch2d': ch2Dob,
        'ch3n': ch3Name,
        'ch3s': ch3Sex,
        'ch3d': ch3Dob,
        'ch4n': ch4Name,
        'ch4s': ch4Sex,
        'ch4d': ch4Dob,
        'av_cl': availedCl,
        'av_al': availedAl,
        'fur_lve': furLve,
        'not_av_lve': notAvailedLve,
        'rep_on': reportingOn,
        'rep_mov': reportedFromMov,
        'acct': acctNo,
        'bank': bankName,
        'sing_acct': singleAcctNo,
        'sing_bank': singleBankName,
        'jnt_acct': jointAcctNo,
        'jnt_bank': jointBankName,
        'sing_code': singleCodeNo,
        'jnt_code': jointCodeNo,
        'h_tele': homeTele,
        'h_vill': homeVillage,
        'h_post': homePost,
        'h_toff': homeTOff,
        'h_teh': homeTehsil,
        'h_dist': homeDistrict,
        'h_state': homeState,
        'h_pin': homePin,
        'h_nrs': homeNrs,
        'c_sec': cSecCdr,
        'c_mmg': cMmgAgl,
        'c_mor': cMorJn,
        'c_snip': cSniper,
        'c_adp': cAdp,
        'c_atgm': cAtgm,
        'c_drill': cDrill,
        'c_bmic': cBmic,
        'c_uei': cUei,
        'c_cdo': cCdo,
        'c_qm': cQm,
        'c_rsi': cRsi,
        'c_jlc': cJlc,
        'c_pc': cPc,
        'c_pt': cPt,
        'c_tpt': cTpt,
        'c_misc': cMisc,
        'c_bsw': cBsw,
        'e_mr1': eMr1,
        'e_mr2': eMr2,
        'e_mr3': eMr3,
        'e_ace1': eAce1,
        'e_ace2': eAce2,
        'e_ace3': eAce3,
        'e_aec3': eAec3,
        'e_ttt1': eTtt1,
        'e_ttt2': eTtt2,
        'e_ttt3': eTtt3,
        'pc_umm': pcUmmedwar,
        'pc_hav': pcHav,
        'pc_nb': pcNbSub,
        'p_lnk': pLnk,
        'p_naik': pNaik,
        'p_hav': pHav,
        'p_nbsub': pNbSub,
        'p_sub': pSub,
        'p_submaj': pSubMaj,
        'p_acp': pAcp,
        'e1n': ere1Name,
        'e1f': ere1From,
        'e1t': ere1To,
        'e2n': ere2Name,
        'e2f': ere2From,
        'e2t': ere2To,
        'e3n': ere3Name,
        'e3f': ere3From,
        'e3t': ere3To,
        'd1o': d1Off,
        'd1a': d1Awd,
        'd1d': d1Dt,
        'd1e': d1Ent,
        'd2o': d2Off,
        'd2a': d2Awd,
        'd2d': d2Dt,
        'd2e': d2Ent,
        'd3o': d3Off,
        'd3a': d3Awd,
        'd3d': d3Dt,
        'd3e': d3Ent,
        'd4o': d4Off,
        'd4a': d4Awd,
        'd4d': d4Dt,
        'd4e': d4Ent,
        'd5o': d5Off,
        'd5a': d5Awd,
        'd5d': d5Dt,
        'd5e': d5Ent,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'domicile': domicile,
        'c_sec_g': cSecCdrG,
        'c_mmg_g': cMmgAglG,
        'c_mor_g': cMorJnG,
        'c_snip_g': cSniperG,
        'c_adp_g': cAdpG,
        'c_atgm_g': cAtgmG,
        'c_drill_g': cDrillG,
        'c_bmic_g': cBmicG,
        'c_uei_g': cUeiG,
        'c_cdo_g': cCdoG,
        'c_qm_g': cQmG,
        'c_rsi_g': cRsiG,
        'c_jlc_g': cJlcG,
        'c_pc_g': cPcG,
        'c_pt_g': cPtG,
        'c_tpt_g': cTptG,
        'c_misc_g': cMiscG,
        'c_bsw_g': cBswG,
      };

  factory JcoOrModel.fromMap(Map<String, dynamic> m) {
    final j = JcoOrModel(subCategory: m['sub_cat'] ?? '', id: m['id']);
    j.armyNo = m['army_no'];
    j.rank = m['rank'];
    j.name = m['name'];
    j.coy = m['coy'];
    j.dob = m['dob'];
    j.doe = m['doe'];
    j.dor = m['dor'];
    j.tos = m['tos'];
    j.rrEreFmn = m['rr_ere_fmn'];
    j.serviceExtn = m['svc_extn'];
    j.sos = m['sos'];
    j.returnDt = m['return_dt'];
    j.icardNo = m['icard_no'];
    j.honoursAwards = m['honours'];
    j.panCardNo = m['pan'];
    j.bloodGp = m['blood_gp'];
    j.caste = m['caste'];
    j.civEdn = m['civ_edn'];
    j.medCat = m['med_cat'];
    j.aadharCard = m['aadhar'];
    j.diag = m['diag'];
    j.dueOn = m['due_on'];
    j.emailId = m['email'];
    j.personalProblem = m['pers_prob'];
    j.photoPath = m['photo'];
    j.duration = m['duration'];
    j.presentWithUnit = m['pres_unit'];
    j.kindredRollVerify = m['kr_verify'];
    j.maritalStatus = m['marital'];
    j.unitAttPers = m['unit_att'];
    j.reportingAt = m['rep_at'];
    j.presentLoc = m['pres_loc'];
    j.dtOfIndn = m['dt_indn'];
    j.father = m['father'];
    j.mother = m['mother'];
    j.wife = m['wife'];
    j.nextOfKin = m['nok'];
    j.ch1Name = m['ch1n'];
    j.ch1Sex = m['ch1s'];
    j.ch1Dob = m['ch1d'];
    j.ch2Name = m['ch2n'];
    j.ch2Sex = m['ch2s'];
    j.ch2Dob = m['ch2d'];
    j.ch3Name = m['ch3n'];
    j.ch3Sex = m['ch3s'];
    j.ch3Dob = m['ch3d'];
    j.ch4Name = m['ch4n'];
    j.ch4Sex = m['ch4s'];
    j.ch4Dob = m['ch4d'];
    j.availedCl = m['av_cl'];
    j.availedAl = m['av_al'];
    j.furLve = m['fur_lve'];
    j.notAvailedLve = m['not_av_lve'];
    j.reportingOn = m['rep_on'];
    j.reportedFromMov = m['rep_mov'];
    j.acctNo = m['acct'];
    j.bankName = m['bank'];
    j.singleAcctNo = m['sing_acct'];
    j.singleBankName = m['sing_bank'];
    j.jointAcctNo = m['jnt_acct'];
    j.jointBankName = m['jnt_bank'];
    j.singleCodeNo = m['sing_code'];
    j.jointCodeNo = m['jnt_code'];
    j.homeTele = m['h_tele'];
    j.homeVillage = m['h_vill'];
    j.homePost = m['h_post'];
    j.homeTOff = m['h_toff'];
    j.homeTehsil = m['h_teh'];
    j.homeDistrict = m['h_dist'];
    j.homeState = m['h_state'];
    j.homePin = m['h_pin'];
    j.homeNrs = m['h_nrs'];
    j.cSecCdr = m['c_sec'];
    j.cMmgAgl = m['c_mmg'];
    j.cMorJn = m['c_mor'];
    j.cSniper = m['c_snip'];
    j.cAdp = m['c_adp'];
    j.cAtgm = m['c_atgm'];
    j.cDrill = m['c_drill'];
    j.cBmic = m['c_bmic'];
    j.cUei = m['c_uei'];
    j.cCdo = m['c_cdo'];
    j.cQm = m['c_qm'];
    j.cRsi = m['c_rsi'];
    j.cJlc = m['c_jlc'];
    j.cPc = m['c_pc'];
    j.cPt = m['c_pt'];
    j.cTpt = m['c_tpt'];
    j.cMisc = m['c_misc'];
    j.cBsw = m['c_bsw'];
    j.eMr1 = m['e_mr1'];
    j.eMr2 = m['e_mr2'];
    j.eMr3 = m['e_mr3'];
    j.eAce1 = m['e_ace1'];
    j.eAce2 = m['e_ace2'];
    j.eAce3 = m['e_ace3'];
    j.eAec3 = m['e_aec3'];
    j.eTtt1 = m['e_ttt1'];
    j.eTtt2 = m['e_ttt2'];
    j.eTtt3 = m['e_ttt3'];
    j.pcUmmedwar = m['pc_umm'];
    j.pcHav = m['pc_hav'];
    j.pcNbSub = m['pc_nb'];
    j.pLnk = m['p_lnk'];
    j.pNaik = m['p_naik'];
    j.pHav = m['p_hav'];
    j.pNbSub = m['p_nbsub'];
    j.pSub = m['p_sub'];
    j.pSubMaj = m['p_submaj'];
    j.pAcp = m['p_acp'];
    j.ere1Name = m['e1n'];
    j.ere1From = m['e1f'];
    j.ere1To = m['e1t'];
    j.ere2Name = m['e2n'];
    j.ere2From = m['e2f'];
    j.ere2To = m['e2t'];
    j.ere3Name = m['e3n'];
    j.ere3From = m['e3f'];
    j.ere3To = m['e3t'];
    j.d1Off = m['d1o'];
    j.d1Awd = m['d1a'];
    j.d1Dt = m['d1d'];
    j.d1Ent = m['d1e'];
    j.d2Off = m['d2o'];
    j.d2Awd = m['d2a'];
    j.d2Dt = m['d2d'];
    j.d2Ent = m['d2e'];
    j.d3Off = m['d3o'];
    j.d3Awd = m['d3a'];
    j.d3Dt = m['d3d'];
    j.d3Ent = m['d3e'];
    j.d4Off = m['d4o'];
    j.d4Awd = m['d4a'];
    j.d4Dt = m['d4d'];
    j.d4Ent = m['d4e'];
    j.d5Off = m['d5o'];
    j.d5Awd = m['d5a'];
    j.d5Dt = m['d5d'];
    j.d5Ent = m['d5e'];
    j.createdAt = m['created_at'];
    j.updatedAt = m['updated_at'];
    j.domicile = m['domicile'];
    j.cSecCdrG = m['c_sec_g'];
    j.cMmgAglG = m['c_mmg_g'];
    j.cMorJnG = m['c_mor_g'];
    j.cSniperG = m['c_snip_g'];
    j.cAdpG = m['c_adp_g'];
    j.cAtgmG = m['c_atgm_g'];
    j.cDrillG = m['c_drill_g'];
    j.cBmicG = m['c_bmic_g'];
    j.cUeiG = m['c_uei_g'];
    j.cCdoG = m['c_cdo_g'];
    j.cQmG = m['c_qm_g'];
    j.cRsiG = m['c_rsi_g'];
    j.cJlcG = m['c_jlc_g'];
    j.cPcG = m['c_pc_g'];
    j.cPtG = m['c_pt_g'];
    j.cTptG = m['c_tpt_g'];
    j.cMiscG = m['c_misc_g'];
    j.cBswG = m['c_bsw_g'];
    return j;
  }
}
