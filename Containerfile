FROM ghcr.io/ublue-os/bazzite:latest AS tishtrya

ARG IMAGE_NAME="${IMAGE_NAME:-tishtrya}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-sunshowers}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-bazzite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"

### 3. PRE-MODIFICATIONS

## Copy System files to be used in image
COPY system_files /

### 4. MODIFICATIONS
## make modifications desired in your image and install packages here, a few examples follow

## Install new packages
RUN rpm-ostree install \
    cockpit-bridge \
    cockpit-kdump \
    cockpit-machines \
    cockpit-navigator \
    cockpit-networkmanager \
    cockpit-podman \
    cockpit-selinux \
    cockpit-storaged \
    cockpit-system \
    code \
    direnv \
    fd-find \
    firefox \
    libguestfs-tools \
    NetworkManager-tui \
    ripgrep \
    subscription-manager \
    virt-install \
    virt-manager \
    virt-viewer \
    zsh

## Add flatpak packages
RUN cat /tmp/flatpak_install >> /usr/share/ublue-os/bazzite/flatpak/install

## Add 1password
RUN /tmp/install-1password.sh

## Configure KDE & GNOME
RUN sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>applications:org.gnome.Prompt.desktop,preferred:\/\/browser,preferred:\/\/filemanager,applications:code.desktop,applications:steam.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
    sed -i '/<entry name="favorites" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>org.gnome.Prompt.desktop,preferred:\/\/browser,org.kde.dolphin.desktop,code.desktop,steam.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.kickoff/contents/config/main.xml

### 5. POST-MODIFICATIONS
## these commands leave the image in a clean state after local modifications
# Cleanup & Finalize
RUN \
    rm -rf \
    /tmp/* \
    /var/* && \
    ostree container commit
