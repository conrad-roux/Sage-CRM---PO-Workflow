<!-- #include file = "../AccpacCRmInt.js" -->
<!-- #include file = "../Accpac/Accpac.js" -->
<!-- #include file = "../serversidefuncts.js" -->
<!-- #include file = "../Accpac/pagehandler.js" -->
<!-- #include file = "../Accpac/datefuncs.js" -->

<%
/*
    Copyright © 1994-2009 Sage Software, Inc.
    $Header: /5.x/5.8/_DevSrc/CRMInstallShield_X/ACCPAC_INTEGRATION_PATCH/Files/WWWroot/CustomPages/Accpac/PO_Requistions.asp 1     21/09/06 9:58 Floode $
*/
%>

<SCRIPT runat="server" language="javascript">
    Server.ScriptTimeout = 600;  //seconds = 10 minutes
    var strTabGroup = "POREQDetail";
//Response.Write(Request.Form());
//Response.End;

// Determine Menu Information
/*var menuselection = Request.QueryString('MENUSELECTION')(1);
var urlmenu       = Request.QueryString('URLMENU')(1);
var menutitle     = Request.QueryString('MENUTITLE')(1);
var mainmenuparams='&MENUTITLE='+Server.URLEncode(menutitle)+'&URLMENU='+Server.URLEncode(urlmenu)+'&MENUSELECTION='+Server.URLEncode(menuselection);
*/

//CRM.AddContent(menuselection);
//CRM.AddContent('<BR>'+urlmenu);
//CRM.AddContent('<BR>'+menutitle);

pageHndlr = new PageHandlerObj();

//Callback functions
pageHndlr.GetFilterFields    = GetFilterFields;
pageHndlr.SetFilterFields    = SetFilterFields;
pageHndlr.HiddenFilterFields = HiddenFilterFields;

pageHndlr.GetVariables();

var VIEW_SYSACCS_POSTING = 10;  // constant (originally from xapi's IDL file)

containerBlock = CRM.GetBlock('container');
contentBlock   = CRM.GetBlock('content');

var ThisVendor = ""

/*if (ThisVendor == '')
{
    with (containerBlock)
    {
        Title = sprintf(CRM.GetTrans('Company_Transactions','NotAccpacCompany'), CRM.GetTrans('Comp_Type', 'Vendor'));
        DisplayButton(Button_Default) = false;

        CRM.AddContent(Execute());
    }

    Response.Write (CRM.GetPage());

    Response.End();
}*/

// Fully Paid is now a checkbox -
// ALWAYS include the not fully paid options, ALSO include fully paid if ticked
FilterE = CRM.GetBlock('entry');

with (FilterE)
{
    FieldName = 'SWPAID';
    EntryType=iEntryType_CheckBox;
    DefaultType=iDefault_Value;
    Size = 1;
    DefaultValue=pageHndlr.sPaid;
}

FilterC = CRM.GetBlock('entry');
with (FilterC) {

    EntryType = iEntryType_AdvSearchSelect;
    SearchSQL = "comp_idvend is not null";
    Caption = CRM.GetTrans('ColNames', 'comp_idvend') + ':';
    CaptionPos = CapTop;
    FieldName = 'comp_idvend';
    LookUpFamily = 'Company';
    Size = 40;
    NewLine = false;
    DefaultType = 1;
    DefaultValue = pageHndlr.vdCode;
}

hiddenBlock  = CRM.GetBlock('content');
hiddenBlock.Contents = HiddenFilterFields();

Filter = CRM.GetBlock('entrygroup');

with (Filter)
{
    Title = CRM.GetTrans('Button', 'Filter');

    AddBlock(FilterE);
    AddBlock(FilterC);
    AddBlock(BuildDateField ('FromDate', CRM.GetTrans('ColNames', 'FromRequisitionDate'), v_FromDate, false));
    AddBlock(BuildDateField ('ToDate',   CRM.GetTrans('ColNames', 'ToRequisitionDate'),   v_ToDate,   false));

    AddButton(ButtonStatus('Filter','Filter.gif','javascript:document.EntryForm.submit()'));

    var sLink = CRM.URL("Purchases/PurchasesEdit.asp")//PORequisitionLink(null, '', "");

    if (sLink != '')
    {
        //if (CRM.GetContextInfo('Company','Comp_Status') != 'Inactive')
            AddButton(ButtonStatus('New','New.gif', sLink));
        //else
            //AddButton(ButtonStatus('New','New.gif',"javascript:alert('" + sprintf(CRM.GetTrans('Accpac_Messages', 'ErrInactive'), CRM.GetTrans('Colnames', 'Comp_IdVend'), ThisVendor) + "');"));
    }

    AddButton(ButtonStatus("Continue", 'Continue.gif', CRM.URL(521)));
}

with (containerBlock)
{
    DisplayButton(Button_Default) = false;

    AddBlock(Filter);
    AddBlock(hiddenBlock);
    AddBlock(contentBlock);
}

CRM.Mode = Edit;

/*  ************************************************************************************** */
/*                                  Open the P/O View                                      */
/*  ************************************************************************************** */

