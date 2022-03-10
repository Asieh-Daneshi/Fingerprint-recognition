% ======================================================================Program no.1
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::(Image Enhancement)
function [final]=fftenhance(image,f)
I = 255-double(image);                                     % Complementing the image
% imshow(I,'DisplayRange',[]);
[w,h] = size(I);
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Dividing picture into 32*32 blocks and calculating Fourier transform in each block
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
w1=floor(w/32)*32;
h1=floor(h/32)*32;
inner = zeros(w1,h1);
for i=1:32:w1
for j=1:32:h1
a=i+31;
b=j+31;
F=fft2( I(i:a,j:b) );
% In order to enhance a specific block by its dominant frequencies, we multiply the
% FFT of the block by its magnitude a set of times, and then calculate the
% inverse Fourier transform
% ..................................................................................
% The f in the following formula is an experimentally determined constant, which we
% choose f=0.45 to calculate. While having a higher "f" improves the appearance of 
% the ridges, filling up small holes in ridges, having too high a "f" can result in 
% false joining of ridges. Thus a termination might become a bifurcation.
% ..................................................................................
factor=abs(F).^f;
block = abs(ifft2(F.*factor));
larv=max(block(:));
if larv==0
larv=1;
end
block= block./larv;
inner(i:a,j:b) = block;
end
end
final=inner*255;
final=histeq(uint8(final));
% -------------------------------------------------------------Program no.2
%(Image Binarization )
function [o] = adaptiveThres(a,W,noShow)
%Adaptive thresholding is performed by segmenting image a
[w,h] = size(a);
o = zeros(w,h);
%seperate it to W block
%step to w with step length W
for i=1:W:w
for j=1:W:h
mean_thres = 0;
if i+W-1 <= w & j+W-1 <= h
mean_thres = mean2(a(i:i+W-1,j:j+W-1));
mean_thres = 0.8*mean_thres;
o(i:i+W-1,j:j+W-1) = a(i:i+W-1,j:j+W-1) < mean_thres;
end
end
end
if nargin == 2
imagesc(o);
colormap(gray);
end
% -------------------------------------------------------------Program no.3
%(for Block Direction Estimation)
function [p,z] = direction(image,blocksize,noShow)
%image=adaptiveThres(image,16,0);
[w,h] = size(image);
direct = zeros(w,h);
gradient_times_value = zeros(w,h);
gradient_sq_minus_value = zeros(w,h);
gradient_for_bg_under = zeros(w,h);
W = blocksize;
theta = 0;
sum_value = 1;
bg_certainty = 0;
blockIndex = zeros(ceil(w/W),ceil(h/W));
%directionIndex = zeros(ceil(w/W),ceil(h/W));
times_value = 0;
minus_value = 0;
center = [];
filter_gradient = fspecial('sobel');
%to get x gradient
I_horizontal = filter2(filter_gradient,image);
%to get y gradient
filter_gradient = transpose(filter_gradient);
I_vertical = filter2(filter_gradient,image);
gradient_times_value=I_horizontal.*I_vertical;
gradient_sq_minus_value=(I_vertical-I_horizontal).*(I_vertical+I_horizontal);
gradient_for_bg_under = (I_horizontal.*I_horizontal) + (I_vertical.*I_vertical);
for i=1:W:w
for j=1:W:h
if j+W-1 < h & i+W-1 < w
times_value = sum(sum(gradient_times_value(i:i+W-1, j:j+W-1)));
minus_value = sum(sum(gradient_sq_minus_value(i:i+W-1, j:j+W-1)));
sum_value = sum(sum(gradient_for_bg_under(i:i+W-1, j:j+W-1)));
bg_certainty = 0;
theta = 0;
if sum_value ~= 0 & times_value ~=0
%if sum_value ~= 0 & minus_value ~= 0 & times_value ~= 0
bg_certainty = (times_value*times_value +
minus_value*minus_value)/(W*W*sum_value);
if bg_certainty > 0.05
blockIndex(ceil(i/W),ceil(j/W)) = 1;
%tan_value = atan2(minus_value,2*times_value);
tan_value = atan2(2*times_value,minus_value);
theta = (tan_value)/2 ;
theta = theta+pi/2;
center = [center;[round(i + (W-1)/2),round(j + (W-1)/2),theta]];
end
end
end
times_value = 0;
minus_value = 0;
sum_value = 0;
end
end
if nargin == 2
imagesc(direct);
hold on;
[u,v] = pol2cart(center(:,3),8);
quiver(center(:,2),center(:,1),u,v,0,'g');
hold off;
end;
x = bwlabel(blockIndex,4);
y = bwmorph(x,'close');
z = bwmorph(y,'open');
p = bwperim(z);
% -------------------------------------------------------------Program no.4
%(to extract ROI)
function [roiImg,roiBound,roiArea] = drawROI(in,inBound,inArea,noShow)
[iw,ih]=size(in);
tmplate = zeros(iw,ih);
[w,h] = size(inArea);
tmp=zeros(iw,ih);
left = 1;
right = h;
upper = 1;
bottom = w;
le2ri = sum(inBound);
roiColumn = find(le2ri>0);
left = min(roiColumn);
right = max(roiColumn);
tr_bound = inBound';
up2dw=sum(tr_bound);
roiRow = find(up2dw>0);
upper = min(roiRow);
bottom = max(roiRow);
%cut out the ROI region image
%show background,bound,innerArea with different gray intensity:0,100,200
for i = upper:1:bottom
for j = left:1:right
if inBound(i,j) == 135
tmplate(16*i-15:16*i,16*j-15:16*j) = 200;
tmp(16*i-15:16*i,16*j-15:16*j) = 1;
elseif inArea(i,j) == 1 & inBound(i,j) ~=1
tmplate(16*i-15:16*i,16*j-15:16*j) = 100;
tmp(16*i-15:16*i,16*j-15:16*j) = 1;
end
end
end
in=in.*tmp;
roiImg = in(16*upper-15:16*bottom,16*left-15:16*right);
roiBound = inBound(upper:bottom,left:right);
roiArea = inArea(upper:bottom,left:right);
%inner area
roiArea = im2double(roiArea) - im2double(roiBound);
if nargin == 3
colormap(gray);
imagesc(tmplate);
end
% -------------------------------------------------------------Program no.5
%(Ridge Thinning)
function edgeDistance =RidgeThin(image,inROI,blocksize)
[w,h] = size(image);
a=sum(inROI);
b=find(a>0);
c=min(b);
d=max(b);
i=round(w/5);
m=0;
for k=1:4
m=m+sum(image(k*i,16*c:16*d));
end
e=(64*(d-c))/m;
a=sum(inROI,2);
b=find(a>0);
c=min(b);
d=max(b);
i=round(h/5);
m=0;
for k=1:4
m=m+sum(image(16*c:16*d,k*i));
end
m=(64*(d-c))/m;
edgeDistance=round((m+e)/2);
% ------------------------------------------------------------Program no. 6
%(Minutia marking)
function [end_list,branch_list,ridgeOrderMap,edgeWidth] = mark_minutia(in,
inBound,inArea,block);
[w,h] = size(in);
[ridgeOrderMap,totalRidgeNum] = bwlabel(in);
imageBound = inBound;
imageArea = inArea;
blkSize = block;
%innerArea = im2double(inArea)-im2double(inBound);
edgeWidth = interRidgeWidth(in,inArea,blkSize);
end_list = [];
branch_list = [];
for n=1:totalRidgeNum
[m,n] = find(ridgeOrderMap==n);
b = [m,n];
ridgeW = size(b,1);
for x = 1:ridgeW
i = b(x,1);
j = b(x,2);
%ifimageArea(ceil(i/blkSize),ceil(j/blkSize))==1&
imageBound(ceil(i/blkSize),ceil(j/blkSize)) ~= 1
if inArea(ceil(i/blkSize),ceil(j/blkSize)) == 1
neiborNum = 0;
neiborNum = sum(sum(in(i-1:i+1,j-1:j+1)));
neiborNum = neiborNum -1;
if neiborNum == 1
end_list =[end_list; [i,j]];
elseif neiborNum == 3
%if two neighbors among the three are connected directly
%there may be three braches are counted in the nearing three cells
tmp=in(i-1:i+1,j-1:j+1);
tmp(2,2)=0;
[abr,bbr]=find(tmp==1);
t=[abr,bbr];
if isempty(branch_list)
branch_list = [branch_list;[i,j]];
else
for p=1:3
cbr=find(branch_list(:,1)==(abr(p)-2+i) & branch_list(:,2)==(bbr(p)-2+j) );
if ~isempty(cbr)
p=4;
break
end
end
if p==3
branch_list = [branch_list;[i,j]];
end
end
end
end
end
end
% -------------------------------------------------------------Program no.7
%(False Minutia removal)
function [pathMap, final_end,final_branch]
=remove_spurious_Minutia(in,end_list,branch_list,inArea,ridgeOrderMap,edgeWidth
[w,h] = size(in);
final_end = [];
final_branch =[];
direct = [];
pathMap = [];
end_list(:,3) = 0;
branch_list(:,3) = 1;
minutiaeList = [end_list;branch_list];
finalList = minutiaeList;
[numberOfMinutia,dummy] = size(minutiaeList);
suspectMinList = [];
for i= 1:numberOfMinutia-1
for j = i+1:numberOfMinutia
d =( (minutiaeList(i,1) - minutiaeList(j,1))^2 + (minutiaeList(i,2)-minutiaeList(j,2))^2)^0.5;
if d < edgeWidth
suspectMinList =[suspectMinList;[i,j]];
end
end
end
[totalSuspectMin,dummy] = size(suspectMinList);
for k = 1:totalSuspectMin
typesum = minutiaeList(suspectMinList(k,1),3) + minutiaeList(suspectMinList(k,2),3)
if typesum == 1
% branch - end pair
if ridgeOrderMap(minutiaeList(suspectMinList(k,1),1),minutiaeList(suspectMinList(k,1),2) )
== ridgeOrderMap(minutiaeList(suspectMinList(k,2),1),minutiaeList(suspectMinList(k,2),2) )
finalList(suspectMinList(k,1),1:2) = [-1,-1];
finalList(suspectMinList(k,2),1:2) = [-1,-1];
end
elseif typesum == 2
% branch - branch pair
if ridgeOrderMap(minutiaeList(suspectMinList(k,1),1),minutiaeList(suspectMinList(k,1),2) )
== ridgeOrderMap(minutiaeList(suspectMinList(k,2),1),minutiaeList(suspectMinList(k,2),2) )
finalList(suspectMinList(k,1),1:2) = [-1,-1];
finalList(suspectMinList(k,2),1:2) = [-1,-1];
end
elseif typesum == 0
% end - end pair
a = minutiaeList(suspectMinList(k,1),1:3);
b = minutiaeList(suspectMinList(k,2),1:3);
if ridgeOrderMap(a(1),a(2)) ~= ridgeOrderMap(b(1),b(2))
[thetaA,pathA,dd,mm] = getLocalTheta(in,a,edgeWidth);
[thetaB,pathB,dd,mm] = getLocalTheta(in,b,edgeWidth);
%the connected line between the two point
thetaC = atan2( (pathA(1,1)-pathB(1,1)), (pathA(1,2) - pathB(1,2)) );
angleAB = abs(thetaA-thetaB);
angleAC = abs(thetaA-thetaC);
if ( (or(angleAB < pi/3, abs(angleAB -pi)<pi/3 )) & (or(angleAC < pi/3, abs(angleAC - pi)
< pi/3)) )
finalList(suspectMinList(k,1),1:2) = [-1,-1];
finalList(suspectMinList(k,2),1:2) = [-1,-1];
end
%remove short ridge later
elseif ridgeOrderMap(a(1),a(2)) == ridgeOrderMap(b(1),b(2))
finalList(suspectMinList(k,1),1:2) = [-1,-1];
finalList(suspectMinList(k,2),1:2) = [-1,-1];
end
end
end
for k =1:numberOfMinutia
if finalList(k,1:2) ~= [-1,-1]
if finalList(k,3) == 0
[thetak,pathk,dd,mm] = getLocalTheta(in,finalList(k,:),edgeWidth);
if size(pathk,1) >= edgeWidth
final_end=[final_end;[finalList(k,1:2),thetak]];
[id,dummy] = size(final_end);
pathk(:,3) = id;
pathMap = [pathMap;pathk];
end
else
final_branch=[final_branch;finalList(k,1:2)];
[thetak,path1,path2,path3] = getLocalTheta(in,finalList(k,:),edgeWidth);
if size(path1,1)>=edgeWidth & size(path2,1)>=edgeWidth & size(path3,1)>=edgeWidth
final_end=[final_end;[path1(1,1:2),thetak(1)]];
[id,dummy] = size(final_end);
path1(:,3) = id;
pathMap = [pathMap;path1];
final_end=[final_end;[path2(1,1:2),thetak(2)]];
path2(:,3) = id+1;
pathMap = [pathMap;path2];
final_end=[final_end;[path3(1,1:2),thetak(3)]];
path3(:,3) = id+2;
pathMap = [pathMap;path3];
end
end
end
end
% -------------------------------------------------------------Program no.8
%(Alignment stage)
function [newXY] = MinuOriginTransRidge(real_end,k,ridgeMap
theta = real_end(k,3);
if theta <0
theta1=2*pi+theta;
end
theta1=pi/2-theta;
rotate_mat=[cos(theta1),-sin(theta1);sin(theta1),cos(theta1)];
%locate all the ridge points connecting to the miniutia
%and transpose it as the form:
%x1 x2 x3...
%y1 y2 y3...
pathPointForK = find(ridgeMap(:,3)== k);
toBeTransformedPointSet = ridgeMap(min(pathPointForK):max(pathPointForK),1:2)';
%translate the minutia position (x,y) to (0,0)
%translate all other ridge points according to the basis
tonyTrickLength = size(toBeTransformedPointSet,2);
pathStart = real_end(k,1:2)';
translatedPointSet = toBeTransformedPointSet - pathStart(:,ones(1,tonyTrickLength)
%rotate the point sets
newXY = rotate_mat*translatedPointS
function [newXY] = MinuOrigin_TransAll(real_end,k)
theta = real_end(k,3);
if theta <0
theta1=2*pi+theta;
end
theta1=pi/2-theta;
rotate_mat=[cos(theta1),-sin(theta1),0;sin(theta1),cos(theta1),0;0,0,1];
toBeTransformedPointSet = real_end';
tonyTrickLength = size(toBeTransformedPointSet,2);
pathStart = real_end(k,:)';
translatedPointSet = toBeTransformedPointSet - pathStart(:,ones(1,tonyTrickLength));
newXY = rotate_mat*translatedPointSet;
%ensure the direction is in the domain[-pi,pi]
for i=1:tonyTrickLength
if or(newXY(3,i)>pi,newXY(3,i)<-pi)
newXY(3,i) = 2*pi - sign(newXY(3,i))*newXY(3,i);
end
end
% -------------------------------------------------------------Program no.9
%(Minutiae matching)
function [newXY] = MinuOrigin_TransAll(real_end,k)
theta = real_end(k,3);
if theta <0
theta1=2*pi+theta;
end
theta1=pi/2-theta;
rotate_mat=[cos(theta1),-sin(theta1),0;sin(theta1),cos(theta1),0;0,0,1];
toBeTransformedPointSet = real_end';
tonyTrickLength = size(toBeTransformedPointSet,2);
pathStart = real_end(k,:)';
translatedPointSet = toBeTransformedPointSet - pathStart(:,ones(1,tonyTrickLength));
newXY = rotate_mat*translatedPointSet;
for i=1:tonyTrickLength
if or(newXY(3,i)>pi,newXY(3,i)<-pi)
newXY(3,i) = 2*pi - sign(newXY(3,i))*newXY(3,i);
end
end