<!-- #include file = "../ACCPAC/Accpac_rw.js" -->
<!-- #include file = "../ACCPAC/utilityfuncs.js" -->
<!-- #include file = "../serversidefuncts.js" -->

<script runat="server" language="JavaScript">

function poDetails(vendor, itemNo, quantity, comment, completion, location, uom, cost, copycost){
var obj = new Object();

obj.vendor = vendor;
obj.itemoNo = itemNo;
obj.quantity = quantity;
obj.comment = comment;
obj.completion = completion;
obj.location = location;
obj.uom = uom;
obj.cost = cost;
obj.copycost = (copycost=='Y') ? 1 : 0;

return obj;
}

function headerDetails(vendor, requester, location, description, reference, exparationDate, requiredDate, comment, onhold){
var obj = new Object();

obj.vendor = vendor;
obj.requester = requester;
obj.location = location;
obj.description = description;
obj.reference = reference;
tmpTestVal = new Date(exparationDate).getFullYear();
if (tmpTestVal == "1899") obj.exparationDate = ""; else obj.exparationDate = new String(exparationDate);
tmpTestVal = new Date(requiredDate).getFullYear();
if (tmpTestVal == "1899") obj.requiredDate = ""; else obj.requiredDate = new String(requiredDate);
obj.comment = comment;
obj.onhold = (onhold == 'Y') ? 1 : 0;

return obj;
}

