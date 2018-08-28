<!-- #include file ="..\crmwizard.js" -->

<%

Container=CRM.GetBlock("container");
List=CRM.GetBlock("PurchasesProgressList");
Container.AddBlock(List);
Container.DisplayButton(1)=false;

var Id = new String(Request.Querystring("Pure_PurchasesID"));

if (Id.toString() == 'undefined') {
   Id = new String(Request.Querystring("Key58"));
}

var Idarr = Id.split(",");

CRM.SetContext("Purchases", Idarr[0]);

CRM.AddContent(Container.Execute('Pure_PurchasesID='+Idarr[0]));
CRM.GetCustomEntityTopFrame("Purchases");
Response.Write(CRM.GetPage());

%>











