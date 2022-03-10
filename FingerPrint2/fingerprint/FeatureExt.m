function [ FeatureMatrix ] = FeatureExt( im,value )
    [row,col]=size(im);
    FeatureMatrix=zeros(1,4);
    count=0;
    for i=2:row-1
        for j=2:col-1        
            if(im(i,j)==1)   
%                 disp(im(i,j));
                crossNumber=CrossNumber(im,i,j);

                if(crossNumber==1) && (NonMarginalPoint(j,i,im)==true)
                    count=count+1;
                    FeatureMatrix(count,1)=j; % x coordinate
                    FeatureMatrix(count,2)=i; % y coordinate
                    FeatureMatrix(count,3)= ...
                        orientationAngle(im,i,j,1); % orientation angle
                    FeatureMatrix(count,4)=value; % type of minutiae
                end;
            end;
        end;
    end;
end

