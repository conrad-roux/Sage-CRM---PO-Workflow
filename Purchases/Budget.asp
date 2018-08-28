<!-- #include file = "../AccpacCRmInt.js" -->
<!-- #include file = "../ACCPAC/Accpac_rw.js" -->
<!-- #include file = "../Accpac/Accpac.js" -->
<!-- #include file = "../serversidefuncts.js" -->
<!-- #include file = "../Accpac/datefuncs.js" -->
<!-- #include file = "../ACCPAC/utilityfuncs.js" -->

<%
/*
       Conrad
*/
%>

<SCRIPT runat="server" language="javascript">

    Server.ScriptTimeout = 600;  //seconds = 10 minutes
    var strTabGroup = "POREQDetail";
    strQSPrimaryKey = "PURE_PurchasesID";
    CRM.GetCustomEntityTopFrame("Purchases");

    var strRecordId = new String(Request.QueryString(strQSPrimaryKey));
    var arrTemp = new Array();
    arrTemp = strRecordId.split(",");
    strRecordId = arrTemp[arrTemp.length - 1];

    containerBlock = CRM.GetBlock('container');
    contentBlock = CRM.GetBlock('content');

    with (containerBlock) {
        DisplayButton(Button_Default) = false;
        AddButton(ButtonStatus("Continue", "Continue.Gif", CRM.URL(521)));
        AddBlock(contentBlock);
    }

    CRM.Mode = Edit;

    var accountMain = 0;
    var arrItems = getItems(strRecordId);
    var sCont = "";
    var valuesArray = new Array();
    var seqNumber = getDBValues("Purchases", "where pure_purchasesID = " + strRecordId, "pure_ReqSeqNumber");
    var itemAmounts = getItemAmount(seqNumber);

    if (arrItems.length > 1)
        for (var i = 0; i < arrItems.length; i++) {
        var o = new Object();
        o.ICITEM = ItemDetails(arrItems[i]);
        o.INVEN = InventoryAccount(o.ICITEM.CNTLACCT);
        o.AMOUNT = 0;

        if (i == 0) {
            o.AMOUNT = findItem(itemAmounts, arrItems[i]);
            valuesArray.push(o);
        }
        else {
            var check = inArray(valuesArray, o.INVEN.INVENT);
            var amt = findItem(itemAmounts, arrItems[i]);

            if (check == "NOTexists") {
                o.AMOUNT = amt;
                valuesArray.push(o);
            }
            else
                valuesArray[check].AMOUNT = parseFloat(valuesArray[check].AMOUNT) + parseFloat(amt);
        }
    }
    else {
        var o = new Object();
        o.ICITEM = ItemDetails(arrItems[0]);
        o.INVEN = InventoryAccount(o.ICITEM.CNTLACCT);
        o.AMOUNT = findItem(itemAmounts, arrItems[0]);
        valuesArray.push(o);
    }

    //build first table
    try {
        for (var i = 0; i < valuesArray.length; i++) {
            Budgets = Budget(valuesArray[i].INVEN.INVENT);

            if (i == 0)
                sCont = GridStartTable() + CreateHeaderString();

            sCont += CreateDetailString(valuesArray[i].AMOUNT);
        }
    }
    catch (ex) {
        Response.Write(valuesArray[i].INVEN.INVENT + ",");
        Response.Write(ex.message + ", " + i);
    }
    sCont += GridEndTable();

    var outSLines = outstandingPO("-2");
    var cons = "";

    for (var i = 0; i < outSLines.length; i++) {
        if (i == 0)
            cons = GridStartTable() + CreateHeaderString2();

        cons += CreateDetailString2(outSLines[i]);
    }
    cons += GridEndTable();

    /*var conts = GridStartTable() + TR(
    GridData(ask.PORHSEQ, '', 'ROW2') +
    GridData(ask.SQOUTSTAND, '', 'ROW2') +
    GridData(ask.EXTENDED, '', 'ROW2') +
    GridData(ask.ITEMNO, '', 'ROW2')
    ) + GridEndTable();*/

    contentBlock.Contents = BuildTable("Budget Transaction", sCont) + "<BR/>" + BuildTable("Outstanding PO Transactions", cons);
    CRM.AddContent(containerBlock.Execute());
    CRM.GetCustomEntityTopFrame("Purchases");
    Response.Write(CRM.GetPage(strTabGroup));

    /*  ************************************************************************************** */
    /*                                  Functions                                              */
    /*  ************************************************************************************** */
    function CreateHeaderString() {
        return TR(
              GridHeader(Budgets.DACCTID) +
              GridHeader(Budgets.DAMT2) +
              GridHeader("Requsition Amount for account") +
              GridHeader("Net Amount After Approval")
             );
    }

    function CreateHeaderString2() {
        return TR(
              GridHeader("Purchase Order Number") +
              GridHeader("Purchase Order Sequence Key") +
              GridHeader("Quantity Outstanding") +
              GridHeader("Amount") +
              GridHeader("Item Number")
             );
    }

    function CreateDetailString(amt) {
        try {
            return TR(
                  GridData(Server.HTMLEncode(Budgets.ACCTID), '', 'ROW2') +
                  GridData(Server.HTMLEncode(Budgets.AMT2), '', 'ROW2') +
                  GridData(Server.HTMLEncode(amt), '', 'ROW2') +
                  GridData(Server.HTMLEncode(Budgets.AMT2 - amt), '', 'ROW2')
                 );
        }
        catch (e) {
            ViewCallFailed(e, 'Creating Detail Rows', 'Rows');
        }
    }

    function CreateDetailString2(obj) {
        try {
            return TR(
                  GridData(Server.HTMLEncode(obj.PONUMBER), '', 'ROW2') +
                  GridData(Server.HTMLEncode(obj.PORHSEQ), '', 'ROW2') +
                  GridData(Server.HTMLEncode(obj.SQOUTSTAND), '', 'ROW2') +
                  GridData(Server.HTMLEncode(obj.EXTENDED), '', 'ROW2') +
                  GridData(Server.HTMLEncode(obj.ITEMNO), '', 'ROW2')
                 );

            //oo.PORHSEQ = trim(POLINES.Fields('PORHSEQ').Value);
            //oo.SQOUTSTAND = trim(POLINES.Fields('SQOUTSTAND').Value);
            //oo.EXTENDED = trim(POLINES.Fields('EXTENDED').Value);
            //oo.ITEMNO = trim(POLINES.Fields('ITEMNO').Value);
        }
        catch (e) {
            ViewCallFailed(e, 'Creating Detail Rows', 'Rows');
        }
    }

    function ItemDetails(sItem) {
        if (trim(sItem) == '')
            return '';

        if (typeof (ICITEMx) == 'undefined') {
            ICITEMx = OpenView('IC0310');
        }

        try {

            ICITEMx.Fields('ITEMNO').PutWithoutVerification(ObjToStr(sItem));
        }
        catch (e) {
            ViewCallFailed(e, 'ICITEM', 'PutWithoutVerification');
        }

        try {
            ICITEMx.Read();
        }
        catch (e) {
            ViewCallFailed(e, 'ICITEM', 'Read');
        }

        var oo = new Object();
        oo.DITEMNO = trim(ICITEMx.Fields('ITEMNO').Description);
        oo.DCNTLACCT = trim(ICITEMx.Fields('CNTLACCT').Description);
        oo.DDESC = trim(ICITEMx.Fields('DESC').Description);

        oo.ITEMNO = trim(ICITEMx.Fields('ITEMNO').Value);
        oo.CNTLACCT = trim(ICITEMx.Fields('CNTLACCT').Value);
        oo.DESC = trim(ICITEMx.Fields('DESC').Value);

        ICITEMx.RecordClear();
        return oo;  
    }

    function InventoryAccount(sItem) {
        if (trim(sItem) == '')
            return '';

        if (typeof (ACCSET) == 'undefined') {
            ACCSET = OpenView('IC0100');
        }

        try {
            ACCSET.Fields('CNTLACCT').PutWithoutVerification(ObjToStr(sItem));
        }
        catch (e) {
            ViewCallFailed(e, 'ACCSET', 'PutWithoutVerification');
        }

        try {
            ACCSET.Read();
        }
        catch (e) {
            ViewCallFailed(e, 'ACCSET', 'Read');
        }

        var oo = new Object();
        oo.DINVENT = trim(ACCSET.Fields('INVACCT').Description);
        oo.INVENT = trim(ACCSET.Fields('INVACCT').Value);

        ACCSET.RecordClear();
        return oo;
    }

    function Budget(sItem) {
        if (trim(sItem) == '')
            return '';

        var segment = getSegment(strQSPrimaryKey);
        sItem = sItem + segment;

        if (typeof (GLBUDG) == 'undefined') {
            GLBUDG = OpenView('GL0003');
        }

        try {
            GLBUDG.Fields('ACCTID').PutWithoutVerification(ObjToStr(sItem));
        }
        catch (e) {
            ViewCallFailed(e, 'GLACC', 'PutWithoutVerification');
        }

        try {
            GLBUDG.Read();
        }
        catch (e) {
            ViewCallFailed(e, 'GLACC', 'Read');
        }
        var year = new Date().getFullYear();

        var month = new Date().getMonth() + 1;
        var netfields = "NETPERD" + month;
        var oo = new Object();
        var found = false;

        while (GLBUDG.Fetch() != false) {
            if (trim(GLBUDG.Fields('ACCTID').Value) == ObjToStr(sItem)) {
                if (trim(GLBUDG.Fields('FSCSYR').Value) == year) {

                    oo.DACCTID = trim(GLBUDG.Fields('ACCTID').Description);
                    oo.DAMT2 = trim(GLBUDG.Fields(netfields).Description);

                    oo.ACCTID = trim(GLBUDG.Fields('ACCTID').Value);
                    oo.AMT2 = trim(GLBUDG.Fields(netfields).Value);

                    found = true;
                }
            }
        }
        if (!found) {
            oo.DACCTID = trim(GLBUDG.Fields('ACCTID').Description);
            oo.DAMT2 = trim(GLBUDG.Fields(netfields).Description);

            oo.ACCTID = sItem;
            oo.AMT2 = 0;
        }

        GLBUDG.RecordClear();
        return oo;
    }

    function getItemAmount(sItem) {
        if (trim(sItem) == '')
            return '';

        if (typeof (REQDETAIL) == 'undefined') {
            REQDETAIL = OpenView('PO0770');
        }
        try {
            REQDETAIL.Fields('RQNHSEQ').PutWithoutVerification(ObjToStr(sItem));
        }
        catch (e) {
            ViewCallFailed(e, 'REQDETAIL', 'PutWithoutVerification - ' + sItem);
        }

        try {
            REQDETAIL.Read();
        }
        catch (e) {
            ViewCallFailed(e, 'REQDETAIL', 'Read');
        }

        var items = new Array();
        while (REQDETAIL.Fetch() != false) {
            if (trim(REQDETAIL.Fields('RQNHSEQ').Value) > (sItem + 1))
                break;
            if (trim(REQDETAIL.Fields('RQNHSEQ').Value) == sItem) {
                var o = new Object();
                o.ItemNo = trim(REQDETAIL.Fields('ITEMNO').Value);
                o.Amount = trim(REQDETAIL.Fields('EXTENDED').Value);
                items.push(o);
            }
        }
        REQDETAIL.RecordClear();
        return items;
    }

    function outstandingPO(sItem) {
        if (trim(sItem) == '')
            return '';

        if (typeof (POLINES) == 'undefined') {
            POLINES = OpenView('PO0630');
        }
        try {
            POLINES.Fields('PORHSEQ').PutWithoutVerification(sItem);
        }
        catch (e) {
            ViewCallFailed(e, 'POLINES', 'PutWithoutVerification - ' + sItem);
        }
        try {
            POLINES.Read();
        }
        catch (e) {
            ViewCallFailed(e, 'POLINES', 'Read');
        }

        var count = 0;
        var ar = new Array();

        while (POLINES.Fetch() != false) {
            if (parseFloat(trim(POLINES.Fields('OQOUTSTAND').Value)) > 0)
                for (var i = 0; i < arrItems.length; i++) {
                if (trim(POLINES.Fields('ITEMNO').Value) == arrItems[i]) {
                    count = count + 1;
                    var oo = new Object();
                    oo.PORHSEQ = trim(POLINES.Fields('PORHSEQ').Value);
                    oo.SQOUTSTAND = trim(POLINES.Fields('SQOUTSTAND').Value);
                    oo.EXTENDED = trim(POLINES.Fields('EXTENDED').Value);
                    oo.ITEMNO = trim(POLINES.Fields('ITEMNO').Value);
                    oo.PONUMBER = "";
                    ar.push(oo);
                    break;
                }
            }
        }
        //Response.Write(count);
        getPONumber(ar);
        POLINES.RecordClear();
        return ar;
    }

    function getPONumber(arr) {
        if (typeof (PONUM) == 'undefined') {
            PONUM = OpenView('PO0620');
        }
        try {
            PONUM.Fields('PORHSEQ').PutWithoutVerification("-2");
        }
        catch (e) {
            ViewCallFailed(e, 'PONUM', 'PutWithoutVerification - ' + sItem);
        }
        try {
            PONUM.Read();
        }
        catch (e) {
            ViewCallFailed(e, 'PONUM', 'Read');
        }
        while (PONUM.Fetch() != false) {
            for (var i = 0; i < arr.length; i++) {
                if (arr[i].PORHSEQ == trim(PONUM.Fields('PORHSEQ').Value)) {
                    arr[i].PONUMBER = trim(PONUM.Fields('PONUMBER').Value);
                    break;
                }
            }
        }

        var match = arr;
        for (var i = 0; i < arr.length; i++) {
            if (arr[i].PONUMBER == "")
                for (var ii = 0; ii < match.length; ii++) {
                if (match[ii].PORHSEQ == arr[i].PORHSEQ) {
                    if (match[ii].PONUMBER != "") {
                        arr[i].PONUMBER = match[ii].PONUMBER;
                        break;
                    }
                }
            }
        }
    }
    Server.ScriptTimeout = ScriptTimeout;
</SCRIPT>