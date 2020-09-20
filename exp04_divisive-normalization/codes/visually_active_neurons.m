function [active_neurons, Nactive_neurons]=visually_active_neurons(features,group,VAR_THREHOLD)
nL=length(features{1})-1;
Nactive_neurons=zeros(nL,1);
active_neurons=cell(nL,1);
for layerid=1:nL
    % extracting response and normalizing
    nNeurons=length(vec(features{1}(layerid).x));% number of neurons
    nimages=length(features);
    response=zeros(nNeurons,nimages); % initializing the matrix
    for ind=1:nimages
        response(:,ind)=vec(features{ind}(layerid).x); % extracting the response
    end
    rg1=response(:,group(:,1));rg2=response(:,group(:,2));rg3=response(:,group(:,3));
    van=find(var(rg1,0,2)>VAR_THREHOLD &var(rg2,0,2)>VAR_THREHOLD &var(rg3,0,2)>VAR_THREHOLD); %visually active neurons
    Nactive_neurons(layerid)=length(van);
    active_neurons{layerid}=van;
end
end