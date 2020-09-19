function [mi_global_local]=check_global_local(features,imagepairDetails)
nL=length(features{1})-1;
N=length(features);
g1=imagepairDetails(:,1);
l1=imagepairDetails(:,2);
g2=imagepairDetails(:,3);
l2=imagepairDetails(:,4);

indexG=find(l1==l2);
indexL=find(g1==g2);
for Layer=1:nL
    temp=features{1}(Layer).x;fl=length(temp(:));
    layerF=zeros(fl,N);
    for ind_img=1:N
        layerF(:,ind_img)=vec(features{ind_img}(Layer).x);
    end
    layerwiseDist(:,Layer)=pdist(layerF','euclidean');
    mean_global_distance(Layer)=nanmean(layerwiseDist(indexG,Layer));
    mean_local_distance(Layer)=nanmean(layerwiseDist(indexL,Layer));
end
mi_global_local=(mean_global_distance-mean_local_distance)./(mean_global_distance+mean_local_distance);
end