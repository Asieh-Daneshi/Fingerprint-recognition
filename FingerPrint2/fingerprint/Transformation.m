function [ NewFeatureMat ] = Transformation( ...
    FeatureMat, RefIndex )

    xRef=FeatureMat(RefIndex,1);
    yRef=FeatureMat(RefIndex,2);
    thRef=FeatureMat(RefIndex,3);

    NewFeatureMat=zeros(1,4);
    R=[cosd(thRef) sind(thRef) 0; ...
       -sind(thRef) cosd(thRef) 0; ...
       0 0 1];
    
    [col,~]=size(FeatureMat);
    for i=1:col
        Temp=R*[FeatureMat(i,1)-xRef; ...
                FeatureMat(i,2)-yRef; ...
                FeatureMat(i,3)-thRef];
                     
        NewFeatureMat(i,1)=Temp(1);
        NewFeatureMat(i,2)=Temp(2);
        NewFeatureMat(i,3)=Temp(3);
        NewFeatureMat(i,4)=FeatureMat(i,4);
        
    end;

end

