FROM fedora as builder
MAINTAINER "Joe Doss" <joe@solidadmin.com>

ARG WIREGUARD_VERSION
ARG WIREGUARD_KERNEL_VERSION
ARG WIREGUARD_SHA256

WORKDIR /tmp

RUN dnf update -y && dnf install \
        libmnl-devel elfutils-libelf-devel findutils binutils boost-atomic boost-chrono \
        boost-date-time boost-system boost-thread cpp dyninst efivar-libs gc \
        gcc glibc-devel glibc-headers guile koji isl libatomic_ops libdwarf libmpc \
        libpkgconf libtool-ltdl libxcrypt-devel make mokutil pkgconf pkgconf-m4 \
        pkgconf-pkg-config unzip zip /usr/bin/pkg-config xz -y && \
        koji download-build --rpm --arch=x86_64 kernel-core-${WIREGUARD_KERNEL_VERSION} && \
        koji download-build --rpm --arch=x86_64 kernel-devel-${WIREGUARD_KERNEL_VERSION} && \
        koji download-build --rpm --arch=x86_64 kernel-modules-${WIREGUARD_KERNEL_VERSION} && \
        dnf install kernel-core-${WIREGUARD_KERNEL_VERSION}.rpm \
        kernel-devel-${WIREGUARD_KERNEL_VERSION}.rpm \
        kernel-modules-${WIREGUARD_KERNEL_VERSION}.rpm -y && \
        dnf clean all && \
        curl -LS https://git.zx2c4.com/WireGuard/snapshot/WireGuard-${WIREGUARD_VERSION}.tar.xz | \
        { t="$(mktemp)"; trap "rm -f '$t'" INT TERM EXIT; cat >| "$t"; sha256sum --quiet -c <<<"${WIREGUARD_SHA256} $t" \
        || exit 1; cat "$t"; } | tar xJf -

RUN cd /tmp/WireGuard-${WIREGUARD_VERSION}/src; \
    KERNELDIR=/usr/lib/modules/${WIREGUARD_KERNEL_VERSION}/build make -j$(nproc) && make install

FROM fedora
MAINTAINER "Joe Doss" <joe@solidadmin.com>

ARG WIREGUARD_KERNEL_VERSION

WORKDIR /tmp

RUN dnf update -y && dnf install kmod koji -y && \
        koji download-build --rpm --arch=x86_64 kernel-core-${WIREGUARD_KERNEL_VERSION} && \
        koji download-build --rpm --arch=x86_64 kernel-modules-${WIREGUARD_KERNEL_VERSION} && \
        dnf install /tmp/kernel-core-${WIREGUARD_KERNEL_VERSION}.rpm \
        kernel-modules-${WIREGUARD_KERNEL_VERSION}.rpm -y && \
        dnf clean all && rm -f /tmp/*.rpm

COPY --from=builder /usr/lib/modules/${WIREGUARD_KERNEL_VERSION}/extra/wireguard.ko \
                    /usr/lib/modules/${WIREGUARD_KERNEL_VERSION}/extra/wireguard.ko

COPY --from=builder /usr/bin/wg /usr/bin/wg
COPY --from=builder /usr/bin/wg-quick /usr/bin/wg-quick

CMD /usr/bin/wg
