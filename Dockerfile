ARG BASE_TAG="develop"
ARG BASE_IMAGE="core-ubuntu-focal"
FROM kasmweb/$BASE_IMAGE:$BASE_TAG
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########


# Install Firefox
COPY ./src/ubuntu/install/firefox/ $INST_SCRIPTS/firefox/
COPY ./src/ubuntu/install/firefox/firefox.desktop $HOME/Desktop/
RUN bash $INST_SCRIPTS/firefox/install_firefox.sh && rm -rf $INST_SCRIPTS/firefox/

#CUSTOMIZE RAFIK

RUN apt-get update && apt-get install -y gnupg gnupg2 wget alsa-firmware-loaders libdssialsacompat-dev libdssialsacompat0 alsa-tools whichman net-tools init libgtk-3-0 libdbus-1-3 libdbus-glib-1-2 libdbus-glib-1-dev libpci-dev libpci3 libegl1 libegl-dev libxtst-dev libxtst6 libnm0 pulseaudio telnet vim lbzip2 && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

RUN \
    FIREFOX_VERSION=103.0.2 \
    FIREFOX_DISTRO=linux-x86_64 \
    FIREFOX_PATH=/usr/lib/firefox \
    && mv /usr/bin/firefox /usr/bin/firefox_ORIG \
    && mv /usr/lib/firefox /usr/lib/firefox_ORIG \
    && mkdir -p ${FIREFOX_PATH} \
    && wget -qO- http://releases.mozilla.org/pub/firefox/releases/${FIREFOX_VERSION}/${FIREFOX_DISTRO}/en-US/firefox-${FIREFOX_VERSION}.tar.bz2 \
    | tar xvj -C /usr/lib/ \
    && ln -s ${FIREFOX_PATH}/firefox /usr/bin/firefox \
    && mkdir -p /usr/lib/firefox/browser/defaults/preferences \
    && touch /usr/lib/firefox/browser/defaults/preferences/firefox.js \
    && echo "pref(\"datareporting.policy.firstRunURL\", \"\");" >> /usr/lib/firefox/browser/defaults/preferences/firefox.js \
    && mv /usr/lib/firefox/updater /usr/lib/firefox/updater_ORIG;mv /usr/lib/firefox/updater.ini /usr/lib/firefox/updater.ini_ORIG;mv /usr/lib/firefox/update-settings.ini /usr/lib/firefox/update-settings.ini_ORIG

#CUSTOMIZE RAFIK END


# Update the desktop environment to be optimized for a single application
RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
RUN cp /usr/share/extra/backgrounds/bg_kasm.png /usr/share/extra/backgrounds/bg_default.png
RUN apt-get remove -y xfce4-panel

# Setup the custom startup script that will be invoked when the container starts
#ENV LAUNCH_URL  http://kasmweb.com

COPY ./src/ubuntu/install/firefox/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod +x $STARTUPDIR/custom_startup.sh

# Install Custom Certificate Authority
# COPY ./src/ubuntu/install/certificates $INST_SCRIPTS/certificates/
# RUN bash $INST_SCRIPTS/certificates/install_ca_cert.sh && rm -rf $INST_SCRIPTS/certificates/

ENV KASM_RESTRICTED_FILE_CHOOSER=1
COPY ./src/ubuntu/install/gtk/ $INST_SCRIPTS/gtk/
RUN bash $INST_SCRIPTS/gtk/install_restricted_file_chooser.sh

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
