f=imread('44170697652547905664.jpg');
img=f;
si=size(f);
img=rgb2gray(img);
g=edge(img,'sobel');
g=imdilate(g,strel('diamond',1));
imshow(g)
g=imdilate(g,strel('line',3,0));
h=imfill(g,'holes');
figure;imshow(h)
G=regionprops(h,'Area','BoundingBox','Extent','Orientation','Centroid');
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
    if (G(j).Area >= area && G(j).Extent >= 0.4 && G(j).Centroid(2)>si(2)/2)
        area=G(j).Area;
        s=j;
    end
end
%--------------------------------------------------------------------------
image=f(G(s).BoundingBox(2):G(s).BoundingBox(2)+G(s).BoundingBox(4),G(s).BoundingBox(1):G(s).BoundingBox(1)+G(s).BoundingBox(3));
figure;imshow(image)
asi=svd(double(image))
% figure;imshow(asi)
