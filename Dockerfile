ARG IMAGE=intersystemsdc/irishealth-community
FROM $IMAGE as builder

WORKDIR /home/irisowner/dev

COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} . ./

USER root
ENV IRISUSERNAME "_SYSTEM"
ENV IRISPASSWORD "IRIS"
ENV PYTHON_PATH=/usr/bin/python3
ENV PATH "/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"

RUN pip install -r requirements1.txt  \
    && chmod 777 /home/irisowner/dev/image
RUN pip install git+https://github.com/openai/CLIP.git  

USER ${ISC_PACKAGE_MGRUSER}
RUN iris start IRIS  \
    && iris session IRIS < iris.script \
    && iris stop IRIS quietly



