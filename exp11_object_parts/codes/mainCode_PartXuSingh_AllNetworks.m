% Code for checking part matching: Xu and Singh
clc;allclear; close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];
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
network_short_name={'VGG-16','mat.VGG-16','VGG-16 randn','VGG-face','Alexnet','Goolgenet','ResNet 50','ResNet 152'};
%% STIM
file_name_stim='xustim.mat';
load(file_name_stim);stim=img;
%% Behavior Effect
reference_mi= 0.071;
reference_name='Xu and Singh, 2002';
y_label_name='Part-Matching Index';
dist_types='Euclidean';
%%
time_taken=cell(length(type),1);
MI_across_layers=cell(length(type),1);
for iter=1:length(type)
    tstart=tic;
    fprintf('\n Network = %s',type{iter});
    features=extract_features(stim,type{iter},dagg_flag(iter),run_path);
    MI_across_layers{iter}=check_part_matching(features);
    time_taken{iter}=toc(tstart);
    fprintf('\n Time taken to run = %2.2f (s)',time_taken{iter});
    
    % Plotting and Saving
    Saving_file_name=['..',SLASH,'results',SLASH,'ALL_networks_Part_matching_Index_XUSINGH_Network=',type{iter}];
    
    if(iter<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures(nanmean(MI_across_layers{iter},1),nansem(MI_across_layers{iter},1),Saving_file_name,reference_mi,reference_name,dist_types,y_label_name);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures(nanmean(MI_across_layers{iter},1),nansem(MI_across_layers{iter},1),Saving_file_name,reference_mi,reference_name,dist_types,y_label_name);
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
figure_name_mainfig=['..',SLASH,'results',SLASH,'Part_matching_Index_XUSINGH_main_figure'];
layerwise_mi_figures(mean_data,sem_data,figure_name_mainfig,reference_mi,reference_name,network_short_name(sel_index),y_label_name);

%% Comparing VGG-16 with VGG-16 matconvnet
sel_index=[1,2];N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N
    mean_data(ind,:)=nanmean(MI_across_layers{sel_index(ind),1},1);
    sem_data(ind,:)=nansem(MI_across_layers{sel_index(ind),1},1);
end
figure_name_mainfig=['..',SLASH,'results',SLASH,'Part_matching_Index_XUSINGH_supp_figure_matconvnet_comparison'];
layerwise_mi_figures(mean_data,sem_data,figure_name_mainfig,reference_mi,reference_name,network_short_name(sel_index),y_label_name);
