function [ score ] = Score( inputF,TemplateF )

    [colT,~]=size(TemplateF);
    [colI,~]=size(inputF);
    thresh=30;
    th_thresh=45;
    score=0;
    
    for i=1:colT
        for j=1:colI
            if(abs(TemplateF(i,1)-inputF(j,1))<=thresh) ...
              &&(abs(TemplateF(i,2)-inputF(j,2))<=thresh) ...
              &&(abs(TemplateF(i,3)-inputF(j,3))<=th_thresh)
                score=score+1;
                break;
            end;
        end;
    end;
    score=score/max(colT,colI);
end

