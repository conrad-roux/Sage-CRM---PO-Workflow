<!-- #include file = "../EntryDefs.js" -->
<!-- #include file = "UtilityFuncs.js" -->
<!-- #include file = "ErrHandlerFunctions.js" -->

<%
/*
    Copyright © 1994-2009 Sage Software, Inc.

    ****************************
    This file is identical to accpac.js other except for the session
    .Open call.  Any changes made to this file should also be made to
    accpac.js.

    !!!!Changes to this file is the default DB set to SAMINC if not defined     at end. This is for testing puroses ONLY!!!!!
    ****************************


    $Header: /5.x/5.8/_DevSrc/CRMInstallShield_X/ACCPAC_INTEGRATION_PATCH/Files/WWWroot/CustomPages/Accpac/accpac_rw.js 1     21/09/06 9:57 Floode $
*/

//EXTENDED = false;  //DO NOT DISPLAY DIALOG
EXTENDED = true;    //DISPLAY DIALOG

DBLINK_SYSTEM  = 0;
DBLINK_COMPANY = 1;

DBLINK_FLG_READWRITE = 0;
DBLINK_FLG_READONLY  = 1;

// Save the Script Timeout which will be restored if OpenView fails.
ScriptTimeout = Server.ScriptTimeout;

// Create the Accpac Object
Database = CRM.GetContextInfo('Company', 'comp_database');

// If the database is not set in the company then the database must be defined
// in the form.
if (Database == '')
{
    Database  = Request.Form('database');
}

// If the database is not set in the company or form then the database must be defined
// in the query string. This is the case when promoting companies to Accpac.
if (!Defined(Database))
{
    Database  = Request.QueryString('database');
}

//This is hardcoded because of the views based on the SAMINC DB. 
//If this is not the correct DB then it would not work because the views would fail
if (!Defined(Database))
{
    //this is for po
    try{purchase  = Request.QueryString('Pure_PurchasesID');
    var objRecord = CRM.FindRecord("Purchases", "Pure_PurchasesID = "+purchase);
    
    if(Defined(objRecord))
    if(objRecord("pure_Vendor") != "" && objRecord("pure_Vendor") != null){
        //find the correct database
        var compRecord = CRM.FindRecord("Company","comp_companyid = "+objRecord("pure_Vendor"));
        Database = compRecord("comp_database");
    }
    else{
        //find default database
        var accpacConfig = CRM.FindRecord("AccPacConfig", "Accp_Database is not null");
        Database = accpacConfig("Accp_Database");
    }
}
catch(ex){}
}

InitAccpac();

function InitAccpac()
{
if (Defined(Database))
{
    Database = trim (Database);

    ConfigQuery = CRM.CreateQueryObj("SELECT * FROM AccpacConfig WHERE accp_database='" + Database + "' AND accp_deleted IS NULL");
    ConfigQuery.SelectSql();

    if (!ConfigQuery.Eof)
    {
        Database    = ConfigQuery.FieldValue('AccP_database');
        CompanyName = ConfigQuery.FieldValue('AccP_description');
        ServerName  = ConfigQuery.FieldValue('AccP_ServerName');

        AccpacSecurityQuery = CRM.CreateQueryObj("SELECT * FROM AccpacSecurity WHERE asec_userid=" + CRM.GetContextInfo('User', 'user_userid') + " AND asec_database='" + Database + "' AND asec_deleted IS NULL");
        AccpacSecurityQuery.SelectSql();

        if (AccpacSecurityQuery.eof)
        {
            UserId        = CRM.GetContextInfo('User', 'User_AccpacID');
            UserPassword  = CRM.CheckFormat(CRM.GetContextInfo('User', 'User_AccpacPSWD'));
        }
        else
        {
            UserId        = AccpacSecurityQuery.FieldValue('asec_accpacid');
            UserPassword  = CRM.CheckFormat(AccpacSecurityQuery.FieldValue('asec_accpacpswd'));
        }

        if (UserPassword == null || UserPassword == '')
        {
            RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                       CRM.GetTrans('Accpac_Messages', 'ErrPasswordBlank'), '', '', true);

            Response.Write (CRM.GetPage());

            Response.End();
        }

        if (UserId == null || UserId == '')
        {
            RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                       CRM.GetTrans('Accpac_Messages', 'ErrUserIDBlank'), '', '', true);

            Response.Write (CRM.GetPage());

            Response.End();
        }

        var now = new Date();

        Database     = Database.toUpperCase();
        UserId       = UserId.toUpperCase();
        UserPassword = UserPassword.toUpperCase();

        var sMessage = "";

        try
        {
            sMessage = "Creating ACCPAC.Session object";
            Accpac = new ActiveXObject("ACCPAC.Session");

        try{
            if (ServerName.substr(0,6).toLowerCase() == 'net://')
            {
                sMessage = sprintf ("Connecting to .NET Remoting server %s", ServerName);
                Accpac.RemoteConnect (ServerName, UserId, UserPassword, "");
            }
            }
            catch(ex)
            {
                Accpac.RemoteConnect("net://ACCACWKS1:9000", "", "", "")
            }

            sMessage = "Intializing ACCPAC.Session object";
            Accpac.Init ("", "EW", "EW9999", "56A");

            sMessage = "Opening ACCPAC.Session object.";
            Accpac.Open(UserId, UserPassword, Database, now.getVarDate(), 1, "");

            sMessage = sprintf ("Opening database link to %s", Database);
            dbLinkCompany = Accpac.OpenDBLink (DBLINK_COMPANY, DBLINK_FLG_READWRITE);

            sMessage = sprintf ("Loading company information for %s", ServerName);
            AccpacCompany = dbLinkCompany.GetCompany ();
        }
        catch(e)
        {
            sMessage = sprintf ("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                e.message,
                                e.number,
                                e.description,
                                sMessage);

            RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR 1'),
                       sprintf (CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), Database, sMessage), '', '', true);

            Response.Write (CRM.GetPage());

            Response.End();
        }
    }
    else
    {
        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                   sprintf (CRM.GetTrans('Accpac_Messages', 'ErrNotConfigured'), Database),'Accpac/config_tablesettings.asp',CRM.GetTrans('Config_Base', 'ConfigSettings'), true);

        Response.Write (CRM.GetPage());

        Response.End();

    }
}
}

%>