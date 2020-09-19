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
type{1}='imagenet-vgg-verydeep-16';
type{2}='imagenet-matconvnet-vgg-verydeep-16.mat';
type{3}='imagenet-vgg-verydeep-16_randn.mat';
type{4}='imagenet-vgg-face';
type{5}='imagenet-caffe-alex';
type{6}='imagenet-googlenet-dag';
type{7}='imagenet-resnet-50-dag';
type{8}='imagenet-resnet-152-dag';
dagg_flag=[0,0,0,0,0,1,1,1];

network_short_name={'VGG-16','mat.VGG-16','VGG-16 randn','VGG-face','Alexnet','Goolgenet','ResNet 50','ResNet 152'};
%% MAIN CODE
time_taken=cell(length(type),1);
MI_across_layers=cell(length(type),1);
%% Reference
reference_mi=(16.075-14.33)/(16.075+14.33);
reference_name='Rollenhagen & Olson, 2000';

for iter=1:length(type)
    tstart=tic;
    fprintf('\n Network- %s \n',type{iter});

    fprintf('\n Extracting Features and Calculating Mirror Confusion \n');
    mirror_confusion_index=CheckMirrorConfusion(stim,type{iter},dagg_flag(iter),run_path);
    MI_across_layers{iter,1}=nanmean(mirror_confusion_index,1);
    MI_across_layers{iter,2}=nansem(mirror_confusion_index,1); 
    %% Plotting
    dist_types='Euclidean';
    y_label='Mirror Confusion Index';
    Saving_file_name=['..',SLASH,'results',SLASH,'Exp02-MCI,net = ',network_short_name{iter},' metric = ',dist_types];
    if(iter<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures(nanmean(mirror_confusion_index,1),nansem(mirror_confusion_index,1),Saving_file_name,reference_mi,reference_name,dist_types,y_label);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures(nanmean(mirror_confusion_index,1),nansem(mirror_confusion_index,1),Saving_file_name,reference_mi,reference_name,dist_types,y_label);
    end
    time_taken{iter}=toc(tstart);
end
%% PLotting the effect for three networks
sel_index=[1,3];
N=length(sel_index);mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N
    mean_data(ind,:)=MI_across_layers{sel_index(ind),1};
    sem_data(ind,:)=MI_across_layers{sel_index(ind),2};
end
file_name=sprintf('..%sresults%sExp02_MainFigure',SLASH,SLASH);
layerwise_mi_figures(mean_data,sem_data,file_name,reference_mi,reference_name,network_short_name(sel_index),'Mirror Confusion Index');

%% Plotting the effect for starting point during training
sel_index=[1,2];
N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N
    mean_data(ind,:)=MI_across_layers{sel_index(ind),1};
    sem_data(ind,:)=MI_across_layers{sel_index(ind),2};
end
file_name=['..',SLASH,'results',SLASH,'Exp02_suppfigure_comparing VGG16 with matconvnet VGG16'];
layerwise_mi_figures(mean_data,sem_data,file_name,reference_mi,reference_name,network_short_name(sel_index),'Mirror Confusion Index');
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

function mirror_confusion_index=CheckMirrorConfusion(stim,type,dagg_flag,run_path)
% Here I assume the Stimuli is arrange in a particulr order
% 100 unique stimuli, followed by 100 mirror about y-axis, followed by 100 mirror about x-axis 
N=100; % There are 100 unique stimuli
mirror_confusion_index=[]; % Horizonatal , Vertical
net=[];
for img=1:N
    img_numbers=[img,N+img,2*N+img];
    stim_sub=stim(img_numbers);
    [features,net]=extract_features(net,stim_sub,type,dagg_flag,run_path);
    nL=length(features{1})-1;
    for L=1:nL
        fi=squeeze(features{1}(L).x);
        fYm=squeeze(features{2}(L).x);
        fXm=squeeze(features{3}(L).x);
        dYm=norm(fYm(:)-fi(:),2);% MIRROR ABOUT X-axis
        dXm=norm(fXm(:)-fi(:),2);% MIRROR ABOUT Y-axis
        mirror_confusion_index(img,L)=(dXm-dYm)./(dXm+dYm);
    end
end
end