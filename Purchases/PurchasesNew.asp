<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->

<%

var Now=new Date();
if (CRM.Mode<Edit) CRM.Mode=Edit;

record=CRM.CreateRecord("Purchases");
if( true )
  record.SetWorkFlowInfo("Purchases Workflow", "Logged");

EntryGroup=CRM.GetBlock("PurchasesNewEntry");
EntryGroup.Title="Purchases";
EntryGroup.CopyErrorsToPageErrorContent = true;
EntryGroup.ShowValidationErrors = false;

context=Request.QueryString("context");
if(!Defined(context) )
  context=Request.QueryString("Key0");

if( !false )
  CRM.SetContext("New");

if( context == iKey_CompanyId && true )
{
  CompId = CRM.GetContextInfo('Company','Comp_CompanyId');
  if ((Defined(CompId)) && (CompId > 0))
  {
    Entry = EntryGroup.GetEntry("Pure_CompanyId");
    Entry.DefaultValue = CompId;
  }
}
else if( context == iKey_PersonId && true )
{
  PersId = CRM.GetContextInfo('Person','Pers_PersonId');
  if ((Defined(PersId)) && (PersId > 0))
  {
    Entry = EntryGroup.GetEntry("Pure_PersonId");
    Entry.DefaultValue = PersId;
  }
}
else if( context == iKey_UserId && true )
{
  UserId = CRM.GetContextInfo('User', 'User_UserId');
  if ((Defined(UserId)) && (UserId > 0))
  {
    Entry = EntryGroup.GetEntry("Pure_UserId");
    Entry.DefaultValue = UserId;
  }
}
else if( context == iKey_ChannelId && true )
{
  ChanId = CRM.GetContextInfo('Channel', 'Chan_ChannelId');
  if ((Defined(ChanId)) && (ChanId > 0))
  {
    Entry = EntryGroup.GetEntry("Pure_ChannelId");
    Entry.DefaultValue = ChanId;
  }
}
else if( context == iKey_LeadId && false )
{
  LeadId = CRM.GetContextInfo('Lead','Lead_LeadId');
  if ((Defined(LeadId)) && (LeadId > 0))
  {
    Entry = EntryGroup.GetEntry("Pure_LeadId");
    Entry.DefaultValue = LeadId;
  }
}
else if( context == iKey_OpportunityId && false )
{
  OppoId = CRM.GetContextInfo('Opportunity','Oppo_OpportunityId');
  if ((Defined(OppoId)) && (OppoId > 0))
  {
    Entry = EntryGroup.GetEntry("Pure_OpportunityId");
    Entry.DefaultValue = OppoId;
  }
}
else if( context == iKey_OrderId && false )
{
  OrderId = CRM.GetContextInfo('Orders','Orde_OrderQuoteId');
  if ((Defined(OrderId)) && (OrderId > 0))
  {
    Entry = EntryGroup.GetEntry("Pure_OrderId");
    Entry.DefaultValue = OrderId;
  }
}
else if( context == iKey_QuoteId && false )
{
  QuoteId = CRM.GetContextInfo('Quotes','Quot_OrderQuoteId');
  if ((Defined(QuoteId)) && (QuoteId > 0))
  {
    Entry = EntryGroup.GetEntry("Pure_QuoteId");
    Entry.DefaultValue = QuoteId;
  }
}
else if( context == iKey_CaseId && false )
{
  CaseId = CRM.GetContextInfo('Case','Case_CaseId');
  if ((Defined(CaseId)) && (CaseId > 0))
  {
    Entry = EntryGroup.GetEntry("Pure_CaseId");
    Entry.DefaultValue = CaseId;
  }
}
else if( context == iKey_AccountId && false )
{
  AccountId = CRM.GetContextInfo('Account','Acc_AccountId');
  if ((Defined(AccountId)) && (AccountId > 0))
  {
    Entry = EntryGroup.GetEntry("Pure_AccountId");
    Entry.DefaultValue = AccountId;
  }
}


names = Request.QueryString("fieldname");
if( Defined(names) )
{
  vals = Request.QueryString("fieldval");
  //get values from dedupe box
  for( i = 1; i <= names.Count; i++)
  {
    Entry = EntryGroup.GetEntry(names(i));
    if( Entry != null )
      Entry.DefaultValue = vals(i);
  }
}

container=CRM.GetBlock("container");
container.AddBlock(EntryGroup);

container.AddButton(
   CRM.Button("Cancel", "cancel.gif", 
      CRM.Url("521")));

if( true )
{
  container.ShowWorkflowButtons = true;
  container.WorkflowTable = 'Purchases';
}

try
{
  CRM.AddContent(container.Execute(record));
}
catch(err)
{
  if(CRM.Mode==Save) {
    CRM.Mode = Edit;
    CRM.AddContent(container.Execute(record));
  }
}

if(CRM.Mode==Save)
  Response.Redirect("PurchasesSummary.asp?J=Purchases/PurchasesSummary.asp&E=Purchases&Pure_PurchasesID="+record("Pure_PurchasesID")+"&"+Request.QueryString);
else
{
  RefreshTabs=Request.QueryString("RefreshTabs");
  if( RefreshTabs = 'Y' )
    Response.Write(CRM.GetPage('New'));
  else
    Response.Write(CRM.GetPage());
}

%>


















