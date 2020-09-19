%% Mirror Confusion Check from a standard pretrained network
% Credits  : GEORGIN
clc;allclear; close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];
%% STIM
stim_file_name=sprintf('natural_stim_50_rotated_90.mat');
load(stim_file_name);

%% Networks
type='imagenet-vgg-verydeep-16';
dagg_flag=0;
dist_types={'Euclidean','CityBlock','pearson','spearman'};

network_short_name='VGG-16';
%% MAIN CODE
time_taken=cell(length(type),1);
MI_across_layers=cell(length(type),1);
%% Reference
reference_mi=(16.075-14.33)/(16.075+14.33);
reference_name='Rollenhagen & Olson, 2000';

%% Extracting Features and calculating mirror confusion index
tic
fprintf('\n Network- %s \n',type);
mirror_confusion_index=CheckMirrorConfusion(stim,type,dagg_flag,run_path,dist_types);
toc

%% Plotting the effect for three networks
sel_index=1:4;
N=length(sel_index);mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N
    mean_data(ind,:)=nanmean(mirror_confusion_index(:,:,sel_index(ind)),1);
    sem_data(ind,:)=nansem(mirror_confusion_index(:,:,sel_index(ind)),1);
end
file_name=sprintf('..%sresults%sExp02_VGG16 distance_metric_comparison',SLASH,SLASH);
layerwise_mi_figures(mean_data,sem_data,file_name,reference_mi,reference_name,dist_types(sel_index),'Mirror Confusion Index');
%% Sub Functions
function [features,net]=extract_features(net,stim,type,dagg_flag,run_path)
if(dagg_flag==0)
    if(isempty(net))
        run(run_path);
        net = load(type) ;
        net = vl_simplenn_tidy(net);
    end
    nimages=length(stim);
    features=cell(nimages,1);
    Src=net.meta.normalization.imageSize(1:2);% size of the normalized image
    rgb_values=net.meta.normalization.averageImage;rgb_values=rgb_values(:);
    average_image=ones(Src(1),Src(2),3);
    for ind=1:3,average_image(:,:,ind)=rgb_values(ind);end
    for ind=1:nimages
        bimage_ip=single(stim{ind});
        if size(bimage_ip,3)==1, bimage_ip = repmat(bimage_ip,1,1,3); end
        cimage=imresize(bimage_ip,Src);
        cimage=cimage-average_image;
        features{ind}=vl_simplenn(net,cimage);
    end
elseif(dagg_flag==1)
    if(isempty(net))
        run(run_path);
        net = dagnn.DagNN.loadobj(load(type)) ;
        net.mode = 'test' ;
    end
    nimages=length(stim);
    features=cell(nimages,1);
    net.conserveMemory=0;
    nL=length(net.layers)-1;
    for i=1:nimages
        bimage_ip=single(stim{i});
        cimage=imresize(bimage_ip,net.meta.normalization.imageSize(1:2));
        cimage = bsxfun(@minus, cimage, net.meta.normalization.averageImage) ;
        %cimage=cimage-ones(1,1,3)*128; % abstract images
        net.eval({'data', cimage})
        for L=1:nL
            scores(L).x = vec(net.vars(L).value);
        end
        features{i}=scores;
    end
end
end

function mirror_confusion_index=CheckMirrorConfusion(stim,type,dagg_flag,run_path,dist_types)
% Here I assume the Stimuli is arrange in a particulr order
% 100 unique stimuli, followed by 100 mirror about y-axis, followed by 100 mirror about x-axis
N=100; % There are 100 unique stimuli
mirror_confusion_index=[]; % Horizonatal , Vertical
net=[];
for img=1:N
    fprintf('%d,',img);
    img_numbers=[img,N+img,2*N+img];
    stim_sub=stim(img_numbers);
    [features,net]=extract_features(net,stim_sub,type,dagg_flag,run_path);
    nL=length(features{1})-1;
    for L=1:nL
        fi=squeeze(features{1}(L).x);
        fYm=squeeze(features{2}(L).x);
        fXm=squeeze(features{3}(L).x);
        for d=1:length(dist_types)
            dYm=distance_calculation(vec(fYm),vec(fi),dist_types{d});% MIRROR ABOUT X-axis
            dXm=distance_calculation(vec(fXm),vec(fi),dist_types{d});% MIRROR ABOUT Y-axis
            mirror_confusion_index(img,L,d)=(dXm-dYm)./(dXm+dYm);
        end
    end
end
end