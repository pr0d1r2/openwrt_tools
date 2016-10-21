# openwrt_tools

Set of tools to manage OpenWRT devices.

## Setup

Run (possibly adjust after copying):

```
cp .hostname.example .hostname
```

### Setup ssh key

Run:

```
sh setup_ssh_key.sh
```

### Setup PXE server

Run:

```
sh setup_pxe_server.sh
```

It internally uses following installers:

#### Setup external USB storage

Assuming you have single USB device connected and it is already formatted, run:

```
sh setup_external_storage.sh
```

#### Setup wget with SSL
By default we do not have ssl certificates:

```
sh setup_external_storage.sh
```
