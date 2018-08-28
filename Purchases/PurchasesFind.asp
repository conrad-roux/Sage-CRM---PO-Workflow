<!-- #include file ="..\crmwizard.js" -->

<%

CRM.SetContext("Find");

if (CRM.Mode<Edit) CRM.Mode=Edit;

var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );

searchEntry=CRM.GetBlock("PurchasesSearchBox");
searchEntry.Title=CRM.GetTrans("Tabnames","Search");
searchEntry.ShowSavedSearch=true;
searchEntry.UseKeyWordSearch=true;

searchList=CRM.GetBlock("PurchasesGrid");
searchContainer=CRM.GetBlock("container");

searchContainer.ButtonTitle="Search";
searchContainer.ButtonImage="Search.gif";

searchContainer.AddBlock(searchEntry);
if( CRM.Mode != 6)
  searchContainer.AddBlock(searchList);

searchContainer.AddButton(CRM.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));

searchList.prevURL=sURL;
CRM.AddContent(searchContainer.Execute(searchEntry));

Response.Write(CRM.GetPage());

%>



