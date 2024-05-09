# iris-image-vector-search
Using IRIS vector search to achieve image retrieval
## Describe 
The image vector retrieval demo uses IRIS Embedded Python and OpenAI's CLIP model to convert images into 512 dimensional vector data. Through the new feature of Vector Search, VECTOR-COSINE is used to calculate similarity and display high similarity images.
## Application direction of image retrieval  
- Image retrieval systems can be used to search for medical image data related to their research topic, for data analysis, pattern recognition, and research, accelerating the process of scientific research.
- The images in the medical imaging database can be used for the education and training of medical students. Through image retrieval, students can search and compare different types of cases, deepening their understanding of disease characteristics and diagnostic methods.
- Image retrieval can be used to assist doctors in diagnosis. By comparing medical imaging data of patients (such as X-rays, CT scans, MRI, etc.) and providing reference images of similar cases through a knowledge base, doctors can quickly obtain relevant information and improve diagnostic accuracy.

## 用法

### Prerequisites
Make sure you have git and Docker desktop installed.
### Installation
#### 1.Clone/git pull the repo into any local directory
```
git clone ***
```  
#### Open the terminal in this directory and run

```
docker-compose build
```
#### Run the IRIS container 

```
docker-compose up -d
```
   
#### 启动dist包
1111

#### Visit the address below
```
http://localhost:8080/
```