<!-- #include file = "../AccpacCRmInt2.js" -->
<script language=jscript runat=server>

    var itemNo = Request.QueryString("Item");
    var location = Request.QueryString("ItemLocation")
    var cost = getItemAmount();

/*
    Response.ContentType = "text/xml";
    Response.Write("<?xml version='1.0' encoding='ISO-8859-1'?>");
    Response.Write("<info>");
    Response.Write("<Price>" + cost + "</Price>");
    Response.Write("</info>");
*/

    Response.Write(cost);

    function getItemAmount() {
    try{
        query = CRM.CreateQueryObj("select recentcost from vICILOC where itemno = '" + itemNo + "' and location = '" + location + "'");
        query.SelectSql();
        var unitD = CRM.FindRecord("Custom_edits", "ColP_ColName = 'pord_unitprice'");
        if (!Defined(unitD))
            unitD = 0.00;
        if (!query.eof) {
            if (parseFloat(query.FieldValue("recentcost")) > parseFloat(unitD))
                return query.FieldValue("recentcost");
            else
                return unitD("Colp_defaultValue");    
        }
        else
            return unitD("Colp_defaultValue");
        }
        catch(ex){return ex.message;}
    }
    
</script>