var PORQNH = OpenView('PO0760');

PORQNH.Order = 1;

try
{
    PORQNH.Browse(PORQNHFilter(),true);
}
catch(e)
{
    ViewCallFailed (e, 'PORQNH', 'Browse');
}

/*  ************************************************************************************** */
/*                                  Count Pages                                            */
/*  ************************************************************************************** */

pageHndlr.CountPages(PORQNH, PORQNHFilter());

/*  ************************************************************************************** */
/*                              Construct From and To Arrows                               */
/*  ************************************************************************************** */

try
{
    var origPORQNHSysAccess = PORQNH.SystemAccess;

    switch (pageHndlr.iCommand)
    {
        case pageHndlr.COMMAND_FIRST:
        case pageHndlr.COMMAND_LAST:
        case pageHndlr.COMMAND_GOTO:
            // Since PORQNH (PO0620) is not composed to its details, we
            // must temporarily set the system access to "POST" during
            // "put without verification" calls.  This prevents spurious
            // errors when the vendor ID has "funny" characters in it.
            PORQNH.SystemAccess = VIEW_SYSACCS_POSTING;

            if (false == pageHndlr.bSortOrder)
                pageHndlr.PutMaxKey(PORQNH);
            else
                pageHndlr.PutMinKey(PORQNH);

            PORQNH.SystemAccess = origPORQNHSysAccess;
            PORQNH.Browse(PORQNHFilter(),pageHndlr.bSortOrder);
            break;

        case pageHndlr.COMMAND_NEXT:
            // Since PORQNH (PO0620) is not composed to its details, we
            // must temporarily set the system access to "POST" during
            // "put without verification" calls.  This prevents spurious
            // errors when the vendor ID has "funny" characters in it.
            PORQNH.SystemAccess = VIEW_SYSACCS_POSTING;
            //PORQNH.Fields('VDCODE').PutWithoutVerification(ObjToStr (ThisVendor));
            PORQNH.Fields('RQNNUMBER').PutWithoutVerification(ObjToStr (pageHndlr.orderkey));
            PORQNH.SystemAccess = origPORQNHSysAccess;
            if (false == pageHndlr.bSortOrder)
                var sFilter = PORQNHFilter() + ' AND (RQNNUMBER<' + enclose(escapeQuotes(pageHndlr.orderkey)) + ')';
            else
                var sFilter = PORQNHFilter() + ' AND (RQNNUMBER>' + enclose(escapeQuotes(pageHndlr.orderkey)) + ')';

            PORQNH.Browse(sFilter,pageHndlr.bSortOrder);
            break;

        case pageHndlr.COMMAND_PREV:
            // Since PORQNH (PO0620) is not composed to its details, we
            // must temporarily set the system access to "POST" during
            // "put without verification" calls.  This prevents spurious
            // errors when the vendor ID has "funny" characters in it.
            PORQNH.SystemAccess = VIEW_SYSACCS_POSTING;
            //PORQNH.Fields('VDCODE').PutWithoutVerification(ObjToStr (ThisVendor));
            PORQNH.Fields('RQNNUMBER').PutWithoutVerification(ObjToStr (pageHndlr.orderkey));
            PORQNH.SystemAccess = origPORQNHSysAccess;
            if (false == pageHndlr.bSortOrder)
                var sFilter = PORQNHFilter() + ' AND (RQNNUMBER>' + enclose(escapeQuotes(pageHndlr.orderkey)) + ')';
            else
                var sFilter = PORQNHFilter() + ' AND (RQNNUMBER<' + enclose(escapeQuotes(pageHndlr.orderkey)) + ')';

            PORQNH.Browse(sFilter, !(pageHndlr.bSortOrder));  // previous means browsing with the OPPOSITE order to the sort order
            break;
    }
}
catch(e)
{
    ViewCallFailed (e, 'PORQNH', 'Get');
}

// Note that DetailsToGet will fetch through all records for COMMAND_LAST
// and will fetch up to the "page before's" last record for COMMAND_GOTO.
var iDetailsToAdd = new Number(pageHndlr.DetailsToGet(PORQNH));

if (pageHndlr.iCommand == pageHndlr.COMMAND_LAST)
{
    // Since DetailsToGet on COMMAND_LAST fetched past the "last" record,
    // we need to re-browse, flipping the direction, so that we will get to
    // to the "last" record in the next fetch.
    PORQNH.Browse(PORQNHFilter(),!(pageHndlr.bSortOrder));
}

Status = new Boolean;
// get the first record
try
{
    Status = PORQNH.Fetch();
    //Status = true;
}
catch(e)
{
    ViewCallFailed (e, 'PORQNH', 'Fetch');
}

