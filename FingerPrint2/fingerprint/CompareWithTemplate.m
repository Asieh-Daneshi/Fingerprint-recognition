function [ score ] = CompareWithTemplate( inputFeatures,templateFeatures )
    score=0;
    ct=size(templateFeatures, 1);
    ci=size(inputFeatures, 1);
    for Ref_T=1:ct
        for Ref_I=1:ci
            if templateFeatures(Ref_T, 4)~=inputFeatures(Ref_I, 4) % only same type points can be used
                continue;
            end;
            TTF=Transformation(templateFeatures,Ref_T);
            TIF=Transformation(inputFeatures,Ref_I);
            s=Score(TIF,TTF);
            fprintf('TRef:%3d, IRef:%3d, score: %f\n', Ref_T, Ref_I, s); %debug
            score=max(double(s), double(score));
        end;
    end;
    
end
