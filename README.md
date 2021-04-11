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
* `beta_arr = beta_gen(iml,masks)`
   * iml &#8594; Target L channel. 
   * `<masks = {targetFaceCut, targetEyeCut, targetLipCut}>`;  

> Face Highlight Transfer 
* `FaceL_HighLight = highlight_transfer(targetFaceCut, l2Ref, l2Target, beta_arr)`
  * l2Ref &#8594; L channel of the warped Reference image. 
  * l2Target &#8594; L channel of the target image. 
  * beta_arr &#8594; Output of beta array generation. 

> Color Transfer
* `[FaceColora, FaceColorb] = color_transfer(alphaBlenda, targetFaceCut, targetcolora, targetcolorb, refcolora, refcolorb)`
    * alphaBlenda &#8594; hyperparameter in color blending (generally 0.8)
    * targetcolora &#8594; 'a' channel of target. 
    * targetcolorb &#8594; 'b' channel of target.
    * targetFaceCut &#8594; Face cut Mask of target.
    * refcolora &#8594; 'a' channel of warped reference.
    * refcolorb &#8594; 'b' channel of warped reference.

> Lip Makeup 
* `resultant = lip_makeup(targetLipCut, reflipmaskw, targetlipmask)`
    * targetLipCut &#8594; Mask of Lip region of the  target. 
    * reflipmaskw &#8594; RGB image of the warped reference image.
    * targetlipmask &#8594; RGB image of the target image.

> Merge Layers
* ``
