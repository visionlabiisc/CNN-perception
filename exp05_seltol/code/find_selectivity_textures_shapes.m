function corr_sparsness_texture=find_selectivity_textures_shapes(features,conditions_ST)
nL=length(features{1})-1;
nimages=length(features);
set1=1:conditions_ST;
set2=conditions_ST+(1:conditions_ST);
nM=conditions_ST;
corr_sparsness_texture=zeros(1,nL);
for layerid=1:nL
    % extracting response and normalizing
    nNeurons=length(vec(features{1}(layerid).x));% number of neurons
    response=zeros(nNeurons,nimages); % initializing the matrix
    for ind=1:nimages
        response(:,ind)=vec(features{ind}(layerid).x); % extracting the response
    end
    nresponse=normalize(response','range');nresponse=nresponse'; % normalizing each neuron across all images
    
    van_set1=sum(nresponse(:,set1),2)>0; %visually active neurons for set1
    van_set2=sum(nresponse(:,set2),2)>0; %visually active neurons for set2
    van=find(van_set1==1 &van_set2==1);
    nvresponse=nresponse(van,:); % normalized response from visually active neurons
    nvan=length(van);nVAN(layerid)=nvan;
    
    % finding the sparsenes for each morphline
    np=nNeurons;
    L=floor(nvan/np);
    r=rem(nvan,np);
    SPAR=zeros(nvan,2);% 1 for refrence set
    
    np=4; % This for loop is used to partition the calculation of sparsness to make it faster
    for index=1:2
        qstim=[nM*(index-1)+(1:nM)];
        for  ii=1:np
            qneu=[L*(ii-1)+(1:L)];
            SPAR(qneu,index)=sparseness(nvresponse(qneu,qstim)); % some nans will be created
        end
        if(r>0) % when nvan is not divissible by np
            qneu=L*np+(1:r);
            SPAR(qneu,index)=sparseness(nvresponse(qneu,qstim)); % some nans will be created
        end
    end
    corr_sparsness_texture(layerid)=nancorrcoef(SPAR(:,1),SPAR(:,2));
end
end
