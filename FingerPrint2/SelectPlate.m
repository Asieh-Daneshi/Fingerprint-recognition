function SelectPlate(f)
img=f;
img=rgb2gray(img);
g=edge(img,'sobel');
g=imdilate(g,strel('diamond',1));
g=imdilate(g,strel('line',2,0));
h=imfill(g,'holes');
G=regionprops(h,'Area','BoundingBox','Extent','Orientation');
%--------------------------------------------------------------------------
% 'Area' — Scalar; the actual number of pixels in the region
% 'BoundingBox' — The smallest rectangle containing the region
% 'Centroid' – 1-by-Q vector that specifies the center of mass of the region.
% Note that the first element of Centroid is the horizontal coordinate (or x-coordinate) of the center of mass, and the second element is the vertical coordinate (or y-coordinate).
% 'Extent' — Scalar that specifies the ratio of pixels in the region to pixels in the total bounding box.
% 'Image' — Binary image (logical) of the same size as the bounding box of the region; the on pixels correspond to the region, and all other pixels are off.
% 'Orientation' — Scalar; the angle (in degrees ranging from -90 to 90 degrees) between the x-axis and the major axis of the ellipse that has the same second-moments as the region.
%--------------------------------------------------------------------------
area=-1;
for j=1:length([G.Extent])
    if (G(j).Area >= area && G(j).Extent >= 0.4)
        area=G(j).Area;
        s=j;
    end
end
%--------------------------------------------------------------------------
image=f(G(s).BoundingBox(2):G(s).BoundingBox(2)+G(s).BoundingBox(4),G(s).BoundingBox(1):G(s).BoundingBox(1)+G(s).BoundingBox(3));
%--------------------------------------------------------------------------
[H theta rho]=hough(edge(image,'canny'));
lines=houghlines(edge(image,'canny'),theta,rho,houghpeaks(H,1));
temp=image;
size1=0;
try
    lines.theta;
    if (lines.theta < 0 && abs(abs(lines.theta)-90) > 3)
        size1=size(image,1)*cos(lines.theta);
        image=imtransform(image,maketform('affine',[1 -1-(lines.theta/100) 0;0 1 0;0 0 1]));
    elseif(lines.theta > 0 && abs(abs(lines.theta)-90) > 3)
        size1=size(image,1)*cos(lines.theta);
        image=imtransform(image,maketform('affine',[1 1.0-(lines.theta/100) 0;0 1 0;0 0 1]));
    end
catch
    lines(1).theta
    if(lines(1).theta < 0 && abs(abs(lines(1).theta)-90) > 3)
        size1=size(image,1)*cos(lines(1).theta);
        image=imtransform(image,maketform('affine',[1 -1-(lines(1).theta/100) 0;0 1 0;0 0 1]));
    elseif(lines(1).theta > 0 && abs(abs(lines(1).theta)-90) > 3)
        size1=size(image,1)*cos(lines(1).theta);
        image=imtransform(image,maketform('affine',[1 1.0-(lines(1).theta/100) 0;0 1 0;0 0 1]));
    end
end
%==========================================================================
if (size1 ~= 0)
    size1=size(image,1)-abs(size1);
end
sizeY=abs(size(image,1)-size(temp,1));
sizeY=abs(size1)+sizeY-abs(sizeY)/3;
[~, a2]=size(image);
image=imcrop(image,[a2/8 sizeY/2 size(image,2) size(image,1)-sizeY]);
image=imresize(image,[100 500]);
figure,imshow(image)


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
MyImage=image;
MyCrop=imcrop(MyImage,[250 25 50 50]);
mini1=min(MyCrop);
mini2=min(mini1');
if mini2 ~= 0
    MyImage=MyImage-mini2;
end
for i=1:100
    for j=1:500
        if MyImage(i,j)>50
            MyImage(i,j)=255;
        end
    end
end
MyCrop=imcrop(MyImage,[250 25 50 50]);
image=MyImage;
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
img=255-image;
img=imfilter(img,fspecial('motion',100,90));
img=im2bw(img,graythresh(img));
img=imresize(img,[100 500]);
%==========================================================================
sumOfRows=sum(img,2);
for i=1:size(sumOfRows)
    if (sumOfRows(i) > 0)
        index1=i;
        break
    end
end

for i=size(sumOfRows):-1:1
    if (sumOfRows(i) > 0)
        index2=i;
        break
    end
end
image=im2bw(image,graythresh(image));
image=imresize(image,[100 500]);
MyCrop=im2bw(MyCrop);
[counts,~]=imhist(MyCrop);
if (counts(1) < counts(2))
    image= ~image;
end
%==========================================================================
final='';
LETT=regionprops(image,'Area','BoundingBox','Extent','Image');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

answer=zeros(27);

for i=1:length([LETT.Area])
    if (LETT(i).Area > 350 && LETT(i).Area < 2300 && LETT(i).Extent > 0.2)
        idx=i;
        B=bwboundaries(image);
        boundary=B{idx};
        hold on;
        plot(boundary(:,2),boundary(:,1),'g','LineWidth',2);
        letter=LETT(i).Image;
        letter=imresize(letter,[40 40]);
%         for j=1:26
%             c='i:\1\DB\';
%             d=num2str(j);
%             e='.jpg';
%             e=strcat(c,d,e);
%             LetterImage=imread(e);
%             LetterImage=im2bw(LetterImage,graythresh(LetterImage));
%             answer(j)=sum(sum(letter == LetterImage));
%         end
%         [~,LetterCode]=max(answer);
%         if (LetterCode(1) < 10)
%             final=strcat(final,num2str(LetterCode(1)));
%         elseif (LetterCode(1) == 10)
%             final=strcat(final,'-Alef-');
%         elseif (LetterCode(1) == 11)
%             final=strcat(final,'-Be-');
%         elseif (LetterCode(1) == 12)
%             final=strcat(final,'-Jim-');
%         elseif (LetterCode(1) == 13)
%             final=strcat(final,'-Dal-');
%         elseif (LetterCode(1) == 14)
%             final=strcat(final,'-Re-');
%         elseif (LetterCode(1) == 15)
%             final=strcat(final,'-Sin-');
%         elseif (LetterCode(1) == 16)
%             final=strcat(final,'-Sad-');    
%         elseif (LetterCode(1) == 17)
%             final=strcat(final,'-Ta-'); 
%         elseif (LetterCode(1) == 18)
%             final=strcat(final,'-Eyn-');    
%         elseif (LetterCode(1) == 19)
%             final=strcat(final,'-Fe-');    
%         elseif (LetterCode(1) == 20)
%             final=strcat(final,'-Ghaf-');    
%         elseif (LetterCode(1) == 21)
%             final=strcat(final,'-Kaf-');    
%         elseif (LetterCode(1) == 22)
%             final=strcat(final,'-Lam-');    
%         elseif (LetterCode(1) == 23)
%             final=strcat(final,'-Mim-');    
%         elseif (LetterCode(1) == 24)
%             final=strcat(final,'-Nun-');    
%         elseif (LetterCode(1) == 25)
%             final=strcat(final,'-Vav-');    
%         elseif (LetterCode(1) == 26)
%             final=strcat(final,'-Ye-');    
%         end
    end
end
final

% B=bwboundaries(h);
% boundary=B{s};
% figure,imshow(f);
% hold on;
% plot(boundary(:,2),boundary(:,1),'r','LineWidth',2);          