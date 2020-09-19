% Checking the webers law results with other distance metrics
clc;allclear; close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];
%% STIM
stim_file_name=['..',SLASH,'stim',SLASH,'webers_images_GJ.mat'];
load(stim_file_name);
%% Networks
type='imagenet-vgg-verydeep-16';
dagg_flag=0;
dist_types={'Euclidean','CityBlock','pearson','spearman'};
time_taken=cell(length(dist_types),1);

%% Length
stim_length=imgs.len;stim_length=stim_length(:);
absolute_delta_L=absdel.len;
relative_delta_L=reldel.len;

% % Intensity
% stim_Intensity=imgs.int;stim_Intensity=stim_Intensity(:);
% absolute_delta_I=absdel.int;
% relative_delta_I=reldel.int;

%% Behavioral Effect
reference_mi_Length=0.1;
reference_name ='Pramod and Arun, 2014';
y_label='Correlation coefficient difference(relative -absolute)';

% Extract Features
features=extract_features(stim_length,type,dagg_flag,run_path);

% Calculate Webers Law with different distance metric
N=length(dist_types);MI_across_layers=cell(N,1);
for iter=1:N
    fprintf('\n Distance Metric = %s \n',dist_types{iter})
    [r_relativeL, r_absoluteL]=check_webers_law(features,absolute_delta_L,relative_delta_L,dist_types{iter});
    MI_across_layers{iter,1}=r_relativeL-r_absoluteL;
end
% Plotting the data
for ind=1:N
    mean_data(ind,:)=MI_across_layers{ind,1};
end
file_name=['..',SLASH,'results',SLASH,'Webers Law for length Distance Metric Comparison'];
layerwise_mi_figures(mean_data,[],file_name,reference_mi_Length,reference_name,dist_types(1:N),y_label);
