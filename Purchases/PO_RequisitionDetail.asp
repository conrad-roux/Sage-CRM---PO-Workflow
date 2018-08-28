<!-- #include file = "../AccpacCRmInt.js" -->
<!-- #include file = "Accpac.js" -->

<%
/*
    Copyright © 1994-2009 Sage Software, Inc.

    $Header: /5.x/5.8/_DevSrc/CRMInstallShield_X/ACCPAC_INTEGRATION_PATCH/Files/WWWroot/CustomPages/Accpac/PO_RequisitionDetail.asp 1     21/09/06 9:58 Floode $
*/
%>
<SCRIPT runat=server language=javascript>
Server.ScriptTimeout = 600;  //seconds = 10 minutes

// Determine Menu Information
var menuselection = Request.QueryString('MENUSELECTION')(1);
var urlmenu       = Request.QueryString('URLMENU')(1);
var menutitle     = Request.QueryString('MENUTITLE')(1);
var mainmenuparams='&MENUTITLE='+Server.URLEncode(menutitle)+'&URLMENU='+Server.URLEncode(urlmenu)+'&MENUSELECTION='+Server.URLEncode(menuselection);

var rqnnumber     = Request.QueryString('RQNNUMBER');
var urlback       = Request.QueryString('URLBACK');
var paramback     = Request.QueryString('PARAMBACK');

//CRM.AddContent(urlback);
//CRM.AddContent('<BR>'+paramback);

var PORQNH = OpenView('PO0760');

PORQNH.Order = 1;

try
{
    PORQNH.Fields('RQNNUMBER').PutWithoutVerification (ObjToStr (rqnnumber));
}
catch(e)
{
    ViewCallFailed (e, 'PORQNH', 'Put');
}

try
{
    PORQNH.Read();
}
catch(e)
{
    ViewCallFailed (e, 'PORQNH', 'Read');
}

var bDisplayOptionalFields = OptionalFieldsLicensed();

var rButtons = '';

//First button - shipping and billing address info
//var sLink = POShipToAddressLink (PORQNH, 'RQNHSEQ');

//if (sLink != '')
//    rButtons += ButtonRow(ButtonStatus(CRM.GetTrans('PO_ShipBillTo','Title'), 'MMLogShow.gif', sLink));

//Second button - Edit
sLink = PORequisitionLink (null, PORQNH.Fields('RQNNUMBER').Value, PORQNH.Fields('VDCODE').Value);

if (sLink != '')
    rButtons += ButtonRow(ButtonStatus('AccpacEdit', 'Edit.gif', sLink));

//Second button - Edit
if (CreatePurchaseOrder(PORQNH))
{
    sLink = POPurchaseOrderLink (null, '', PORQNH.Fields('VDCODE').Value, PORQNH.Fields('RQNNUMBER').Value);

    if (sLink != '')
        rButtons += ButtonRow(ButtonStatus('NewPOOrder', 'New.gif', sLink));
}


rButtons += ButtonRow(ButtonStatus(menuselection, 'Continue.gif',
                      CRM.URL(urlback) +
                      paramback));

rButtons += ButtonRow(ButtonStatus(menutitle, 'Continue.gif', CRM.URL(urlmenu)));

rButtons = ButtonTable(rButtons);

sContent = GridStartTable();

