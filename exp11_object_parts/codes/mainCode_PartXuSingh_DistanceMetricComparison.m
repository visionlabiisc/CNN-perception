% Checking the results with other distance metrics
% Georgin Jacob,22-7-2020 : FIRST VERSION  
clc;allclear; close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];

%% STIM
file_name='xustim.mat';
load(file_name);stim=img;
%% Behavior Effect
reference_mi= 0.071;
reference_name='Xu and Singh, 2002';
%% NETWORK
type{1}='imagenet-vgg-verydeep-16';
dagg_flag=0;

%% Extract Features
features=extract_features(stim,type{1},dagg_flag(1),run_path);

%% Calculate Part-Matching Index 
dist_types={'Euclidean','CityBlock','pearson','spearman'};
N=length(dist_types);
MI_across_layers=cell(N,1);
for iter=1:N
    fprintf('\n Distance Metric = %s \n',dist_types{iter})
    MI_across_layers{iter,1}=check_part_matching(features,dist_types{iter});
end
%% Plotting the data
file_name=['..',SLASH,'results',SLASH,'Part_matching_Index_XUSINGH Distance Metric Comparison'];
y_label_name='Part-Matching Index';

for iter=1:N
    mean_data(iter,:)=MI_across_layers{iter,1};
end
sem_data=[];
layerwise_mi_figures(mean_data,sem_data,file_name,reference_mi,reference_name,dist_types(1:N),y_label_name);
%% SUBFUNCTIONS
function part_matching_index=check_part_matching(features,dist_type)
nL=length(features{1})-1;% Skipping the last layers
dN=zeros(2,nL);dU=zeros(2,nL);
for L=1:nL
    f=cell(6,1);
    for ind=1:6
        f{ind}=vec(squeeze(features{ind}(L).x));
    end
    dN(1,L)=distance_calculation(f{1},f{2},dist_type);
    dN(2,L)=distance_calculation(f{4},f{5},dist_type);
    
    dU(1,L)=distance_calculation(f{1},f{3},dist_type);
    dU(2,L)=distance_calculation(f{4},f{6},dist_type);
end
%%
part_matching_index=(dU-dN)./(dU+dN);
part_matching_index=nanmean(part_matching_index,1);
end