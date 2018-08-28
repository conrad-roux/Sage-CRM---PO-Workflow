<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->
<!-- #include file ="..\serversidefuncts.js" -->

<%
var strQSPrimaryKey = "PURE_PurchasesID";
var strEntity = "Purchases";
var strPrimaryKeyField = "PURE_PurchasesID";
var strScreenObject = "PurchasesNewEntry";
var strScreenTitle = "Requisitions";
var strChangeURL = "purchases/PurchasesEdit.asp";
var strContinueURL = "purchases/PurchasesList.asp";
var strAddItemURL = "purchases/POREQDetailEdit.asp";
var strCancelURL = "purchases/POREQDetailEdit.asp";
var strPromoteURL = "purchases/POReqPromotion.asp";
var strBudgetURL = "purchases/Budget.asp";
var strConvertURL = "purchases/POPromotion.asp";
var strCancelBackURL = "purchases/PurchasesSummary.asp";
var strTab = "Purchases";

var strRecordId = new String(Request.QueryString(strQSPrimaryKey));
var arrTemp = new Array();
arrTemp = strRecordId.split(",");
strRecordId = arrTemp[arrTemp.length-1];

if(Defined(strRecordId)){
    var objRecord = CRM.FindRecord(strEntity, strPrimaryKeyField+" = "+strRecordId);
    
    if(objRecord("pure_Rejected") == 1){
        objRecord("pure_Status") = "Rejected";
        objRecord.SaveChanges();
    }
}    

var objContainer = CRM.GetBlock("container");
objContainer.DisplayButton(Button_Default) = false;
var objEntryScreen = CRM.GetBlock(strScreenObject);
objEntryScreen.Title = strScreenTitle;
objEntryScreen.DisplayForm = false;

if(CRM.Mode == 0){

//this piece will exclude the button when already promoted ( && objRecord("pure_Name") == null)
if(objRecord("pure_Status") != "Rejected" && objRecord("pure_Status") != "Closed" && !Defined(objRecord("pure_PONumber")))
    objContainer.AddButton(CRM.Button("Change","Edit.Gif",CRM.URL(strChangeURL)+"&PURE_PurchasesID="+strRecordId));
    
if((objRecord("pure_userid") == CRM.GetContextInfo("User","user_userid") || CRM.GetContextInfo("User","user_userid") == objRecord("pure_createdby")) && !Defined(objRecord("pure_name")))
    objContainer.DisplayButton(Button_Delete) = true;
    
objContainer.AddButton(CRM.Button("Continue","Continue.Gif",CRM.URL(strContinueURL)));
objContainer.ShowWorkflowButtons = true;
objContainer.WorkflowTable = 'Purchases';

if(Defined(objRecord("pure_reqseqnumber"))){
    if(objRecord("pure_pendingApprove") == CRM.GetContextInfo("User","user_userid") && objRecord("pure_Status") != "Rejected" && objRecord("pure_Status") != "Closed")
        objContainer.AddButton(CRM.Button("Budget","CheckPrice.gif",CRM.URL(strBudgetURL)+"&PURE_PurchasesID="+strRecordId));
}

objContainer.AddBlock(objEntryScreen);
CRM.AddContent(objContainer.Execute(objRecord));
CRM.GetCustomEntityTopFrame(strTab);
Response.Write(CRM.GetPage(strTab));

var objContainer1 = CRM.GetBlock("container");
var objItemList = CRM.GetBlock("POREQDetailList");
objItemList.PadBottom = false;
objContainer1.DisplayButton(Button_Default) = false;
if(!Defined(objRecord("pure_Name")) && (objRecord("pure_userid") == CRM.GetContextInfo("User","user_userid") || CRM.GetContextInfo("User","user_userid") == objRecord("pure_createdby")))
    objContainer1.AddButton(CRM.Button("Add Item","New.Gif",CRM.URL(strAddItemURL)+"&PORD_PurchasesID="+strRecordId));
objContainer1.AddBlock(objItemList);

Response.Write(objContainer1.Execute("pord_purchasesid="+strRecordId));
}

if(CRM.Mode == 3){

objContainer.AddButton(CRM.Button("Cancel","Cancel.Gif",CRM.URL(strCancelBackURL)+"&PURE_PurchasesID="+strRecordId));
    
if(objRecord("pure_userid") == CRM.GetContextInfo("User","user_userid") || CRM.GetContextInfo("User","user_userid") == objRecord("pure_createdby"))
    objContainer.DisplayButton(Button_Delete) = true;

    if(Defined(objRecord("pure_reqseqnumber"))){
        if(objRecord("pure_pendingApprove") == CRM.GetContextInfo("User","user_userid") && objRecord("pure_Status") != "Rejected" && objRecord("pure_Status") != "Closed")
            objContainer.AddButton(CRM.Button("Budget","CheckPrice.gif",CRM.URL(strBudgetURL)+"&PURE_PurchasesID="+strRecordId));
    }

objContainer.AddBlock(objEntryScreen);
CRM.AddContent(objContainer.Execute(objRecord));
CRM.GetCustomEntityTopFrame(strTab);
Response.Write(CRM.GetPage(strTab));
}

if(CRM.Mode == 4){
    createTrackingRecord(objRecord("pure_purchasesid"), "Record Deleted");
    objRecord("pure_deleted") = 1;
    objRecord.SaveChanges();
    var detailRecord = CRM.FindRecord("POREQDetail","pord_purchasesID = "+strRecordId);
    if(Defined(detailRecord("pord_recordid"))){
        detailRecord("pord_deleted") = 1;
        detailRecord.SaveChanges();
    }
    Response.Redirect(CRM.URL(strContinueURL));
}
%>