function [ bool ] = NonMarginalPoint( x,y,im )
    [h,w]=size(im);
    
    %increase x -->
    bool=false;
    i=x+1;
    while(i<=w)
       if (im(y,i)==1)
           bool=true;
           break;
       end;
       i=i+1;
    end;
    if (bool==false)
        return;
    end;
    
    %decrease x <--
    bool=false;
    i=x-1;
    while(i>=1)
       if (im(y,i)==1)
           bool=true;
           break;
       end;
       i=i-1;
    end;
    if (bool==false)
        return;
    end;
    
    %decrease y ^
    bool=false;
    i=y-1;
    while(i>=1)
       if (im(i,x)==1)
           bool=true;
           break;
       end;
       i=i-1;
    end;
    if (bool==false)
        return;
    end;
    
    %increase y (down)
    bool=false;
    i=y+1;
    while(i<=h)
       if (im(i,x)==1)
           bool=true;
           break;
       end;
       i=i+1;
    end;
   
    
    
end

