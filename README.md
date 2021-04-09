# makeup_transfer

# Setup
Download and extract following matlab toolbox - 
https://pdollar.github.io/toolbox/

Edit the path of the toolbox in Code_Final/GetLandMarks.m
addpath(genpath('../toolbox-master'))

# Run Code
Start with Run_Code.m


* After completing layer decomposition add these: 
  * addpath('./PoissonLaplaceEditingDemo'); 
  * start from "SEPARATE LIGHTNESS INTO LARGE SCALE AND DETAIL LAYERS" section of "test_stanford_mod.m".
  * give suitable value to "outputPath".
