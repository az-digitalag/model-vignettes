Welsch Content and Organization
================

  - Welsch server is on OpenStack, which provides resources needed to
    generate a virtual machine of desired size. We get this service for
    free through CyVerse, and they also set up OpenStack domain for
    this.
  - On the server, there are a bunch of Docker containers. Detailed
    information is available in [the PEcAn documentation on
    Docker](https://pecanproject.github.io/pecan-documentation/develop/docker-index.html).
  - What the containers are is specified in a docker-compose.yml, which
    is based on the general PEcAn one at
    <https://github.com/PecanProject/pecan/blob/develop/docker-compose.yml>.
  - There are Docker images/containers for Postgres, BETYdb, and
    RStudio, as well as portainer, minio, traefik, and Thredds. Three
    PEcAn models (sipnet, ED2, MAESPA) also have images/containers.
  - A Docker image/container for RStudio is also available on Welsch
    with persistent, named volumes for users data (/home) and general
    purpose use (/data)
  - Internally routed container ports are shown under `labels` (for
    traefik) and external ports are listed under `ports`.
  - The monitor container controls how each model container is run.
  - In the .yml, network is used for the name of the virtual network (in
    this case, `pecan`) to allow running containers to more easily
    communicate with one another.
  - The volumes section contains the named volumes for persistent data
    to be mounted for some of the containers.
