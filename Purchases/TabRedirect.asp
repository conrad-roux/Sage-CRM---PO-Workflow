<!-- #include file = "../AccpacCRmInt.js" -->

<%
var accpacConfig = CRM.FindRecord("AccPacConfig", "Accp_Database is not null");
Database = accpacConfig("Accp_Database");
strDatabase = Database;
Response.Redirect(CRM.URL("Purchases/PO_Requisitions.asp")+"&MENUTITLE=P%2FO+Inquiry+Menu&URLMENU=Accpac%2FPO%5FMainMenu%2Easp&MENUSELECTION=Requisitions&Database="+strDatabase);
%>