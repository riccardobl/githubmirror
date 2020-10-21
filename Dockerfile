FROM ubuntu:latest

ENV BACKUP_ORG_NAME="jMonkeyEngine-mirrors"
ENV ACCESS_USER=""
ENV ACCESS_TOKEN=""
ENV WORK_DIR="/wdir"
ENV BASE_REPOLIST="/app/repolist.txt"
ENV GENERATED_REPOLIST="/wdir/gen-repolist.txt"
ENV TIME_BETWEEN_EXECUTIONS=3600
ENV TIME_BETWEEN_CLONES=10

RUN mkdir -p /app && mkdir -p $WORK_DIR
RUN apt-get update&&apt-get upgrade -y &&apt-get install wget curl git -y
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash &&  apt-get install  -y git-lfs &&git lfs install&&apt-get clean -y

RUN wget "https://github.com/cli/cli/releases/download/v1.1.0/gh_1.1.0_linux_amd64.tar.gz" -O /tmp/gh.tar.gz&& \
mkdir -p /tmp/ghext && \
tar -xzf /tmp/gh.tar.gz -C  /tmp/ghext && \
ls   /tmp/ghext  &&\
rm /tmp/ghext/gh_*/LICENSE  || true && \
cp -vf  /tmp/ghext/gh_*/bin/gh /usr/local/bin/gh &&\
rm -Rf /tmp/ghext &&\
ls  /usr/local/bin/gh && \
chmod +x  /usr/local/bin/gh &&\
 /usr/local/bin/gh --version

ADD mirror.sh /app/mirror.sh
ADD automirror.sh /app/automirror.sh
ADD repolist.txt /app/repolist.txt

RUN  useradd -d /wdir -u 1000 -r -M -U nonroot &&\
chown -Rf nonroot:nonroot /app 

USER nonroot
ENTRYPOINT [ "/app/automirror.sh" ]

WORKDIR /app