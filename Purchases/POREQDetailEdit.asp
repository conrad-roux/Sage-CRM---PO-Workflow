<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->
<!-- #include file ="..\serversidefuncts.js" -->

<%
var strQSPrimaryKey = "PORD_RecordId";
var strQSForeignKey = "PORD_purchasesId";
var strEntity = "POREQDetail";
var strPrimaryKeyField = "PORD_RecordID";
var strForeignKeyField = "PORD_PurchasesID";
var strScreenObject = "POREQDetailEntryScreen";
var strScreenTitle = "Item Detail";
var strCancelURL = CRM.URL("purchases/PurchasesSummary.asp");
var strSaveURL = "purchases/PurchasesSummary.asp";
var strTab = "POREQDetail";
var itemAction = "";

var strRecordId = new String(Request.QueryString(strQSPrimaryKey));
var arrTemp = new Array();
arrTemp = strRecordId.split(",");
strRecordId = arrTemp[arrTemp.length-1];

var strForeignKeyId = new String(Request.QueryString(strQSForeignKey));
var arrTemp = new Array();
arrTemp = strForeignKeyId.split(",");
strForeignKeyId = arrTemp[arrTemp.length-1];

if(Defined(strRecordId))
{
itemAction = "Item Updated:";
var objRecord = CRM.FindRecord(strEntity, strPrimaryKeyField+" = "+strRecordId);
strForeignKeyId = objRecord(strForeignKeyField);
}
else
{
itemAction = "Item Added:";
var objRecord = CRM.CreateRecord(strEntity);
objRecord("pord_accpacstatus") = 0;
objRecord(strForeignKeyField) = strForeignKeyId;
if(CRM.Mode == 0)CRM.Mode = 1;
}

objHeaderRecord = CRM.FindRecord("Purchases","pure_PurchasesID = "+strForeignKeyId);
 
var objContainer = CRM.GetBlock("container");
var objEntryScreen = CRM.GetBlock(strScreenObject);
objEntryScreen.Title = strScreenTitle;

if(!objHeaderRecord.eof)
{
    var locationEntryField = objEntryScreen.GetEntry("pord_Location");
    locationEntryField.DefaultType = 1;
    locationEntryField.DefaultValue = objHeaderRecord("pure_Location");
    
    var vendorEntryField = objEntryScreen.GetEntry("pord_vendor");
    vendorEntryField.DefaultType = 1;
    vendorEntryField.DefaultValue = objHeaderRecord("pure_vendor");
}

objContainer.AddButton(CRM.Button("Cancel","Cancel.Gif",strCancelURL+"&PURE_PurchasesID="+strForeignKeyId));
objContainer.AddBlock(objEntryScreen);

if(Defined(objHeaderRecord("pure_Name"))){
    if((objHeaderRecord("pure_PendingApprove") == CRM.GetContextInfo("User","user_userid") || objHeaderRecord("pure_createdby") == CRM.GetContextInfo("User","user_userid")) && !Defined(objHeaderRecord("pure_PONumber"))){
        objContainer.DisplayButton(Button_Default) = true;
        objContainer.DisplayButton(Button_Delete) = true;
    }    
    else
        objContainer.DisplayButton(Button_Default) = false;
}
else{
objContainer.DisplayButton(Button_Default) = true;
objContainer.DisplayButton(Button_Delete) = true;
}

CRM.AddContent(objContainer.Execute(objRecord));
CRM.AddContent(
              "<" + "script>" +
              "XmlHttp = null; "+
              "function CallAspPage(aspPath) {" +
              "    var strQS = location.href.split(/\\?/)[1]; " +
              "    var strAddr;" +
              "    if (window.location.toString().toLowerCase().search('eware.dll')==-1) {" +
              "        strAddr = window.location.toString().split('CustomPages')[0];" +
              "    } else {" +
              "        strAddr = window.location.toString().split('eware.dll')[0];" +
              "    }" +
              "    var strURL = strAddr + aspPath + '&' + strQS; " +
              "    if (window.XMLHttpRequest) {" +
              "        XmlHttp = new XMLHttpRequest();" +
              "    } else {" +
              "        XmlHttp = new ActiveXObject('Microsoft.XMLHTTP');" +
              "    }" +
              "    /*alert(1);*/" +
              "    XmlHttp.open('GET',strURL,true); " +
              "    XmlHttp.setRequestHeader('Content-Type', 'text/xml'); " +
              "    XmlHttp.onreadystatechange = OnStateChange;" +
              "    XmlHttp.send(null); " +
              "}" +
              "function OnStateChange() {" +
              "if(XmlHttp.readyState == 0 || XmlHttp.readyState == 4){" +
              "var res = (XmlHttp.status == 0 || (XmlHttp.status >= 200 && XmlHttp.status < 300) || XmlHttp.status == 304 || XmlHttp.status == 1233);" +
              "/*alert (res);" +
              "alert(XmlHttp.responseText);*/" +
              "$('#pord_unitprice').val((XmlHttp.responseText).toString());" +
              "}" +
              "}" +
              "</s" + "cript>"
              );
        CRM.AddContent(
              "<" + "script>" +
              "function getPrice(itemNo,locationNo) {" +
              "var res = CallAspPage('CustomPages/Purchases/checkItemPrice.asp?Item='+itemNo+'&ItemLocation='+locationNo+'');" +
              "}" +
              "</s" + "cript>"
              );


if(CRM.Mode == 2 && objContainer.Validate()){

    if(Defined(objRecord("pord_itemNo")))
        objRecord("pord_itemdesc") = getDBValues("vICITEM", "where rowid = "+objRecord("pord_itemNo"), "description");
    else
        objRecord("pord_itemdesc") = objRecord("pord_noInvItem");
    
    createTrackingRecord(objHeaderRecord("pure_purchasesid"), itemAction+" "+objRecord("pord_itemdesc"));
    objRecord.SaveChanges();
    Response.Redirect(CRM.URL("purchases/PurchasesSummary.asp")+"&PURE_PurchasesID="+strForeignKeyId);
}
if(CRM.Mode == 4){

    if(Defined(objRecord("pord_itemNo")))
        objRecord("pord_itemdesc") = getDBValues("vICITEM", "where rowid = "+objRecord("pord_itemNo"), "description");
    else
        objRecord("pord_itemdesc") = objRecord("pord_noInvItem");
    
    createTrackingRecord(objHeaderRecord("pure_purchasesid"), "Item Deleted: "+objRecord("pord_itemdesc"));
    Response.Redirect(CRM.URL("purchases/PurchasesSummary.asp")+"&PURE_PurchasesID="+strForeignKeyId);
}

Response.Write(CRM.GetPage(strTab));
%>