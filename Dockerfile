FROM ubuntu:trusty
MAINTAINER Takahiro Shizuki <shizu@futuregadget.com>

ENV HOST_HOME $HOME
ENV CLIENT_HOME /root


# set package repository mirror
RUN sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive/%g" /etc/apt/sources.list

# dependencies
RUN apt-get update -o Acquire::ForceIPv4=true
RUN apt-get install -y p7zip bzip2 cmake curl git man nkf ntp psmisc software-properties-common tmux unzip vim wget
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
RUN mkdir -p $CLIENT_HOME/ansible
RUN bash -c 'echo 127.0.0.1 ansible_connection=local > $CLIENT_HOME/ansible/localhost'



# Option, User Environment

# japanese packages
RUN wget -t 1 -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | apt-key add -
RUN wget -t 1 -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | apt-key add -
RUN wget -t 1 https://www.ubuntulinux.jp/sources.list.d/wily.list -O /etc/apt/sources.list.d/ubuntu-ja.list
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
RUN echo "ibus-daemon -drx" >> $CLIENT_HOME/.bashrc


# diff merge
WORKDIR $CLIENT_HOME/src
RUN wget -t 1 http://download-us.sourcegear.com/DiffMerge/4.2.0/diffmerge_4.2.0.697.stable_amd64.deb
RUN dpkg -i diffmerge_4.2.0.697.stable_amd64.deb


# Emacs24.5
#RUN apt-get -y install build-essential libgnutls28
#RUN apt-get -y build-dep emacs24
#RUN mkdir -p $CLIENT_HOME/src
#WORKDIR $CLIENT_HOME/src
#RUN wget -t 1 http://ftp.gnu.org/gnu/emacs/emacs-24.5.tar.gz
#RUN tar -xf emacs-24.5.tar.*
#WORKDIR $CLIENT_HOME/src/emacs-24.5
#RUN ./configure
#RUN sed -i.bak -e "s%CANNOT_DUMP=no%CANNOT_DUMP=yes%g" $CLIENT_HOME/src/emacs-24.5/src/Makefile
#RUN make && make install

# spacemacs
#RUN git clone --recursive https://github.com/syl20bnr/spacemacs $CLIENT_HOME/.emacs.d


# nvm and node.js
ENV NODE_VERSION v4.2.6
RUN git clone https://github.com/creationix/nvm.git $CLIENT_HOME/.nvm
RUN echo "if [[ -s $CLIENT_HOME/.nvm/nvm.sh ]] ; then source $CLIENT_HOME/.nvm/nvm.sh ; fi" >> $CLIENT_HOME/.bashrc
RUN bash -c 'source $CLIENT_HOME/.nvm/nvm.sh && nvm install $NODE_VERSION && nvm use $NODE_VERSION && nvm alias default $NODE_VERSION && ln -s $CLIENT_HOME/.nvm/versions/node/$NODE_VERSION/bin/node /usr/bin/node && ln -s $CLIENT_HOME/.nvm/versions/node/$NODE_VERSION/bin/npm /usr/bin/npm'

## install npm packages
RUN npm -g --ignore-scripts install spawn-sync
RUN npm -g --unsafe-perm install node-sass
RUN npm -g install less
RUN npm -g install stylus
RUN npm -g install eslint


# Set Env
ENV SHELL /bin/bash
RUN mkdir $CLIENT_HOME/.ssh
RUN chmod 600 $CLIENT_HOME/.ssh
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
#RUN apt-get -y install apache2 libapache2-mod-php5 php5-mysql mysql-server-5.6 mysql-client-5.6
#RUN apt-get clean

#RUN sed -i.bak -e "s%;date.timezone =%date.timezone = Tokyo/Asia%g" /etc/php5/apache2/php.ini
#RUN usermod -u 1000 www-data


# Install SBCL from the tarball binaries.
RUN wget -t 1 http://prdownloads.sourceforge.net/sbcl/sbcl-1.3.1-x86-64-linux-binary.tar.bz2	 -O $CLIENT_HOME/src/sbcl.tar.bz2 \
&&    mkdir $CLIENT_HOME/src/sbcl \
&&    tar jxvf $CLIENT_HOME/src/sbcl.tar.bz2 --strip-components=1 -C $CLIENT_HOME/src/sbcl/ \
&&    cd $CLIENT_HOME/src/sbcl \
&&    sh install.sh \
&&    rm -rf $CLIENT_HOME/src/sbcl/

WORKDIR $CLIENT_HOME/src/sbcl
RUN wget -t 1 http://beta.quicklisp.org/quicklisp.lisp
RUN bash -c 'echo "(defvar *dist-url* \"http://beta.quicklisp.org/dist/quicklisp/2015-12-18/distinfo.txt\")" > $CLIENT_HOME/src/sbcl/install.lisp'
RUN bash -c 'echo "(load \"quicklisp.lisp\")" >> $CLIENT_HOME/src/sbcl/install.lisp'
RUN bash -c 'echo "(quicklisp-quickstart:install :path \"$CLIENT_HOME/quicklisp/\" :dist-url *dist-url*)" >> $CLIENT_HOME/src/sbcl/install.lisp'
RUN bash -c 'echo "(with-open-file (out \"$CLIENT_HOME/.sbclrc\" :direction :output) (format out \"(load "$CLIENT_HOME/quicklisp\/setup.lisp")\"))" >> $CLIENT_HOME/src/sbcl/install.lisp'

RUN sbcl --non-interactive --load $CLIENT_HOME/src/sbcl/install.lisp


# options
# .bashrc
RUN bash -c 'echo alias ls=\"ls --color\" >> $CLIENT_HOME/.bashrc'


# docker run
WORKDIR $CLIENT_HOME
ENV DISPLAY 192.168.99.1:0
ADD ansible $CLIENT_HOME/ansible
CMD xfce4-terminal --tab --command "ansible-playbook ansible/playbook.yml"
