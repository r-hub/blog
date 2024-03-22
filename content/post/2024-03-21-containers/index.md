---
slug: rhub-containers
title: "Docker containers for R users and developers"
authors:
- Gábor Csárdi
date: "2024-03-21"
tags:
- Docker
- containers
- R versions
output: hugodown::hugo_document
rmd_hash: c088cbc87ddcafeb

---

## TL;DR

If you need a Docker container with R, or need to run a specific R version or need to run R on a specific platform, then chances are, you don't need to compile R or build your own ocker image. Take a look at the links below.

## [`rstudio/r-docker`](https://github.com/rstudio/r-docker)

Containers corresponding to Posit's R builds from [rstudio/r-buidls](https://github.com/rstudio/r-builds)

Advantages:

-   Many Linux distributions, currently all supported versions of Ubuntu, Debian, CentOS, Rocky Linux, and openSUSE.
-   Extensively tested. These Ubuntu (20.04 currently) builds are used on [Posit Cloud](https://posit.cloud/), [shinyapps.io](https://shinyapps.io/), and the [`r-lib/actions/setup-r`](https://github.com/r-lib/actions/tree/v2-branch/setup-r) GitHub Action also installs these on Linux.
-   They support all versions of R from R 3.1.0, and R-devel.
-   It is possible to install multiple versions of R on these containers.

List of Docker images at the time of writing:

| Tag                               | Description                                               |
|---------------------------|---------------------------------------------|
| `rstudio/r-base:<x.y.z>-<distro>` | R version `x.y.z` on the specified OS                     |
| `rstudio/r-base:<x.y>-<distro>`   | Latest R version in the `x.y` branch, on the specified OS |

`<x.y.z>` can be any version from `3.1.0` to `4.3.3` or `devel`. `<x.y>` can be any minor version from `3.1` to `4.3`. `<distro>` can be one of `focal`, `jammy`, `bullseye`, `bookworm`, `centos7`, `rockylinux8` `rockylinux9`, `opensuse154` and `opensuse155`.

See the [GitHub repo](https://github.com/rstudio/r-docker#releases-and-tags) or [Docker Hub](https://hub.docker.com/r/rstudio/r-base/tags?page=1&name=4.3.3) for the current list of containers.

## [`r-lib/rig`](https://github.com/r-lib/rig#id-container)

Some of these containers use the same R builds as `rstudio/r-docker`.

Advantages:

-   Many Linux Distributions, currently all supported versions of Ubuntu, Debian, Fedora and OpenSUSE.
-   Extensively tested. These Ubuntu (20.04 `linux/amd64` currently) builds are used on [Posit Cloud](https://posit.cloud/), [shinyapps.io](https://shinyapps.io/), and the [`r-lib/actions/setup-r`](https://github.com/r-lib/actions/tree/v2-branch/setup-r) GitHub Action also installs these on Linux.
-   They come with [rig](https://github.com/r-lib/rig), to be able to add more R versions easily.
-   They come with [pak](https://github.com/r-lib/pak), to be able to install R packages easily, including automatic system dependency installation.
-   They are availbale for `linux/amd64` and `linux/arm64` architectures.
-   The `linux/amd64` Ubunntu, Deian and OpenSUSE containers are set up to use Posit Public Package Manager to install binary builds of R packages.
-   The `ghcr.io/r-lib/rig/multi` container comes with the latest versions of the six last R minor branches, including R-next and R-devel, preinstalled.

List of Docker images at the time of writing:

| Tag                                  | Description                       |
|--------------------------------------|-----------------------------------|
| `ghcr.io/r-lib/rig/multi`            | Last 6 minor R versions           |
| `ghcr.io/r-lib/rig/<distro>-release` | R-release on the specified distro |
| `ghcr.io/r-lib/rig/<distro>-devel`   | R-devel on the specified distro   |

`<distro>` can be one of `ubuntu-22.04`, `ubuntu-20.04`, `debian-12`, `debian-11`, `debian-10`, `fedora-39`, `fedora-38`, `opensuse-15.5`, `opensuse-15.4`.

See the current list of containers at the [GitHub repository](https://github.com/r-lib/rig#all-containers).

## [`r-hub/r-minimal`](https://github.com/r-hub/r-minimal)

Minimal containers on Alpine Linux. These containers have a very minimal R installation, and they are aimed for cloud deployments and serverless apps.

Advantages:

-   Very small image size. The current R 4.3.3 `linux/amd64` container is 20.8 MB compressed and 35.7 MB uncompressed.
-   They are availbale for `linux/amd64` and `linux/arm64` architectures.
-   They support the last four minor R releases, and R-next and R-devel.
-   They come with tools to help with package and system dependency installation and cleanup.

List of images at the time of writing

| Tag                                       | Description                            |
|-------------------------------------|-----------------------------------|
| `ghcr.io/r-hub/r-minimal/r-minimal:devel` | R-devel                                |
| `ghcr.io/r-hub/r-minimal/r-minimal:next`  | Next version of R, typically R-patched |
| `ghcr.io/r-hub/r-minimal/r-minimal:x.y.z` | R `x.y.z`                              |
| `ghcr.io/r-hub/r-minimal/r-minimal:x.y`   | Last release of the `x.y` branch       |

See the current list of containers at the [GitHub repository](https://github.com/r-hub/r-minimal#supported-r-versions).

## [`r-hub/containers`](https://github.com/r-hub/containers)

Many of them are set up similarly to the Linux systems CRAN uses for [regular](https://cran.r-project.org/web/checks/check_flavors.html) and [extra](https://cran.r-project.org/web/checks/check_issue_kinds.html) package checks.

Advantages:

-   They are built daily, with the most recent R-devel.
-   They come with [pak](https://github.com/r-lib/pak), to be able to install R packages easily, including automatic system dependency installation.
-   Most containers are set up to use package binaries from [`r-hub/repos`](https://github.com/r-hub/repos).

List of containers at the time of writing:

| Tag                                   | Description                                                                          |
|-------------------------------|-----------------------------------------|
| `ghcr.io/r-hub/containers/atlas`      | Tests with alternative BLAS/LAPACK implementations                                   |
| `ghcr.io/r-hub/containers/centos7`    | Last 5 minor releases, R-next, R-devel on CentOS 7                                   |
| `ghcr.io/r-hub/containers/clang-asan` | Tests of memory access errors using AddressSanitizer or Undefined Behavior Sanitizer |
| `ghcr.io/r-hub/containers/clang16`    | Checks with Clang 16.x.y                                                             |
| `ghcr.io/r-hub/containers/clang17`    | Checks with Clang 17.x.y                                                             |
| `ghcr.io/r-hub/containers/clang18`    | Checks with Clang 18.x.y                                                             |
| `ghcr.io/r-hub/containers/donttest`   | Tests including `\donttest` examples                                                 |
| `ghcr.io/r-hub/containers/gcc13`      | Checks with GCC 13.x                                                                 |
| `ghcr.io/r-hub/containers/intel`      | Checks with Intel oneAPI 2023.x compilers                                            |
| `ghcr.io/r-hub/containers/mkl`        | Tests with alternative BLAS/LAPACK implementations                                   |
| `ghcr.io/r-hub/containers/nold`       | Tests without long double                                                            |
| `ghcr.io/r-hub/containers/nosuggests` | Tests without suggested packages                                                     |
| `ghcr.io/r-hub/containers/valgrind`   | Tests of memory access errors using valgrind                                         |

See the [current list of containers](https://r-hub.github.io/containers/).

## [r-hub/evercran\`](https://github.com/r-hub/evercran)

Includes containers for all R versions ever released, including very old and very-very old versions.

Advantages:

-   Supports all R versions, starting from R 0.0 (alpha-test) to the latest release.
-   Every container is set up to use an appropriate daily snapshot of CRAN.
-   Older R versions use a similarly old Debian distro, so system dependencies work better.
-   Newer R versions are available for `linux/amd64` and `linux/arm64` platforms. (Containers before R 3.0.0 use `linux/i386`.)

List of containers at the time of writing:

| Tag                              | Description                       |
|----------------------------------|-----------------------------------|
| `ghcr.io/r-hub/evercran/<x.y.z>` | Container with R `x.y.z`          |
| `ghcr.io/r-hub/evercran/pre`     | All R versions from 0.0 to 0.16.1 |
| `ghcr.io/r-hub/evercran/0.x`     | R 0.49 -- R 1.0.0                 |
| `ghcr.io/r-hub/evercran/1.x`     | R 1.0.0 -- R 1.9.1                |
| `ghcr.io/r-hub/evercran/2.x`     | R 2.0.0 -- R 2.15.3               |

`<x.y.z>` can be any released R version from `0.0` to the latest release (currently `4.3.3`).

See the current list of containers on the [GitHub page](https://github.com/r-hub/evercran#containers-with-multiple-r-versions).

## Links

-   [The Rocker Project](https://rocker-project.org/): Docker Containers for the R Environment

