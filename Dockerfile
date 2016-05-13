FROM pritunl/archlinux:latest
MAINTAINER Takahiro Shizuki <shizu@futuregadget.com>

ENV HOST_HOME $HOME
ENV CLIENT_HOME /root


# set package repository mirror
RUN /bin/sh -c 'echo Server = http://ftp.tsukuba.wide.ad.jp/Linux/archlinux/\$repo/os/\$arch > /etc/pacman.d/mirrorlist'
RUN /bin/sh -c 'echo Server = http://ftp.jaist.ac.jp/pub/Linux/ArchLinux/\$repo/os/\$arch >> /etc/pacman.d/mirrorlist'

# yaourt
RUN /bin/sh -c 'echo [archlinuxfr] >> /etc/pacman.conf'
RUN /bin/sh -c 'echo SigLevel = Never >> /etc/pacman.conf'
RUN /bin/sh -c 'echo Server = http://repo.archlinux.fr/\$arch >> /etc/pacman.conf'
RUN /bin/sh -c 'echo SUDONOVERIF=1' >> /etc/yaourtr
RUN pacman --sync --refresh --noconfirm yaourt
RUN pacman -Sc && pacman-optimize

# fundamental
RUN pacman --noconfirm -Syu
RUN pacman --noconfirm -S p7zip bzip2 curl fakeroot git gvim man ntp openssh psmisc sudo tmux unzip wget

# development
RUN pacman --noconfirm -S gcc cmake make patch tig

# x window relations
RUN pacman --noconfirm -S xterm xfce4-terminal leafpad

# ansible2
WORKDIR $CLIENT_HOME
RUN pacman --noconfirm -S python2-pip python2-virtualenv python2-yaml libffi openssl
RUN pip2 install --upgrade setuptools
RUN pip2 install --upgrade pip
RUN pip2 install markupsafe  --user
RUN C_INCLUDE_PATH=/usr/lib64/libffi-3.2.1/include pip2 install ansible --user
RUN /bin/sh -c 'echo export PATH=\$PATH:$CLIENT_HOME/.local/bin' >> $CLIENT_HOME/.bashrc
RUN mkdir -p $CLIENT_HOME/ansible
RUN bash -c 'echo 127.0.0.1 ansible_connection=local > $CLIENT_HOME/ansible/localhost'

# nkf latest
WORKDIR /opt/src
RUN wget -t 1 http://jaist.dl.sourceforge.jp/nkf/59912/nkf-2.1.3.tar.gz
RUN tar zxvf nkf-2.1.3.tar.gz
WORKDIR /opt/src/nkf-2.1.3
RUN make
RUN make install

# group & user add
RUN groupadd shizuki
RUN useradd -m -g shizuki -G wheel -s /usr/sbin/bash shizuki
RUN /bin/sh -c 'echo shizuki   ALL=\(ALL\) ALL' > /etc/sudoers


# docker run
ENV DISPLAY 192.168.99.1:0
RUN /bin/sh -c 'echo export VISUAL="vim" >> $CLIENT_HOME/.bashrc'
RUN bash -c 'echo alias ls=\"ls --color\" >> $CLIENT_HOME/.bashrc'

ENV LANG ja_JP.UTF-8
RUN /bin/sh -c "echo ja_JP.UTF-8 UTF-8 > /etc/locale.gen"
RUN locale-gen
#RUN localectl set-locale LANG=ja_JP.UTF-8

WORKDIR /opt/src
ADD ansible /opt/src/ansible
RUN PATH=$PATH:$CLIENT_HOME/.local/bin ansible-playbook -v --extra-vars "taskname=ricty_diminished-font" ansible/playbook.yml
RUN fc-cache -rfv

ADD terminalrc $CLIENT_HOME/.config/xfce4/terminal/
WORKDIR $CLIENT_HOME
CMD xfce4-terminal