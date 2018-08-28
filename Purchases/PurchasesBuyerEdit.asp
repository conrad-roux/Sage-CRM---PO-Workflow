<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->

<%

var strQSPrimaryKey = "Pura_rowid";
var strEntity = "PurchaseAdmin";
var strScreenObject = "PurchasesBuyer";
var strScreenTitle = "Admin Buyer"
var strContinueURL = "purchases/PurchasesBuyerList.asp";
var strTab = "AdminTab";
var strRedirectURL = "Purchases/PurchasesBuyerList.asp"
var strPrimaryKeyField = "pura_rowid"

var strRecordId = new String(Request.QueryString(strQSPrimaryKey));
var arrTemp = new Array();
arrTemp = strRecordId.split(",");
strRecordId = arrTemp[arrTemp.length-1];

if(Defined(strRecordId))
{
var objRecord = CRM.FindRecord(strEntity, strPrimaryKeyField+" = "+strRecordId);
}
else
{
var objRecord = CRM.CreateRecord(strEntity);
if(CRM.Mode == 0)CRM.Mode = 1;
}
 
var objContainer = CRM.GetBlock("container");
var objEntryScreen = CRM.GetBlock(strScreenObject);
objContainer.DisplayButton(Button_Delete) = true;
objEntryScreen.Title = strScreenTitle;
objContainer.AddButton(CRM.Button("Continue","Continue.Gif",CRM.URL(strContinueURL)));
objContainer.AddBlock(objEntryScreen);

CRM.AddContent(objContainer.Execute(objRecord));
Response.Write(CRM.GetPage(strTab));

if(CRM.Mode == 2)
    Response.Redirect(CRM.URL(strRedirectURL));
if(CRM.Mode == 4)
    Response.Redirect(CRM.URL(strRedirectURL));
%>