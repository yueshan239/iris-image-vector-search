Class VectorSearch.Rest.CommonRest Extends %CSP.REST
{

Parameter HandleCorsRequest = "true";

XData UrlMap [ XMLNamespace = "http://www.bjgoodwill.com/urlmap" ]
{
<Routes>
  <Route Url="/*" Method="OPTIONS" Call="GetStatus"/>
  <Route Url="/VectorSearch/:Method" Method="POST" Call="Search"/>
</Routes>
}

ClassMethod GetStatus(ser As %String) As %Status
{
     Quit $$$OK
}

/// Search
ClassMethod Search(Method As %String) As %Status
{
	kill ^Log
	Do %response.SetHeader("Content-Type", "application/json;charset=UTF-8")
	Try{
		Set content=""
		Set:$L(%request.Content)'=0 content=$zcvt(%request.Content.Read(),"I","UTF8")
		
		Set ^Log($ZDT($NOW(),3,,6))="Calling the Search interface :"_content
		Set tsc = ##class(VectorSearch.Service.Search).Send(Method,content,.out)
	   	set message=out.StringValue
	   	
	}Catch(e){
		Set ^Log($ZDT($NOW(),3,,6))="ERROR :"_e.DisplayString()
		Set message="{""code"":500,""data"":"""",""success"":0,""msg"":""Server Internal Error""}"
	}
    w $zcvt(message,"O","UTF8")
    Quit $$$OK
}

}

