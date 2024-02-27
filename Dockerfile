FROM debian:bullseye
WORKDIR /distr
COPY ./distr .

# переменные среды для сборки образа
ENV DEBIAN_FRONTEND=noninteractive \
    LANG='ru_RU.UTF-8' LANGUAGE='ru_RU:en' LC_ALL='ru_RU.UTF-8'

# update apt-get
RUN echo "deb http://deb.debian.org/debian bullseye contrib non-free" > /etc/apt/sources.list.d/contrib.list; \
    apt-get update

# создаем пользователя для запуска vnc
RUN echo "Create Jenkins user"
RUN useradd -m -s /bin/bash -U jenkins
RUN echo 'jenkins:Zxxzcvvc234' | chpasswd
COPY config/passwd /home/jenkins/.vnc/passwd
RUN chown -R jenkins:jenkins /home/jenkins/.vnc
RUN chmod -R u=rwx /home/jenkins/.vnc
COPY test_start.sh /home/jenkins/onec_start.sh
RUN chown -R jenkins:jenkins /home/jenkins/onec_start.sh
RUN chmod -R u=rwx /home/jenkins/onec_start.sh


# устанавливаем пакеты для клиента 1С
RUN echo "Installing libraries for 1C"
RUN apt-get install -y ttf-mscorefonts-installer fontconfig \
        libfreetype6 \
        libgsf-1-common \
        unixodbc \
        glib2.0 \
        ca-certificates \
        locales \
        locales-all \
        libharfbuzz-icu0 \
        libenchant-2-2 \
        imagemagick; \
    fc-cache; \
    cp /usr/lib/x86_64-linux-gnu/libenchant-2.so.2 /usr/lib/x86_64-linux-gnu/libenchant.so.1

RUN echo ru_RU.UTF-8 UTF-8 >> /etc/locale.gen
RUN locale-gen; update-locale; echo LANG=ru_RU.UTF-8 > /etc/default/locale

# устанавливаем локаль для установки 1С с русским интерфейсом
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:en
ENV LC_ALL ru_RU.UTF-8

# Xfce UI -- устанавливаем оконный менеджер
RUN echo "Installing Xfce4 UI components"; \
    apt-get -qq install -y supervisor xfce4 xfce4-terminal; \
    apt-get -qq purge -y pm-utils xscreensaver*

# устанавливаем 1С
RUN echo "Installing 1C client"
RUN /distr/setup-full-8.3.24.1342-x86_64.run --mode unattended --enable-components client_full,client_thin
RUN rm -rf /distr
COPY config/conf.cfg /opt/1C/v8.3/x86_64/conf/

# устанавливаем пакеты организации работы jenkins
RUN echo "Installing components for Jenkins"
RUN apt-get install -y openssh-server
RUN apt-get install -y openjdk-17-jre
RUN apt-get install -y tightvncserver

# устанавливаем пакеты для отладки образа
RUN echo "Installing components for img debug"
RUN apt-get install -y aptitude mc nano iputils-ping

# настраиваем и стартуем ssh
RUN echo "Start sshd for Jenkins chanel"
RUN mkdir /var/run/sshd
RUN echo 'root:Zxxzcvvc234' | chpasswd
RUN echo 'PermitRootLogin yes' > /etc/ssh/sshd_config.d/permitroot.conf
EXPOSE 22
EXPOSE 5901
CMD ["/usr/sbin/sshd", "-D"]
