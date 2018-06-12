# Atomic WireGuard

Atomic WireGuard is a containerized method for building the WireGuard kernel module on Fedora Atomic Host and Silverblue. It also can be used on Fedora Workstation instead of the [wireguard-dkms and wireguard-tools](https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/packages/) packages. The end goals of this project is to allow for WireGuard to be built reliably on distributions with immutable file systems. It also can be used as an example for building other kernel modules on immutable infrastructure.

This is a work in progress. Please use at your own risk. Issues and PRs are very welcome.

## Limitations

* This will add 5 to 10 minutes of time to your boot process if you do not have the WireGuard kernel module built for your booted kernel version.
* This will fail to build if you do not have Internet access. Do not use this if you rely on WireGuard for connectivity to the Internet.
* This is a stopgap until WireGuard gets pushed into the mainline kernel.

## Requirements

* [container-selinux-2.61](https://koji.fedoraproject.org/koji/buildinfo?buildID=1083837) or higher
* podman 0.5.1 or higher
* systemd 238 or higher
* systemd-networkd

## Installation

### Fedora Atomic Host and Silverblue

```bash
# rpm-ostree upgrade
# sudo curl -Lo /tmp/container-selinux-2.61-1.git9b55129.fc28.noarch.rpm https://kojipkgs.fedoraproject.org/packages/container-selinux/2.61/1.git9b55129.fc28/noarch/container-selinux-2.61-1.git9b55129.fc28.noarch.rpm
# rpm-ostree upgrade /tmp/container-selinux-2.61-1.git9b55129.fc28.noarch.rpm
# sudo curl -Lo /etc/yum.repos.d/atomic-wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/atomic-wireguard/repo/fedora-28/jdoss-atomic-wireguard-fedora-28.repo
# sudo rpm-ostree install atomic-wireguard
# systemctl reboot
# sudo systemctl enable systemd-networkd.service
# sudo systemctl start systemd-networkd.service
# sudo systemctl enable atomic-wireguard
# sudo systemctl start atomic-wireguard
```

### Fedora Workstation

```bash
# sudo dnf copr enable jdoss/atomic-wireguard
# sudo dnf install atomic-wireguard
# sudo systemctl enable systemd-networkd.service
# sudo systemctl start systemd-networkd.service
# sudo systemctl enable atomic-wireguard
# sudo systemctl start atomic-wireguard
```

Note: As soon as the next Fedora Atomic composes come out manually installing `container-selinux-2.61` will get removed from the above steps.

## Usage

Atomic WireGuard ships an artisanally handcrafted bash script called `atomic-wireguard-module` that calls podman to build the kernel module in a container. It accepts the following arguments:

```bash
build       Build wireguard kernel module container
load        Load wireguard kernel module
unload      Unload wireguard kernel module
reload      Build and reload wireguard kernel module
```

Atomic Wireguard also has a systemd unit file which on start waits for NetworkManager to finish starting up and then it will build and load the WireGuard kernel module. You can also use `systemctl reload atomic-wireguard` to run the build process, unload and then load the kernel module. This is handy if you want to change the WireGuard kernel module version. To change the version, just edit the `WIREGUARD_VERSION` and `WIREGUARD_SHA265` lines in `/etc/sysconfig/atomic-wireguard`. Please note that this needs to be the exact version number and SHA256 hash of a released WireGuard snapshot. You can verify that the kernel module is loaded with `lsmod |grep wireguard`.

### Setting up systemd-networkd

**Generate WireGuard Keys**

`# wg genkey | tee /etc/wireguard/wg0-private.key | wg pubkey > /etc/wireguard/wg0-public.key`

**Create /etc/systemd/network/wg0.netdev**

`# vi /etc/systemd/network/wg0.netdev`

```bash
[NetDev]
Name=wg0
Kind=wireguard
Description=Atomic WireGuard

[WireGuard]
PrivateKey=${LOCAL PUBLIC KEY}
ListenPort=51820

[WireGuardPeer]
PublicKey=${REMOTE PUBLIC KEY}
AllowedIPs=0.0.0.0/0
Endpoint=${REMOTE IP ADDRESS}:51820
```

Note: Replace `${LOCAL PUBLIC KEY}` with your generated public key stored in `/etc/wireguard/wg0-public.key`. Replace `${REMOTE PUBLIC KEY}` with the public key from the remote WireGuard server and `${REMOTE IP ADDRESS}` from the remote WiredGuard server.

**Create /etc/systemd/network/wg0.network**

`# vi /etc/systemd/network/wg0.network`

```bash
[Match]
Name=wg0

[Network]
Address=10.122.122.1/24
```

**Fix permissions and reload systemd**

```bash
# chown root.systemd-network /etc/systemd/network/wg0.*
# chmod 0640 /etc/systemd/network/wg0.*
# systemctl daemon-reload
# systemctl restart systemd-networkd
```

**Verify WireGuard is working**

```bash
# wg show wg0
# networkctl status wg0
# ip addr show dev wg0
```

## Troubleshooting

TBD by user feedback.

## Todo

* Write Troubleshooting Guide in README.md based off end user feedback

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-cool-feature`)
3. Commit your changes (`git commit -m 'Add a cool feature'`)
4. Push to the branch (`git push origin my-cool-feature`)
5. Create new a Pull Request with a detailed description

## License

The MIT License

Copyright (c) 2018 Joe Doss

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
