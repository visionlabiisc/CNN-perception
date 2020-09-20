function model_coefficient=divisive_normalization(features_pairs,features_singleton,active_neurons,Nactive_neurons,imgpairs,imgsingles,Blank_ID)
nL=length(features_singleton{1})-1;
activeLayers=find(Nactive_neurons~=0);
model_coefficient=zeros(2,nL);
for layers=activeLayers'
    fprintf('\n Layers %s',num2str(layers));
    Fp=zeros(Nactive_neurons(layers),length(imgpairs));
    Fsum=zeros(Nactive_neurons(layers),length(imgpairs));
    
    for ind=1:length(imgpairs) % across image pairs
        f=cell(3,1);count=0;% init
        for p=1:3 % position, expecting stimuli only in two positions
            if(imgpairs(ind,p)~=Blank_ID)
                count=count+1;
                sel_index=(imgsingles(:,p)==imgpairs(ind,p));
                temp=features_singleton{sel_index};
                f{count}=vec(temp(layers).x);
            end
        end
        temp=vec(features_pairs{ind}(layers).x);Fp(:,ind)=temp(active_neurons{layers});
        temp_sum=0*f{1};% init
        for i=1:count
            temp_sum=temp_sum+f{i};
        end
        Fsum(:,ind)=temp_sum(active_neurons{layers});
    end
    [nc_combined]= find_normalization_combined(Fp,Fsum);
    model_coefficient(:,layers)=nc_combined';
end
end