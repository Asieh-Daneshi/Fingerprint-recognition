function [ FeatureMat ] = TotalFeatureExt( original_im )
    original_im=im2bw(original_im);

    im=original_im;
    im=bwmorph(im,'thin');
    FeatureMatrix1=FeatureExt(im,3);
    
    imc=imcomplement(original_im);
    imc=bwmorph(imc,'thin');
    FeatureMatrix=FeatureExt(imc,1);

    FeatureMat=[FeatureMatrix1;FeatureMatrix2];
end

