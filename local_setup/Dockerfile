FROM centos:7

RUN yum install -y -q -e 0 wget unzip

WORKDIR /tmp

RUN wget -q https://releases.hashicorp.com/terraform/0.14.6/terraform_0.14.6_linux_amd64.zip

RUN unzip ./terraform_0.14.6_linux_amd64.zip

RUN mv terraform /usr/local/bin/terraform

RUN chmod a+x /usr/local/bin/terraform

RUN terraform --version
