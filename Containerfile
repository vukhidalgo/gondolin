ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-41}"

FROM ghcr.io/ublue-os/bazzite:latest AS tishy-base

ARG IMAGE_NAME="${IMAGE_NAME:-tishy}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-sunshowers}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-bazzite}"
ARG FEDORA_MAJOR_VERSION

## Copy system files over
COPY system_files /

## Add infrequently-updated packages

RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    rpm-ostree install \
        direnv \
        evtest \
        fd-find \
        kontact \
        libguestfs-tools \
        perf \
        powertop \
        ripgrep \
        strace \
        yakuake \
        zsh && \
    cat /tmp/flatpak_install >> /usr/share/ublue-os/bazzite/flatpak/install && \
    /tmp/cleanup.sh && \
    ostree container commit

FROM tishy-base AS tishy-1password

## Add 1password
COPY system_files /
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    /tmp/install-1password.sh && \
    /tmp/cleanup.sh && \
    ostree container commit

## Next: install system Chrome
FROM tishy-1password AS tishy-chrome

## Add system Chrome
COPY system_files /
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    /tmp/install-chrome.sh && \
    /tmp/cleanup.sh && \
    ostree container commit

## Lastly: install other packages

FROM tishy-chrome AS tishy
ARG FEDORA_MAJOR_VERSION

## Install other new packages
COPY system_files /
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    curl -Lo /etc/yum.repos.d/_copr_wezfurlong-wezterm-nightly.repo https://copr.fedorainfracloud.org/coprs/wezfurlong/wezterm-nightly/repo/fedora-"${FEDORA_MAJOR_VERSION}"/wezfurlong-wezterm-nightly-"${FEDORA_MAJOR_VERSION}".repo && \
    rpm-ostree install \
        chromium \
        code \
        firefox \
        NetworkManager-tui \
        virt-install \
        virt-manager \
        virt-viewer \
        wezterm && \
    sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>applications:org.gnome.Prompt.desktop,preferred:\/\/browser,preferred:\/\/filemanager,applications:code.desktop,applications:steam.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
    sed -i '/<entry name="favorites" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>org.gnome.Prompt.desktop,preferred:\/\/browser,org.kde.dolphin.desktop,code.desktop,steam.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.kickoff/contents/config/main.xml && \
    /tmp/cleanup.sh && \
    ostree container commit
