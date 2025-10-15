# General info
This repository contains the Dockerfiles used to generate pre-configured images based on the [Robotology Superbuild](https://github.com/robotology/robotology-superbuild).

The main goal is to significantly **accelerate development and testing cycles** by providing ready-to-use environments.

---

## Key Features

* **Pre-built Images:** The resulting Docker images are available as packages under the **`icub-tech`** organization on GitHub.
* **Automatic Updates:** Images are automatically rebuilt under the following conditions:
    1.  Every two weeks (bi-weekly schedule).
    2.  Immediately, whenever a Dockerfile in this repository is updated.
* **Faster Iteration:** By using these images, developers can bypass lengthy compilation steps and focus directly on application logic and testing.

## Contribution and Feedback

**⚠️ This repository and its documentation are currently under active development.**

Your feedback is highly valued!

* **Bugs or Issues:** If you encounter any errors or problems, please **open a new Issue**. We are committed to resolving issues quickly.
* **Documentation or Feature Requests:** If you require additional information in the documentation or need new features (e.g., new base images, different configurations), please **open an Issue** detailing your request.

# Details

## Docker images structure

Our docker images are included inside the folder [`dockerfile_images/basic`](dockerfile_images/basic), with the following structure:
```
master
     |_ docker-deployment-images
                                |_ basic
                                        |_ superbuild
                                        |_ superbuild-icubhead-robometry
                                        ...
     |_ deprecated-images
```

where
- `basic`: contains images mostly used as base for more complex images
- `deprecated-images`: Files in deprecated-images (e.g., grasp-the-ball) contain Dockerfiles for legacy applications. They are not maintained but can serve as inspirational templates for complex image configurations.

:warning: **Important note**: the **name** of the image folder is important, as our [building pipeline](https://github.com/icub-tech-iit/docker-deployment-images/actions/workflows/devel.yml) uses it to **tag the image**. Thus it must be lower case, as docker does not support upper case in the image name.

Each folder typically includes:
- a **`Dockerfile`** used respectively to build a `sources` image. The `sources` is an image used for development, where we keep the project repositories
- a **`Dockerfile4Production`** (optional), used to build a `binaries` image.  The `binaries` is an image built starting from sources, but only copying required libraries, binaries etc. from it and thus lighter than the `sources`.
- a **`conf_build.ini`**, including the arguments to build the image.
- an **`entrypoint.sh`** (optional), which usually includes definition of the environment. This file is typically copied inside the image (e.g. see [here](https://github.com/icub-tech-iit/code/blob/e17bb0d36471233bfd2d6baa69cf238f103ee904/dockerfile_images/basic/superbuild/Dockerfile#L79)) and then executed when the container is started (e.g. see [here](https://github.com/icub-tech-iit/code/blob/e17bb0d36471233bfd2d6baa69cf238f103ee904/dockerfile_images/basic/superbuild/Dockerfile#L102)). 

### The conf build file

The `conf_build` is structured as follows:
```
[sources]
START_IMG=ubuntu:focal
$(cat DATE_TAG)
release={{steps.get_version.outputs.VERSION}}
sbtag={{matrix.tag}}

[binaries]
SOURCE_IMG={{env.DEFAULT_USER}}/{{matrix.apps}}:{{steps.get_version.outputs.VERSION}}{{steps.get_version.outputs.TAG}}_sources
START_IMG=ubuntu:focal

[tag]
{{matrix.apps}}:{{steps.get_version.outputs.VERSION}}{{steps.get_version.outputs.TAG}}

[superbuild]

[children]
superbuild-ros2

[demos]


```

:warning: **Important note**: for **custom** images, the conf build file keeps the same structure, but some sections / placeholders are missing. In particular, the following is an example of a conf build looks like:
```
[sources]
START_IMG=ubuntu:focal
$(cat DATE_TAG)

[binaries]
SOURCE_IMG={{env.DEFAULT_USER}}/{{matrix.apps}}:{{steps.get_version.outputs.VERSION}}_sources
START_IMG=ubuntu:focal

[tag]
{{matrix.apps}}:{{steps.get_version.outputs.VERSION}}

[children]
superbuild-ros2
```

The file contains the following sections:

#### `[tag]` (required)
This indicates the `--tag` argument for the docker build and docker push instructions. **It does not include the `_sources` or `_binaries` tag**.

This section **must always be**:
- `{{matrix.apps}}:{{steps.get_version.outputs.VERSION}}{{steps.get_version.outputs.TAG}}` for both images **based on `robotology-superbuild`** and **custom images**.

In particular:
- the tag does not contain any data regarding the owner of the image, since that piece of information is added using environmental variables during the step contained in the `Workflow` file depending on where the image should be pushed (specifically this is done because at this time two different images container are maintaned, i.e. `GitHub Container Registry` and `DockerHub`); 
- the parameters defined in curly brackets are placeholders for variables filled by the [`onCodeChanges`](https://github.com/icub-tech-iit/docker-deployment-images/actions/workflows/onCodeChanges.yml) GA action and replaced by the GA action itself. More specifically:
  - `{{matrix.apps}}`: the corresponding variable is filled [here](https://github.com/icub-tech-iit/docker-deployment-images/blob/f9a4572c3eed1fb317a82f70774f4f3d2519aae7/.github/workflows/onCodeChanges.yml#LL283C1-L284C5) with the name of the image to be built (i.e. the folder name). We then replace the placeholder with the actual value [here](https://github.com/icub-tech-iit/docker-deployment-images/blob/f9a4572c3eed1fb317a82f70774f4f3d2519aae7/.github/workflows/onCodeChanges.yml#L395);
  - `{{steps.get_version.outputs.VERSION}}`: the corresponding variable is filled [here](https://github.com/icub-tech-iit/docker-deployment-images/blob/f9a4572c3eed1fb317a82f70774f4f3d2519aae7/.github/workflows/onCodeChanges.yml#LL344C32-L344C32) with the last release of code. We then replace the placeholder with the actual value [here](https://github.com/icub-tech-iit/docker-deployment-images/blob/f9a4572c3eed1fb317a82f70774f4f3d2519aae7/.github/workflows/onCodeChanges.yml#L396);
  - `{{steps.get_version.outputs.TAG}}`: the corresponding variable is filled [here](https://github.com/icub-tech-iit/docker-deployment-images/blob/f9a4572c3eed1fb317a82f70774f4f3d2519aae7/.github/workflows/onCodeChanges.yml#LL345C13-L350C15) with the project tag (e.g. `stable`, `unstable` or `empty`)

Note: check [this](https://github.com/icub-tech-iit/docker-deployment-images/wiki/Docker-images#naming-convention-for-docker-images) for more details on the image naming convention.

#### `[sources]` (optional)
This indicates that the image will build a `_sources` image. This **should not be included** if a `Dockerfile` **is not provided**.
Beneath this tag is a list of the arguments to be used when running the `docker build` instruction.

This section **must always be** as follows:
- `START_IMG=<image_name>` where <image_name> bust be replaced with the name of the image used as a base to build the current one
- `$(cat DATE_TAG)` is used to set the date of building

If you also need to recompile `robotology-superbuild`, the following additional parameters are also **required**:
- `release={{steps.get_version.outputs.VERSION}}` is the last release of code and is replaced with the same logic described [above](https://github.com/icub-tech-iit/docker-deployment-images/blob/master/README.md#tag-required) 
- `sbtag={{matrix.tag}}` is the superbuild project tag and is replaced with the same logic described [above](https://github.com/icub-tech-iit/docker-deployment-images/blob/master/README.md#tag-required) (**only for images based on `robotology-superbuild`**)

#### `[binaries]` (optional)
This indicates that the image will build a `_binaries` image. This **should not be included** if a `Dockerfile4Production` **is not provided**. 
Beneath this tag is a list of arguments to be used when running the `docker build` instruction.

This section **must always be** as follows:
- `START_IMG=<image_name>` has to include the name of the image we use as a base to build the current one;
- `SOURCE_IMG=<source_image_name>` is the `sources` image we use to start build the `binaries` image. This must be the value specified below the [binaries tag](https://github.com/icub-tech-iit/docker-deployment-images/blob/f9a4572c3eed1fb317a82f70774f4f3d2519aae7/dockerfile_images/basic/superbuild/conf_build.ini#LL7C1-L7C11) section followed by `_sources`. 

#### `[superbuild]` (optional)
This indicates that this image compiles `robotology-superbuild` in its `Dockerfile`. This allows the github action to correctly tag the image with the superbuild release/master version. This **tag should not be included for custom images**.

#### `[children]` (optional)
This indicates that some images will depend on this image. Beneath this tag is a list of the images that should be rebuilt when changes are done to this image.

#### `[demos]` (optional)
This indicates that some demos will depend on this image. Beneath this tag is a list of demos that will be tested when changes are done to this image.
