% RELSIZE CODES
% Credits: GJ
clc;clear all;close all;

%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];

%% STIM 
filename_stim='relSize.mat';
load(filename_stim);
%% Netw orks to be tested
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

reference_mi=0.39;
reference_name='Vighneshvel & Arun 2015';
grey_region_name='IT Interaction effect for 7% of tetrads';
y_label='average realative size index for top 7 % of tetrads';
for iter=1:length(type)
    tstart=tic;
    fprintf('\n Extracting Features\n');
    features_relsize=extract_features(stim,type{iter},dagg_flag(iter),run_path);
    [miLayerwise_selected_mean,miLayerwise_selected_sem]=check_relsize_effect(features_relsize);
    MI_across_layers{iter,1}=miLayerwise_selected_mean;
    MI_across_layers{iter,2}=miLayerwise_selected_sem;
    
    %% Plotting
    fprintf('\n Plotting..\n');

    Saving_file_name=['..',SLASH,'results',SLASH,'Exp07-Rel. Size, net = ',network_short_name{iter}];
    if(iter<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures(MI_across_layers{iter,1}',MI_across_layers{iter,2}',Saving_file_name,reference_mi,reference_name,network_short_name{iter},y_label,grey_region_name);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures(MI_across_layers{iter,1}',MI_across_layers{iter,2}',Saving_file_name,reference_mi,reference_name,network_short_name{iter},y_label,grey_region_name);
    end
end
%% Plotting the effect for VGG-16 and Random Network
sel_index=[1,3];N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N
    mean_data(ind,:)=MI_across_layers{sel_index(ind),1};
    sem_data(ind,:)=MI_across_layers{sel_index(ind),2};
end

Saving_file_name=['..',SLASH,'results',SLASH,'Exp07_REL_size_main_figure'];
layerwise_mi_figures(mean_data,sem_data,Saving_file_name,reference_mi,reference_name,network_short_name(sel_index),y_label,grey_region_name);

%% Plotting the effect for VGG-16 and Matconvnet
sel_index=[1,2];N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N
    mean_data(ind,:)=MI_across_layers{sel_index(ind),1};
    sem_data(ind,:)=MI_across_layers{sel_index(ind),2};
end
Saving_file_name=['..',SLASH,'results',SLASH,'Exp07_REL_size_supp_figure_VGG16_verus_matconvnet'];
layerwise_mi_figures(mean_data,sem_data,Saving_file_name,reference_mi,reference_name,network_short_name(sel_index),y_label,grey_region_name);
