function [r_relative, r_absolute]=check_webers_law(features,absolute_delta,relative_delta,dist_type)
features=reshape(features,[length(absolute_delta),2]);
nL=length(features{1})-1;% Skipping the last layers
COND=size(features,1);% conditions
r_absolute=zeros(1,nL); % absolute correlation
r_relative=zeros(1,nL);  % relative correlation
FD=zeros(COND,nL);
for L=1:nL
    for c=1:COND
        f1=vec(features{c,1}(L).x);
        f2=vec(features{c,2}(L).x);
        FD(c,L)=distance_calculation(f1,f2,dist_type);
    end
    r_absolute(L) = nancorrcoef(FD(:,L),absolute_delta);
    r_relative(L) = nancorrcoef(FD(:,L),relative_delta);
end
end