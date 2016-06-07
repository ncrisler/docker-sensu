FROM ubuntu:14.04
MAINTAINER zeagler

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install \
      curl \
      redis-server \
      wget \
      vim


RUN wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.2/rabbitmq-server_3.6.2-1_all.deb && \
    
    # Add Sensu repository
    wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | apt-key add - && \
    echo "deb http://repositories.sensuapp.org/apt sensu main" | tee /etc/apt/sources.list.d/sensu.list
    

    # Install Sensu and Erlang (RabbitMQ requirement)
RUN dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get --force-yes -y install \
      erlang-nox \
      sensu \
      socat \
      uchiwa && \
    
    # Install RabbitMQ
    dpkg -i rabbitmq-server_3.6.2-1_all.deb
   
# Set max connections on redis and rabbitmq
RUN sed -i "s/# ULIMIT=65536/ULIMIT=65536/" /etc/default/redis-server && \
    sed -i "s/#ulimit -n 1024/ulimit -n 65536/" /etc/default/rabbitmq-server

# Install enterprise edition dependencies
RUN apt-get install -y \
  acl at-spi2-core ca-certificates-java colord cpp cpp-4.8 dbus dbus-x11 \
  dconf-gsettings-backend dconf-service desktop-file-utils dosfstools \
  fontconfig fontconfig-config fonts-dejavu-core fonts-dejavu-extra fuse \
  gconf-service gconf-service-backend gconf2 gconf2-common gdisk groff-base \
  gvfs gvfs-common gvfs-daemons gvfs-libs hicolor-icon-theme java-common \
  libapparmor1 libasound2 libasound2-data libasyncns0 libatasmart4 \
  libatk-bridge2.0-0 libatk-wrapper-java libatk-wrapper-java-jni libatk1.0-0 \
  libatk1.0-data libatspi2.0-0 libavahi-client3 libavahi-common-data \
  libavahi-common3 libavahi-glib1 libbonobo2-0 libbonobo2-common \
  libcairo-gobject2 libcairo2 libcanberra0 libcloog-isl4 libcolord1 \
  libcolorhug1 libcups2 libdatrie1 libdbus-glib-1-2 libdconf1 libdrm-intel1 \
  libdrm-nouveau2 libdrm-radeon1 libelf1 libexif12 libflac8 libfontconfig1 \
  libfontenc1 libfreetype6 libfuse2 libgconf-2-4 libgconf2-4 libgd3 \
  libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgif4 libgl1-mesa-dri \
  libgl1-mesa-glx libglapi-mesa libglib2.0-0 libglib2.0-data libgmp10 \
  libgnome2-0 libgnome2-bin libgnome2-common libgnomevfs2-0 \
  libgnomevfs2-common libgphoto2-6 libgphoto2-l10n libgphoto2-port10 \
  libgraphite2-3 libgtk-3-0 libgtk-3-bin libgtk-3-common libgtk2.0-0 \
  libgtk2.0-bin libgtk2.0-common libgudev-1.0-0 libgusb2 libharfbuzz0b libice6 \
  libicu52 libidl-common libidl0 libieee1284-3 libisl10 libjasper1 libjbig0 \
  libjpeg-turbo8 libjpeg8 liblcms2-2 libllvm3.4 libmpc3 libmpfr4 libnspr4 \
  libnss3 libnss3-nssdb libogg0 liborbit-2-0 liborbit2 libpam-systemd \
  libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libparted0debian1 \
  libpciaccess0 libpcsclite1 libpixman-1-0 libpolkit-agent-1-0 \
  libpolkit-backend-1-0 libpolkit-gobject-1-0 libpulse0 libpython-stdlib \
  libsane libsane-common libsecret-1-0 libsecret-common libsm6 libsndfile1 \
  libsystemd-daemon0 libsystemd-login0 libtdb1 libthai-data libthai0 libtiff5 \
  libtxc-dxtn-s2tc0 libudisks2-0 libusb-1.0-0 libv4l-0 libv4lconvert0 \
  libvorbis0a libvorbisenc2 libvorbisfile3 libvpx1 libwayland-client0 \
  libwayland-cursor0 libx11-6 libx11-data libx11-xcb1 libxau6 libxaw7 \
  libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0 libxcb-render0 \
  libxcb-shape0 libxcb-shm0 libxcb-sync1 libxcb1 libxcomposite1 libxcursor1 \
  libxdamage1 libxdmcp6 libxext6 libxfixes3 libxft2 libxi6 libxinerama1 \
  libxkbcommon0 libxml2 libxmu6 libxmuu1 libxpm4 libxrandr2 libxrender1 \
  libxshmfence1 libxt6 libxtst6 libxv1 libxxf86dga1 libxxf86vm1 ntfs-3g \
  openjdk-7-jre openjdk-7-jre-headless parted policykit-1 policykit-1-gnome \
  psmisc python python-minimal python2.7 python2.7-minimal sgml-base \
  shared-mime-info sound-theme-freedesktop systemd-services systemd-shim \
  tzdata-java udisks2 x11-common x11-utils xml-core

COPY scripts/ /scripts
COPY default-config/ /etc/sensu/
WORKDIR /scripts
EXPOSE 3000 4567 5671 6379 15672
CMD ["/scripts/start.sh"]