function buildPORequest(objHeader, arrDetail) {
try
        {
            //setting all the variables
            var customError = 0;
            var customMess = "";
            
            var headerVendorCode = objHeader.vendor;
            var headerRequester = objHeader.requester;
            var headerLocationCode = objHeader.location;
            var headerDescription = objHeader.description;
            var headerReference = objHeader.reference;
            var headerExparationDate = objHeader.exparationDate;
            var headerRequiredDate = objHeader.requiredDate;
            var headerComment = objHeader.comment;
            var headerHold = objHeader.onhold;
        
            sMessage = sprintf("Open views", "Company");
            //-----------------------------------------------------------------

            PORQN1header = OpenView("PO0760");
            PORQN1detail1 = OpenView("PO0770");
            PORQN1detail2 = OpenView("PO0750");
            PORQN1detail3 = OpenView("PO0759");
            PORQN1detail4 = OpenView("PO0763");
            PORQN1detail5 = OpenView("PO0773");
            PORQN1detail6 = OpenView("PO0777");
            
            sMessage = sprintf("Compose the Views", "Company");
            //------------------------------------------------------------
            ComposePRViews();

            sMessage = sprintf("Compose the Requisition");
            //---------------------------------------------------------------
            PORQN1header.Order = 1;
            PORQN1header.Order = 0;

            PORQN1header.Fields("RQNHSEQ").PutWithoutVerification ("0");            //Requisition Sequence Key

            PORQN1header.Init();
            PORQN1header.Order = 1;
            PORQN1detail1.RecordClear();
            PORQN1detail2.Init();

            customError = 12;
            customMess = "Vendor error - Vendor might be inactive";
            
            if (headerVendorCode != null && headerVendorCode != "")
                PORQN1header.Fields("VDCODE").Value = headerVendorCode              //Vendor   
            PORQN1header.Fields("PROCESSCMD").PutWithoutVerification ("1");         //Command

            PORQN1header.Process();

            sMessage = sprintf("Accpac dates incorrect");
            PORQN1header.Fields("REQUESTBY").Value = headerRequester;                         //Requested by
            //PORQN1header.Fields("EXPIRED").Value = "1";

            if (headerExparationDate != "") PORQN1header.Fields("EXPIRATION").Value = AccpacDateEX(headerExparationDate);        // Expiration Date
            if (headerRequiredDate != "") PORQN1header.Fields("EXPARRIVAL").Value = AccpacDateEX(headerRequiredDate);         // Date Required

            customError = 13;
            customMess = "Location error - please see logs";
            PORQN1header.Fields("STCODE").Value = headerLocationCode;                              //Location

            customError = 14;
            customMess = "Description is incorrect";
            PORQN1header.Fields("DESCRIPTIO").Value = headerDescription;                       //Description
            PORQN1header.Fields("REFERENCE").Value = headerReference;                        //Reference
            PORQN1header.Fields("COMMENT").Value = headerComment;                           //Comment
            PORQN1header.Fields("ONHOLD").Value = headerHold;
            
            /*******************************************************************/
            /********************BUILD DETAIL LINES*****************************/
            
            for(var iLoop = 0; iLoop < arrDetail.length; iLoop++)
            {
            
                customError = 1;
                customMess = arrDetail[iLoop].itemoNo;
            
                PORQN1detail1.RecordCreate(0);
                PORQN1detail1.Fields("ITEMNO").Value = ObjToStr(arrDetail[iLoop].itemoNo);          //"A1-103/0"   *arrDetail[iLoop].itemoNo*                //Item Number
                PORQN1detail1.Fields("PROCESSCMD").PutWithoutVerification ("1");                  //Command
                PORQN1detail1.Process();

                customError = 11;
                //customError = 0;
                PORQN1detail1.Fields("UNITCOST").Value = ObjToStr(arrDetail[iLoop].cost);

                customError = 2;
                
                PORQN1detail1.Fields("OQORDERED").Value = ObjToStr(arrDetail[iLoop].quantity);          //Quantity Ordered
                PORQN1detail1.Fields("ORDERUNIT").Value = ObjToStr(arrDetail[iLoop].uom);              //UOM
                PORQN1detail1.Fields("CPCOSTTOPO").Value = ObjToStr(arrDetail[iLoop].copycost);         //Copy Cost to PO
                PORQN1detail1.Fields("PROCESSCMD").PutWithoutVerification("1");                       //Command

                customError = 3;
                
                if(arrDetail[iLoop].comment != "" || arrDetail[iLoop].comment != null || arrDetail[iLoop].comment != " ")
                {
                    PORQN1detail1.Fields("HASCOMMENT").Value = "1"                                    //Comments/Instructions
                    PORQN1detail2.RecordCreate(0)
                    PORQN1detail2.Fields("COMMENT").PutWithoutVerification (arrDetail[iLoop].comment)         //Comments/Instructions
                    PORQN1detail2.Insert();
                    PORQN1detail2.Fields("RQNCREV").PutWithoutVerification ("-2")                       //Comment Identifier
                }
                
                customError = 4;
                
                PORQN1detail1.Insert();
                PORQN1detail1.Fields("RQNLREV").PutWithoutVerification ("-1");          //Line Number
            }
     
            customError = 0;
     
            PORQN1detail1.Read();
            PORQN1detail1.RecordCreate(0);
            
            PORQN1detail1.Read();
            PORQN1header.Insert();

            var RQNNUMBER = PORQN1header.Fields("RQNNUMBER").Value;
            var RQNHSEQ = PORQN1header.Fields("RQNHSEQ").Value;
            var FCCURRENCY = PORQN1header.Fields("FCEXTENDED").Value;
            
            PORQN1header.Init();
            PORQN1header.Order = 0;

            PORQN1header.Fields("RQNHSEQ").PutWithoutVerification ("0");            //Requisition Sequence Key
            
            PORQN1header.Init();
            PORQN1header.Order = 1;
            PORQN1detail1.RecordClear();
            PORQN1detail2.Init();


            return [RQNNUMBER, RQNHSEQ, FCCURRENCY];
        }
        catch(e) {

            if (customError == 0) {
                sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                e.message,
                                e.number,
                                e.description,
                                sMessage);

                RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

                Response.Write(CRM.GetPage());
                Response.End();
            }
            else {

                switch (customError) {
                    case 1:
                        sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                "The Item Number does not match any item in Sage ERP",
                                e.number,
                                e.description,
                                customMess);

                        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                        sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

                        Response.Write(CRM.GetPage());
                        Response.End();
                        break;
                    case 2:
                        sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                "The selected Unit of Measure is not availble for this Item - "+customMess,
                                e.number,
                                e.description,
                                customMess);

                        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                        sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

                        Response.Write(CRM.GetPage());
                        Response.End();
                        break;
                    case 3:
                        sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                "Item Comment lines cannot be added for item - "+customError,
                                e.number,
                                e.description,
                                customMess);

                        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                        sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

                        Response.Write(CRM.GetPage());
                        Response.End();
                        break;
                    case 4:
                        sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                "The requsition cannot be inserted into Sage ERP due to an error",
                                e.number,
                                e.description,
                                customMess);

                        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                        sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

                        Response.Write(CRM.GetPage());
                        Response.End();
                        break;
                    case 11:
                        sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                "The unit price is incorrect due to an error on Sage ERP",
                                e.number,
                                e.description,
                                customMess);

                        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                        sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

                        Response.Write(CRM.GetPage());
                        Response.End();
                        break;
                    case 12:
                        sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                "The Vendor is incorrect due to an error on Sage ERP",
                                e.number,
                                e.description,
                                customMess);

                        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                        sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

                        Response.Write(CRM.GetPage());
                        Response.End();
                        break; 
                     case 13:
                        sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                "The Location is incorrect due to an error on Sage ERP",
                                e.number,
                                e.description,
                                customMess);

                        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                        sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

                        Response.Write(CRM.GetPage());
                        Response.End();
                        break;
                    case 14:
                        sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                "The Description is incorrect due to an error on Sage ERP",
                                e.number,
                                e.description,
                                customMess);

                        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                        sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

                        Response.Write(CRM.GetPage());
                        Response.End();
                        break;    
                }
            }
        }
    }

