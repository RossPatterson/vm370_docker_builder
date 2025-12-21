# Dockerfile for the VM/370 Container
# Build the things the final image will need
FROM ubuntu:latest

RUN apt-get update
RUN apt-get install --no-install-recommends -y unzip wget netcat-traditional ca-certificates
RUN apt-get install --no-install-recommends -y dos2unix regina-rexx
RUN apt-get install --no-install-recommends -y python3 python-is-python3

# Build Hercules 3.x
RUN <<EOF
	set -x
    # Hercules Spinhawk 3.x dependencies:
    apt-get install -y autoconf automake build-essential gawk git m4 libbz2-dev zlib1g-dev

    mkdir -p ~/build_herc
    cd ~/build_herc
    ### TEMP >>>
    git clone https://github.com/RossPatterson/spinhawk.git
    cd spinhawk
    git switch h_0782
    ### This is what we should normally do instead of the above:
    # git https://github.com/rbowler/spinhawk.git
    # cd spinhawk
    ### <<< TEMP
    ./util/bldlvlck
	chmod a+x autogen.sh
    ./autogen.sh
    ./configure --prefix=/usr/local/hercules
    make
    make check
    make install
    cd
    rm -rf ~/build_herc
	mkdir -p /opt/hercules/vm370
    echo "export PATH=\"/usr/local/hercules/bin:\$PATH\"" > /opt/hercules/vm370/setup.sh
    echo "export LD_LIBRARY_PATH=\"/usr/local/hercules/lib:\$LD_LIBRARY_PATH\"" >> /opt/hercules/vm370/setup.sh
EOF

WORKDIR     /opt/hercules/vm370

# Local Config files
COPY *.sh hercules.conf cleandisks.conf ./
RUN dos2unix *.sh hercules.conf cleandisks.conf
RUN chmod +x *.sh && \
    chmod -x hercules.conf cleandisks.conf

# DASD
COPY disks/ ./disks/

# Build & Sanity Test VM/370 Host
RUN /opt/hercules/vm370/build.sh && \
    rm /opt/hercules/vm370/build.sh

# Cleanup
RUN rm -r ./disks
RUN rm cleandisks.conf


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
COPY --from=0 /usr/local/hercules/ /usr/local/hercules/

EXPOSE      3270 8038 3505
ENTRYPOINT  ["/opt/hercules/vm370/start_vm370.sh"]
