<!-- #include file = "../AccpacCRmInt.js" -->
<!-- #include file = "../ACCPAC/Accpac_rw.js" -->
<!-- #include file = "../Accpac/Accpac.js" -->
<!-- #include file = "../serversidefuncts.js" -->
<!-- #include file = "../Accpac/pagehandler.js" -->
<!-- #include file = "../Accpac/datefuncs.js" -->
<!-- #include file = "../ACCPAC/utilityfuncs.js" -->

<%
/*
    Copyright © 1994-2009 Sage Software, Inc.
    $Header: /5.x/5.8/_DevSrc/CRMInstallShield_X/ACCPAC_INTEGRATION_PATCH/Files/WWWroot/CustomPages/Accpac/PO_Requistions.asp 1     21/09/06 9:58 Floode $
*/
%>

<SCRIPT runat="server" language="javascript">

Server.ScriptTimeout = 600;  //seconds = 10 minutes
var strTabGroup = "POREQDetail";
strQSPrimaryKey = "PURE_PurchasesID";

var strRecordId = new String(Request.QueryString(strQSPrimaryKey));
var arrTemp = new Array();
arrTemp = strRecordId.split(",");
strRecordId = arrTemp[arrTemp.length - 1];

pageHndlr = new PageHandlerObj();
pageHndlr.GetFilterFields    = GetFilterFields;
pageHndlr.SetFilterFields    = SetFilterFields;
pageHndlr.HiddenFilterFields = HiddenFilterFields;
pageHndlr.GetVariables();

containerBlock = CRM.GetBlock('container');
contentBlock   = CRM.GetBlock('content');

with (containerBlock)
{
    DisplayButton(Button_Default) = false;
    AddButton(ButtonStatus("Continue", "Continue.Gif", CRM.URL(521)));
    AddBlock(contentBlock);
}

CRM.Mode = Edit;

/*  ************************************************************************************** */
/*               REPLACE WITH THE CALL TO THE VIEW WITH THE ITEM INSIDE                    */
/*  ************************************************************************************** */

var accountMain = 0;
var arrItems = getItems(strRecordId);
var sCont = "";
var valuesArray = new Array();
var seqNumber = getDBValues("Purchases", "where pure_purchasesID = " + strRecordId, "pure_SeqNumber");
var itemAmounts = getItemAmount(seqNumber);

if (arrItems.length > 1)
    for (var i = 0; i < arrItems.length; i++) {
    var o = new Object();
    o.ICITEM = ItemDetails(arrItems[i]);
    o.INVEN = InventoryAccount(o.ICITEM.CNTLACCT);
    o.AMOUNT = 0;
    
    //first item should always be pushed in
    if (i == 0) {
        o.AMOUNT = findItem(itemAmounts, arrItems[i]);
        valuesArray.push(o);
    }
    else {
        var check = inArray(valuesArray, o.INVEN.INVENT);
        var amt = findItem(itemAmounts, arrItems[i]);
    
        if (check == "NOTexists") {
            o.AMOUNT = amt;
            valuesArray.push(o);
        }
        else
            valuesArray[check].AMOUNT = parseFloat(valuesArray[check].AMOUNT) + parseFloat(amt);
    }
}
else {
    var o = new Object();
    o.ICITEM = ItemDetails(arrItems[0]);
    o.INVEN = InventoryAccount(o.ICITEM.CNTLACCT);
    o.AMOUNT = findItem(itemAmounts, arrItems[0]);
    valuesArray.push(o);
}

try {
    for (var i = 0; i < valuesArray.length; i++) {
        Budgets = Budget(valuesArray[i].INVEN.INVENT);
    
    if (i == 0)
        sCont = GridStartTable() + CreateHeaderString();
        
    sCont += CreateDetailString(valuesArray[i].AMOUNT);
}
}
catch(ex) {
    Response.Write(valuesArray[i].INVEN.INVENT+",");
    Response.Write(ex.message+", "+i);
}

