<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->
<!-- #include file = "..\ACCPAC\utilityfuncs.js" -->
<!-- #include file = "..\serversidefuncts.js" -->
<!-- #include file = "accpacPOPages.asp" -->


<%
var strEntity = "Purchases";
var strSeEntity = "PurchasesProgress";
var strQSPrimaryKey = "PURE_PurchasesID";
var strScreenObject = "PurchasesProgressNoteBox";
var strScreenTitle = "Tracking";
var strPrimaryKeyField = "pure_purchasesprogressid";
var strTab = "PurchasesProgress";
var strCancelURL = CRM.URL("purchases/PurchasesSummary.asp");

var strRecordId = new String(Request.QueryString(strQSPrimaryKey));
var arrTemp = new Array();
arrTemp = strRecordId.split(",");
strRecordId = arrTemp[arrTemp.length-1];

var objRecord = CRM.CreateRecord(strSeEntity);
if(CRM.Mode == 0)CRM.Mode = 1;

objRecord("pure_purchasesid") = strRecordId;

var objContainer = CRM.GetBlock("container");
objContainer.AddButton(CRM.Button("Cancel","Cancel.Gif",strCancelURL+"&PURE_PurchasesID="+strRecordId));
var objEntryScreen = CRM.GetBlock(strScreenObject);
objEntryScreen.Title = strScreenTitle;
objContainer.AddBlock(objEntryScreen);

CRM.AddContent(objContainer.Execute(objRecord));
Response.Write(CRM.GetPage(strTab));

if(CRM.Mode == 2){
    var purchasesRecord = CRM.FindRecord(strEntity,"Pure_purchasesID = "+strRecordId);
    
    var header = new Object();
    header.reqNumber = purchasesRecord("pure_name");
    RejectPR(header);
    
    //createTrackingRecord(purchasesRecord("pure_purchasesid"), "Rejected by "+getUserName(CRM.GetContextInfo("User","user_userid")));
    purchasesRecord("pure_stage") = "Requisition_Rejected";
    purchasesRecord("pure_status") = "Rejected";
    purchasesRecord("pure_EpiryDate") = crmDate(new Date());
    purchasesRecord.SetWorkFlowInfo("Purchases Workflow", "Rejected");
    purchasesRecord.SaveChanges();
    Response.Redirect(CRM.URL("purchases/PurchasesSummary.asp")+"&PURE_PurchasesID="+strRecordId);
    }
%>