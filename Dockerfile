# Dockerfile for the VM/370 Container

###############################################################################
# Build the things the final image will need

# We're pinned to 24.04 "noble" because later GCC versions can't compile
# Spinhawk.
FROM rosspatterson/spinhawk:latest AS builder

RUN apt-get update && \
	apt-get install --no-install-recommends -y \
		netcat-traditional net-tools python3 python-is-python3 regina-rexx

WORKDIR /opt/hercules/vm370

# Local Config files
COPY *.sh cleandisks.conf hercules.conf ./
RUN dos2unix *.sh cleandisks.conf hercules.conf
RUN chmod +x *.sh && \
    chmod -x cleandisks.conf hercules.conf

# DASD
COPY disks/ ./disks/

# Build & Sanity Test VM/370 Host
RUN /opt/hercules/vm370/build.sh && \
    rm /opt/hercules/vm370/build.sh

# Cleanup
RUN rm -r ./disks && \
	rm cleandisks.conf

###############################################################################
# Create the final Docker Image
FROM rosspatterson/spinhawk:latest

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
		c3270 netcat-traditional python3 python-is-python3 regina-rexx

WORKDIR /opt/hercules/vm370

COPY --from=builder /opt/hercules/vm370/*      ./
COPY --from=builder /usr/local/bin/herccontrol /usr/local/bin/herccontrol
COPY --from=builder /usr/local/bin/yata        /usr/local/bin/yata
COPY --from=builder /usr/local/bin/vma         /usr/local/bin/vma
COPY --from=builder /usr/local/hercules/       /usr/local/hercules/

EXPOSE      3270 8038 3505

ENTRYPOINT  ["/opt/hercules/vm370/start_vm370.sh"]