sCont += GridEndTable();
contentBlock.Contents = pageHndlr.BuildTable(CreateTitleString(), sCont);

CRM.AddContent (containerBlock.Execute());
CRM.AddContent ('<INPUT TYPE=HIDDEN NAME=txtChild VALUE=POREFRESH></INPUT>');

Response.Write (CRM.GetPage(strTabGroup));


/*  ************************************************************************************** */
/*                                  Functions                                              */
/*  ************************************************************************************** */

function CreateTitleString()
{
    return "Budget Transaction"; //pageHndlr.ShowPageNavControls('Purchases/Test.asp?Database=' + Database, '', '');
}

function CreateHeaderString()
{
    return TR(
              GridHeader(Budgets.DACCTID) +
              GridHeader(Budgets.DAMT2) +
              GridHeader("Requsition Amount for account") +
              GridHeader("Net Amount After Approval")
             );
}

function CreateDetailString(amt)
{
    try {    
        return TR(
                  GridData(Server.HTMLEncode(Budgets.ACCTID), '', pageHndlr.rowclass) +
                  GridData(Server.HTMLEncode(Budgets.AMT2), '', pageHndlr.rowclass) +
                  GridData(Server.HTMLEncode(amt), '', pageHndlr.rowclass) +
                  GridData(Server.HTMLEncode(Budgets.AMT2 - amt), '', pageHndlr.rowclass)
                 );
    }
    catch(e)
    {
        ViewCallFailed (e, 'ICITEM', 'Get 2');
    }
}

function FormOnChangeScript(sName)
{
    return sprintf ('javascript: document.EntryForm._HIDDEN%s.value=document.EntryForm.%s.value; ', sName, sName);
}

function HiddenFilterFields()
{
    return '';
}

function GetFilterFields()
{
    var sFromDate     = '';
    var sToDate       = MaxDate();

    if (CRM.Mode == Save) // Apply Filter button or Goto was pressed
    {
        if (pageHndlr.GotoButtonSelected())
        {
            v_FromDate        = pageHndlr.GetFormString('_HIDDENFromDate', sFromDate);
            v_ToDate          = pageHndlr.GetFormString('_HIDDENToDate',   sToDate);
        }
        else
        {
            v_FromDate        = pageHndlr.GetFormString('FromDate', sFromDate);
            v_ToDate          = pageHndlr.GetFormString('ToDate',   sToDate);
        }
    }
    else
    {
        v_FromDate        = pageHndlr.GetQueryString('myFromDate', sFromDate);
        v_ToDate          = pageHndlr.GetQueryString('myToDate',   sToDate);
    }
}

function SetFilterFields()
{
    return '&myFromDate='        + Server.URLEncode(v_FromDate)     +
           '&myToDate='          + Server.URLEncode(v_ToDate);
}

function ItemDetails(sItem) {
    if (trim(sItem) == '')
        return '';

    if (typeof (ICITEMx) == 'undefined') {
        ICITEMx = OpenView('IC0310');
    }

    try {

        ICITEMx.Fields('ITEMNO').PutWithoutVerification(ObjToStr(sItem));
    }
    catch (e) {
        ViewCallFailed(e, 'ICITEM', 'PutWithoutVerification');
    }
    
    try {
        ICITEMx.Read();
    }
    catch (e) {
        ViewCallFailed(e, 'ICITEM', 'Read');
    }
    

    var oo = new Object();
    oo.DITEMNO = trim(ICITEMx.Fields('ITEMNO').Description);
    oo.DCNTLACCT = trim(ICITEMx.Fields('CNTLACCT').Description);
    oo.DDESC = trim(ICITEMx.Fields('DESC').Description);
    
    oo.ITEMNO = trim(ICITEMx.Fields('ITEMNO').Value);
    oo.CNTLACCT = trim(ICITEMx.Fields('CNTLACCT').Value);
    oo.DESC = trim(ICITEMx.Fields('DESC').Value);

    ICITEMx.RecordClear();
    return oo;
}

