# Atomic WireGuard

Atomic WireGuard is a containerized method for building the WireGuard kernel module on Fedora Atomic Host and Silverblue. The end goals of this project is to allow for WireGuard to be built reliably on distributions with immutable file systems. It is a work in progress and PRs are very welcome.

## Limitations

* This will add 5 to 10 minutes of time to your boot process if you do not have the WireGuard kernel module built for your booted kernel version.
* This will fail if you do not have Internet access. Do not use this if you rely on WireGuard for connectivity to the Internet.

## Requirements

* [container-selinux-2.61](https://koji.fedoraproject.org/koji/buildinfo?buildID=1083837) or higher
* podman 0.5.1 or higher
* systemd 238 or higher
* systemd-networkd

## Installation

* sudo dnf copr enable jdoss/atomic-wireguard
* sudo dnf install atomic-wireguard
* sudo systemctl enable systemd-networkd.service
* sudo systemctl start systemd-networkd.service
* sudo systemctl start atomic-wireguard
* sudo systemctl enable atomic-wireguard

## Usage

Atomic WireGuard ships an artisanally handcrafted bash script called `atomic-wireguard-module` that calls podman to build the kernel module in a container. It accepts the following arguments:

```bash
build       Build wireguard kernel module container
load        Load wireguard kernel module
unload      Unload wireguard kernel module
reload      Build and reload wireguard kernel module
```

It also has a systemd unit file which on start waits for NetworkManager to startup and then it will build and load the WireGuard kernel module. You can also use `systemctl reload atomic-wireguard` to run the build process, unload and then load the kernel module. This is handy if you want to change the WireGuard kernel module version. To change the version, just edit the `WIREGUARD_VERSION` line in `/etc/sysconfig/atomic-wireguard`. Please note that this needs to be the exact version number of a released snapshot. Anything else and the build process will fail.

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
