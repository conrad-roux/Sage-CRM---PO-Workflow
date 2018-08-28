<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->
<!-- #include file ="..\serversidefuncts.js" -->

<%
var strQSPrimaryKey = "PURE_PurchasesID";
var strEntity = "Purchases";
var strPrimaryKeyField = "PURE_PurchasesID";
var strScreenObject = "PurchasesNewEntry";
var strScreenTitle = "Purchases"
var strCancelURL = "purchases/PurchasesList.asp";           //Routes to PurchaseList.asp if canceling from a new record
var strCancelBackURL = "purchases/PurchasesSummary.asp";       //Routes to PurchaseSummary.asp if Record exists
var strAddItemURL = "purchases/POREQDetailEdit.asp";
var strDetailEntity = "POReqDetail";
strDetailKeyField = "pord_purchasesID";
var strTab = "POREQDetail";

var strRecordId = new String(Request.QueryString(strQSPrimaryKey));
var arrTemp = new Array();
arrTemp = strRecordId.split(",");
strRecordId = arrTemp[arrTemp.length-1];


if(CRM.Mode == 0)CRM.Mode = 1;

if(Defined(strRecordId))
    var objRecord = CRM.FindRecord(strEntity, strPrimaryKeyField+" = "+strRecordId);
else
{
    var objRecord = CRM.CreateRecord(strEntity); //create the record and set workflow
    objRecord("pure_accpacstatus") = 0;
    objRecord.SetWorkFlowInfo("Purchases Workflow", "Logged");
}

var objContainer = CRM.GetBlock("container");
var objEntryScreen = CRM.GetBlock(strScreenObject);
objEntryScreen.Title = strScreenTitle;

if(Defined(strRecordId))
    objContainer.AddButton(CRM.Button("Cancel","Cancel.Gif",CRM.URL(strCancelBackURL)+"&PURE_PurchasesID="+strRecordId));
else
    objContainer.AddButton(CRM.Button("Cancel","Cancel.Gif",CRM.URL(strCancelURL)));
    
objContainer.AddBlock(objEntryScreen);
CRM.AddContent(objContainer.Execute(objRecord));

if((CRM.Mode == 2) && (objContainer.Validate())){
    if(objRecord("pure_status") == "InProgress" && objRecord("pure_stage") == "Logged"){
        createTrackingRecord(objRecord("pure_purchasesID"), "Header details changed");
        strRecordId = objRecord(strPrimaryKeyField);
        var currentLocation = objRecord("pure_location");
        var currentVendor = objRecord("pure_vendor");
        
        var a = 0;
        var detailRecords = CRM.FindRecord(strDetailEntity,strDetailKeyField+ " = " +strRecordId);
        if(!detailRecords.Eof){
            detailRecords("pord_location") = currentLocation;
            detailRecords("pord_vendor") = currentVendor;
            detailRecords.SaveChanges();
        }
        Response.Redirect(CRM.URL("purchases/PurchasesSummary.asp")+"&PURE_PurchasesID="+strRecordId+"&test=2");
    }
    else{
        createTrackingRecord(objRecord("pure_purchasesID"), "Requested for "+getUserName(objRecord("pure_userid")));
        objRecord("pure_status") = "InProgress";
        objRecord("pure_stage") = "Logged";
        objRecord.SaveChanges();
        strRecordId = objRecord(strPrimaryKeyField);
        Response.Redirect(CRM.URL("purchases/PurchasesSummary.asp")+"&PURE_PurchasesID="+strRecordId+"&test=1");
    }
}

Response.Write(CRM.GetPage(strTab));
%>
