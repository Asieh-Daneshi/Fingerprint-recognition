%**************************************************************************
% Reading fingerprint image
%==========================================================================
[FileName,PathName] = uigetfile('*.jpg','Select the Input Image');
if isequal(FileName,0)
   disp('User selected Cancel')
else
   disp(['User selected', fullfile(PathName, FileName)])
end

%--------------------------------------------------------------------------
im=imread([PathName FileName]);
inputFeatures=TotalFeatureExt(im);
load templates;

%--------------------------------------------------------------------------

score_thresh=0.9;

max_score=0;
for i=1:4
    fprintf('\n\n\n\n---------------\n');
    fprintf('Library Item: %d\n', i);
    fprintf('---------------\n');
    
    rows=(templateDatabase(:,5)==i);
    score=CompareWithTemplate(inputFeatures, templateDatabase(rows,1:4));
    max_score=max(double(score), double(max_score));
    if(score>=score_thresh)
        fprintf('\nINPUT MATCHED - Score: %f\n', max_score);
        disp(['Picture: library/' int2str(i) '.jpg']);
        showMinutiae(im,inputFeatures, ...
            ['MATCHED - Picture: library/' int2str(i) '.jpg']);
        return;
    end;
    fprintf('NOT MATCHED - Maximum Score: %f\n', max_score);
    max_score=0;
end;

fprintf('\nINPUT NOT MATCHED');
showMinutiae(im,inputFeatures, 'NOT MATCHED');
