#!/bin/bash

# This script provides common customization options for the ISO
# 
# Usage: Copy this file to config.sh and make changes there.  Keep this file (default_config.sh) as-is
#   so that subsequent changes can be easily merged from upstream.  Keep all customiations in config.sh

# The version of Ubuntu to generate.  Successfully tested LTS: bionic, focal, jammy, noble
# See https://wiki.ubuntu.com/DevelopmentCodeNames for details
export TARGET_UBUNTU_VERSION="questing"

# The Ubuntu Mirror URL. It's better to change for faster download.
# More mirrors see: https://launchpad.net/ubuntu/+archivemirrors
export TARGET_UBUNTU_MIRROR="http://mirrors.aliyun.com/ubuntu/"

# The packaged version of the Linux kernel to install on target image.
# See https://wiki.ubuntu.com/Kernel/LTSEnablementStack for details
export TARGET_KERNEL_PACKAGE="linux-generic"

# The file (no extension) of the ISO containing the generated disk image,
# the volume id, and the hostname of the live environment are set from this name.
export TARGET_NAME="Ubuntu"

# The text label shown in GRUB for booting into the live environment
export GRUB_LIVEBOOT_LABEL="Try Ubuntu without installing"

# The text label shown in GRUB for starting installation
export GRUB_INSTALL_LABEL="Install Ubuntu"

# Packages to be removed from the target system after installation completes succesfully
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect
"

# Package customisation function.  Update this function to customize packages
# present on the installed system.
function customize_image() {
    # install graphics and desktop
    apt-get install -y \
        alsa-utils \
        apt-config-icons-hidpi \
        dmz-cursor-theme \
        fonts-ubuntu \
        fonts-liberation \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        fonts-noto-core \
        gdm3 \
        gnome-shell \
        gnome-shell-extension-appindicator \
        gnome-shell-extension-desktop-icons-ng \
        gnome-shell-extension-ubuntu-dock \
        gnome-shell-extension-ubuntu-tiling-assistant \
        gnome-control-center \
        gnome-disk-utility \
        gnome-keyring \
        gnome-terminal \
        gnome-session-canberra \
        gnome-menus \
        gsettings-ubuntu-schemas \
        ubuntu-settings \
        ubuntu-session \
        ubuntu-wallpapers \
        iio-sensor-proxy \
        ibus-libpinyin \
        ibus-pinyin \
        va-driver-all \
        ubuntu-drivers-common \
        adb \
        fastboot \
        yaru-theme-icon \
        yaru-theme-sound \
        yaru-theme-gtk \
        yaru-theme-gnome-shell

    # useful tools
    apt-get install -y \
        curl \
        vim \
        nano \
        less \
        clangd \
        clang \
        build-essential \
        gdb \
        tree

    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > "/etc/apt/sources.list.d/google-chrome.list"
    apt update -y
    apt install -y google-chrome-stable

    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
    rm -f microsoft.gpg
    cat > /etc/apt/sources.list.d/vscode.sources << EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF
    apt update -y
    apt install code-insiders

    cat >> /etc/sysctl.conf << 'SYSCTLEOF'
vm.swappiness=1
vm.vfs_cache_pressure=50
vm.dirty_background_ratio=1
vm.dirty_ratio=50
kernel.nmi_watchdog=0
net.ipv4.tcp_congestion_control=bbr
SYSCTLEOF

    apt-get install -y fastfetch git

    # purge
    local unwanted_packages=(
        "gnome-bluetooth-sendto"
        "gnome-initial-setup"
        "gnome-font-viewer"
        "gnome-clocks"
        "gnome-logs"
        "gnome-remote-desktop"
        "gnome-system-monitor"
        "gnome-text-editor"
        "gnome-startup-applications"
        "printer-driver-*"
        "papers"
        "orca"
        "packagekit"
        "avahi-daemon"
        "whoopsie"
        "firefox"
        "cloud-init"
        "ubuntu-pro-client"
        "ubuntu-advantage-tools"
	"snapd"
	"firefox"
	"sssd"
        "aisleriot"
        "hitori"
        "gnome-characters"
        "gnome-software"
        "gnome-online-accounts-gtk"
        "gnome-power-manager"
        "zutty"
        "wpagui"
    )

    for package in "${unwanted_packages[@]}"; do
        apt purge -y $package 2>/dev/null || true
    done
    rm -rf /var/cache/snapd/

    apt install busybox-initramfs  dracut-install  fuse3  initramfs-tools  initramfs-tools-bin  initramfs-tools-core  klibc-utils libklibc  linux-base  zstd -y
    apt autoremove --purge -y

    systemctl mask systemd-networkd-wait-online.service || true
    systemctl disable bluetooth.service || true
    systemctl disable casper-md5check.service || true
}

# Used to version the configuration.  If breaking changes occur, manual
# updates to this file from the default may be necessary.
export CONFIG_FILE_VERSION="0.4"
