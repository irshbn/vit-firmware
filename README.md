# Visual Transformers on FPGA

A research of optimization techniques for visual transformer (ViT) and
multimodal models based on CPU+FPGA architectures

## Contents

This repo consists of several key components:

1. [`vivado/`](./vivado/) directory contains HDL sources, test suite, and automation
scripts to work within AMD Xilinx Vivado™ framework
2. [`yocto/`](./yocto/) directory contains custom meta layer and config files
for embedded development within The Yocto Project® framework
3. [`Dockerfile`](./Dockerfile) and [`docker-entrypoint.sh`](./docker-entrypoint.sh)
provide containerised yocto build server setup

## Repo initialization

This project uses [mise](https://mise.jdx.dev/) for task automation and environment
management, although you can in theory run tasks manually as bash scripts.
Review [.mise/tasks](./.mise/tasks/) directory for more reference.

> To view all available tasks and their descriptions run `mise tasks`.
> Additionally, all tasks provide a [usage](https://usage.jdx.dev/) command line
> interface specification so you can get specific task reference info by running
> `mise run <task> -h`

### Yocto build-server setup

This project relies on a Docker image with minimal Ubuntu setup for better compatibility
and reproducibility of Yocto build-server setups.

1. Ensure you have [docker-cli](https://www.docker.com/) installed and on PATH

2. Define the image reference (aka name) by either:

   - (preferred) defining `YOCTO_IMAGE` env variable in a `.mise.local.toml` file
   (place it at the project root)

   - setting `YOCTO_IMAGE` env variable manually for the task in the next step

   - supplying a positional arg to the task in the next step

3. Run `mise run yocto:docker-build <reference>` to start image building. The
`<reference>` arg is optional when `YOCTO_IMAGE` is set, but if provided it will
take precedence over the env variable.

4. After the build is complete, verify you have your newly built image listed in
the output of the `docker images` command

> `.mise.local.toml` (or, equivalently, `mise.local.toml`) takes precedence over
> `.mise/config.toml` file, but is excluded from source control. This allows for
> flexible per-user project configuration without polluting git history.
> See [mise configuration](https://mise.jdx.dev/configuration.html) for more information.

### Yocto build-server first run

Run `mise run yocto:docker-run` to start the build-server container. Be sure to
provide the image reference to this task the same way as for the build task.
Upon starting for the first time, the build-server will populate the `yocto/sources`
directory with xilinx-yocto meta-layers and source the dedicated `setupsdk` script.

> It is important to note that xilinx-yocto sources are versioned and should match
> the release version of the Vivado toolchain. The version is controlled by `XIL_VERSION`
> env variable, but if it is unset, the task will try to infer the version from
> a local vivado installation. If all attempts at discovering the version fail
> (as well as if `yocto/` directory is improperly mounted to the server),
> container will start in a dry-run mode without setting up the SDK.

### Vivado project reconstruction

Run `mise run vivado:create-project` to populate `vivado/project` directory with
files needed to completely reproduce Vivado workflow, including block design and
synthesis/implementation run definitions. You can then run `mise run vivado:open-project`
to open the created project in Vivado GUI to verify its integrity.

## Development flow

🚧 This section is under construction and will be expanded in the future 🏗

This project tries to unify Vivado and Yocto frameworks into a single
pipelined workflow. As the project matures, it will grow a more smooth and stable
development flow API. Currently a complete build cycle looks like the following:

1. Develop with Vivado to turn HDL sources into a hardware description `.xsa` file
with bitstream included

2. Run `mise run vivado:xsct-sdtgen` to generate `devicetree/` directory containing
device tree files based on `.xsa` file (requires `xsct` tool, which is distributed
with the Vivado suite and usually found in `<vivado_install_dir>/xsct-trim/bin`)

3. Run `mise run yocto:docker-run` to start yocto build-server and enter build-server
bash shell

4. From within build-server run
`gen-machineconf parse-sdt --hw-description /home/build/devicetree \
  -c conf -l conf/local.conf --machine-name axu2cgb`
This results in board-specific configuration files being added to the yocto build

5. From within build-server run `bitbake vit-image-minimal` to start the
building process

6. After the build finishes, exit build-server shell and use `dd` to flash bootable
SD-card with the `yocto/build/tmp/deploy/images/axu2cgb/vit-image-minimal.wic`

7. Using the SD-card boot into axu2cgb board via usb-uart serial line, login as
`petalinux`, and create a new password for the user.

In the end you should have a working petalinux distribution on your board

## Interfacing with the devboard

The `vit-image-minimal` distribution includes a [radvd](https://docs.opnsense.org/manual/radvd.html)
service that makes the board function as a router that distributes ipv6 addresses
for communication over ethernet. It uses stateless autoconfiguration (SLAAC)
and advertises only the subnet prefix, which is configured via `RA_PREFIX` env
variable.

Based on this prefix, there are several helper tasks defined to automate board connection
establishment:

1. `board:get-ip` utilizes `RA_PREFIX` to discover devboard's global unique ipv6
address. This task is relied upon by other related tasks.

2. `board:connect` starts an interactive ssh session to the board. The default
ssh login is `petalinux` but can be overridden via `--username` flag

3. `board:copy-id` runs `ssh-copy-id` to copy local user ssh keys over to the board
for passwordless login

> Default `RA_PREFIX` is set in the `.mise/config.toml` but can be overridden in
> `.mise.local.toml` according to user preferences. If `RA_PREFIX` is unset,
> radvd daemon will advertise a generic `2001:db8:0:1::` prefix.

## Maintainers

- Iaroslav Shubin <iar.shubin@gmail.com>
- Aleksey Kuchkov <biblbroxxx@gmail.com>
