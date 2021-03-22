Create PEcAn Docker Development Environment on OpenStack Server
================

**Tombstone** is a private cloud of Cyverse’s, which has compute nodes
(hardware) at UITS.

**OpenStack** is run on these compute nodes; OpenStack is way of
creating virtual machines (i.e., servers).

**Exosphere** is a way to access a bunch of OpenStack clouds and manage
virtual machines on those clouds. (note: Exosphere is optional to use
here, it is just used to launch virtual machines)

Our OpenStack cloud is called “tombstone-cloud”, we are working on
project called “cals” and we are creating a new virtual machine here.

Additional notes for running on HPC are here:
<https://hackmd.io/4fZ0EEYgQ06Jf-TTFTliUg>

### Set up OpenStack account (one time only)

  - Get OpenStack credentials for cloud (Julian for Tombstone)
  - Access Exosphere interface. Either
      - [Use the Exosphere Web Portal](https://try.exosphere.app/) OR
      - [Download and install on your
        computer](https://try.exosphere.app/packages/)
  - In Exosphere, add new OpenStack Project
  - Either:
      - Enter openrc and password from
        [stache](https://stache.arizona.edu/) OR
      - Enter credentials
          - keystone auth url:
            <https://tombstone-cloud.cyverse.org:5000/v3>
          - user domain: cso
          - username (in stache)
          - password (in stache)
  - Our group is using OpenStack cloud called tombstone, select check
    box for “cals – CALS Project” and hit “Choose”
  - If you hit “Remove Project”, just repeat these instructions to get
    it back

### Set up new server

  - Click “Create” and then “Server”
  - Choose a descriptive name for your server
  - Choose image “Ubuntu-18.0.4.raw”
  - Choose size “medium2” (2-4 CPUs, 8-16 GB ram)
  - Under “Choose a root disk size”, select ‘Custom disk size’, choose
    at least 100 GB
  - If you have had an OpenStack ssh keypair created, at this step under
    “Advanced Options”, select “Show” and add that
  - Hit “Create”
  - The new virtual machine should show up in list of servers on
    Tombstone as building
  - Once the server is created, lock it immediately so it can’t be
    changed (accidentally or not) by clicking on server name and select
    “Lock” under “Server Actions”
  - Suspend when not using
  - After a few minutes it will be ready to use

### Access your new server

  - Get into: `ssh exouser@[ip address]`
  - Enter exouser password that you can find in the Exosphere UI under
    ‘show password’
  - To keep the server running even while closed, use tmux (note: can’t
    copy and paste from tmux terminal while using iTerm2)
      - Set up tmux session with `tmux`
      - View all tmux sessions with `tmux ls`
      - Use existing tmux session with `tmux a -t [number]`

#### \[Optional\] create your own user

    sudo adduser [username]
    sudo usermod -aG sudo [username] # add to sudoers

#### \[Optional\] Generate an ssh keypair to login from your own computer

This will make it easier to connect to your virtual machine from the
terminal on your own computer.

    ssh keygen -f [ip addresss]
    # passcode not required

Or use the handy PEcAn script that sets up `.ssh/config` as well

``` sh
~/pecan/scripts/sshkey.sh
```

Add the public key to your server using the Exosphere interface.

    # sudo apt install xclip 
    xclip < ~/.ssh/[ip address].pub

In Exosphere:

  - Select your server
  - Select ‘Server Dashboard’
  - Select ‘Accounts’
  - Select your account
  - Select ‘Add Public Key’
  - paste contents of \~/.ssh/\[ip address\].pub

### Install Docker and Docker Compose

  - Docker
    <https://docs.docker.com/engine/install/ubuntu/#installation-methods>
  - Docker Compose <https://docs.docker.com/compose/install/>

<!-- end list -->

``` sh
sudo apt update && sudo apt upgrade
sudo apt install docker docker-compose
```

Also described in [PEcAn
DEV-INTRO.md](https://github.com/PecanProject/pecan/blob/develop/DEV-INTRO.md)

### Get dev environment set up

  - Fork [the Pecan repo](https://github.com/PecanProject/pecan) and
    `git clone` to get copy on server
  - Follow instructions in
    [DEV-INTRO](https://github.com/PecanProject/pecan/blob/develop/DEV-INTRO.md)
    to set up Docker stack
      - You will know this works by running the `docker.sipnet.xml` and
        results show up in `/data/tests/sipnet`

### Open web user interfaces

To access web interfaces including RStudio, PEcAn, BETYdb, and Shiny
Apps, you need to open an SSH tunnel from the virtual machine to your
own computer.

  - Have to add public key to server
  - Open an ssh tunnel
      - `ssh -L 127.0.0.1:8000:127.0.0.1:8000 exouser@128.196.65.110`
      - Enter password
  - Open your browser to <http://localhost:8000/>

### ssh into database

  - Install Postgres client: `sudo apt install postgresql-client`
  - Create an ssh keypair `./pecan/scripts/sshkey.sh`
  - Specify host port by adding a line `Port 1657` in `.ssh/config`
    under the welsch server information
      - (this is specific to CyVerse OpenStack, for security it does not
        use default ssh port 22)
  - Mount welsch postgres to port 5433: `ssh -Nf -L 5433:localhost:5432
    welsch.cyverse.org`

????:

  - Find database IP address from within server by doing `docker
    container inspect pecan_postgres_1 | grep \"IPAddress\" | grep -v
    \"\"`
  - On local command line, run `ssh -N -L 127.0.0.1:5433:[database IP
    address]:5432 exouser@[server number]` and enter password
  - In a new window, open postgres with `psql -h 127.0.0.1 -p 5433 -U
    bety bety`
  - Can do this simultaneously while enabling interfaces with `ssh -N
    -L 127.0.0.1:5433:[database IP address]:5432
    -L 127.0.0.1:8000:127.0.0.1:8000 exouser@[server number]`

### Rebuild Docker containers

### ssh into HPC

    ~/pecan/scripts/sshkey.sh

host name: `hpc.arizona.edu` username: your UA login

#### connect to Welsch Bety