try
{
    sContent += TR(TD(PORQNH.Fields('RQNNUMBER').Description,  PORequisitionLink (PORQNH.Fields('RQNNUMBER').Value, PORQNH.Fields('RQNNUMBER').Value, PORQNH.Fields('VDCODE').Value))+
                   TD(PORQNH.Fields('VDCODE').Description,     VendorLink(PORQNH.Fields('VDCODE').Value, PORQNH.Fields('VDCODE').Value))+
                   TD(PORQNH.Fields('APPROVED').Description,   FieldPresentationValue(PORQNH.Fields('APPROVED')))+
                   TD(PORQNH.Fields('DATE').Description,       AccpacDateEX(PORQNH.Fields('DATE').Value))+
                   TD(PORQNH.Fields('EXPIRATION').Description, AccpacDateEX(PORQNH.Fields('EXPIRATION').Value))+
                   TD(PORQNH.Fields('POSTDATE').Description,   AccpacDateEX(PORQNH.Fields('POSTDATE').Value)));

    sContent += '<TR>' +
                TD(PORQNH.Fields('EXPARRIVAL').Description,   AccpacDateEX(PORQNH.Fields('EXPARRIVAL').Value)) +
                TD(PORQNH.Fields('DESCRIPTIO').Description,   Server.HTMLEncode(PORQNH.Fields('DESCRIPTIO').Value))+
                TD(PORQNH.Fields('REFERENCE').Description,    Server.HTMLEncode(PORQNH.Fields('REFERENCE').Value))+
                TD(PORQNH.Fields('ONHOLD').Description,       FieldPresentationValue(PORQNH.Fields('ONHOLD'))) +
                TD(PORQNH.Fields('STCODE').Description,       PORQNH.Fields('STCODE'));

    if (PORQNH.Fields('HASJOB').Value)
        sContent += TD(PORQNH.Fields('HASJOB').Description, FieldPresentationValue (PORQNH.Fields('HASJOB')));

    sContent += '</TR>';

    sContent += '<TR>' +
                 TD(PORQNH.Fields('REQUESTBY').Description,  PORQNH.Fields('REQUESTBY').Value)+
                 TD(PORQNH.Fields('APPROVER').Description,   PORQNH.Fields('APPROVER').Value)+
                 TD(PORQNH.Fields('COMMENT').Description,    Server.HTMLEncode(PORQNH.Fields('COMMENT').Value))+
                 TD(PORQNH.Fields('FCEXTENDED').Description, formatCurrency(PORQNH.Fields('FCEXTENDED').Value, PORQNH.Fields('FCCURRENCY').Value));

    if (bDisplayOptionalFields)
        sContent += TD(CRM.GetTrans('ColNames', 'OptionalFields'), OptionalFieldLink (PORQNH.Fields('VALUES').Value, 'PO0763', 'RQNHSEQ=' + PORQNH.Fields('RQNHSEQ').Value));

    sContent += '</TR>';
}
catch(e)
{
    ViewCallFailed (e, 'PORQNH', 'Get');
}

sContent += GridEndTable();

CRM.AddContent('<TABLE COLS=3><TR>'+
                 '<TD WIDTH=85%>'+BuildTable(CRM.GetTrans('Colnames', 'RequisitionInformation'), sContent)+'</TD>'+
                 '<TD>&nbsp;</TD>'+
                 '<TD ALIGN=TOP VALIGN=TOP>'+rButtons+'</TD>'+
                 '</TR>'+
                 '</TABLE>');


var PORQNL  = OpenView('PO0770');
var PORQNLV = OpenView('PO0777');

try
{
    ComposeViews();
}
catch(e)
{
    ViewCallFailed (e, 'PORQNH', 'Compose');
}

try
{
    PORQNL.Browse('RQNHSEQ='+PORQNH.Fields('RQNHSEQ').Value, true);
}
catch(e)
{
    ViewCallFailed (e, 'PORQNH', 'Browse');
}

sContent = GridStartTable();

if (PORQNH.Fields('HASJOB').Value)
    sContent += GridHeader(PORQNL.Fields('CONTRACT').Description)  +
                GridHeader(PORQNL.Fields('PROJECT').Description)   +
                GridHeader(PORQNL.Fields('CCATEGORY').Description) +
                GridHeader(PORQNL.Fields('COSTCLASS').Description);

sContent += GridHeader(PORQNL.Fields('ITEMNO').Description) +
            GridHeader(PORQNL.Fields('ITEMDESC').Description) +
            GridHeader(PORQNL.Fields('LOCATION').Description) +
            GridHeader(PORQNL.Fields('VDCODE').Description) +
            GridHeader(PORQNL.Fields('VDNAME').Description) +
            GridHeader(PORQNL.Fields('EXPARRIVAL').Description) +
            GridHeader(DivR(PORQNL.Fields('OQORDERED').Description)) +
            GridHeader(PORQNL.Fields('ORDERUNIT').Description) +
            GridHeader(DivR(PORQNL.Fields('UNITCOST').Description)) +
            GridHeader(DivR(PORQNL.Fields('EXTENDED').Description));

