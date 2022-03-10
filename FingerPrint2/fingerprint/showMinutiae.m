function [] = showMinutiae( im,FeatureMat,msg )

    figure,imshow(im),title(msg);
    hold on;
    [col,~]=size(FeatureMat);
    for i=1:col
        if FeatureMat(i,4)==1
            plot(FeatureMat(i,1),FeatureMat(i,2) ...
                ,'Marker','o','MarkerEdgecolor','r' ...
                ,'MarkerSize',3);
        else
            plot(FeatureMat(i,1),FeatureMat(i,2) ...
                ,'Marker','s','MarkerEdgecolor','b' ...
                ,'MarkerSize',3);
        end;
    end;
    hold off;
end

