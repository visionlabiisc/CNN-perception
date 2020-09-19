% Global Local Main code
% Change Log
% Georgin 26-12-2018 : First Version
% Georgin 19-7-2020 : 1. General Code for Linux and Windows 2. Changed from relative path to absolutre

clc;allclear; close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];
%% STIM
file_name_stim=['..',SLASH,'stim',SLASH,'GL.mat'];
load(file_name_stim);
%% NETWORK
type{1}='imagenet-vgg-verydeep-16';
type{2}='imagenet-matconvnet-vgg-verydeep-16.mat';
type{3}='imagenet-vgg-verydeep-16_randn.mat';
type{4}='imagenet-vgg-face';
type{5}='imagenet-caffe-alex';
type{6}='imagenet-googlenet-dag';
type{7}='imagenet-resnet-50-dag';
type{8}='imagenet-resnet-152-dag';
dagg_flag=[0,0,0,0,0,1,1,1];
legend_name={'VGG-16','mat.VGG-16','VGG-16 randn','VGG-face','Alexnet','Goolgenet','ResNet 50','ResNet 152'};

time_taken=cell(length(type),1);
MI_across_layers=cell(length(type),1);
imagepairDetails=L2_str.Image_Pair_Details;

%% Behavior effect Calculation
% RT=L2_str.RT.trial_wise;RT=nanmean(RT,3);RT=nanmean(RT,2);dobs=1./RT;
% reference_mi=check_global_local_behavior(dobs,imagepairDetails);
reference_mi=0.0975;
reference_name='Jacob and Arun, 2019';
y_label_name='Global Advantage Index';
dist_types='Euclidean';
for iter=1:length(type)
    tstart=tic;
    fprintf('\n Network = %s',type{iter});
    features=extract_features(stim,type{iter},dagg_flag(iter),run_path);
    
    % Global Local
    [mi_global_local]=check_global_local(features,imagepairDetails);
    MI_across_layers{iter,1}=mi_global_local; % This is a mean data
    time_taken{iter}=toc(tstart);
    fprintf('\n Time taken to run = %2.2f (s)',time_taken{iter});
    
    % Plotting and Saving
    file_name_pdf=['..',SLASH,'results',SLASH,'ALL_networks_global_local_Network=',type{iter}];
    
    if(iter<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures(mi_global_local,[],file_name_pdf,reference_mi,reference_name,dist_types,y_label_name);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures(mi_global_local,[],file_name_pdf,reference_mi,reference_name,dist_types,y_label_name);
    end
end
%% Comparing VGG-16 Networks
sel_index=[1,3];N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N
    mean_data(ind,:)=nanmean(MI_across_layers{sel_index(ind),1},1);
    sem_data(ind,:)=nansem(MI_across_layers{sel_index(ind),1},1);
end
file_name_pdf_main=['..',SLASH,'results',SLASH,'global_advantage_main_figure'];
layerwise_mi_figures(mean_data,sem_data,file_name_pdf_main,reference_mi,reference_name,legend_name(sel_index),y_label_name);

%% Comparing VGG-16 versus VGG-16 matconvnet 
sel_index=[1,2];N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N
    mean_data(ind,:)=nanmean(MI_across_layers{sel_index(ind),1},1);
    sem_data(ind,:)=nansem(MI_across_layers{sel_index(ind),1},1);
end
file_name_pdf_main=['..',SLASH,'results',SLASH,'global_advantage_supp_figure_VGG16_versus_VGG16matconvnet'];
layerwise_mi_figures(mean_data,sem_data,file_name_pdf_main,reference_mi,reference_name,legend_name(sel_index),y_label_name);
