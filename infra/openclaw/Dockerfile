FROM alpine:3.20

# Install tools at build time (so runtime can be read-only)
RUN apk add --no-cache \
    iptables \
    curl \
    busybox-extras \
    ca-certificates

# Create non-root user/group (1000:1000)
RUN addgroup -g 1000 -S app && adduser -u 1000 -S app -G app

# Copy scripts into image (no need to mount them for runtime)
COPY entrypoint.sh /entrypoint.sh
COPY firewall.sh /firewall.sh
COPY security-test.sh /security-test.sh

RUN chmod +x /firewall.sh /security-test.sh

CMD ["sleep", "infinity"]
