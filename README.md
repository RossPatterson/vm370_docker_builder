# VM-370
This repository is a builder for a Docker container that provides an emulated S/370 mainframe (Hercules) running VM/370 based on distributions of VM/370 Release 6, circa 1979.

# Releases
The Docker images are at https://hub.docker.com/repository/docker/rosspatterson/vm370.

See this repository's release tab for the Dockerfile build source and the VM/370 DASD files.

# History
- latest -> 1.6.8
- Version 1.6.7 adds Python and switches to the Python version of the herccontrol tool.
- Version 1.6.0 is built from the VM/370 Community Edition v1.1.2 distribution.
- Version 1.5.3 is built from the VM/370 Community Edition v1.1.0 distribution.
- Version 1.3.4 corresponds to Six Pack 1.3 Beta 3.

See changelog.txt for full version history

# Links
- VM/370 SixPack distribution - http://www.smrcc.org.uk/members/g4ugm/VM370.htm
- VM/370 Community Edition distribution - http://vm370.org/vm
- Hercules home page - http://www.hercules-390.eu/
- Hercules 4.0 Fork - https://github.com/SDL-Hercules-390/hyperion
- Discussions on VM/370 are done here - https://groups.io/g/h390-vm

# To use this repo
1. Prepare Docker:
   1. If you don't already have a Docker account, create one at https://www.docker.com.
   1. Create a "vm370" Docker repository.
   1. Create a Personal Access Token at https://app.docker.com/settings/personal-access-tokens with "Read & Write" permission.  **NOTE:** Docker only shows you the token when you generate it.  You can never see its value again, so copy it immediately and save it.
1. Fork this repository in GitHub.
1. Create the following action secrets in your fork:
   1. `DOCKER_USERNAME` - your Docker userid.
   1. `DOCKER_PASSWORD` - your Docker personal access token.
1. Go to the Actions tab on your fork and enable workflows.
1. Make a change, commit it, and push it to your fork.  The `dockertest.yml/DockerTest` GitHub workflow job will test the container build.
1. Tag the revision as `vn.n.n` (_e.g._, "v1.5.4") and push the tag to GitHub.  The `dockerpush.yml/DockerPublish` GitHub workflow job will push the container image to Docker.

# To update the Docker image

1. Clone this repository to your disk.
1. Download the VM/370 distribution you want to build.
1. Delete the old DASD base and shadow files from `disks/` and `disks/shadows/`.
1. Add the new DASD files to `disks/`.
1. Review the following files and make any necessary changes:
   1. `build.sh` - shell script to build the Docker container.
   1. `cleandisks.conf` - Hercules configuration for removing shadow files.
   1. `hercules.conf` - main Hercules configuration.
   1. `github/workflows/*.yml` - GitHub workflow files.
   1. `Dockerfile` - the main Docker control file.
1. Commit the changes and push to GitHub.
1. Wait for the `dockertest.yml/DockerTest` GitHub workflow job to run and verify its success.
1. Tag the revision as `vn.n.n` (_e.g._, "v1.5.4") and push the tag to GitHub.  **NOTE:** The leading "v" is necessary - it triggers the push to Docker.
1. Wait for the `dockerpush.yml/DockerPublish` GitHub workflow job to run.
1. Verify that your Docker userid has the new version of the container image.
1. When you're happy with the container image, consider updating the `latest` tag to point to it:
   1. Start your Docker engine (_e.g._, Docker desktop).
   1. `docker pull userid/vm370:x.y.z`
   1. `docker tag  userid/vm370:x.y.z userid/vm370:latest`
   1. `docker push userid/vm370:latest`
   1. Stop your Docker engine.
1. When you're ready to make the CMS370-BREXX and CMS370-GCCLIB build systems use the container image, update the `builder` tag to point to it:
   1. Start your Docker engine (_e.g._, Docker desktop).
   1. `docker pull userid/vm370:x.y.z`
   1. `docker tag  userid/vm370:x.y.z userid/vm370:builder`
   1. `docker push userid/vm370:builder`
   1. Stop your Docker engine.
   1. Go to your CMS370-BREXX and CMS370-GCCLIB repositories, and review the following files and make any necessary changes:
      1. `cmsbuild.sh` - shell script to build the code.
      1. `github/workflows/build.yml` - GitHub workflow files.
