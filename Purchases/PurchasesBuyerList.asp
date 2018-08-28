<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->

<%
var strBlockName = "UsersList";
var strTabName = "POREQDetail";
var strNewURL = "Purchases/PurchasesAdminEdit.asp";
var strBuyerURL = "Purchases/PurchasesBuyerEdit.asp";
var strContinueURL = "purchases/PurchasesBuyerList.asp";

var objContainer = CRM.GetBlock("container");
var objList = CRM.GetBlock(strBlockName);
objList.PadBottom = false; //takes rows away based on items exists
objList.DeleteGridCol("pura_requester");
objList.DeleteGridCol("pura_appprover");
objList.DeleteGridCol("pura_uppervalue");

objContainer.AddBlock(objList);
objContainer.DisplayButton(Button_Default) = false;
objContainer.AddButton(CRM.Button("New Buyer","New.Gif",CRM.URL(strBuyerURL)));
objContainer.AddButton(CRM.Button("Continue","Continue.Gif",CRM.URL(strContinueURL)));

var arg = "pura_buyer is not null";
CRM.AddContent(objContainer.Execute(arg));
Response.Write(CRM.GetPage("PurchasesAdmin"));

%>