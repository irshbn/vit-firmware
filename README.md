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

## Repo initialisation

This project uses [mise](https://mise.jdx.dev/) for task automation and
environment management, although it is possible to run all tasks
by hand as bash scripts.

> To view all available tasks run `mise tasks` or view the contents of
> [.mise/tasks](./.mise/tasks/) directory manually. Additionally, all tasks
> provide a [usage](https://usage.jdx.dev/) command line interface specification
> so you can get specific task reference info by running `mise run <task> -h`

### Yocto build-server setup

1. Ensure you have [docker](https://www.docker.com/) installed and on PATH
2. Run `mise run yocto:docker-build` to start image building
3. After the build is complete, verify you have a 'xil-yocto:latest' image listed
in `docker images`

> The default image reference is determined by `YOCTO_IMAGE` env var, which you
> can change within the [.mise/config.toml](./.mise/config.toml) or by supplying
> it as a positional arg to the `yocto:docker-build` task

### Yocto build-server first run

Run `mise run yocto:docker-run` to start the build-server container. If you provided
a custom image reference as a cli arg during build, then make sure to supply the
same reference to this task as well.

Upon starting for the first time, the build-server will populate the `yocto/sources`
directory with xilinx-yocto meta-layers and source the dedicated `setupsdk` script.
It is important to note that xilinx-yocto sources are versioned and should match
the release version of the Vivado toolchain. The version is controlled by `XILBRANCH`
variable in the `docker-entrypoint.sh` script.

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
5. From within build-server run `bitbake petalinux-image-minimal` to start the
building process
6. After the build finishes, exit build-server shell and use `dd` to flash bootable
SD-card with the `yocto/build/tmp/deploy/images/axu2cgb/petalinux-image-minimal.wic`
7. Using the SD-card boot the axu2cgb board, login as `petalinux`, and create a
new password for the user

In the end you should have a working petalinux distribution on your board

## Maintainers

Iaroslav Shubin <iar.shubin@gmail.com>

Aleksey Kuchkov <biblbroxxx@gmail.com>
