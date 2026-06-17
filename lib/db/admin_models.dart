// Admin-managed records — separate tables for Leave, ERE, Health, Out Strength

class LeaveRecord {
  int? id; String armyNo;
  String? leaveType, fromDt, toDt, days, reportingDt, remarks, createdAt;
  LeaveRecord({required this.armyNo, this.id});
  Map<String,dynamic> toMap()=>{
    'id':id,'army_no':armyNo,'leave_type':leaveType,'from_dt':fromDt,
    'to_dt':toDt,'days':days,'reporting_dt':reportingDt,
    'remarks':remarks,'created_at':createdAt};
  factory LeaveRecord.fromMap(Map<String,dynamic> m)=>LeaveRecord(armyNo:m['army_no']??'',id:m['id'])
    ..leaveType=m['leave_type']..fromDt=m['from_dt']..toDt=m['to_dt']
    ..days=m['days']..reportingDt=m['reporting_dt']..remarks=m['remarks']..createdAt=m['created_at'];
}

class EreRecord {
  int? id; String armyNo;
  String? ereUnit, appointment, fromDt, toDt, returnDt, remarks, createdAt;
  EreRecord({required this.armyNo, this.id});
  Map<String,dynamic> toMap()=>{
    'id':id,'army_no':armyNo,'ere_unit':ereUnit,'appointment':appointment,
    'from_dt':fromDt,'to_dt':toDt,'return_dt':returnDt,
    'remarks':remarks,'created_at':createdAt};
  factory EreRecord.fromMap(Map<String,dynamic> m)=>EreRecord(armyNo:m['army_no']??'',id:m['id'])
    ..ereUnit=m['ere_unit']..appointment=m['appointment']..fromDt=m['from_dt']
    ..toDt=m['to_dt']..returnDt=m['return_dt']..remarks=m['remarks']..createdAt=m['created_at'];
}

class HealthRecord {
  int? id; String armyNo;
  String? category, medCat, medCatDetail, diag, hospital, boardDt, dueOn, remarks, createdAt;
  // Weight Record fields (used when category is a Coy, not Temp/Permt LMC)
  String? ht, ibw, abw, pct10, bmi, weightClass, age, wMonth, wValue;
  HealthRecord({required this.armyNo, this.id});
  Map<String,dynamic> toMap()=>{
    'id':id,'army_no':armyNo,'category':category,'med_cat':medCat,'med_cat_detail':medCatDetail,
    'diag':diag,'hospital':hospital,'board_dt':boardDt,'due_on':dueOn,
    'remarks':remarks,'ht':ht,'ibw':ibw,'abw':abw,'pct10':pct10,'bmi':bmi,
    'weight_class':weightClass,'age':age,'w_month':wMonth,'w_value':wValue,
    'created_at':createdAt};
  factory HealthRecord.fromMap(Map<String,dynamic> m)=>HealthRecord(armyNo:m['army_no']??'',id:m['id'])
    ..category=m['category']..medCat=m['med_cat']..medCatDetail=m['med_cat_detail']..diag=m['diag']
    ..hospital=m['hospital']..boardDt=m['board_dt']..dueOn=m['due_on']..remarks=m['remarks']
    ..ht=m['ht']..ibw=m['ibw']..abw=m['abw']..pct10=m['pct10']..bmi=m['bmi']
    ..weightClass=m['weight_class']..age=m['age']..wMonth=m['w_month']..wValue=m['w_value']
    ..createdAt=m['created_at'];
}

class OutStrengthRecord {
  int? id; String armyNo;
  String? reason, location, fromDt, expectedReturn, remarks, createdAt;
  OutStrengthRecord({required this.armyNo, this.id});
  Map<String,dynamic> toMap()=>{
    'id':id,'army_no':armyNo,'reason':reason,'location':location,
    'from_dt':fromDt,'expected_return':expectedReturn,
    'remarks':remarks,'created_at':createdAt};
  factory OutStrengthRecord.fromMap(Map<String,dynamic> m)=>OutStrengthRecord(armyNo:m['army_no']??'',id:m['id'])
    ..reason=m['reason']..location=m['location']..fromDt=m['from_dt']
    ..expectedReturn=m['expected_return']..remarks=m['remarks']..createdAt=m['created_at'];
}