<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->
<!-- #include file = "..\serversidefuncts.js" -->
<!-- #include file = "accpacPOPages.asp" -->

<%

var strEntity = "Purchases"
var strDetailEntity = "POReqDetail"
var strQSPrimaryKey = "PURE_PurchasesID";
strSeEntity = "PurchaseAdmin";

var strRecordId = new String(Request.QueryString(strQSPrimaryKey));
var arrTemp = new Array();
arrTemp = strRecordId.split(",");
strRecordId = arrTemp[arrTemp.length-1];

var purchasesRecord = CRM.FindRecord(strEntity,"Pure_purchasesID = "+strRecordId);
var purchasesDetailrecord = CRM.FindRecord(strDetailEntity,"Pord_purchasesID = "+strRecordId);

var locationRecord = getDBValues("vICLOC","where vICLOCrowid = "+purchasesRecord("pure_location"),"LOCATION");

var header = headerDetails(getDBValues("Company","where comp_companyid = "+purchasesRecord("pure_Vendor"),"comp_idVend"), getDBValues("Users","where user_userid = "+purchasesRecord("pure_UserID"),"user_FirstName"), locationRecord, purchasesRecord("pure_Description"), purchasesRecord("pure_reference"), purchasesRecord("pure_EpiryDate"), purchasesRecord("pure_requireddate"), purchasesRecord("pure_comment"),purchasesRecord("pure_onhold"));

var detail = Array();
while(!purchasesDetailrecord.eof) {

var checkItem = purchasesDetailrecord("pord_itemNo");
if(Defined(checkItem))
    var detailobj = poDetails(getDBValues("Company","where comp_companyid = "+purchasesRecord("pure_Vendor"),"comp_idVend"), getDBValues("vICITEM","where rowid = "+purchasesDetailrecord("pord_itemNo"),"itemNo"), purchasesDetailrecord("pord_OQORDERED"), purchasesDetailrecord("pord_comment"), purchasesDetailrecord("pord_completion"), locationRecord, purchasesDetailrecord("pord_uom"), purchasesDetailrecord("pord_unitprice"),purchasesDetailrecord("pord_copycosttopo"));
else
    var detailobj = poDetails(getDBValues("Company","where comp_companyid = "+purchasesRecord("pure_Vendor"),"comp_idVend"), purchasesDetailrecord("pord_noInvItem"), purchasesDetailrecord("pord_OQORDERED"), purchasesDetailrecord("pord_comment"), purchasesDetailrecord("pord_completion"), locationRecord, purchasesDetailrecord("pord_uom"), purchasesDetailrecord("pord_unitprice"),purchasesDetailrecord("pord_copycosttopo"));

detail.push(detailobj);
purchasesDetailrecord.NextRecord();
}

//Response.Write("date: " +header.requiredDate);

purchasesRecord.SetWorkFlowInfo("Purchases Workflow", "Requisition Created");

//build the actual PO request and Post
var reqFieldnumber = buildPORequest(header, detail);

createTrackingRecord(purchasesRecord("pure_purchasesid"), "Requisition Created in ERP")

//look for a buyer
var segment = purchasesRecord("pure_segment");
var adminRecord = CRM.FindRecord(strSeEntity,"Pura_segment = '"+segment+"' and pura_requester is null and pura_appprover is null");

if(adminRecord("pura_buyer") != null && adminRecord("pura_buyer") != "")
{
//there is a buyer set up for this segment
//add this buyer
purchasesRecord("pure_buyerApprove") = adminRecord("pura_buyer");
purchasesRecord("pure_assignedUserid") = adminRecord("pura_buyer");
}
else{
purchasesRecord("pure_buyerApprove") = "0";
purchasesRecord("pure_assignedUserid") = findApprover(purchasesRecord("pure_PurchasesID"),1);
}

purchasesRecord("pure_Name") = reqFieldnumber[0];
purchasesRecord("pure_ReqSeqNumber") = parseFloat(reqFieldnumber[1]);
purchasesRecord("pure_TotalValue") = reqFieldnumber[2];
purchasesRecord("pure_PendingApprove") = findApprover(purchasesRecord("pure_PurchasesID"),1);
purchasesRecord("pure_Stage") = "Requisition_Created";
createTrackingRecord(purchasesRecord("pure_purchasesid"), "Pending Approval From "+getUserName(purchasesRecord("pure_PendingApprove")));
purchasesRecord.SaveChanges();

//update the date and time seperatly - CRM does not want to do it correctly using the API
//purchasesRecord("pure_lastupdated") = crmDate(new Date());
var updateStr = "Update Purchases set pure_lastupdated = '" + crmDate(new Date()) + "' where pure_purchasesID = "+purchasesRecord("pure_purchasesid");
CRM.ExecSql(updateStr);

Response.Redirect(CRM.URL("Purchases/PurchasesSummary.asp")+"&"+strQSPrimaryKey+"="+strRecordId);

%>