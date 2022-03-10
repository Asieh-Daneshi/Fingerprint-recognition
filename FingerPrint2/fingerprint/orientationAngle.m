function [ Angle ] = orientationAngle( im,i,j,value )

    Angle=0;
    if(im(i+1,j)==value)
        Angle=225;
    elseif(im(i+1,j-1)==value)
        Angle=135;
    elseif(im(i,j-1)==value)
        Angle=180;
    elseif(im(i-1,j-1)==value)
        Angle=135;
    elseif(im(i-1,j)==value)
        Angle=90;
    elseif(im(i-1,j+1)==value)
        Angle=45;
    elseif(im(i,j+1)==value)
        Angle=0;
    elseif(im(i+1,j+1)==value)
        Angle=315;
    end;

end

