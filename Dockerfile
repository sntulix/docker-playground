FROM ubuntu:trusty
MAINTAINER Takahiro Shizuki <shizu@futuregadget.com>

ENV HOME /root
ENV DISPLAY 192.168.99.1:0


# set package repository mirror
RUN sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive/%g" /etc/apt/sources.list

# dependencies
RUN apt-get update -o Acquire::ForceIPv4=true
RUN apt-get install -y bzip2 curl git man nkf ntp psmisc software-properties-common tmux unzip vim wget
RUN apt-get clean

# git latest
RUN add-apt-repository -y ppa:git-core/ppa
RUN apt-get update -o Acquire::ForceIPv4=true
RUN apt-get install -y git tig


# x window relations
RUN apt-get -y install python-appindicator xterm xfce4-terminal leafpad vim-gtk
RUN apt-get clean


# ansible2
RUN apt-get -y install python-dev python-pip
RUN pip install ansible markupsafe



# Option, User Environment

# japanese packages
RUN wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | apt-key add -
RUN wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | apt-key add -
RUN wget https://www.ubuntulinux.jp/sources.list.d/wily.list -O /etc/apt/sources.list.d/ubuntu-ja.list
RUN apt-get update -o Acquire::ForceIPv4=true
RUN apt-get -y install language-pack-ja-base language-pack-ja fonts-ipafont-gothic dbus-x11
RUN apt-get -y install ibus-skk
RUN apt-get -y install skkdic skkdic-cdb skkdic-extra skksearch skktools
RUN update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja
RUN apt-get clean

ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
ENV LC_CTYPE ja_JP.UTF-8

ENV GTK_IM_MODULE ibus
ENV QT_IM_MODULE ibus
ENV XMODIFIERS @im=ibus
RUN echo "ibus-daemon -drx" >> /root/.bashrc


# diff merge
WORKDIR /root/src
RUN wget http://download-us.sourcegear.com/DiffMerge/4.2.0/diffmerge_4.2.0.697.stable_amd64.deb
RUN dpkg -i diffmerge_4.2.0.697.stable_amd64.deb


# Emacs24.5
#RUN apt-get -y install build-essential libgnutls28
#RUN apt-get -y build-dep emacs24
#RUN mkdir -p /root/src
#WORKDIR /root/src
#RUN wget http://ftp.gnu.org/gnu/emacs/emacs-24.5.tar.gz
#RUN tar -xf emacs-24.5.tar.*
#WORKDIR /root/src/emacs-24.5
#RUN ./configure
#RUN sed -i.bak -e "s%CANNOT_DUMP=no%CANNOT_DUMP=yes%g" /root/src/emacs-24.5/src/Makefile
#RUN make && make install

# spacemacs
#RUN git clone --recursive https://github.com/syl20bnr/spacemacs /root/.emacs.d


# nvm and node.js
ENV NODE_VERSION v4.2.6
RUN git clone https://github.com/creationix/nvm.git /root/.nvm
RUN echo "if [[ -s /root/.nvm/nvm.sh ]] ; then source /root/.nvm/nvm.sh ; fi" > /root/.bash_profile
RUN bash -c 'source /root/.nvm/nvm.sh && nvm install $NODE_VERSION && nvm use $NODE_VERSION && nvm alias default $NODE_VERSION && ln -s /root/.nvm/versions/node/$NODE_VERSION/bin/node /usr/bin/node && ln -s /root/.nvm/versions/node/$NODE_VERSION/bin/npm /usr/bin/npm'

## install npm packages
RUN npm -g --ignore-scripts install spawn-sync
RUN npm -g --unsafe-perm install node-sass
RUN npm -g install less
RUN npm -g install stylus
RUN npm -g install eslint

# Java8
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update -o Acquire::ForceIPv4=true


# android studio
WORKDIR /root/src
RUN wget https://dl.google.com/dl/android/studio/ide-zips/2.0.0.14/android-studio-ide-143.2609919-linux.zip
RUN unzip android-studio-ide-143.2609919-linux.zip -d /opt
RUN bash -c 'export PATH=$PATH:/opt/android-studio/bin'
RUN apt-get install -y lib32z1 lib32ncurses5 lib32bz2-1.0 lib32stdc++6 libc6-i386 lib32gcc1 # solution for "Unable to run mksdcard SDK tool."