function RejectPR(objHeader) {
        try {
            sMessage = sprintf("setting Variables", "Company");
            //setting all the variables
            var reqNumber = objHeader.reqNumber;

            sMessage = sprintf("Open views", "Company");
            //-----------------------------------------------------------------

            PORQN1header = OpenView("PO0760");
            PORQN1detail1 = OpenView("PO0770");
            PORQN1detail2 = OpenView("PO0750");
            PORQN1detail3 = OpenView("PO0759");
            PORQN1detail4 = OpenView("PO0763");
            PORQN1detail5 = OpenView("PO0773");
            PORQN1detail6 = OpenView("PO0777");

            sMessage = sprintf("Compose the Views", "Company");
            //------------------------------------------------------------
            ComposePRViews();

            sMessage = sprintf("Reject the requisition");
            //---------------------------------------------------------------
            PORQN1header.Order = 1;
            PORQN1header.Order = 0;

            sMessage = sprintf("Requisition Sequence Number");
            PORQN1header.Fields("RQNHSEQ").PutWithoutVerification("0");            //Requisition Sequence Key

            sMessage = sprintf("Requisition Number");
            PORQN1header.Init();
            PORQN1header.Order = 1;
            PORQN1detail1.RecordClear();
            PORQN1detail2.Init();
            PORQN1header.Fields("RQNNUMBER").Value = reqNumber;                     //ReqNumber   
            PORQN1header.Fields("PROCESSCMD").PutWithoutVerification("1");         //Command

            PORQN1header.Process();
            PORQN1header.Read();

            sMessage = sprintf("Expiration Date");
            PORQN1header.Fields("EXPIRATION").Value = AccpacDateEX(new Date());        // Expiration Date
            //sMessage = sprintf("On Hold");
            //PORQN1header.Fields("ONHOLD").Value = "1";
            //sMessage = sprintf("Expired");
            //PORQN1header.Fields("EXPIRED").Value = "1";
            
            PORQN1header.Update();
            PORQN1header.Init();
            PORQN1header.Order = 0;

            PORQN1header.Fields("RQNHSEQ").PutWithoutVerification("0")            //Requisition Sequence Key

            PORQN1header.Init();
            PORQN1header.Order = 1
            PORQN1detail1.RecordClear();
            PORQN1detail2.Init();
        }
        catch (e) {
            sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                e.message,
                                e.number,
                                e.description,
                                sMessage);

            RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

            Response.Write(CRM.GetPage());
            Response.End();
        }
    }