function InventoryAccount(sItem) {
    if (trim(sItem) == '')
        return '';

    if (typeof (ACCSET) == 'undefined') {
        ACCSET = OpenView('IC0100');
    }

    try {
        ACCSET.Fields('CNTLACCT').PutWithoutVerification(ObjToStr(sItem));
    }
    catch (e) {
        ViewCallFailed(e, 'ACCSET', 'PutWithoutVerification');
    }

    try {
        ACCSET.Read();
    }
    catch (e) {
        ViewCallFailed(e, 'ACCSET', 'Read');
    }

    var oo = new Object();
    oo.DINVENT = trim(ACCSET.Fields('INVACCT').Description);
    oo.INVENT = trim(ACCSET.Fields('INVACCT').Value);

    ACCSET.RecordClear();
    return oo;
}

function Budget(sItem) {
    if (trim(sItem) == '')
        return '';

    //*************************************
    //*************************************
    //*************************************
    //*************************************
    var segment = getSegment(strQSPrimaryKey);
    sItem = sItem+segment;
        
    if (typeof (GLBUDG) == 'undefined') {
        GLBUDG = OpenView('GL0003');
    }

    try {
        GLBUDG.Fields('ACCTID').PutWithoutVerification(ObjToStr(sItem));
    }
    catch (e) {
        ViewCallFailed(e, 'GLACC', 'PutWithoutVerification');
    }

    try {
        GLBUDG.Read();
    }
    catch (e) {
        ViewCallFailed(e, 'GLACC', 'Read');
    }
    var year = new Date().getFullYear();
    
    var month = new Date().getMonth() + 1;
    var netfields = "NETPERD" + month;
    var oo = new Object();
    var found = false;

    while (GLBUDG.Fetch() != false) {
        if (trim(GLBUDG.Fields('ACCTID').Value) == ObjToStr(sItem)) {
            if (trim(GLBUDG.Fields('FSCSYR').Value) == year) {
            
                oo.DACCTID = trim(GLBUDG.Fields('ACCTID').Description);
                oo.DAMT2 = trim(GLBUDG.Fields(netfields).Description);

                oo.ACCTID = trim(GLBUDG.Fields('ACCTID').Value);
                oo.AMT2 = trim(GLBUDG.Fields(netfields).Value);

                found = true;
            }
        }
    }
    if (!found) {
        oo.DACCTID = trim(GLBUDG.Fields('ACCTID').Description);
        oo.DAMT2 = trim(GLBUDG.Fields(netfields).Description);

        oo.ACCTID = sItem;
        oo.AMT2 = 0;
    }

    GLBUDG.RecordClear();
    return oo;
}

function getItemAmount(sItem) {
    if (trim(sItem) == '')
        return '';

    if (typeof (REQDETAIL) == 'undefined') {
        REQDETAIL = OpenView('PO0770');
    }
    try {
        REQDETAIL.Fields('RQNHSEQ').PutWithoutVerification(ObjToStr(sItem));
    }
    catch (e) {
        ViewCallFailed(e, 'REQDETAIL', 'PutWithoutVerification - ' + sItem);
    }

    try {
        REQDETAIL.Read();
    }
    catch (e) {
        ViewCallFailed(e, 'REQDETAIL', 'Read');
    }

    var items = new Array();
    while (REQDETAIL.Fetch() != false) {
        if (trim(REQDETAIL.Fields('RQNHSEQ').Value) == sItem) {
            var o = new Object();
            o.ItemNo = trim(REQDETAIL.Fields('ITEMNO').Value);
            o.Amount = trim(REQDETAIL.Fields('EXTENDED').Value);
            items.push(o);
        }
    }
    REQDETAIL.RecordClear();
    return items;
}
Server.ScriptTimeout = ScriptTimeout;
</SCRIPT>