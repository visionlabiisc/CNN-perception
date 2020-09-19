% Rsurf figure codes;
% GJ 13-10-2018
clc;clear all;close all;

%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();

%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];

%% STIM
filename_stim='rsurf.mat';
load(filename_stim);

%% Networks to be tested
type{1}='imagenet-vgg-verydeep-16';
type{2}='imagenet-matconvnet-vgg-verydeep-16.mat';
type{3}='imagenet-vgg-verydeep-16_randn.mat';
type{4}='imagenet-vgg-face';
type{5}='imagenet-caffe-alex';
type{6}='imagenet-googlenet-dag';
type{7}='imagenet-resnet-50-dag';
type{8}='imagenet-resnet-152-dag';
network_short_name={'VGG-16','mat.VGG-16','VGG-16 randn','VGG-face','Alexnet','Goolgenet','ResNet 50','ResNet 152'};
dagg_flag=[0,0,0,0,0,1,1,1];

time_taken=cell(length(type),1);
MI_across_layers=cell(length(type),1);

reference_mi=0.55;
reference_name='Ratan Murty & Arun 2016';
grey_region_name='IT Interaction effect for 9% of tetrads';
y_label='average of surface invariance index for top 9 % tetrads';
for iter=1:2%length(type)
    tstart=tic;
    fprintf('\n Extracting Features\n');
    features=extract_features(stim,type{iter},dagg_flag(iter),run_path);
    [miLayerwise_selected_mean,miLayerwise_selected_sem]=check_rsurf_effect(features);
    MI_across_layers{iter,1}=miLayerwise_selected_mean;
    MI_across_layers{iter,2}=miLayerwise_selected_sem;
    
%     %% Plotting
%     fprintf('\n Plotting..\n');

%     Saving_file_name=['..',SLASH,'results',SLASH,'Exp08-Rsurf, net = ',network_short_name{iter}];
%     if(iter<=4) % Layer-wise plot for VGG-Network
%         layerwise_mi_figures(MI_across_layers{iter,1}',MI_across_layers{iter,2}',Saving_file_name,reference_mi,reference_name,network_short_name{iter},y_label,grey_region_name);
%     else % layer-wise plot for other network
%         layerwise_mi_nonVGGfigures(MI_across_layers{iter,1}',MI_across_layers{iter,2}',Saving_file_name,reference_mi,reference_name,network_short_name{iter},y_label,grey_region_name);
%     end
%     time_taken{iter}=toc(tstart);
end
% 
% %% PLotting the effect for VGG-16 and random networks
% sel_index=[1,3];N=length(sel_index);
% mean_data=zeros(N,37);
% sem_data=zeros(N,37);
% for ind=1:N
%     mean_data(ind,:)=MI_across_layers{sel_index(ind),1};
%     sem_data(ind,:)=MI_across_layers{sel_index(ind),2};
% end
% Saving_file_name=['..',SLASH,'results',SLASH,'Exp08_Rsurf_main_figure'];
% layerwise_mi_figures(mean_data,sem_data,Saving_file_name,reference_mi,reference_name,network_short_name(sel_index),y_label,grey_region_name);

%% PLotting the effect for VGG-16 and vgg16 matconvenet
sel_index=[1,2];N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N
    mean_data(ind,:)=MI_across_layers{sel_index(ind),1};
    sem_data(ind,:)=MI_across_layers{sel_index(ind),2};
end
Saving_file_name=['..',SLASH,'results',SLASH,'Exp08_Rsurf_supp_figure_vgg16_verus_matconvnet'];
layerwise_mi_figures(mean_data,sem_data,Saving_file_name,reference_mi,reference_name,network_short_name(sel_index),y_label,grey_region_name);