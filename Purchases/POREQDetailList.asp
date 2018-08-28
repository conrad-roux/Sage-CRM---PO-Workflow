<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->

<%
var strBlockName = "POREQDetailList";
var strTabName = "POREQDetail";
var strNewURL = "Purchases/POREQDetailEdit.asp";

var objContainer = CRM.GetBlock("container");
var objList = CRM.GetBlock(strBlockName);
objList.PadBottom = false; //takes rows away based on items exists

objContainer.AddBlock(objList);
objContainer.DisplayButton(Button_Default) = false;
objContainer.AddButton(CRM.Button("New","New.Gif",CRM.URL(strNewURL)));

CRM.AddContent(objContainer.Execute());
Response.Write(CRM.GetPage(strTabName));

%>