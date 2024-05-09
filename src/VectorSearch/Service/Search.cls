/// Vector retrieval service class
Class VectorSearch.Service.Search
{

ClassMethod Send(Method As %String, pRequest As %String, Output pResponse As Ens.StringResponse) As %Status
{

	if Method="Import"{
		Set tSC=..Import(pRequest,.pResponse)
	}elseif Method="SearchImage"{
		Set tSC=..SearchImage(pRequest,.pResponse)
	}
	Quit $$$OK
}

/// Image import, convert the image into 512 dimensional data using the OPENAI CLIP model, 
/// and store it in a vector database
ClassMethod Import(pRequest As %String, Output pResponse As Ens.StringResponse) As %Status
{
	Set Result = ##class(VectorSearch.Util.ResponseTool).%New()
	Set pResponse=##class(Ens.StringResponse).%New()
	try{
		
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest)
		Set Path ="/home/irisowner/dev/image/"
		Set image =json.imageName
		Set base64 =json.imageBase64
		Set time =$TRanslate($ZDT($NOW(),3,,4),"-, ,:,.")
		Set imagePath =Path_time_"_"_image
		Set ^Log($ZDT($NOW(),3,,6))="base64 :"_base64
		
		// Convert BASE64 to an image and store it in a table
		Set tsc= ..Base64ToImage(base64,imagePath)
	    if 'tsc{
			Set str=Result.Response("F",,tsc)
			Set pResponse.StringValue = $REPLACE(str,"\u0000","")
			Quit
		}
		// Convert images into 512 dimensional vector data through CLIP
		Set Vector = ..LoadClip(imagePath)
		
		// Insert images and vectors into the library
		&SQL(Insert into VectorSearch_DB.ImageDB (Image, ImageVector, Name)
			values(:base64,TO_VECTOR(:Vector,double),:image)
		)
		
		Set data ={}
		Set data.id = %ROWID
				
		Set str=Result.Response("T",data,"SUCCESS")


	}Catch(e)
	{
		Set ErrorMsg=$SYSTEM.Status.GetErrorText(e.DisplayString())	
		Set str=Result.Response("F",,ErrorMsg)
	}
	Set pResponse.StringValue = $REPLACE(str,"\u0000","")
	Quit $$$OK
}

/// Image vector retrieval, using IRIS vector retrieval function to retrieve images
ClassMethod SearchImage(pRequest As %String, Output pResponse As Ens.StringResponse) As %Status
{
	Set Result = ##class(VectorSearch.Util.ResponseTool).%New()
	Set pResponse=##class(Ens.StringResponse).%New()
	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest)
		Set tStatment = ##class(%SQL.Statement).%New()
		Set arr =[],object ={}
		Set id = json.id  // Registration return ID
		Set size = json.size  
		Set page = json.page 
		Set count = json.count // Total number of queries
		Set total =0
		if $L(count)=0 Set count =1

		Set sql ="select top ? count(1) as total , id as vid,Image,VECTOR_COSINE(TO_VECTOR(ImageVector,double),"
				_"(select TO_VECTOR(ImageVector,double) from VectorSearch_DB.ImageDB where id= ? )) Similarity "
				_"from VectorSearch_DB.ImageDB order by Similarity desc"
		
		if ($L(size) '=0 && $L(page)'=0 && size '=0 && page '=0)
		{
			Set PageTop = size*(page-1)+ 1
			Set PageButtom = size * page
			Set sql = "SELECT %VID AS ContentID ,* FROM ( "_sql_") WHERE %VID BETWEEN "_PageTop_" and "_PageButtom
		}
		Set ^Log($ZDT($NOW(),3,,6))="Query SQL :"_sql
		Set tSC = tStatment.%Prepare(sql)
		Set tResult = tStatment.%Execute(count,id)				
		while tResult.%Next(){
			Set data = {}
			Set data.id =tResult.%Get("vid")
			Set data.image =tResult.%Get("Image")
			Set data.similarity =tResult.%Get("Similarity")
			Set total =tResult.%Get("total")
			d arr.%Push(data)
		}
		Set object.data =arr
		Set object.total =total
				
		Set str=Result.Response("T",object,"SUCCESS")


	}Catch(e)
	{
		Set ErrorMsg=$SYSTEM.Status.GetErrorText(e.DisplayString())	
		Set str=Result.Response("F",,ErrorMsg)
	}
	Set pResponse.StringValue = $REPLACE(str,"\u0000","")
	Quit $$$OK
}

/// Tool , image to BASE64 conversion
ClassMethod ImageToBase64(ImagePath) [ Language = python ]
{
import base64
with open(ImagePath, "rb") as img_file:
	# Read binary data from image files
	img_binary = img_file.read()
	# Encode binary data into Base64 strings
	base64_string = base64.b64encode(img_binary).decode('utf-8')
return base64_string
}

/// Tool, BASE6 to image conversion
ClassMethod Base64ToImage(base64string, OutputPath) [ Language = python ]
{
import base64
try:
    # Decoding Base64 strings into binary data
    binary_data = base64.b64decode(base64string)
    # Write binary data to a file
    with open(OutputPath, 'wb') as file:
         file.write(binary_data)
    return True
except Exception as e:
     print("Saving image failed:", str(e))
     return False
}

/// Tool, OPENAI CLIP model vectorizing images
ClassMethod LoadClip(imagePath) [ Language = python ]
{
import torch
import clip
from PIL import Image

device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load("ViT-B/32", device=device)

image = preprocess(Image.open(imagePath)).unsqueeze(0).to(device)

with torch.no_grad():
    image_features = model.encode_image(image)
return str(image_features[0].tolist())
}

}

