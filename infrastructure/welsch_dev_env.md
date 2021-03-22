Development Environment for Welsch PEcAn
================

This should all happen in [Welsch](http://welsch.cyverse.org:8787/).

### Specify path for compiled files

  - In home directory, create new folder for compiled files, e.g.,
    R\_Libs
  - Open up .Rprofile file
  - Add another library path, e.g., `.libPaths("~/R_libs")`

### Get source code

  - Fork [main PEcAn repo](https://github.com/pecanproject/pecan)
  - Clone this into Welsch home directory
  - Always work off of the develop branch to get most recent changes
  - Set up upstream remote as main PEcAn repo
  - Keep develop updated by doing the following:
      - `git fetch upstream`
      - `git merge upstream/develop`
      - `git push origin develop`

### Compile source code

  - Navigate into source code folder, e.g., `cd pecan/`
  - Run `make install`, which will take a while
  - This generates compiled PEcAn packages in compiled files folder,
    e.g., R\_Libs
  - Update compiled files by running `make install`

### Change and test source code

  - Create branch off of develop for new feature, e.g., `git checkout -b
    new_feature develop`
  - Make and save changes to source files
  - Restart R session and load in just changed package(s), e.g.,
    `library(PEcAn.db)`
  - Look at changed functions, they should not have changes yet
  - Do `install` on all affected PEcAn packages, e.g.,
    `devtools::install("pecan/base/db")` (can’t do `load_all` because
    other PEcAn packages won’t see those loaded libraries)
  - Check that changes show up in function(s) as desired
  - Test that changes have desired effect

### Add changes to PEcAn develop

  - Once changes are working, run `make document` and `make` on source
    code to compile
  - Test changes are working once again
  - Commit and push these changes to your fork and open up a PR in the
    main PEcAn repo

## Appendix

### Installing new R packages

The necessary R packages should already be installed on Welsch. Follow
these instructions below to install additional packages.

  - Create a folder called `R_Libs` in your home directory

![enter image description
here](https://files.osf.io/v1/resources/a4p9n/providers/osfstorage/5e4ab6d73e86a8023d6e6024?mode=render)

  - Open up the .Rprofile file that should also be in your home
    directory. If there is no file there, create a new text file in home
    directory called .Rprofile

![enter image description
here](https://files.osf.io/v1/resources/a4p9n/providers/osfstorage/5e4ab6463e86a8023f6e67bd?mode=render)

  - Add a new line to this .Rprofile file: `.libPaths("~/R_Libs")`
  - Test that this worked by executing `.libPaths()` in the console; the
    first object should be a path to the new folder
  - Install R packages here by running `install.packages("pkg_name", lib
    = "~/R_Libs")` in the console

### Installing R packages from GitHub

Some additional packages are only available from GitHub. To install
these, the package ‘devtools’ needs to be installed and loaded using
`install.packages("devtools")` and `library(devtools)`. Then the
function install\_github() can be used.

  - As an example, run
    `devtools::install_github("fellmk/PostJAGS/postjags")` and
    `library(postjags)` to obtain a small package that provides
    functions for summarizing and restarting JAGS and OpenBUGS models
