# Dockerfile for the VM/370 Container

# Build the things the final image will need
FROM ubuntu:latest

RUN apt-get update
RUN apt-get install --no-install-recommends -y unzip wget netcat-traditional ca-certificates
RUN apt-get install --no-install-recommends -y dos2unix regina-rexx
RUN apt-get install --no-install-recommends -y python3 python-is-python3

# Build Hercules 4.x
RUN <<EOF
    # Hercules Helper needs sudo, even if we're root:
    apt-get install -y --no-install-recommends sudo

    # SDL-Hercules-390 Hyperion 4.x required packages
    # Debian/Ubuntu/Mint/etc
    sudo apt-get -y install git wget time
    sudo apt-get -y install build-essential cmake flex gawk m4 autoconf automake libtool-bin libltdl-dev
    sudo apt-get -y install libbz2-dev zlib1g-dev
    sudo apt-get -y install libcap2-bin
    sudo apt-get -y install libregina3-dev

    mkdir -p build_herc/build_dir
    cd build_herc
    git clone https://github.com/wrljet/hercules-helper.git
    cd build_dir
    ### The below is temporary until Hercules releases the fix for https://github.com/SDL-Hercules-390/hyperion/issues/792.
    ### TEMP >>>
    git_branch_hercules="i_0782" \
        git_repo_hercules="https://github.com/RossPatterson/hyperion.git" \
        ../hercules-helper/hercules-buildall.sh --accept-root --auto --flavor=sdl-hyperion --no-setcap --no-tests --prefix=/usr/local/hercules4
    ### <<< TEMP
    ### This is what we should normally do instead of the above:
    # ../hercules-helper/hercules-buildall.sh --accept-root --auto --flavor=sdl-hyperion --no-setcap --no-tests --prefix=/usr/local/hercules4
    cd ../..
    rm -rf build_herc

    # Hercules 4.x quits immediately if nothing is running
    mkdir /opt || true
    mkdir /opt/hercules || true
    mkdir /opt/hercules/vm370 || true
    echo "* Start VM/370" > /opt/hercules/vm370/start_vm370.rc
    echo "ipl 6A1" > /opt/hercules/vm370/start_vm370.rc

    # Add our newly-built Hercules to the path
    echo "export PATH=\"/usr/local/hercules4/bin:\$PATH\"" > /opt/hercules/vm370/setup.sh
    echo "export LD_LIBRARY_PATH=\"/usr/local/hercules4/lib:\$LD_LIBRARY_PATH\"" >> /opt/hercules/vm370/setup.sh
EOF

WORKDIR     /opt/hercules/vm370

# Local Config files
COPY *.sh hercules.conf cleandisks.conf build.rc cleandisks.rc ./
RUN dos2unix *.sh hercules.conf cleandisks.conf build.rc cleandisks.rc
RUN chmod +x *.sh && \
    chmod -x hercules.conf cleandisks.conf build.rc cleandisks.rc

# DASD
COPY disks/ ./disks/

# Build & Sanity Test VM/370 Host
RUN /opt/hercules/vm370/build.sh && \
    rm /opt/hercules/vm370/build.sh

# Cleanup
RUN rm -r ./disks
RUN rm cleandisks.conf cleandisks.rc


# Create the final Docker Image
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install --no-install-recommends -y c3270 zip unzip netcat-traditional \
    dos2unix regina-rexx wget ca-certificates python3 python-is-python3 && \
    apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
    rm -rf /var/lib/apt/lists/*

WORKDIR     /opt/hercules/vm370

COPY --from=0 /opt/hercules/vm370/* ./
COPY --from=0 /usr/local/bin/herccontrol /usr/local/bin/herccontrol
COPY --from=0 /usr/local/bin/yata /usr/local/bin/yata
COPY --from=0 /usr/local/hercules4 /usr/local/hercules4

EXPOSE      3270 8038 3505
ENTRYPOINT  ["/opt/hercules/vm370/start_vm370.sh"]
