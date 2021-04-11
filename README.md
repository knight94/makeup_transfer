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


> Beta array generation
* `<beta_arr = beta_gen(iml,masks)>' 
   * iml is the Subject image L channel. 
   * `<masks = {targetFaceCut, targetEyeCut, targetLipCut}>`;  

> Face Highlight Transfer 
* `<FaceL_HighLight = highlight_transfer(targetFaceCut, l2Ref, l2Target, beta_arr)>`
  * l2Ref is the Lchannel of the warped Reference image. 
  * 
