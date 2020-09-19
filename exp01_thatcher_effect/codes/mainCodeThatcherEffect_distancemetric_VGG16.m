% Checking the results with other distance metrics
clc;clear all;close all;
clc;allclear; close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];
%% STIM
stim_file_name=sprintf('tatcherFaces.mat');
load(stim_file_name);
% Skip 50 pixels from top row and bottom row to remove the black region.
S=50;
for i =1:length(stim)
    x=stim{i};
    stim{i}=x(S:end-S,:,:);
end
%% Networks
type='imagenet-vgg-verydeep-16';
dagg_flag=0;
dist_types={'Euclidean','CityBlock','pearson','spearman'};
time_taken=cell(length(dist_types),1);
MI_across_layers=cell(length(dist_types),1);

% Effect Reference Level
reference_mi=(4.89-2.92)./(4.89+2.92); % Table-2, Bartlet and Searcy, 1993  
reference_name ='Bartlet and Searcy, 1993';

features=extract_features(stim,type,dagg_flag,run_path);

% Calcualte the Thatcher Index with different distance metric
N=length(dist_types);
MI_across_layers=cell(N,1);
for iter=1:N
    fprintf('\n Distance Metric = %s \n',dist_types{iter})
    MI_across_layers{iter,1}=CheckThatcherEffect(features,dist_types{iter});
end
% Plotting the data
for ind=1:N
    mean_data(ind,:)=nanmean(MI_across_layers{ind,1},1);
    sem_data(ind,:)=nansem(MI_across_layers{ind,1},1);
end 
file_name=['..',SLASH,'results',SLASH,'Thatcher Effect Distance Metric Comparison'];
layerwise_mi_figures(mean_data,sem_data,file_name,reference_mi,reference_name,dist_types(1:N),'Thatcher Index');
%% ************** SUBFUNCTIONS *********************************
function thatcherIndex=CheckThatcherEffect(features,dist_type)
nL=length(features{1})-1;% Skipping the last layers
N=20;
features=reshape(features,[N,4]); % Expecting that there are 80 image in total always. 
thatcherIndex=zeros(N,nL);
for ind=1:length(features)
    for L=1:nL
        v1=features{ind,1}(L).x;
        v2=features{ind,2}(L).x;
        v3=features{ind,3}(L).x;
        v4=features{ind,4}(L).x;
        v12=distance_calculation(v1(:),v2(:),dist_type);
        v34=distance_calculation(v3(:),v4(:),dist_type);
        thatcherIndex(ind,L)=(v12-v34)./(v12+v34);
    end
end
end


