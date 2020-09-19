clc;clear all;close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];
%% STIM
stim_file_name='webers_images_GJ.mat';
load(stim_file_name);
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
%% Length
stim_length=imgs.len;stim_length=stim_length(:);
absolute_delta_L=absdel.len;
relative_delta_L=reldel.len;
% Intensity
stim_Intensity=imgs.int;stim_Intensity=stim_Intensity(:);
absolute_delta_I=absdel.int;
relative_delta_I=reldel.int;
time_taken=cell(length(type),1);
RC_across_layers=cell(length(type),1);

%% Behavioral Effect
reference_mi_Length=0.1;
reference_name ='Pramod and Arun, 2014';
dist_type='Euclidean';
for iter=1:length(type)
    tstart=tic;
    fprintf('\n Network- %s\n',type{iter});
    % length
    features=extract_features(stim_length,type{iter},dagg_flag(iter),run_path);
    [r_relativeL, r_absoluteL]=check_webers_law(features,absolute_delta_L,relative_delta_L,dist_type);
    RC_across_layers{iter,1}=r_relativeL-r_absoluteL;
    
    % Intensity
    features=extract_features(stim_Intensity,type{iter},dagg_flag(iter),run_path);
    [r_relativeI, r_absoluteI]=check_webers_law(features,absolute_delta_I,relative_delta_I,dist_type);
    RC_across_layers{iter,2}=r_relativeI-r_absoluteI;
    %% Plotting
    y_label='Correlation coefficient difference(relative -absolute)';
    Saving_file_name=['..',SLASH,'results',SLASH,'Exp06-Webers Law, net = ',network_short_name{iter},' metric = ',dist_type];
    if(iter<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures(RC_across_layers{iter,1},[],Saving_file_name,reference_mi_Length,reference_name,dist_type,y_label);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures(RC_across_layers{iter,1},[],Saving_file_name,reference_mi_Length,reference_name,dist_type,y_label);
    end
    time_taken{iter}=toc(tstart);
end
%% Plotting the effect for VGG-16 and random Network
% Length
sel_index=[1,3];N=length(sel_index);
mean_data=zeros(N,37);
for ind=1:N
    mean_data(ind,:)=RC_across_layers{sel_index(ind),1};
end
sem_data=[];
y_label='Correlation coefficient difference(relative -absolute)';
Saving_file_name_mainfig=['..',SLASH,'results',SLASH,'WebersLaw_Length_main_figure'];
layerwise_mi_figures(mean_data,[],Saving_file_name_mainfig,reference_mi_Length,reference_name,network_short_name(sel_index),y_label);
%% Plotting the effect for VGG-16 and VGG-16 matconvenet
% Length
sel_index=[1,2];N=length(sel_index);
mean_data=zeros(N,37);
for ind=1:N
    mean_data(ind,:)=RC_across_layers{sel_index(ind),1};
end
sem_data=[];
y_label='Correlation coefficient difference(relative -absolute)';
Saving_file_name_mainfig=['..',SLASH,'results',SLASH,'WebersLaw_Length_supp_figure_matconvnet'];
layerwise_mi_figures(mean_data,[],Saving_file_name_mainfig,reference_mi_Length,reference_name,network_short_name(sel_index),y_label);


