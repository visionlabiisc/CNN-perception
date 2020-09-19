%% Thatcher Effect check with a standard pretrained network
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
stim_file_name=sprintf('tatcherFaces.mat');
load(stim_file_name);
% Skip 50 pixels from top row and bottom row to remove the black region.
S=50;
for i =1:length(stim)
    x=stim{i};
    stim{i}=x(S:end-S,:,:);
end
%% Networks
% networks
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

time_taken=cell(length(type),1);
MI_across_layers=cell(length(type),1);
sel_colour=colormap('Lines');

% Effect Reference Level
reference_mi=(4.89-2.92)./(4.89+2.92); % Table-2, Bartlet and Searcy, 1993  
reference_name ='Bartlet and Searcy, 1993';
for iter=1:length(type)
    tstart=tic;
    fprintf('\n Network- %s \n',type{iter});
    % Extracting Features
    fprintf('\n Extracting Features\n');
    features=extract_features(stim,type{iter},dagg_flag(iter),run_path);
    nL=length(features{1})-1;
    fprintf('\n Checking thatcherization\n');
    thatcherIndex=CheckThatcherEffect(features);
    MI_across_layers{iter,1}=thatcherIndex;

%% Plotting
    dist_types='Euclidean';
    y_label='Thatcher Index';
    Saving_file_name=['..',SLASH,'results',SLASH,'Exp01-TI,net = ',network_short_name{iter},' metric = ',dist_types];
    if(iter<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures(nanmean(thatcherIndex,1),nansem(thatcherIndex,1),Saving_file_name,reference_mi,reference_name,dist_types,y_label);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures(nanmean(thatcherIndex,1),nansem(thatcherIndex,1),Saving_file_name,reference_mi,reference_name,dist_types,y_label);
    end
end
%% PLotting the effect for three networks
sel_index=[1,3,4];

N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N  
    mean_data(ind,:)=nanmean(MI_across_layers{sel_index(ind),1},1);
    sem_data(ind,:)=nansem(MI_across_layers{sel_index(ind),1},1);
end
file_name=['..',SLASH,'results',SLASH,'Exp01_mainfigure_VGG16_variants'];
layerwise_mi_figures(mean_data,sem_data,file_name,reference_mi,reference_name,network_short_name(sel_index),'Thatcher Index');

%% Plotting the effect for starting point during training
sel_index=[1,2];
N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N  
    mean_data(ind,:)=nanmean(MI_across_layers{sel_index(ind),1},1);
    sem_data(ind,:)=nansem(MI_across_layers{sel_index(ind),1},1);
end
file_name=['..',SLASH,'results',SLASH,'Exp01_suppfigure_comparing VGG16 with matconvnet VGG16'];
layerwise_mi_figures(mean_data,sem_data,file_name,reference_mi,reference_name,network_short_name(sel_index),'Thatcher Index');
