FROM ubuntu:18.04

LABEL Simon Egli <docker_android_studio_860dd6@egli.online>

ARG USER=android

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y \
        build-essential git neovim wget unzip sudo \
        libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 \
        libxrender1 libxtst6 libxi6 libfreetype6 libxft2 xz-utils vim\
        libxrender1 libxtst6 libxi6 libfreetype6 libxft2 xz-utils vim\
        qemu qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils libnotify4 libglu1 libqt5widgets5 openjdk-8-jdk openjdk-11-jdk xvfb \
        && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -g 1000 -r $USER
RUN useradd -u 1000 -g 1000 --create-home -r $USER
RUN adduser $USER libvirt
RUN adduser $USER kvm
#Change password
RUN echo "$USER:$USER" | chpasswd
#Make sudo passwordless
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USER
RUN usermod -aG sudo $USER
RUN usermod -aG plugdev $USER

#VOLUME /androidstudio-data
#RUN mkdir /androidstudio-data && chown $USER:$USER /androidstudio-data

COPY provisioning/docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
COPY provisioning/ndkTests.sh /usr/local/bin/ndkTests.sh
RUN chmod +x /usr/local/bin/*
COPY provisioning/51-android.rules /etc/udev/rules.d/51-android.rules

USER $USER

WORKDIR /home/$USER

#Install Flutter
ARG FLUTTER_URL=https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_1.22.2-stable.tar.xz
ARG FLUTTER_VERSION=1.22.2

RUN wget "$FLUTTER_URL" -O flutter.tar.xz && \
        tar -xvf flutter.tar.xz && \
        rm flutter.tar.xz

#Android Studio
ARG ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.1.1.21/android-studio-2022.1.1.21-linux.tar.gz
ARG ANDROID_STUDIO_VERSION=2022.1.1.21

RUN wget "$ANDROID_STUDIO_URL" -O android-studio.tar.gz && \
        tar xzvf android-studio.tar.gz && \
        rm android-studio.tar.gz

ARG NDK_VERSION=23.1.7779620

# Helpful links for info on installing SDK, NDK:
#   https://developer.android.com/tools/sdkmanager
COPY binaries/commandlinetools-linux-9477386_latest.zip .
#RUN mkdir -p Android/sdk && \
#    unzip commandlinetools-linux-9477386_latest.zip && \
#    mkdir latest && \
#    mv cmdline-tools/* latest && \
#    mv latest cmdline-tools/ && \
#    mv cmdline-tools Android/sdk/ && \
#    echo "y\ny\ny\ny\ny\ny\n" | ./Android/sdk/cmdline-tools/latest/bin/sdkmanager --licenses && \
#    echo "y\n" | ./Android/sdk/cmdline-tools/latest/bin/sdkmanager --install "ndk;$NDK_VERSION" && \
#    ./Android/sdk/cmdline-tools/latest/bin/sdkmanager --install "platform-tools" && \
#    ./Android/sdk/cmdline-tools/latest/bin/sdkmanager --install "platforms;android-11" && \

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV ANDROID_HOME=/home/$USER/Android

#RUN sudo mkdir -p /studio-data/profile /studio-data/platform-tools
#RUN sudo chown -R $USER:$USER /studio-data
#RUN ln -s /studio-data/profile/AndroidStudio$ANDROID_STUDIO_VERSION .AndroidStudio$ANDROID_STUDIO_VERSION
#RUN ln -s /studio-data/Android Android
#RUN ln -s /studio-data/profile/android .android
#RUN ln -s /studio-data/profile/java .java
#RUN ln -s /studio-data/profile/gradle .gradle
ENV ANDROID_EMULATOR_USE_SYSTEM_LIBS=1

WORKDIR /home/$USER

ENTRYPOINT [ "/usr/local/bin/docker_entrypoint.sh" ]
