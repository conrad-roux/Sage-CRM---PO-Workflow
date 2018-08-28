<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->
<!-- #include file ="..\serversidefuncts.js" -->
<!-- #include file = "accpacPOPages.asp" -->

<%

var strEntity = "Purchases"
var strQSPrimaryKey = "PURE_PurchasesID";
var strDetailEntity = "PoReqDetail";

var strRecordId = new String(Request.QueryString(strQSPrimaryKey));
var arrTemp = new Array();
arrTemp = strRecordId.split(",");
strRecordId = arrTemp[arrTemp.length-1];

var purchasesRecord = CRM.FindRecord(strEntity,"Pure_purchasesID = "+strRecordId);
var header = new Object();
header.reqNumber = purchasesRecord("pure_Name");
header.vendor = getDBValues("Company","where comp_companyid = "+purchasesRecord("pure_Vendor"),"comp_idVend");
header.description = purchasesRecord("pure_description");
header.reference = purchasesRecord("pure_reference");
header.noOfItems = getCount("POReqDetail","where pord_PurchasesID = "+purchasesRecord("pure_PurchasesID")+" and pord_deleted is null","pord_recordid");

var purchasesDetailrecord = CRM.FindRecord(strDetailEntity,"Pord_purchasesID = "+strRecordId+" and pord_deleted is null");
var detail = new Array();
while(!purchasesDetailrecord.eof) {
var obj = new Object();
obj.cost = purchasesDetailrecord("pord_unitprice");

if(Defined(purchasesDetailrecord("pord_noInvItem")))
    obj.account = getDBValues("vGLAMF","where rowid = "+purchasesDetailrecord("pord_glacc"),"ACCTID");
else
    obj.account = "";
    
detail.push(obj);
purchasesDetailrecord.NextRecord();
}

purchasesRecord.SetWorkFlowInfo("Purchases Workflow", "PO Created");
var poFieldNumber = buildPO(header,detail);

createTrackingRecord(purchasesRecord("pure_purchasesid"), "Purchase Order Created in ERP");
purchasesRecord("pure_ponumber") = poFieldNumber[0];
purchasesRecord("pure_accpacseqnumber") = poFieldNumber[1];
purchasesRecord("pure_accpacstatus") = "Synced";
purchasesRecord("pure_stage") = "PO_Created";
purchasesRecord("pure_status") = "Closed";
purchasesRecord.SaveChanges();

//update the date and time seperatly - CRM does not want to do it correctly using the API
//purchasesRecord("pure_lastupdated") = crmDate(new Date());
var updateStr = "Update Purchases set pure_lastupdated = '" + crmDate(new Date()) + "' where pure_purchasesID = "+purchasesRecord("pure_purchasesid");
CRM.ExecSql(updateStr);

Response.Redirect(CRM.URL("Purchases/PurchasesSummary.asp")+"&"+strQSPrimaryKey+"="+strRecordId)

%>