if (bDisplayOptionalFields)
    sContent += GridHeaderWidth(CRM.GetTrans('ColNames', 'OptionalFields'), false, '5%');

try
{
    var rowclass = 'ROW1';

    while ( PORQNL.Fetch() != false )
    {
        var itemline = ItemLink(PORQNL.Fields('ITEMNO').Value, PORQNL.Fields('LOCATION').Value, '');

        sContent += '<TR>';

        if (PORQNH.Fields('HASJOB').Value)
        {
            sContent += GridData(PMContractLink (PORQNL.Fields('CONTRACT').Value, PORQNL.Fields('CONTRACT').Value, ''),'',rowclass) +
                        GridData(PORQNL.Fields('PROJECT').Value,'',rowclass) +
                        GridData(PORQNL.Fields('CCATEGORY').Value,'',rowclass) +
                        GridData(FieldPresentationValue(PORQNL.Fields('COSTCLASS')),'',rowclass);
        }

        sContent += GridData(itemline,'',rowclass) +
                    GridData(Server.HTMLEncode(PORQNL.Fields('ITEMDESC').Value),'',rowclass) +
                    GridData(LocationDescription(PORQNL.Fields('LOCATION').Value),'',rowclass) +
                    GridData(VendorLink(PORQNL.Fields('VDCODE').Value, PORQNL.Fields('VDCODE').Value),'',rowclass) +
                    GridData(Server.HTMLEncode(PORQNL.Fields('VDNAME').Value),'',rowclass) +
                    GridData(AccpacDateEX(PORQNL.Fields('EXPARRIVAL').Value),'',rowclass) +
                    GridData(DivR(PORQNL.Fields('OQORDERED').Value),'',rowclass) +
                    GridData(PORQNL.Fields('ORDERUNIT').Value,'',rowclass) +
                    GridData(DivR(ItemContractCostLink(PORQNL.Fields('ITEMNO').Value, PORQNL.Fields('VDCODE').Value, PORQNL.Fields('UNITCOST'), PORQNL.Fields('CURRENCY').Value)),'',rowclass) +
                    GridData(DivR(formatCurrency(PORQNL.Fields('EXTENDED').Value,   PORQNL.Fields('CURRENCY').Value)),'',rowclass);

        if (bDisplayOptionalFields)
            sContent += GridData(OptionalFieldLink (PORQNL.Fields('VALUES').Value, 'PO0773', 'RQNHSEQ=' + PORQNL.Fields('RQNHSEQ').Value + ' AND ' + 'RQNLREV=' + PORQNL.Fields('RQNLREV').Value),'',rowclass);

        sContent += '</TR>';

        if (rowclass == 'ROW1') rowclass = 'ROW2'; else rowclass = 'ROW1';
    }
}
catch(e)
{
    ViewCallFailed (e, 'PORQNL', 'Get');
}


sContent += GridEndTable();

CRM.AddContent('<BR>' + BuildTable(PORQNL.Description, sContent));

CRM.AddContent('<INPUT TYPE=HIDDEN NAME=txtChild VALUE=POREFRESH></INPUT>');

Response.Write(CRM.GetPage());

function CreatePurchaseOrder(XXVIEW)
{
    if (XXVIEW.Fields('ISCOMPLETE').Value)
        return false;

    return true;
}

Server.ScriptTimeout = ScriptTimeout;
</SCRIPT>

<SCRIPT runat=server language=vbScript>
Function ComposeViews()
    PORQNH.Compose Array(Nothing, PORQNL, Nothing, Nothing, PORQNLV)
    PORQNL.Compose Array(PORQNH, Nothing, Nothing, Nothing, PORQNLV)
    PORQNLV.Compose Array(PORQNH, Nothing, PORQNL)
End Function
</SCRIPT>