function [ crossNum ] = CrossNumber( im,i,j )

    crossNum=0;
    a=zeros(1,8);
    a(1)=im(i,j+1);
    a(2)=im(i-1,j+1);
    a(3)=im(i-1,j);
    a(4)=im(i-1,j-1);
    a(5)=im(i,j-1);
    a(6)=im(i+1,j-1);
    a(7)=im(i+1,j);
    a(8)=im(i+1,j+1);
    a(9)=a(1);
    for i=1:8
        crossNum=crossNum+abs(a(i)-a(i+1));
    end;
    crossNum=crossNum/2;
end

