Working With Welsch’s PEcAn BETYdb Database
================

# BETYdb at the University of Arizona

URL: <http://welsch.cyverse.org:8000/bety/>

### **Navicat: set up Welsch BETYdb connection**

### First time only

1.  Get CyVerse account by requesting one on the [CyVerse
    website](https://user.cyverse.org/services/mine)
2.  Set up Navicat connection
    1.  [Download Navicat
        Premium](https://www.navicat.com/en/download/navicat-premium)
    2.  Click “Connection” button in upper left corner and select
        “PostgreSQL”
    3.  Click on “General” tab and in “Connection Name” field add a
        descriptive name, e.g., WelschBetyDB
    4.  Click on “SSH” tab, enter the following, and then click Save:
          - Host: welsch.cyverse.org
          - Port: 1657
          - User Name: CyVerse account user name
          - Authentication Method: “Password”
          - Password: Cyverse account password

### Open connection

Double click on “localhost\_5432” in left-hand menu. Then double click
on “bety” to open.

Run and save queries using “New Query” button.

### **SSH: set up Welsch BETYdb connection**

This is all done on the command line.

### First time only

1.  Get CyVerse account by requesting one on the [CyVerse
    website](https://user.cyverse.org/services/mine)

2.  Install PostgreSQL

<!-- end list -->

    brew install postgresql

### Open SSH tunnel

The `username@welsch.cyverse.org` argument is not an email address, but
rather specifies your CyVerse account

Replace “username” with your CyVerse account username

    ssh -N -L 127.0.0.1:5433:127.0.0.1:5432 -p 1657 username@welsch.cyverse.org

An alternative option is to separate the last argument into two
arguments and include an additional flag before them

    ssh -N -L 127.0.0.1:5433:127.0.0.1:5432 -p 1657 -l username welsch.cyverse.org

Type in your CyVerse account password when prompted for a password

### Open connection

Open up another shell window and type in the following, replacing
“username” with your CyVerse account username

    psql -h 127.0.0.1 -p 5433 -U username bety

This should open up the following prompt:

    bety=>

### **Test BETYdb connection**

Type in the below and execute

    select * from sites where id = 9000000004;

This should return information for a growth chamber at the Donald
Danforth Center in St. Louis, Missouri
