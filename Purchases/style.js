$(document).ready(function() {
    $("#stylespanID").closest("table").parents("table:first").attr("class", "ButtonGroup");
    $("table[align='LEFT'").find("td[width='20']").remove();
    $("table[align='LEFT'").closest("tr").clone().appendTo("table.ButtonGroup");
    $("table[align='LEFT'").first("table").find("td.Button").last().remove();
    $("table[align='LEFT'").last("table").find("td:first").remove();
    //$("td.Button").after("<table><tr id='somerandomrow'><td></td></tr></table>");
    //$("td").width(20).filter(":contains('&nbsp;')").remove();
    //$("#stylespanID").parents("table:first").parents("table").attr("class", "ButtonGroup");
});