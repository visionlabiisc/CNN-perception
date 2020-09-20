function corr_max_sparsness_ref=find_selectivity_morphlines(features)
nL=length(features{1})-1;
nimages=length(features);
%% CONSTANTS
nMorphs=4;
nDeci=5; % number of decimals considered
stim_per_morph=11;
ref_Set=[1    12    23    34    11    22    33    44];

pairs_sel=nchoosek(1:nMorphs+1,2);% select all combinations
SEL_CORR=zeros(size(pairs_sel,1),nL); % all pairwise correlations
nVAN=zeros(nL,1); % number of visually responsive neurons across layers.
nNeu=zeros(nL,1); % total number of neurons in a layer
corr_max_sparsness_ref=zeros(1,nL);
for layerid=1:nL
    % extracting response and normalizing
    nNeurons=length(vec(features{1}(layerid).x));% number of neurons
    nNeu(layerid)=nNeurons;
    response=zeros(nNeurons,nimages); % initializing the matrix
    for ind=1:nimages
        response(:,ind)=vec(features{ind}(layerid).x); % extracting the response
    end
    nresponse=normalize(response','range');nresponse=nresponse'; % normalizing each neuron across all images
    van=find(sum(nresponse,2)>0); %visually active neurons, using sum effectively instead of variance, normalized ones will have values between 0 and 1. It will be zero for constant
    nvresponse=nresponse(van,:); % normalized response from visually active neurons
    nvan=length(van);nVAN(layerid)=nvan;
    % finding the sparsenes for each morphline
    SPAR=zeros(nvan,nMorphs+1);% 1 for refrence set
    for morphid=1:nMorphs
        qstim=[stim_per_morph*(morphid-1)+(1:stim_per_morph)]; % selecting the stim in each morphline
        SPAR(:,morphid)=sparseness(nvresponse(:,qstim)); % some nans will be created
    end
    SPAR(:,nMorphs+1)=sparseness(nvresponse(:,ref_Set));
    SPAR=round(SPAR,nDeci);% rounding to 4 decimal places
    for ind=1:length(pairs_sel)
        ind_1=pairs_sel(ind,1);ind_2=pairs_sel(ind,2);
        SEL_CORR(ind,layerid)=nancorrcoef(SPAR(:,ind_1),SPAR(:,ind_2));
    end
    max_sparsness=max(SPAR(:,1:4),[],2); % Max. correlation among four morphilines
    refset_sparsness=SPAR(:,5);
    corr_max_sparsness_ref(layerid)=nancorrcoef(max_sparsness,refset_sparsness); % correlation between max sparsness and reference set
end
end
