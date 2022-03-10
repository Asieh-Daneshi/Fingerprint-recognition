templateDatabase=[];
for i=1:4
    fileName=[int2str(i) '.jpg'];
    im=imread(['library/' fileName]);
    temporary =TotalFeatureExt(im);
    temporary(:,5)=i;
    templateDatabase=[templateDatabase;temporary];
end;
save('templates.mat','templateDatabase');