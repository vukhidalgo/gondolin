FROM ghcr.io/ublue-os/bazzite:latest AS tishy-base

ARG IMAGE_NAME="${IMAGE_NAME:-tishy}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-sunshowers}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-bazzite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"

## Copy system files over
COPY system_files /

## Add ryzenadj and infrequently-updated packages

RUN sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo

RUN rpm-ostree install \
    direnv \
    evtest \
    fd-find \
    libguestfs-tools \
    perf \
    powertop \
    ripgrep \
    ryzenadj \
    strace \
    yakuake \
    zsh

## Add flatpak packages
RUN cat /tmp/flatpak_install >> /usr/share/ublue-os/bazzite/flatpak/install

## Commit
RUN rm -rf /var/* && ostree container commit

FROM tishy-base AS tishy-1password

## Add 1password
COPY system_files /
RUN /tmp/install-1password.sh

## Commit
RUN rm -rf /var/* && ostree container commit

## Next: install system Chrome
FROM tishy-1password AS tishy-chrome

## Add system Chrome
COPY system_files /
RUN /tmp/install-chrome.sh

## Commit
RUN rm -rf /var/* && ostree container commit

## Lastly: install other packages

FROM tishy-chrome AS tishy

## Install other new packages
RUN rpm-ostree install \
    chromium \
    code \
    firefox \
    NetworkManager-tui \
    virt-install \
    virt-manager \
    virt-viewer

## Configure KDE & GNOME
RUN sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>applications:org.gnome.Prompt.desktop,preferred:\/\/browser,preferred:\/\/filemanager,applications:code.desktop,applications:steam.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
    sed -i '/<entry name="favorites" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>org.gnome.Prompt.desktop,preferred:\/\/browser,org.kde.dolphin.desktop,code.desktop,steam.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.kickoff/contents/config/main.xml

### 5. POST-MODIFICATIONS
## these commands leave the image in a clean state after local modifications
# Cleanup & Finalize
RUN \
    rm -rf /tmp/* /var/* && \
    ostree container commit