function checkVendor(objHeader,arrDetail) {
    try {
        sMessage = sprintf("setting Variables", "Company");
        //setting all the variables
        var reqNumber = objHeader.reqNumber;
        var vendorNumber = objHeader.vendor;
        var count = objHeader.noOfItems;
        var line = 1000;
    
        sMessage = sprintf("Open views - check vendor", "Company");
        //-----------------------------------------------------------------

        PORQN1header = OpenView("PO0760");
        PORQN1detail1 = OpenView("PO0770");
        PORQN1detail2 = OpenView("PO0750");
        PORQN1detail3 = OpenView("PO0759");
        PORQN1detail4 = OpenView("PO0763");
        PORQN1detail5 = OpenView("PO0773");
        PORQN1detail6 = OpenView("PO0777");

        sMessage = sprintf("Compose the Views - req vendor", "Company");
        //------------------------------------------------------------
        ComposePRViews();

        sMessage = sprintf("Check the vendor on the PR");
        //---------------------------------------------------------------
        PORQN1header.Order = 1;
        PORQN1header.Order = 0;

        PORQN1header.Fields("RQNHSEQ").PutWithoutVerification("0");            //Requisition Sequence Key

        PORQN1header.Init();
        PORQN1header.Order = 1;
        PORQN1detail1.RecordClear();
        PORQN1detail2.Init();
        PORQN1header.Fields("RQNNUMBER").Value = reqNumber;                     //ReqNumber   
        PORQN1header.Fields("PROCESSCMD").PutWithoutVerification("1");         //Command

        PORQN1header.Fields("VDCODE").Value = vendorNumber;                     //Vendor
        PORQN1header.Fields("PROCESSCMD").PutWithoutVerification("1");         //Command

        PORQN1header.Process();
        PORQN1header.Read();
        PORQN1detail2.Init();
        
        PORQN1detail2.Browse("", 1);
        PORQN1detail2.Fetch();
        
        for(var c=0; c < count; c++){
            PORQN1detail1.Fields("RQNLREV").PutWithoutVerification (ObjToStr(line));        //Line Number
            PORQN1detail1.Read();
            PORQN1detail1.Fields("VDCODE").Value = vendorNumber;                    //Vendor
            PORQN1detail1.Fields("UNITCOST").Value = arrDetail[c].cost;
            PORQN1detail1.Update();
            line = line + 1000;
        }
        
        PORQN1header.Update();
        PORQN1header.Init();
        PORQN1header.Order = 0

        PORQN1header.Fields("RQNHSEQ").PutWithoutVerification ("0")            //Requisition Sequence Key

        PORQN1header.Init();
        PORQN1header.Order = 1
        PORQN1detail1.RecordClear();
        PORQN1detail2.Init();
    }
    catch (e) {
        sMessage = sprintf("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                e.message,
                                e.number,
                                e.description,
                                sMessage);

        RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                sprintf(CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

        Response.Write(CRM.GetPage());
        Response.End();
    }
}

function buildPO(objHeader, arrDetail) {
try {
            checkVendor(objHeader, arrDetail);

            sMessage = sprintf("setting Variables", "Company");
            //setting all the variables
            var reqNumber = objHeader.reqNumber;
            var vendorNumber = objHeader.vendor;
            var description = objHeader.description;
            var reference = objHeader.reference;       
            var count = objHeader.noOfItems;
            var line = -1;
    
            //building the line item object
            sMessage = sprintf("Open views", "Company");
            POPOR1header = OpenView("PO0620");
            POPOR1detail1 = OpenView("PO0630");
            POPOR1detail2 = OpenView("PO0610");
            POPOR1detail3 = OpenView("PO0632");
            POPOR1detail4 = OpenView("PO0619");
            POPOR1detail5 = OpenView("PO0623");
            POPOR1detail6 = OpenView("PO0633");

            ComposePOViews();

            POPOR1header.Order = 1;
            POPOR1header.Order = 0;

            POPOR1header.Fields("PONUMBER").PutWithoutVerification("-1");

            sMessage = sprintf("Header 1", "Company");
            POPOR1header.Fields("PORHSEQ").PutWithoutVerification ("0");            //Purchase Order Sequence Key

            POPOR1header.Init();
            POPOR1header.Order = 1;
            POPOR1detail1.RecordClear();
            POPOR1detail3.Init();
            POPOR1detail2.Init();

            sMessage = sprintf("vendor number - " + vendorNumber, "Company");
            POPOR1header.Fields("VDCODE").Value = vendorNumber;                           // Vendor
            POPOR1header.Fields("PROCESSCMD").PutWithoutVerification ("1");         // Command
            POPOR1header.Process();

            sMessage = sprintf("has req data - " + vendorNumber, "Company");
            POPOR1header.Fields("HASRQNDATA").Value = "1"
            POPOR1detail3.RecordClear();
            POPOR1detail3.RecordCreate(0)

            sMessage = sprintf("req number - |"+reqNumber+"|", "Company");
            POPOR1detail3.Fields("RQNNUMBER").Value = ObjToStr(reqNumber);                 // Requisition Number
            POPOR1detail3.Insert();
            POPOR1detail3.Fields("PORRREV").PutWithoutVerification("-1")         // Line Number
            
            sMessage = sprintf("Function 9", "Company");
            POPOR1detail3.Read();
            POPOR1detail4.Fields("FUNCTION").Value = "9";                                      //Function
            POPOR1detail4.Process();

            sMessage = sprintf("detail 3", "Company");
            POPOR1detail3.Fields("PORRREV").PutWithoutVerification ("-1")          //Line Number

            POPOR1detail3.Read()
            POPOR1header.Fields("DESCRIPTIO").Value = description;          //Description
            POPOR1header.Fields("REFERENCE").Value = reference;             //Reference

            sMessage = sprintf("updating Lines", "Company");
            for (var c = 0; c < count; c++) {
                if (arrDetail[c].account != "") {
                    
                    sMessage = sprintf("Line number - |" + line + "|", "Company");
                    POPOR1detail1.Fields("PORLREV").PutWithoutVerification(ObjToStr(line));        //Line Number
                    POPOR1detail1.Read();
                    
                    sMessage = sprintf("Line Account (" + c + ") + (" + arrDetail[c].account + ") + (" + arrDetail[c].unit + ") - |" + line + "|", "Company");
                    POPOR1detail1.Fields("GLACEXPENS").Value = ObjToStr(arrDetail[c].account);                  //gl expense account
                    
                    sMessage = sprintf("Line Update");
                    POPOR1detail1.Update();
                }
                sMessage = sprintf("Line Increment");
                line = line - 1;
            }

            sMessage = sprintf("detail 4", "Company");
            POPOR1detail4.Fields("FUNCTION").PutWithoutVerification("8");           //Function
            POPOR1detail4.Process();
            POPOR1header.Insert();
            var PONUMBER = POPOR1header.Fields("PONUMBER").Value;
            var PORHSEQ = POPOR1header.Fields("PORHSEQ").Value;
            POPOR1header.Init();
            POPOR1header.Order = 0;

            POPOR1header.Fields("PORHSEQ").PutWithoutVerification("0")            //Purchase Order Sequence Key

            return [PONUMBER, PORHSEQ];

        }
        catch(e)
        {
            sMessage = sprintf ("<BR>Name='%s'<BR>Message='%s'<BR>Number=%s<BR>Description='%s'<BR>Operation='%s'",
                                e.name,
                                e.message,
                                e.number,
                                e.description,
                                sMessage);          

            RaiseError(CRM.GetTrans('Accpac_Messages', 'ERROR'),
                       sprintf (CRM.GetTrans('Accpac_Messages', 'ErrOpeningCompany'), "data", sMessage), '', '', true);

            Response.Write (CRM.GetPage());
            Response.End();
        }
}

</script>

<SCRIPT runat=server language=vbScript>
Function ComposePRViews()

    PORQN1header.Compose Array(PORQN1detail2, PORQN1detail1, PORQN1detail3, PORQN1detail4, PORQN1detail6)
    PORQN1detail1.Compose Array(PORQN1header, PORQN1detail2, PORQN1detail3, PORQN1detail5, PORQN1detail6)
    PORQN1detail2.Compose Array(PORQN1header, PORQN1detail1)
    PORQN1detail3.Compose Array(PORQN1header, PORQN1detail2, PORQN1detail1, PORQN1detail6)
    PORQN1detail4.Compose Array(PORQN1header)
    PORQN1detail5.Compose Array(PORQN1detail1)
    PORQN1detail6.Compose Array(PORQN1header, PORQN1detail3, PORQN1detail1)
    
End Function
Function ComposePOViews()
    POPOR1header.Compose Array(POPOR1detail2, POPOR1detail1, POPOR1detail3, POPOR1detail4, POPOR1detail5)
    POPOR1detail1.Compose Array(POPOR1header, POPOR1detail2, POPOR1detail4, Nothing, Nothing, POPOR1detail6)
    POPOR1detail2.Compose Array(POPOR1header, POPOR1detail1)
    POPOR1detail3.Compose Array(POPOR1header, POPOR1detail4)
    POPOR1detail4.Compose Array(POPOR1header, POPOR1detail2, POPOR1detail1, POPOR1detail3)
    POPOR1detail5.Compose Array(POPOR1header)
    POPOR1detail6.Compose Array(POPOR1detail1)
End Function    
</SCRIPT>
