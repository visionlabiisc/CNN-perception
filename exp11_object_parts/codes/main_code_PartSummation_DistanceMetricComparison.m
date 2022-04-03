%% Part-Summation model with distance metric check using a standard pretrained network
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
type='imagenet-vgg-verydeep-16';
dagg_flag=0;
short_name='VGG-16';
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
dist_types={'Euclidean','CityBlock','pearson','spearman'};
time_taken=cell(length(type),1);
load('L2_natunat.mat');
%% Extract Features
features=extract_features(stim,type,dagg_flag,run_path);
%% Calculate the part-summation model with different distance metric
N=length(dist_types);
MI_across_layers=cell(N,1);
for iter=1:N
    fprintf('\n Distance Metric = %s \n',dist_types{iter})
    [r_natural,r_unnatural]=check_part_summation(features,L2_str,dist_types{iter});
    MI_across_layers{iter,1}=r_natural-r_unnatural;
end
%% Plotting the data
mean_data=[];
sem_data=[];
for ind=1:N
    mean_data(ind,:)=MI_across_layers{ind,1};
end 
file_name=['..',SLASH,'results',SLASH,'Part-Matching_Pramod_Distance Metric Comparison'];
y_lim=[-0.2,0.2];
layerwise_mi_figures_part_summation(mean_data,sem_data,file_name,reference_mi,reference_name,dist_types(1:N),y_label_name,[],y_lim);

