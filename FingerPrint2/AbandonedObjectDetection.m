%**************************************************************************
% Abandoned Object Detection
%==========================================================================
roi = [100 80 360 240];
% Maximum number of objects to track
maxNumObj = 200;
% Number of frames that an object must remain stationary before an alarm is raised
alarmCount = 45;
% Maximum number of frames that an abandoned object can be hidden before it
% is no longer tracked
maxConsecutiveMiss = 4;
areaChangeFraction = 13;     % Maximum allowable change in object area in percent
centroidChangeFraction = 18;    % Maximum allowable change in object centroid in percent
% Minimum ratio between the number of frames in which an object is detected
% and the total number of frames, for that object to be tracked.
minPersistenceRatio = 0.7;
% Offsets for drawing bounding boxes in original input video
PtsOffset = int32(repmat([roi(1), roi(2), 0, 0],[maxNumObj 1]));
%--------------------------------------------------------------------------
% Create a VideoFileReader System object to read video from a file.
hVideoSrc = vision.VideoFileReader;
hVideoSrc.Filename = 'viptrain.avi';
hVideoSrc.VideoOutputDataType = 'single';   %The default is single
% Create a ColorSpaceConverter System object to convert the RGB image to Y'CbCr format.
hColorConv = vision.ColorSpaceConverter('Conversion', 'RGB to YCbCr');
% Create an Autothresholder System object to convert an intensity image to a binary image.
hAutothreshold = vision.Autothresholder('ThresholdScaleFactor', 1.3);
% Create a MorphologicalClose System object to fill in small gaps in the detected objects.
hClosing = vision.MorphologicalClose('Neighborhood', strel('square',5));
% Create a BlobAnalysis System object to find the area, centroid, and bounding box of the objects in the video.
hBlob = vision.BlobAnalysis('MaximumCount', maxNumObj, 'ExcludeBorderBlobs', true);
hBlob.MinimumBlobArea = 100;
hBlob.MaximumBlobArea = 2500;
% Create a ShapeInserter System object to draw rectangles around the abandoned objects.
hDrawRectangles1 = vision.ShapeInserter('Fill',true, 'FillColor', 'Custom', ...
    'CustomFillColor', [1 0 0], 'Opacity', 0.5);
% Create a TextInserter System object to display the number of objects in the video.
hDisplayCount = vision.TextInserter('Text', '%4d', 'Color', [1 1 1]);
% Create a ShapeInserter System object to draw rectangles around all the detected objects in the video.
hDrawRectangles2 = vision.ShapeInserter('BorderColor', 'Custom', ...
    'CustomBorderColor', [0 1 0]);
% Create a ShapeInserter System object to draw a rectangle around the region of interest.
hDrawBBox = vision.ShapeInserter('BorderColor', 'Custom', ...
    'CustomBorderColor', [1 1 0]);
% Create a ShapeInserter System object to draw rectangles around all the identified objects in the segmented video.
hDrawRectangles3 = vision.ShapeInserter('BorderColor', 'Custom', ...
    'CustomBorderColor', [0 1 0]);
% Create System objects to display results.
pos = [10 300 roi(3)+25 roi(4)+25];
hAbandonedObjects = vision.VideoPlayer('Name', 'Abandoned Objects', 'Position', pos);
pos(1) = 45+roi(3); % move the next viewer to the right
hAllObjects = vision.VideoPlayer('Name', 'All Objects', 'Position', pos);
pos = [80+2*roi(3) 300 roi(3)-roi(1)+25 roi(4)-roi(2)+25];
hThresholdDisplay = vision.VideoPlayer('Name', 'Threshold', 'Position', pos);
%**************************************************************************
% Video Processing Loop
%==========================================================================
% Create a processing loop to perform abandoned object detection on the input video. This loop uses the System objects you instantiated above.
firsttime = true;
while ~isDone(hVideoSrc)
    Im = step(hVideoSrc);
    % Select the region of interest from the original video
    OutIm = Im(roi(2):end, roi(1):end, :);
    YCbCr = step(hColorConv, OutIm);
    CbCr  = complex(YCbCr(:,:,2), YCbCr(:,:,3));

    % Store the first video frame as the background
    if firsttime
        firsttime = false;
        BkgY      = YCbCr(:,:,1);
        BkgCbCr   = CbCr;
    end
    SegY    = step(hAutothreshold, abs(YCbCr(:,:,1)-BkgY));
    SegCbCr = abs(CbCr-BkgCbCr) > 0.05;

    % Fill in small gaps in the detected objects
    Segmented = step(hClosing, SegY | SegCbCr);

    % Perform blob analysis
    [Area, Centroid, BBox] = step(hBlob, Segmented);

    % Call the helper function that tracks the identified objects and
    % returns the bounding boxes and the number of the abandoned objects.
    [OutCount, OutBBox] = videoobjtracker(Area, Centroid, BBox, maxNumObj, ...
       areaChangeFraction, centroidChangeFraction, maxConsecutiveMiss, ...
       minPersistenceRatio, alarmCount);

    % Display the abandoned object detection results
    Imr = step(hDrawRectangles1, Im, OutBBox+PtsOffset);
    Imr(1:15,1:30,:) = 0;
    Imr = step(hDisplayCount, Imr, OutCount);
    step(hAbandonedObjects, Imr);
    BlobCount = size(BBox,1);

    BBoxOffset = BBox + int32(repmat([roi(1) roi(2) 0  0],[BlobCount 1]));
    Imr = step(hDrawRectangles2, Im, BBoxOffset);

    % Display all the detected objects
    Imr(1:15,1:30,:) = 0;
    Imr = step(hDisplayCount, Imr, OutCount);
    Imr = step(hDrawBBox, Imr, roi);
    step(hAllObjects, Imr);

    % Display the segmented video
    SegBBox = PtsOffset;
    SegBBox(1:BlobCount,:) = BBox;
    SegIm = step(hDrawRectangles3, repmat(Segmented,[1 1 3]), SegBBox);
    step(hThresholdDisplay, SegIm);
end
release(hVideoSrc);