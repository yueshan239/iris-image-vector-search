Class VectorSearch.DB.ImageDB Extends %Persistent
{

Property Name As %String(MAXLEN = 200);

Property Image As %String(MAXLEN = "");

Property ImageVector As %Library.Vector(DATATYPE = "double", LEN = 512);

Storage Default
{
<Data name="ImageDBDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Image</Value>
</Value>
<Value name="4">
<Value>ImageVector</Value>
</Value>
</Data>
<DataLocation>^VectorSearch.DB.ImageDBD</DataLocation>
<DefaultData>ImageDBDefaultData</DefaultData>
<IdLocation>^VectorSearch.DB.ImageDBD</IdLocation>
<IndexLocation>^VectorSearch.DB.ImageDBI</IndexLocation>
<StreamLocation>^VectorSearch.DB.ImageDBS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

