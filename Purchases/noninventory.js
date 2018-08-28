function setFieldParams() {
    try {
        if ($(check).is(':checked')) {
            $(fieldItemSPAN).closest("td").hide();
            $(fieldTextSPAN).closest("td").show();
            $(fieldAccSPAN).closest("td").show();
            $(fieldCostFIELD).attr("checked","checked");
        }
        else {
            $(fieldItemSPAN).closest("td").show();
            $(fieldTextSPAN).closest("td").hide();
            $(fieldAccSPAN).closest("td").hide();
            $(fieldCostFIELD).removeAttr("checked"); 
        }
    }
    catch (ex) { alert("error: "+ex.message); }
}
function setReadyParams() {
    try {
        if ($(hiddenCheck).val() == "Y") {
            $(fieldItemSPAN).closest("td").hide();
            $(fieldTextSPAN).closest("td").show();
            $(fieldAccSPAN).closest("td").show();
        }
        else {
            $(fieldItemSPAN).closest("td").show();
            $(fieldTextSPAN).closest("td").hide();
            $(fieldAccSPAN).closest("td").hide();
        }
    }
    catch (ex) { alert("error: " + ex.message); }
}
$(document).ready(
function setFields() {
    hiddenCheck = "input[name='_HIDDENpord_usenoninventory']";
    check = "#_IDpord_usenoninventory";
    fieldTextSPAN = "#_Datapord_noinvitem";
    fieldItemSPAN = "#_Datapord_itemno";
    fieldAccSPAN = "#_Datapord_glacc"
    fieldCostFIELD = "#_IDpord_copycosttopo";

    if ($(check).val() == "on")
        setFieldParams();
    else
        setReadyParams();
});