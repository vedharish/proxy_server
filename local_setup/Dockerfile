FROM centos:7

RUN yum install -y -q -e 0 wget unzip python3 python3-pip epel-release

RUN yum install -y -q -e 0 ansible

WORKDIR /tmp

RUN wget -q https://releases.hashicorp.com/terraform/0.14.6/terraform_0.14.6_linux_amd64.zip
RUN unzip ./terraform_0.14.6_linux_amd64.zip
RUN mv terraform /usr/local/bin/terraform
RUN chmod a+x /usr/local/bin/terraform

RUN python3 -m pip install awscli

RUN mkdir -p /etc/workdir
WORKDIR /etc/workdir

ADD files/entrypoint.sh /etc/workdir/entrypoint.sh
RUN chmod a+x /etc/workdir/entrypoint.sh

ENTRYPOINT [ "/etc/workdir/entrypoint.sh" ]

RUN yum install -y openssh-clients
