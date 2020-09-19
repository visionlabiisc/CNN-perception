function [miLayerwise_selected_mean,miLayerwise_selected_sem]=check_rsurf_effect(features)
nimages=length(features);
p.nL=length(features{1})-1;
p.nSETS=6;
p.nGroups=4;
p.nStimPerSet=13;
p.percentage_selected=0.09;

miLayerwise_selected_mean=zeros(p.nL,1);
miLayerwise_selected_sem=zeros(p.nL,1);
nTetrad=zeros(p.nL,p.nSETS*p.nGroups);
array_neuron_stats=zeros(p.nL,3);% neurons per layer, visually active neurons, tetrads showing positive RE

for layerid=1:p.nL
    fprintf('\n Layer - %d',layerid);
    % getting response and normalizing
    nNeurons=length(vec(features{1}(layerid).x));
    array_neuron_stats(layerid,1)=nNeurons;
    response=zeros(nNeurons,nimages);
    for ind=1:nimages
        response(:,ind)=vec(features{ind}(layerid).x);
    end
    nresponse=normalize(response','range');nresponse=nresponse';
    
    van=find(sum(nresponse,2)>0); %visually active neurons
    nvresponse=nresponse(van,:); % normalized response from visually active neurons
    nvan=length(van);
    array_neuron_stats(layerid,2)=nvan/nNeurons;
    %init
    RE_L=zeros( nvan,p.nSETS*p.nGroups); % residual error
    selected_tetrads=zeros( nvan,p.nSETS*p.nGroups); % selected tetrads
    MI_L=zeros(size(nresponse,1),p.nSETS*p.nGroups); % modulation index layerwise
    MI_L_average=[];
    count=0;
    MIn=[];
    for set=1:p.nSETS
        set_start=p.nStimPerSet*(set-1)+1;
        for group=1:p.nGroups
            count=count+1;
            imag=set_start+[0,(group-1)*3+(1:3)];
            
            % Repeating the analysis from paper.
            % selecting visually active neuron. Select the neurons having
            % positive residual error. Checking if those neurons shows the
            % rsurf effect.
            n_img1=nresponse(van,imag(1));
            n_img2=nresponse(van,imag(2));
            n_img3=nresponse(van,imag(3));
            n_img4=nresponse(van,imag(4));
            temp_sum=sum([n_img1,n_img2,n_img3,n_img4],2);
            n_active_tertads=length(find(temp_sum>0));
            nTetrad(layerid,count)=n_active_tertads;
            % removing the non active tetrads
            index=find(temp_sum<=0);
            n_img1(index)=NaN;
            n_img2(index)=NaN;
            n_img3(index)=NaN;
            n_img4(index)=NaN;
            mr1=(n_img1+n_img2)/2;mr2=(n_img3+n_img4)/2;
            mc1=(n_img1+n_img3)/2;mc2=(n_img2+n_img4)/2;
            T=[n_img1,n_img2,n_img3,n_img4];
            re=T+mean(T,2)-[mr1, mr1,mr2,mr2]-[mc1, mc2, mc1, mc2];% finding the resudual error
            RE_L(:,count)=sum(abs(re),2);
            %calculating MI per neurons
            d14=abs(n_img1-n_img4);
            d23=abs(n_img2-n_img3);
            MIn(:,count)=(d23-d14)./(d14+d23);
            
            % repeating the default analysis by appending all the neuronal
            % response to form a single feature per image per layer
            img1=response(van,imag(1));
            img2=response(van,imag(2));
            img3=response(van,imag(3));
            img4=response(van,imag(4));
            % modulation index
            d14_avg=norm(img1-img4,2);
            d23_avg=norm(img2-img3,2);
            MI_Layerwise(layerid,count)=(d23_avg-d14_avg)/(d14_avg+d23_avg); % modulation index of a tetrad
            
        end
    end
    % selecting tetrads
    MIn_selected=MIn(:); %vectroizing the MI of tetrads
    vactorized_RE_L=RE_L(:);
    vactorized_RE_L(isnan(vactorized_RE_L))=-9999999;  % representing NaN as a large negative value, This is done to match the indexing
    [tempV,tempI]=sort(vactorized_RE_L,'descend'); % sorting the vectroized RI
    count_active_tetrads=sum( nTetrad(layerid,:));
    
    %------------ Selection between fraction of tetrad and all tetrads
    % showing positive interaction.
    temp_number=floor(p.percentage_selected*count_active_tetrads);
    %temp_number=length(find(tempV>0)); % selecting all tetrad having positive residual error
    array_neuron_stats(layerid,3)=temp_number/(nNeurons*p.nSETS *p.nGroups);
    %----------------
    selected_tetrads=selected_tetrads(:);
    selected_tetrads(tempI(1:temp_number))=1;%tempV(1:p.SEL_TETRAD);% weighting the selected tetrad with their RE
    MIn_selected(selected_tetrads(:)==0)=[];
    
    %%%%
    fprintf('\nAmong Selected ( max RE = %.2f min RE = %.2f ) \n',max(tempV(1:temp_number)),min(tempV(1:temp_number)))
    %%%%%%
    % mean and SEM
    miLayerwise_selected_mean(layerid)=nanmean(MIn_selected);
    miLayerwise_selected_sem(layerid)=nansem(MIn_selected);

end
end