# Set Env
ENV SHELL /bin/bash
RUN mkdir /root/.ssh
RUN chmod 600 /root/.ssh
ENV DISPLAY 192.168.99.1:0
ENV GIT_USER_NAME "Takahiro Shizuki"
ENV GIT_USER_EMAIL "shizu@futuregadget.com"

# git config
RUN git config --global push.default simple
RUN git config --global user.name $GIT_USER_NAME
RUN git config --global user.email $GIT_USER_EMAIL

# Set Timezone
RUN cp /usr/share/zoneinfo/Japan /etc/localtime

# OpenGL env
env LIBGL_ALWAYS_INDIRECT 1
#env DRI_PRIME 1


# web server
RUN apt-get -y install apache2 libapache2-mod-php5 php5-mysql mysql-server-5.6 mysql-client-5.6
RUN apt-get clean

RUN sed -i.bak -e "s%;date.timezone =%date.timezone = Tokyo/Asia%g" /etc/php5/apache2/php.ini
RUN usermod -u 1000 www-data


# create Java8 install script.
RUN bash -c "echo apt-get -y install oracle-java8-installer > /root/src/install-java8.sh"
RUN bash -c "echo apt-get -y install oracle-java8-set-default >> /root/src/install-java8.sh"
RUN chmod +x /root/src/install-java8.sh


# Install SBCL from the tarball binaries.
RUN wget http://prdownloads.sourceforge.net/sbcl/sbcl-1.3.1-x86-64-linux-binary.tar.bz2	 -O /root/src/sbcl.tar.bz2 \
&&    mkdir /root/src/sbcl \
&&    tar jxvf /root/src/sbcl.tar.bz2 --strip-components=1 -C /root/src/sbcl/ \
&&    cd /root/src/sbcl \
&&    sh install.sh \
&&    rm -rf /root/src/sbcl/

WORKDIR /root/src/sbcl
RUN wget http://beta.quicklisp.org/quicklisp.lisp
RUN bash -c 'echo "(defvar *dist-url* \"http://beta.quicklisp.org/dist/quicklisp/2015-12-18/distinfo.txt\")" > /root/src/sbcl/install.lisp'
RUN bash -c 'echo "(load \"quicklisp.lisp\")" >> /root/src/sbcl/install.lisp'
RUN bash -c 'echo "(quicklisp-quickstart:install :path \"/root/quicklisp/\" :dist-url *dist-url*)" >> /root/src/sbcl/install.lisp'
RUN bash -c 'echo "(with-open-file (out \"/root/.sbclrc\" :direction :output) (format out \"(load "/root/quicklisp\/setup.lisp")\"))" >> /root/src/sbcl/install.lisp'

RUN sbcl --non-interactive --load /root/src/sbcl/install.lisp


# option, visual studio code
RUN add-apt-repository ppa:ubuntu-desktop/ubuntu-make
RUN apt-get update
RUN apt-get -y install ubuntu-make
RUN apt-get -y install libgtk2.0-0 libgconf-2-4 libnss3 libasound-dev

# Install VSCode and Java8 & Init spacemacs
#RUN /usr/bin/xfce4-terminal --tab --command /root/src/install-java8.sh --tab --command emacs --tab --command "umake web visual-studio-code"
RUN /usr/bin/xfce4-terminal --tab --command /root/src/install-java8.sh --tab --command "umake web visual-studio-code"
RUN ln -s /root/.local/share/umake/bin/visual-studio-code /usr/bin/visual-studio-code

# youtube-dl
RUN curl https://yt-dl.org/downloads/2016.03.18/youtube-dl -o /usr/local/bin/youtube-dl
RUN chmod a+rx /usr/local/bin/youtube-dl


WORKDIR /root

# docker run usual
RUN bash -c 'echo docker run -it --rm -v ~/:/home/\$USER -p 80:80 local/playground xfce4-terminal' # for working.
