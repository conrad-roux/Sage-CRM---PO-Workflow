<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->
<!-- #include file = "..\ACCPAC\utilityfuncs.js" -->
<!-- #include file = "..\serversidefuncts.js" -->
<!-- #include file = "accpacPOPages.asp" -->

<%
var strEntity = "Purchases";
var strSeEntity = "PurchaseAdmin";
var strQSPrimaryKey = "PURE_PurchasesID";
var strDetailEntity = "POReqDetail";

var strRecordId = new String(Request.QueryString(strQSPrimaryKey));
var arrTemp = new Array();
arrTemp = strRecordId.split(",");
strRecordId = arrTemp[arrTemp.length-1];

var purchasesRecord = CRM.FindRecord(strEntity,"Pure_purchasesID = "+strRecordId);

var purchasesDetailrecord = CRM.FindRecord(strDetailEntity,"Pord_purchasesID = "+strRecordId+" and pord_deleted is null");
var detail = 0;
while(!purchasesDetailrecord.eof) {
detail = detail + parseFloat(purchasesDetailrecord("pord_unitprice"));
purchasesDetailrecord.NextRecord();
}

var value = detail;

if(purchasesRecord("pure_buyerapprove") != 0)
{
//buyer needs to approve this record
    
    if(purchasesRecord("pure_Vendor") == null || purchasesRecord("pure_Vendor") == "")
    {
        sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                "Approval of Requisition",
                "When a buyer approves a record you need a Vendor",
                "1000",
                "Sage ERP does not accept this action",
                "Vendor cannot be blank");

        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                       sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

        Response.Write(CRM.GetPage());
        Response.End();
    }
    else
    {
        createTrackingRecord(purchasesRecord("pure_purchasesid"), "Buyer approval by "+getUserName(CRM.GetContextInfo("User","user_userid")));
        purchasesRecord("pure_buyerapprove") = 0;
        purchasesRecord("pure_stage") = "Requisition_Approved";
        purchasesRecord("pure_assignedUserID") = purchasesRecord("pure_PendingApprove");
        purchasesRecord.SaveChanges();
        
        Response.Redirect(CRM.URL("Purchases/PurchasesList.asp")+"&"+strQSPrimaryKey+"="+strRecordId);
    }
}

if(purchasesRecord("pure_pendingapprove") != 0)
{
    if(purchasesRecord("pure_lastapproved") == null){
    //this is the first time approval gets done
        var approver = findApprover(purchasesRecord("pure_PurchasesID"),2,CRM.GetContextInfo("User","user_userid"));
        var limits = getLimits(purchasesRecord("pure_PurchasesID"),1); //limits.upper and limits.lower is the object
    
        if(parseFloat(limits.upper) >= parseFloat(value)){
        //high limit is greater and needs only one approval
        
            if(purchasesRecord("pure_Vendor") == null || purchasesRecord("pure_Vendor") == "")
            {
                sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                        "Approval of Requisition",
                        "When promoting to Accpac your Vendor cannot be blank",
                        "1000",
                        "Sage ERP does not accept this action",
                        "Vendor cannot be blank");

                RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                               sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

                Response.Write(CRM.GetPage());
                Response.End();
            }
            else
            {
                purchasesRecord("pure_lastapproved") = parseFloat(CRM.GetContextInfo("User","user_userid"));
                purchasesRecord("pure_pendingapprove") = 0;
                purchasesRecord("pure_assignedUserID") = 0;
                purchasesRecord("pure_stage") = "Requisition_Approved";
                createTrackingRecord(purchasesRecord("pure_purchasesid"), "Approved by "+getUserName(CRM.GetContextInfo("User","user_userid")));
                purchasesRecord.SaveChanges();
                
                Response.Redirect(CRM.URL("Purchases/POPromotion.asp")+"&"+strQSPrimaryKey+"="+strRecordId)
            }
        }
        else{
        //high limit is less than value and needs more approvals
            purchasesRecord("pure_lastapproved") = parseFloat(CRM.GetContextInfo("User","user_userid"));
            purchasesRecord("pure_pendingapprove") = approver;
            purchasesRecord("pure_assignedUserID") = approver;
            purchasesRecord("pure_stage") = "Requisition_Approved";
            createTrackingRecord(purchasesRecord("pure_purchasesid"), "Approved by "+getUserName(CRM.GetContextInfo("User","user_userid")));
            createTrackingRecord(purchasesRecord("pure_purchasesid"), "Pending Approval From "+getUserName(approver));
            purchasesRecord.SaveChanges();
            
            Response.Redirect(CRM.URL("Purchases/PurchasesList.asp")+"&"+strQSPrimaryKey+"="+strRecordId);
        } 
    }
    else{
    //this is all the other approvals
        var limits2 = getLimits(purchasesRecord("pure_PurchasesID"),2);

       if(parseFloat(limits2.upper) >= parseFloat(value)){
        //high limit is greater and needs only one approval
        
            if(purchasesRecord("pure_Vendor") == null || purchasesRecord("pure_Vendor") == "")
            {
                sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                        "Approval of Requisition",
                        "When promoting to Accpac your Vendor cannot be blank",
                        "2000",
                        "Sage ERP does not accept this action",
                        "Vendor cannot be blank");

                RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                               sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

                Response.Write(CRM.GetPage());
                Response.End();
            }
            else{
                purchasesRecord("pure_lastapproved") = parseFloat(CRM.GetContextInfo("User","user_userid"));
                purchasesRecord("pure_pendingapprove") = 0;
                purchasesRecord("pure_assignedUserID") = 0;
                purchasesRecord("pure_stage") = "Requisition_Approved";
                createTrackingRecord(purchasesRecord("pure_purchasesid"), "Approved by "+getUserName(CRM.GetContextInfo("User","user_userid")));
                purchasesRecord.SaveChanges();
                
                Response.Redirect(CRM.URL("Purchases/POPromotion.asp")+"&"+strQSPrimaryKey+"="+strRecordId)
            }
        }
        else{
        //high limit is lesser than value and needs more approvals
            var approver = findApprover(purchasesRecord("pure_PurchasesID"),2,CRM.GetContextInfo("User","user_userid"));
            purchasesRecord("pure_lastapproved") = parseFloat(CRM.GetContextInfo("User","user_userid"));
            purchasesRecord("pure_pendingapprove") = approver;
            purchasesRecord("pure_assignedUserID") = approver;
            purchasesRecord("pure_stage") = "Requisition_Approved";
            createTrackingRecord(purchasesRecord("pure_purchasesid"), "Approved by "+getUserName(CRM.GetContextInfo("User","user_userid")));
            createTrackingRecord(purchasesRecord("pure_purchasesid"), "Pending Approval From "+getUserName(approver));
            purchasesRecord.SaveChanges();
            
            Response.Redirect(CRM.URL("Purchases/PurchasesList.asp")+"&"+strQSPrimaryKey+"="+strRecordId);
        } 
    } 
}

/*}
else
{
        sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                "Approval of Requisition",
                                "When promoting to Accpac your Vendor cannot be blank",
                                "1111",
                                "Sage ERP does not accept this action",
                                "Vendor cannot be blank");

        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                       sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

        Response.Write(CRM.GetPage());
        Response.End();
}*/
//Response.Redirect(CRM.URL("Purchases/POPromotion.asp")+"&"+strQSPrimaryKey+"="+strRecordId)
%>