## General info
This repository contains all dockerfiles useful to build the docker images employed both for development purposes and for deploying applications.


## Docker images structure

Our docker images are included inside the folder [`code/dockerfile_images`](https://github.com/icub-tech-iit/code/tree/feat/doc/dockerfile_images), with the following structure:
```
code
    |_ dockerfile_images
                        |_ basic
                                |_ superbuild
                                |_ ubuntu:focal
                                ...
                        |_ demos
                                |_ blender
                                |_ funny-things
                                ...
```

where
- `basic`: contains images mostly used as base for more complex images
- `demos`: contains more complex images related to specific applications

:warning: **Important note**: the **name** of the image folder is important, as our [building pipeline](https://github.com/icub-tech-iit/code/tree/feat/doc/.github/workflows#docker-build-pipeline) uses it to **tag the image**. Thus it must be lower case, as docker does not support upper case in the image name.

Each folder typically includes:
- a **`Dockerfile`** used respectively to build a `sources` image. The `sources` is an image used for development, where we keep the project repositories
- a **`Dockerfile4Production`** (optional), used to build a `binaries` image.  The `binaries` is an image built starting from sources, but only copying required libraries, binaries etc. from it and thus lighter than the `sources`.
- a **`conf_build.ini`**, including the arguments to build the image.
- an **`entrypoint.sh`** (optional), which usually includes definition of the environment. This file is typically copied inside the image (e.g. see [here](https://github.com/icub-tech-iit/code/blob/e17bb0d36471233bfd2d6baa69cf238f103ee904/dockerfile_images/basic/superbuild/Dockerfile#L79)) and then executed when the container is started (e.g. see [here](https://github.com/icub-tech-iit/code/blob/e17bb0d36471233bfd2d6baa69cf238f103ee904/dockerfile_images/basic/superbuild/Dockerfile#L102)). 

### The conf build file

The `conf_build` is structured as follows:
```
[sources]
START_IMG=icubteamcode/ubuntu:focal
$(cat DATE_TAG)
release={{steps.get_version.outputs.VERSION}}
sbtag={{matrix.tag}}

[binaries]
SOURCE_IMG=icubteamcode/{{matrix.apps}}:{{steps.get_version.outputs.VERSION}}{{steps.get_version.outputs.TAG}}_sources
START_IMG=icubteamcode/ubuntu:focal

[tag]
icubteamcode/{{matrix.apps}}:{{steps.get_version.outputs.VERSION}}{{steps.get_version.outputs.TAG}}

[superbuild]

[children]
grasp-the-ball
open-face
supervise-calib
superbuild-google
funny-things

[demos]
yarpBasicDeploy
robotBaseStartup
```

:warning: **Important note**: for **custom** images, the conf build file keeps the same structure, but some sections / placeholders are missing. In particular, the following is an example of a conf build looks like:
```
[sources]
START_IMG=icubteamcode/ubuntu:focal
$(cat DATE_TAG)

[binaries]
SOURCE_IMG=icubteamcode/{{matrix.apps}}:{{steps.get_version.outputs.VERSION}}_sources
START_IMG=icubteamcode/ubuntu:focal

[tag]
icubteamcode/{{matrix.apps}}:{{steps.get_version.outputs.VERSION}}

[children]
grasp-the-ball-gazebo
```

The file contains the following sections:

#### `[tag]` (required)
This indicates the `--tag` argument for the docker build and docker push instructions. **It does not include the `_sources` or `_binaries` tag**.

This section **must always be**:
- `icubteamcode/{{matrix.apps}}:{{steps.get_version.outputs.VERSION}}{{steps.get_version.outputs.TAG}}` for images **based on `robotology-superbuild`**  
- `icubteamcode/{{matrix.apps}}:{{steps.get_version.outputs.VERSION}}` for **custom images**.

In particular:
- the tag always starts with `icubteamcode`, since this is the name of our repository on `DockerHub`; 
- the parameters defined in curly brackets are placeholders for variables filled by the [`onCodeChanges`](https://github.com/icub-tech-iit/code/blob/master/.github/workflows/onCodeChanges.yml) GA action and replaced by the GA action itself. More specifically:
  - `{{matrix.apps}}`: the corresponding variable is filled [here](https://github.com/icub-tech-iit/code/blob/60f35af272decec9b0ab0f1c7ea016bffd8e1690/.github/workflows/onCodeChanges.yml#L255-L256) with the name of the image to be built (i.e. the folder name). We then replace the placeholder with the actual value [here](https://github.com/icub-tech-iit/code/blob/60f35af272decec9b0ab0f1c7ea016bffd8e1690/.github/workflows/onCodeChanges.yml#L336);
  - `{{steps.get_version.outputs.VERSION}}`: the corresponding variable is filled [here](https://github.com/icub-tech-iit/code/blob/60f35af272decec9b0ab0f1c7ea016bffd8e1690/.github/workflows/onCodeChanges.yml#L295) with the last release of code. We then replace the placeholder with the actual value [here](https://github.com/icub-tech-iit/code/blob/60f35af272decec9b0ab0f1c7ea016bffd8e1690/.github/workflows/onCodeChanges.yml#L337);
  - `{{steps.get_version.outputs.TAG}}`: the corresponding variable is filled [here](https://github.com/icub-tech-iit/code/blob/60f35af272decec9b0ab0f1c7ea016bffd8e1690/.github/workflows/onCodeChanges.yml#L296-L301) with the project tag (e.g. `stable`, `unstable` or empty)

Note: check [this](https://github.com/icub-tech-iit/code/tree/feat/doc/.github/workflows#naming-convention-for-docker-images) for more details on the image naming convention.

#### `[sources]` (optional)
This indicates that the image will build a `_sources` image. This **should not be included** if a `Dockerfile` **is not provided**.
Beneath this tag is a list of the arguments to be used when running the `docker build` instruction.

This section **must always be** as follows:
- `START_IMG=<image_name>` where <image_name> bust be replaced with the name of the image used as a base to build the current one
- `$(cat DATE_TAG)` is used to set the date of building

If you also need to recompile `robotology-superbuild`, the following additional parameters are also **required**:
- `release={{steps.get_version.outputs.VERSION}}` is the last release of code and is replaced with the same logic described [above](https://github.com/icub-tech-iit/code/tree/feat/doc/dockerfile_images#tag-required) 
- `sbtag={{matrix.tag}}` is the superbuild project tag and is replaced with the same logic described [above](https://github.com/icub-tech-iit/code/tree/feat/doc/dockerfile_images#tag-required) (**only for images based on `robotology-superbuild`**)

#### `[binaries]` (optional)
This indicates that the image will build a `_binaries` image. This **should not be included** if a `Dockerfile4Production` **is not provided**. 
Beneath this tag is a list of arguments to be used when running the `docker build` instruction.

This section **must always be** as follows:
- `START_IMG=<image_name>` has to include the name of the image we use as a base to build the current one;
- `SOURCE_IMG=<source_image_name>` is the `sources` image we use to start build the `binaries` image. This must be the value specified below the [tag](https://github.com/icub-tech-iit/code/tree/feat/doc/dockerfile_images#tag-required) section followed by `_sources`. 

#### `[superbuild]` (optional)
This indicates that this image compiles `robotology-superbuild` in its `Dockerfile`. This allows the github action to correctly tag the image with the superbuild release/master version. This **tag should not be included for custom images**.

#### `[children]` (optional)
This indicates that some images will depend on this image. Beneath this tag is a list of the images that should be rebuilt when changes are done to this image.

#### `[demos]` (optional)
This indicates that some demos will depend on this image. Beneath this tag is a list of demos that will be tested when changes are done to this image.
