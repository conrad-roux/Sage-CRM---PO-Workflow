<%

function getDBValues(objectName, whereClause, fieldName)
{
    try{
        valuesQuery = CRM.CreateQueryObj("SELECT " + fieldName + " FROM " + objectName + " "+whereClause);
        valuesQuery.SelectSql();
        return valuesQuery.FieldValue(fieldName);
    }
    catch(ex){
        Response.Write(ex.message);
    }
}


function getCount(objectName, whereClause, fieldName)
{
    try{
        valuesQuery = CRM.CreateQueryObj("SELECT " + fieldName + " FROM " + objectName + " "+whereClause);
        valuesQuery.SelectSql();
        return valuesQuery.RecordCount;
    }
    catch(ex){
        Response.Write(ex.message);
    }
}

function getItems(reqNumber)
{
    valuesQuery = CRM.CreateQueryObj("SELECT * FROM POREQDETAIL WHERE PORD_PURCHASESID = "+reqNumber);
    valuesQuery.SelectSql();
    var str = "";
    
    var itemsNo = new Array();
    while(!valuesQuery.eof){
        itemsNo.push(valuesQuery.FieldValue("pord_itemno"));
        valuesQuery.NextRecord();
    }
    for(var i = 0; i < itemsNo.length; i++)
        str += itemsNo[i] + ",";
        
    str = str.substr(0,str.length-1);
    
    itemQuery = CRM.CreateQueryObj("SELECT * FROM vICITEM WHERE RowID in (" + str + ")");
    itemQuery.SelectSql();
    
    var items = new Array();
    while(!itemQuery.eof){
        items.push(itemQuery.FieldValue("FMTITEMNO"));
        itemQuery.NextRecord();
    }
    
    return items;     
}

function crmDate(date)
{
    var today = new Date(date);
    var dd = today.getDate();
    var mm = today.getMonth()+1;//January is 0!
    var yyyy = today.getFullYear();
    if(dd<10){dd='0'+dd}
    if(mm<10){mm='0'+mm}
    
    var hours = today.getHours();
    var minutes = today.getMinutes();
    var seconds = today.getSeconds();
    
    return formattedDate = yyyy+'-'+mm+'-'+dd+' '+hours+':'+minutes+':'+seconds;
}

function accpacDate(date)
{
    var today = new Date(date);
    var dd = today.getDate();
    var mm = today.getMonth()+1;//January is 0!
    var yyyy = today.getFullYear();
    if(dd<10){dd='0'+dd}
    if(mm<10){mm='0'+mm}
    
    return formattedDate = yyyy+''+mm+''+dd;
}

function createTrackingRecord(primaryRefKey, note, requester)
{
    var strEntity = "PurchasesProgress";
    var orgRecord = CRM.FindRecord("Purchases","pure_purchasesID = "+primaryRefKey);
    var objRecord = CRM.CreateRecord(strEntity);
    objRecord("pure_ProgressNote") = note;
    objRecord("pure_purchasesID") = primaryRefKey;
    objRecord("pure_userid") = orgRecord("pure_userid");
    objRecord.SaveChanges();
}

function findApprover(primaryRefKey, keyType, requester)
{
    var strEntity = "Purchases";
    var objRecord = CRM.FindRecord(strEntity, "pure_purchasesID = "+primaryRefKey);
    
    if(keyType == 1){
        //not been approved first yet
        var apprRecord = CRM.FindRecord("PurchaseAdmin", "pura_requester = "+objRecord("pure_userid"));
        //check if he is availble on status
        var status = CRM.FindRecord("users","user_userid = "+apprRecord("pura_Appprover"));
        return apprRecord("pura_Appprover");
    }
    else if(keyType == 2){
        var apprRecord = CRM.FindRecord("PurchaseAdmin", "pura_requester = "+requester);
        return apprRecord("pura_Appprover");
    }
}

function getLimits(primaryRefKey, keyType)
{
    var strEntity = "Purchases";
    var strSeEntity = "PurchaseAdmin";
    var obj = new Object();
    
    if(keyType == 1){
    var objRecord = CRM.FindRecord(strEntity, "pure_purchasesID = "+primaryRefKey);
    var approverRecord = CRM.FindRecord(strSeEntity,"pura_requester = "+objRecord("pure_userid"));
    
    obj.upper = approverRecord("pura_upperValue");
    obj.lower = approverRecord("pura_lowerValue");
    }
    else{
    var objRecord = CRM.FindRecord(strEntity, "pure_purchasesID = "+primaryRefKey);
    var approverRecord = CRM.FindRecord(strSeEntity,"pura_appprover = "+objRecord("pure_pendingApprove"));
    
    obj.upper = approverRecord("pura_upperValue");
    obj.lower = approverRecord("pura_lowerValue");
    }
    
    return obj;
}

function getSegment(primaryRefKey)
{
    var strEntity = "Purchases";
    var strSeEntity = "PurchaseAdmin";
    
    var objRecord = CRM.FindRecord(strEntity, "pure_purchasesID = "+primaryRefKey);
    var approverRecord = CRM.FindRecord(strSeEntity,"pura_requester = "+objRecord("pure_userid"));
    
    return approverRecord("pura_segment");
}

function inArray(pArray, val) {
    for (var i = 0; i < pArray.length; i++) {
        if (pArray[i].INVEN.INVENT == val) {
            return i;
        }
    }
    return "NOTexists";
}

function findItem(pArray, val)
{
    for(var i = 0; i < pArray.length; i++)
    {
        if(pArray[i].ItemNo == val)
           return pArray[i].Amount;
    }
    return 0;
}

function getUserName(userid)
{
    var objRecord = CRM.FindRecord("Users", "user_userid = "+userid);
    var name = "";
    
    if(Defined(objRecord("user_FirstName")))
        name = objRecord("user_FirstName");
    
    if(Defined(objRecord("user_LastName")))
        name = name + " " + objRecord("user_LastName");
    
    if(!Defined(name))
        name = "Userid Incorrect";
        
        return name;
}

function checkRequesterList(userid)
{
    var apprRecord = CRM.FindRecord("PurchaseAdmin", "pura_requester = "+userid);
    
    if(Defined(apprRecord("pura_requester")))
        return true;
    else
        return false;
}
%>