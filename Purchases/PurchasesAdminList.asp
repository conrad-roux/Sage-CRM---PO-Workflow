<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->

<%
var strBlockName = "UsersList";
var strTabName = "POREQDetail";
var strNewURL = "Purchases/PurchasesAdminEdit.asp";
var strBuyerURL = "Purchases/PurchasesBuyerEdit.asp";
var strContinueURL = "purchases/PurchasesAdminList.asp";

var objContainer = CRM.GetBlock("container");
var objList = CRM.GetBlock(strBlockName);
objList.PadBottom = false; //takes rows away based on items exists
objList.DeleteGridCol("pura_buyer");

objContainer.AddBlock(objList);
objContainer.DisplayButton(Button_Default) = false;
objContainer.AddButton(CRM.Button("New Requester","New.Gif",CRM.URL(strNewURL)));
objContainer.AddButton(CRM.Button("Continue","Continue.Gif",CRM.URL(strContinueURL)));

var arg = "pura_buyer is null";
CRM.AddContent(objContainer.Execute(arg));
Response.Write(CRM.GetPage("PurchasesAdmin"));

%>