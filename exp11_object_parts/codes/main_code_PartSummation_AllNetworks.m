%% Part-Summation model check with a standard pretrained network
% Credits  : GEORGIN
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
legend_name={'VGG-16','mat.VGG-16','VGG-16 randn','VGG-face','Alexnet','Goolgenet','ResNet 50','ResNet 152'};
%% STIM
file_name_stim='natunat_stim.mat';
load(file_name_stim);
stim=images;
for ind=1:length(stim)
    stim{ind}=padarray(stim{ind},[0,50],0,'both');
end
%% Behavior Effect
reference_mi=  0.16;
reference_name='Pramod and Arun, 2016';
y_label_name='Natural Part Advantage';
dist_types='Euclidean';
time_taken=cell(length(type),1);
MI_across_layers=cell(length(type),1);

for iter=1:length(type)
    tstart=tic;
    fprintf('\n Network = %s',type{iter});
    features=extract_features(stim,type{iter},dagg_flag(iter),run_path);
    [r_natural,r_unnatural]=check_part_summation(features,L2_str,dist_types);
    MI_across_layers{iter,1}=r_natural-r_unnatural;
    time_taken{iter}=toc(tstart);
    fprintf('\n Time taken to run = %2.2f (s)',time_taken{iter});

    % Plotting and Saving
    file_name=['..',SLASH,'results',SLASH,'ALL_networks_Part_Summation_Pramod_Network=',type{iter}];
    y_lim=[-0.2,0.2];if(iter==4),  y_lim=[-0.5,0.5];end
    
    if(iter<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures_part_summation(MI_across_layers{iter,1}',[],file_name,reference_mi,reference_name,dist_types,y_label_name,[],y_lim);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures_part_summation(MI_across_layers{iter,1}',[],file_name,reference_mi,reference_name,dist_types,y_label_name,[],y_lim);
    end
end
%% Comparing VGG-16 Networks
sel_index=[1,3];N=length(sel_index);
mean_data=zeros(N,37);
y_lim=[-0.2,0.2];
for ind=1:N
    mean_data(ind,:)=MI_across_layers{sel_index(ind),1}';
end
file_name_mainfigure=['..',SLASH,'results',SLASH,'Part_matching_Index_Pramod_main_figure'];
layerwise_mi_figures_part_summation(mean_data,[],file_name_mainfigure,reference_mi,reference_name,legend_name(sel_index),y_label_name,[],y_lim);

%% Comparing VGG-16 with matconvnet VGG-16
sel_index=[1,2];N=length(sel_index);
mean_data=zeros(N,37);
sem_data=zeros(N,37);
y_lim=[-0.2,0.2];
for ind=1:N
    mean_data(ind,:)=MI_across_layers{sel_index(ind),1}';
end
file_name_mainfigure=['..',SLASH,'results',SLASH,'Part_matching_Index_Pramod_supp_figure_VGGmatconvnet'];
layerwise_mi_figures_part_summation(mean_data,[],file_name_mainfigure,reference_mi,reference_name,legend_name(sel_index),y_label_name,[],y_lim);