s = new String();
if (Status == false)
{
    containerBlock.Title = CRM.GetTrans('Company_Transactions', 'NoRecordsVendor');
    containerBlock.Title = containerBlock.Title + " - " + sFilter
}
else
{
    pageHndlr.SetFirstKey(PORQNH.Fields('RQNNUMBER').Value);

    while (Status != false && pageHndlr.iDetails < iDetailsToAdd)
    {
        pageHndlr.SetLastKey(PORQNH.Fields('RQNNUMBER').Value);

        pageHndlr.AddDetail(CreateDetailString());

        try
        {
            Status = PORQNH.Fetch();
        }
        catch(e)
        {
            ViewCallFailed (e, 'PORQNH', 'Fetch');
        }
    }

    if (Status == false)
        pageHndlr.FoundEndofFile();

    contentBlock.Contents = pageHndlr.ShowDetails(CreateTitleString(), CreateHeaderString());
}

CRM.AddContent (containerBlock.Execute());
CRM.AddContent ('<INPUT TYPE=HIDDEN NAME=txtChild VALUE=POREFRESH></INPUT>');

Response.Write(CRM.GetPage(strTabGroup));


/*  ************************************************************************************** */
/*                                  Functions                                              */
/*  ************************************************************************************** */

function CreateTitleString()
{
    return pageHndlr.ShowPageNavControls('Purchases/PO_Requisitions.asp?Database='+Database,'','');
}

function CreateHeaderString()
{
    var docnumtitle = PORQNH.Fields('RQNNUMBER').Description + pageHndlr.ShowNavButton('Purchases/PO_Requisitions.asp?Database='+Database,pageHndlr.COMMAND_SORT);

    return TR(GridHeaderWidth(CRM.GetTrans('ColNames', 'DrillDown'), false, '5%') +
              GridHeader(docnumtitle) +
              GridHeader(PORQNH.Fields('VDCODE').Description) +
              GridHeader(PORQNH.Fields('ONHOLD').Description) +
              GridHeader(PORQNH.Fields('REFERENCE').Description) +
              GridHeader(PORQNH.Fields('DESCRIPTIO').Description) +
              GridHeader(PORQNH.Fields('DATE').Description) +
              GridHeader(PORQNH.Fields('EXPARRIVAL').Description) +
              GridHeader(PORQNH.Fields('FCEXTENDED').Description)
             );
}


function CreateDetailString()
{
    try
    {
        var onholdstatus = '&nbsp;';

        if (PORQNH.Fields('ONHOLD') != 0)
            onholdstatus = FieldPresentationValue(PORQNH.Fields('ONHOLD'));

        return TR(GridDataWidth(ButtonStatus('', 'MMLogShow.gif', CRM.URL('Purchases/PO_RequisitionDetail.asp?Database='+Database) +
                                             '&URLBACK=' + Server.URLEncode('Purchases/PO_Requisitions.asp?Database='+Database) +
                                             '&PARAMBACK='+Server.URLEncode(pageHndlr.GetPageInfo())+
                                             "&RQNNUMBER="+Server.URLEncode(PORQNH.Fields('RQNNUMBER').Value)),'',pageHndlr.rowclass, '5%') +
                  GridData(PORequisitionLink (PORQNH.Fields('RQNNUMBER').Value, PORQNH.Fields('RQNNUMBER').Value, PORQNH.Fields('VDCODE').Value),'', pageHndlr.rowclass) +
                  GridData(Server.HTMLEncode(PORQNH.Fields('VDCODE').Value), '', pageHndlr.rowclass) +
                  GridData(onholdstatus,'',pageHndlr.rowclass) +
                  GridData(Server.HTMLEncode(PORQNH.Fields('REFERENCE').Value), '', pageHndlr.rowclass) +
                  GridData(Server.HTMLEncode(PORQNH.Fields('DESCRIPTIO').Value),'',pageHndlr.rowclass) +
                  GridData(AccpacDateEX(PORQNH.Fields('DATE').Value),'',pageHndlr.rowclass) +
                  GridData(AccpacDateEX(PORQNH.Fields('EXPARRIVAL').Value),'',pageHndlr.rowclass) +
                  GridData(DivR(formatCurrency(PORQNH.Fields('FCEXTENDED').Value, PORQNH.Fields('FCCURRENCY').Value)),'',pageHndlr.rowclass)
                 );
    }
    catch(e)
    {
        ViewCallFailed (e, 'PORQNH', 'Get');
    }
}

function PORQNHFilter()
{
    var sFilter = "" //sprintf('(VDCODE=%s)', enclose(escapeQuotes(ThisVendor)));

    sFilter += sprintf('(DATE>=%s) AND (DATE<=%s)',
                       GetBCDDateString(v_FromDate), GetBCDDateString(v_ToDate));

    if (pageHndlr.sPaid != 'on')
        sFilter += ' AND (ISCOMPLETE=0)';

    if (pageHndlr.vdCode != undefined && pageHndlr.vdCode != "") {
        //Response.Write(pageHndlr.vdCode);
        sFilter += ' AND (VDCODE = ' + getDBValues("Company", "where comp_companyid = " + pageHndlr.vdCode, "comp_idvend") + ')';
        //Response.Write(sFilter)
    }
    
    //Response.Write(sFilter);
    //Response.End;

    return sFilter;
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

Server.ScriptTimeout = ScriptTimeout;
</SCRIPT>