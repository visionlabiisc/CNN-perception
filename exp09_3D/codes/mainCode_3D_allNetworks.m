% figure code 3D perception
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
file_name_stim='3d.mat';
load(file_name_stim);  % Images

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
%% Effect Reference Level
reference_mi(1)=0.4;reference_name{1}='Enns & Rensink,1990';
reference_mi(2)=0.76;reference_name{2}='Enns & Rensink,1991';
%% EXTRACT FEATURES
time_taken=cell(length(type),1);
MI_across_layers=cell(length(type),1);
dist_types='Euclidean';
y_label='3D Index';
for iter=1:length(type)
    tstart=tic;
    fprintf('\n Extracting Features\n');
    features=extract_features(stim,type{iter},dagg_flag(iter),run_path);
    mi_3d=check_3D(features,dist_types);
    
    MI_across_layers{iter,1}=mi_3d(1,:); % This is a mean data
    MI_across_layers{iter,2}=mi_3d(2,:); % This is a mean data
    
    
    %% Plotting
    legend_name={'Cond-1','Cond-2'};
    Saving_file_name=['..',SLASH,'results',SLASH,'Exp09-3D,net = ',network_short_name{iter},' metric = ',dist_types];
    if(iter<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures(mi_3d,[],Saving_file_name,reference_mi,reference_name,legend_name,y_label);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures(mi_3d,[],Saving_file_name,reference_mi,reference_name,legend_name,y_label);
    end
    
    time_taken{iter}=toc(tstart);
end
%% Plotting the effect for two networks
sel_index=[1,3];N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N
    mean_data(2*ind-1,:)=MI_across_layers{sel_index(ind),1};
    mean_data(2*ind,:)=MI_across_layers{sel_index(ind),2};
end
legend_name={['Cond-1 ',network_short_name{1}],['Cond-2 ',network_short_name{1}],['Cond-1 ',network_short_name{3}],['Cond-2 ',network_short_name{3}]};
Saving_file_name=['..',SLASH,'results',SLASH,'3D_main_figure'];

order=[1,3,2,4];
mean_data=mean_data(order,:);
legend_name=legend_name(order);
layerwise_mi_figures(mean_data,[],Saving_file_name,reference_mi,reference_name,legend_name,y_label);

%% Comparng vgg16 versus vgg16 matconvnet
sel_index=[1,2];N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
for ind=1:N
    mean_data(2*ind-1,:)=MI_across_layers{sel_index(ind),1};
    mean_data(2*ind,:)=MI_across_layers{sel_index(ind),2};
end
legend_name={['Cond-1 ',network_short_name{sel_index(1)}],['Cond-2 ',network_short_name{sel_index(1)}],['Cond-1 ',network_short_name{sel_index(2)}],['Cond-2 ',network_short_name{sel_index(2)}]};
Saving_file_name=['..',SLASH,'results',SLASH,'3D_supp_figure_VGG16_VGG16matconvenet'];

order=[1,3,2,4];
mean_data=mean_data(order,:);
legend_name=legend_name(order);
layerwise_mi_figures(mean_data,[],Saving_file_name,reference_mi,reference_name,legend_name,y_label);


