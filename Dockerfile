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
RUN pacman --noconfirm -S p7zip bzip2 curl fakeroot git gvim man net-tools ntp openssh psmisc sudo tmux unzip wget cifs-utils

# development
RUN pacman --noconfirm -Syu
RUN pacman --noconfirm -S gcc cmake make patch tig ruby

# x window relations
RUN pacman --noconfirm -S xterm xfce4-terminal

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


# youtube-dl
RUN curl -s -L https://yt-dl.org/downloads/2016.03.18/youtube-dl -o /usr/local/bin/youtube-dl
RUN chmod a+rx /usr/local/bin/youtube-dl


# dropbox
WORKDIR /usr/bin
RUN wget -t 1 https://raw.github.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh
RUN chmod +x dropbox_uploader.sh


# environment
RUN umask 002

# group & user add
RUN /bin/sh -c 'echo root   ALL=\(ALL\) ALL' > /etc/sudoers
RUN groupadd shizuki
RUN useradd -m -g shizuki -G wheel -s /usr/sbin/bash shizuki
RUN /bin/sh -c 'echo shizuki   ALL=\(ALL\) ALL' >> /etc/sudoers


# docker run
ENV DISPLAY 192.168.1.1:0
RUN /bin/sh -c 'echo export VISUAL="vim" >> $CLIENT_HOME/.bashrc'
RUN bash -c 'echo alias ls=\"ls --color\" >> $CLIENT_HOME/.bashrc'

ENV LANG ja_JP.UTF-8
RUN /bin/sh -c "echo ja_JP.UTF-8 UTF-8 > /etc/locale.gen"
RUN locale-gen
#RUN localectl set-locale LANG=ja_JP.UTF-8

# fonts
RUN mkdir -p /usr/share/fonts
WORKDIR /usr/share/fonts
RUN wget -t 1 --no-check-certificate https://github.com/mzyy94/RictyDiminished-for-Powerline/archive/3.2.4-powerline-early-2016.zip -O ricty_diminished.zip
RUN /bin/sh -c 'unzip -jo ricty_diminished.zip'
RUN fc-cache -rfv


# heroku
RUN pacman --noconfirm -S ruby
RUN wget -qO- https://toolbelt.heroku.com/install.sh | sh
RUN /bin/bash -c 'echo export PATH="/usr/local/heroku/bin:$PATH" >> ~/.bashrc'



# ssh
WORKDIR /root
RUN bash -c "mkdir .ssh && chmod 700 .ssh"
RUN bash -c "cd .ssh/ && touch authorized_keys && chmod 600 authorized_keys"
RUN bash -c "cd .ssh/ && touch config && chmod 600 config"


# cifs
RUN mkdir -p /mnt/host/Downloads


#WORKDIR /opt/src
ADD ansible /root
#RUN PATH=$PATH:$CLIENT_HOME/.local/bin ansible-playbook -v --extra-vars "taskname=samba" ansible/playbook.yml

ADD terminalrc $CLIENT_HOME/.config/xfce4/terminal/
WORKDIR $CLIENT_HOME
COPY run_ansible.sh /root/ansible
#CMD bash

CMD xfce4-terminal --tab --command "bash -c 'echo $HOST_IP HOST_IP >> /etc/hosts'" --tab --command "bash -c 'echo \"//$HOST_IP/Downloads /mnt/host/Downloads cifs rw,cache=strict,vers=1.0,sec=ntlmssp,username=shizuki,domain=SHIZUKI-MBP-WIN,uid=0,noforceuid,gid=0,noforcegid,addr=$HOST_IP,file_mode=0755,dir_mode=0755,iocharset=utf8,nounix,serverino,mapposix,rsize=61440,wsize=65536,actimeo=1 0 0\" >> /etc/fstab'"

#CMD xfce4-terminal --tab --command run_ansible.sh
#CMD xfce4-terminal --tab --command "bash -c 'echo \"TODO: dropbox_uploader.sh && cd /opt/src/ && ansible-playbook -v --extra-vars "taskname=copy_ssh" ansible/playbook.yml && ./run_ansible.sh\" && echo \"press any key.\" && read'"
