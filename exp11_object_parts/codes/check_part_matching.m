function part_matching_index=check_part_matching(features)
nL=length(features{1})-1;% Skipping the last layers
dN=zeros(2,nL);dU=zeros(2,nL);
for L=1:nL
    f=cell(6,1);
    for ind=1:6
        f{ind}=vec(squeeze(features{ind}(L).x));
    end
    dN(1,L)=norm(f{1}-f{2},1);
    dN(2,L)=norm(f{4}-f{5},1);
    
    dU(1,L)=norm(f{1}-f{3},1);
    dU(2,L)=norm(f{4}-f{6},1);
end
%%
part_matching_index=(dU-dN)./(dU+dN);
part_matching_index=nanmean(part_matching_index,1);
end