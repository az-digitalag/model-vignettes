# ED2 Model on HPC notes/documentation

Any HPC specific questions can be directed to the HPC team email list:  
hpc-consult-request@list.arizona.edu

The primary difference the HPC will have compared to what might be considered a standard ED2 model launch is that docker is not available on the HPC environment. Instead Singularity is available and for the most part can accomplish the same goals.

See [Singularity docs](https://sylabs.io/docs/) for more information on the similarities/differences and cross-over between the two.

1) First thing is to simply ssh into the HPC, like so:

    ```bash
    ssh <your-username>@hpc.arizona.edu
    ```

    As per the directions, access Ocelote: 
    
    ```bash
    ocelote
    ```
    
    Alternatively you could also make use of the 'Open OnDemand' interface located [here](https://ood.hpc.arizona.edu). Select Files tab, then Home Directory. Then click on "Open in terminal" button, selecting Ocelote. 
    
    Documentation, shell access, and job submission forms may be found here among other useful interfacing tools.

2) Secondly most modules (such as Singularity) are ready to go by default on the HPC. The following command will load Singularity: 

    ```bash
    module load singularity
    ```

    Use `module avail` to see the full list of available modules. 

3) Pull the image down from Docker Hub: [pecan/model-ed2-2.2.0](https://hub.docker.com/r/pecan/model-ed2-2.2.0). This can be done with the following Singularity command

    ```bash
    singularity pull pecan-model-ed2.sif docker://pecan/model-ed2-2.2.0:develop
    ```
    
    When this has finished there should be a SIF file called `pecan-model-ed2.sif` for the Singularity container which will be used later. 

4) This done the next step would be to download some site data to run the model on. For the purposes of doing a test run the set found [here](https://pecanproject.github.io/pecan-documentation/master/workflow-modules.html#install-data) was used.
    Here this set uses curl which is a module that may need to be loaded just as Singularity was before: 
    
    ```bash
    module load curl
    ```

    Get the sites data: 
    
    ```bash
    curl -o sites.tgz http://isda.ncsa.illinois.edu/~kooper/EBI/sites.tgz
    tar zxf sites.tgz
    sed -i -e "s#/home/kooper/Projects/EBI#${PWD}#" sites/*/ED_MET_DRIVER_HEADER
    rm sites.tgz
    ```

    Then get inputs data:  
    
    ```bash
    curl -o inputs.tgz http://isda.ncsa.illinois.edu/~kooper/EBI/inputs.tgz
    tar zxf inputs.tgz
    rm inputs.tgz
    ```

5) From here the two final things needed are the `config.xml` and the ED2IN files (for the purposes of this test run the ones used were [here](https://pecanproject.github.io/pecan-documentation/master/workflow-modules.html#inst-ed2), scroll down until you see ED 2.2 r82, focus on the second part where it says to perform a test run)

    Get ED2IN files: 
    
    ```bash
    mkdir testrun.ed.r82
    cd testrun.ed.r82
    curl -o ED2IN http://isda.ncsa.illinois.edu/~kooper/EBI/ED2IN.r82
    sed -i -e "s#\$HOME#$HOME#" ED2IN
    ```
    
    Get config file:  
    
    ```bash
    curl -o config.xml  http://isda.ncsa.illinois.edu/~kooper/EBI/config.r82.xml
    ```

6) All this done there should simply be left to run the container and mount everything onto it correctly in a highly convoluted manner, like so:  

    ```bash
    singularity run -B ~/<path-sites-folder>:/data -B ~/<path-to-inputs-folder>:/data/inputs -B ~/<path-to-config.xml>:/work/config.xml -B ~/ED2IN:/work/ED2IN ~/<path-ed2-singularity-image-file> /bin/bash
    ```
    
    If you download all these files to your home directory, it will look like this with the correct paths, for example: 
    
    ```bash
    singularity run -B ~/sites/ -B ~/ed_inputs/ -B testrun.ed.r82/config.xml -B testrun.ed.r82/ED2IN ~/pecan-model-ed2.sif /bin/bash
    ```
    
    `-B` is the singularity flag for mounting to containers
    
    After this command is executed (given there are no errors of course) you will be within the container shell. There may be different visual representations the console will give for being in the container and could seem almost as if there is no difference. To check that you are within type out `ed2` and press tab to autocomplete the command. `ed2.git` should be what it completes to. Or simply trying to execute the `ed2.git` command should not return a `bash:command ed2.git is not recognized` error.

7) At this point the `ed2.git` command should be executed with the `-s` flag to stop anything relying on mpi.

8) As far as fully implementing/running the model as a whole (as in outside of a small test run) see this documentation for either calling up an [interactive HPC session](https://public.confluence.arizona.edu/display/UAHPC/Running+Jobs#RunningJobs-6.InteractiveJobs) or simply [submitting an HPC job](https://public.confluence.arizona.edu/display/UAHPC/Running+Jobs). 
