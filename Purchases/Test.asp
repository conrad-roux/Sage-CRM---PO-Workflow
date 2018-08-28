<!-- #include file ="..\crmwizard.js" -->
<!-- #include file ="..\crmconst.js" -->

<%   

var objContainer = CRM.GetBlock("container");
objContainer.DisplayButton(Button_Default) = false;
var objEntryScreen = CRM.GetBlock("TestScreen");
objEntryScreen.Title = "TestScreen";
objEntryScreen.DisplayForm = false;
objContainer.AddBlock(objEntryScreen);

CRM.Mode = Edit;
CRM.AddContent(objContainer.Execute());
        CRM.AddContent(
              "<" + "script>" +
              "XmlHttp = null; "+
              "function CallAspPage(aspPath) {" +
              "    var strQS = location.href.split(/\\?/)[1]; " +
              "    var strAddr;" +
              "    if (window.location.toString().toLowerCase().search('eware.dll')==-1) {" +
              "        strAddr = window.location.toString().split('CustomPages')[0];" +
              "    } else {" +
              "        strAddr = window.location.toString().split('eware.dll')[0];" +
              "    }" +
              "    var strURL = strAddr + aspPath + '&' + strQS; " +
              "    if (window.XMLHttpRequest) {" +
              "        XmlHttp = new XMLHttpRequest();" +
              "    } else {" +
              "        XmlHttp = new ActiveXObject('Microsoft.XMLHTTP');" +
              "    }" +
              "    alert(1);" +
              "    XmlHttp.open('GET',strURL,true); " +
              "    XmlHttp.setRequestHeader('Content-Type', 'text/xml'); " +
              "    XmlHttp.onreadystatechange = OnStateChange;" +
              "    XmlHttp.send(null); " +
              "}" +
              "function OnStateChange() {" +
              "if(XmlHttp.readyState == 0 || XmlHttp.readyState == 4){" +
              "var res = (XmlHttp.status == 0 || (XmlHttp.status >= 200 && XmlHttp.status < 300) || XmlHttp.status == 304 || XmlHttp.status == 1233);" +
              "alert (res);" +
              "alert(XmlHttp.responseText);" +
              "}" +
              "}" +
              "</s" + "cript>"
              );
        CRM.AddContent(
              "<" + "script>" +
              "function doMessage(itemNo) {" +
              "var res = CallAspPage('CustomPages/Purchases/server.asp?Item='+itemNo+'&ItemLocation=1');" +
              "}" +
              "</s" + "cript>"
              );
Response.Write(CRM.GetPage("Opportunity"));

%>