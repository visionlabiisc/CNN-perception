function [r_natural,r_unnatural]=check_part_summation(features,L2_str,dist_type)

nL=length(features{1})-1;% Skipping the last layers
%% CNN dsitances for the image pairs
img_pairs=L2_str.img_pairs;
cnn_d=zeros(length(img_pairs),nL);
count=0;
for i=1:length(img_pairs)
    ip=img_pairs(i,:);
    for L=1:nL
        f1=vec(squeeze(features{ip(1)}(L).x));
        f2=vec(squeeze(features{ip(2)}(L).x));
        cnn_d(i,L)=distance_calculation(f1,f2,dist_type);
    end
end

%% All
allparts=L2_str.partsTD;allparts(:,[2,4])=allparts(:,[2,4])-7; % the right part is numbered from 8-14, substrating 7 to make  it from 1-7
% unnatural
qunat=1:492;
[~,~,X] = FitBatonModel([],allparts(qunat,:),1);Xu=X(:,[1:42,end]);
% natural
qnat=492+(1:492);
[~,~,X] = FitBatonModel([],allparts(qnat,:),1);Xn=X(:,[1:42,end]);

%% behavioral distance
RT=L2_str.RT;
meanRT=nanmean(nanmean(RT,3),2);
dobs=1./meanRT;
% common part
common_stim=1:8:49;
common_stim_pair=nchoosek(common_stim,2);
common_stim_pair_index=zeros(length(common_stim_pair),1);
for ind=1:length(common_stim_pair)
    s1=common_stim_pair(ind,1);
    s2=common_stim_pair(ind,2);
    sel_index=find(L2_str.img_pairs(qunat,1)==s1 & L2_str.img_pairs(qunat,2)==s2);
    common_stim_pair_index(ind)=sel_index;
end

%% Fititng the model
r_unnatural=zeros(nL,1);
r_natural=zeros(nL,1);
for L=1:nL
    dcnnU=cnn_d(qunat,L);bu=regress(dcnnU,Xu);pdcnnU=Xu*bu;
    dcnnN=cnn_d(qnat,L);bn=regress(dcnnN,Xn);pdcnnN=Xu*bn;
    r_unnatural(L)=nancorrcoef(dcnnU(common_stim_pair_index),pdcnnU(common_stim_pair_index));
    r_natural(L)=nancorrcoef(dcnnN(common_stim_pair_index),pdcnnN(common_stim_pair_index));
end
end