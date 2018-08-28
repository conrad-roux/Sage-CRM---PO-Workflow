<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->
<!-- #include file = "../serversidefuncts.js" -->

<%

CRM.AddContent('<script>');
CRM.AddContent(
	"function SelectSegment(segment,trans){" +
		"var stage=document.getElementById('pure_stage');" +
		"if(segment==null){" +
			"var o=0;" +
			"while(stage.options[o].text!=trans)o++;" + 
			"stage.selectedIndex=o;" +
		"}else{" +
			"stage.value=segment;" + 
		"}" +
		"document.EntryForm.submit();" +
	"}");
CRM.AddContent('</script>');

function h(str) {
	var allowedChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -_!"£$%^&*()/[]{}#,.@:;';
	var escapeChars = '\\\n\t\O\r\v\'';
	var escapeCodes = ['\\\\','\\n','\\t','\\O','\\r', '\\v', '\\\''];
	var result = '', ch;
	for(var i = 0; i < str.length; i++) {
		ch = str.charAt(i);
		if (allowedChars.indexOf(ch)==-1) {
			var code=escapeChars.indexOf(ch);
			if (code != -1) result += escapeCodes[code];
			else result += '\\u'+('000' + str.charCodeAt(i).toString(16)).slice(-4);
		} else result += ch;
	}
	return result;
}

if(CRM.Mode == View)
CRM.Mode = Edit;

var strBlockName = "PurchasesGrid";
var strTabName = "POREQDetail";
var strNewURL = "Purchases/PurchasesEdit.asp";
var strFilterBox = "PurchasesFilterBox";
var strFilterButton = CRM.Button("filter", "filter.gif", "javascript:document.EntryForm.submit();");
var newButton = CRM.Button("New","New.Gif",CRM.URL(strNewURL));
var userRecord = CRM.GetContextInfo("user","user_userid");
var argWhere = "(pure_userid = " + userRecord + " or pure_createdby = " + userRecord + " or pure_PendingApprove = "+userRecord+") and pure_Deleted is null";

var objList = CRM.GetBlock(strBlockName);
objList.PadBottom = false;
var filterBox = CRM.GetBlock(strFilterBox);
filterBox.NewLine = false;
var lp = 0;
var prevStatus = "";
var prevStage = "";

var strArg = argWhere;
var myE = new Enumerator(filterBox);
while (!myE.atEnd()) {
    myEntryBlock = myE.item();
    if (String(Request.Form(myE.item())) != 'undefined') {
        if(String(Request.Form(myE.item())) == '#USER#'){
            strArg += " and " + myE.item() + " like '" + userRecord + "'";
        }
        else{
            if(myE.item() == "pure_stage"){
                var iit = String(Request.Form(myE.item()))
                iit = iit.split(",");
                if(iit[0] == "--All--" || iit[0] == "ALL") iit[0] = "%";
                strArg += " and " + myE.item() + " like '" + iit[0] + "'";
                prevStage = iit;
            }
            else if(myE.item() == "pure_status"){
                var iit = String(Request.Form(myE.item()))
                iit = iit.split(",");
                if(iit[0] == "--All--" || iit[0] == "ALL") iit[0] = "%";
                strArg += " and " + myE.item() + " like '" + iit[0] + "'";
                prevStatus = iit;
            }
            else
                strArg += " and " + myE.item() + " like '" + Request.Form(myE.item()) + "%'";
        }    
    }
    else if(lp == 0){strArg += " and pure_status = 'InProgress'";lp=1;};
    
    myEntryBlock.NewLine = true;
    myEntryBlock.AllowBlank = false;
    myE.moveNext();
}

/******************************************/

var Chart = CRM.GetBlock("pipeline");
Chart.PipelineStyle('ShowLegend','True');
var strSQL = "select Row_number() over(order by pure_stage) as Row, pure_stage, count(*) as t from purchases with (nolock) where " + strArg + " group by pure_stage order by pure_stage";

//Response.Write(strSQL);

var queryObj = CRM.CreateQueryObj(strSQL);
queryObj.SelectSQL();
var noneValue=CRM.GetTrans('GenCaptions', 'None');
var segment=0;
var chosenSegment=-1;
var clickSegment;
var filterStage = Request.Form('pure_stage');
var strStage;

while(!queryObj.eof)
{
	if(queryObj("t")!="0")
	{
		var stage = queryObj('pure_stage');
		//Response.Write(filterStage+"</br>");
		//Response.Write(stage==filterStage || (!Defined(stage) && filterStage==noneValue) + "</BR>");
		if (stage==filterStage || (!Defined(stage) && filterStage==noneValue)) chosenSegment = segment;
		if (stage) {
			strStage = CRM.GetTrans('pure_stage', stage);
			stage = "'" + h(stage) + "'";
		} else {
			strStage = h(noneValue)
			stage = "null, '" + strStage + "'";
		}
		clickSegment = (segment==chosenSegment) ? "''" : stage;
		Chart.AddPipeEntry(strStage,queryObj("t"),queryObj("t")+" "+strStage,"Javascript:SelectSegment(" + clickSegment + ")");
		segment++;
	}
	queryObj.Next();
}
Chart.Selected = chosenSegment;
//Response.Write(strSQL);
Chart.ChooseBackground(2);
/*****************************************/

/*****************************************/

var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );

List=CRM.GetBlock(strBlockName);
List.prevURL=sURL;

container = CRM.GetBlock('container');
container.AddBlock(List);

container.AddBlock(filterBox);
List.ArgObj=filterBox;

if ((Request.Form('HIDDENSCROLLMODE') != '2') && (Request.Form('HIDDENSCROLLMODE') != '3')) 
{
	container.Execute(); // This is the first execute which we drop.
}

/*****************************************/

var objContainer = CRM.GetBlock("container");

objContainer.AddBlock(Chart);
objContainer.AddBlock(objList);
objContainer.AddBlock(filterBox);
objContainer.DisplayButton(Button_Default) = false;

with (filterBox) 
{ 
NewLine = false; 
AddButton(strFilterButton);
ButtonLocation = Bottom; 
ButtonAlignment = Left; 
} 

//Response.Write(strArg);
objList.ArgObj = strArg;

if(checkRequesterList(CRM.GetContextInfo("User","user_userid")))
    filterBox.AddButton(newButton);

CRM.AddContent(objContainer.Execute());
Response.Write(CRM.GetPage(strTabName));

%>
