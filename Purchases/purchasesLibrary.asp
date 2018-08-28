<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->

<%

var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );
var PersonKey = '';
var CompanyKey = '';
var OpportinityKey = '';
var HasCommunication = '';

Container=CRM.GetBlock("container");

List=CRM.GetBlock("LibraryList");
List.prevURL=sURL;

var Id = new String(Request.Querystring("pure_purchasesID"));

if (Id.toString() == 'undefined') {
   Id = new String(Request.Querystring("Key58"));
}

CRM.SetContext("Purchases", Id);

if (Id != 0 && ( true || true || true) ) {

   record = CRM.FindRecord("Purchases", "pure_purchasesid=" + Id);

   if ( true )	
      CompanyKey = "&Key" + iKey_CompanyId + "=" + "";	
   if ( true )	
      PersonKey = "&Key" + iKey_PersonId + "=" + "";	   	
   if ( true )	
      OpportinityKey = "&Key" + iKey_OpportunityId + "=" + "";
}

if (true)
{
   HasCommunication = "&MakeCommunicationYN=Y";
}

Container.AddBlock(List);
Container.AddButton(CRM.Button("New", "new.gif", CRM.URL(343)+"&Key-1="+iKey_CustomEntity+PersonKey+CompanyKey+OpportinityKey+HasCommunication+"&PrevCustomURL="+List.prevURL+"&E=purchases"));
Container.DisplayButton(1)=false;

if( Id != '')
{
  CRM.AddContent(Container.Execute("Libr_purchases="+Id));
}

CRM.GetCustomEntityTopFrame("purchases");
Response.Write(CRM.GetPage());

%>









