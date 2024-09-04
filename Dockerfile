FROM ubuntu

RUN apt update
RUN apt -y upgrade
RUN apt -y install wget perl gcc make

CMD ["bash"]

EXPOSE 80
EXPOSE 443

LABEL image.author = "Aida Guerrero"
