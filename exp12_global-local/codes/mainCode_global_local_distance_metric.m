% Checking the results with other distance metrics
% Georgin Jacob,19-7-2020 : FIRST VERSION  
clc;allclear; close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];

%% STIM
file_name_stim='GL.mat';
load(file_name_stim);
%% NETWORK
type{1}='imagenet-vgg-verydeep-16';
dagg_flag=0;

%% Behvaioral Effect
reference_mi=0.0975;
reference_name='Jacob and Arun, 2019';

%% Extract Features
features=extract_features(stim,type{1},dagg_flag(1),run_path);

%% Calculate Index for data types
dist_types={'Euclidean','CityBlock','pearson','spearman'};
nL=length(features{1})-1;
N=length(features);nD=length(dist_types);
g1=imagepairDetails(:,1);l1=imagepairDetails(:,2);
g2=imagepairDetails(:,3);l2=imagepairDetails(:,4);

indexG=find(l1==l2);
indexL=find(g1==g2);
for Layer=1:nL
    fprintf('\nLayer- %d', Layer)
    temp=features{1}(Layer).x;fl=length(temp(:));
    layerF=zeros(fl,N);
    for ind_img=1:N
        layerF(:,ind_img)=vec(features{ind_img}(Layer).x);
    end
    for ind=1:nD
        fprintf('\nDistance Types- %s', dist_types{ind})
        layerwiseDist=distance_calculation_matrix(layerF',dist_types{ind});
        mean_global_distance(ind,Layer)=nanmean(layerwiseDist(indexG));
        mean_local_distance(ind,Layer)=nanmean(layerwiseDist(indexL));
    end
end
mi_global_local=(mean_global_distance-mean_local_distance)./(mean_global_distance+mean_local_distance);
mean_data=mi_global_local;sem_data=[];

file_name_pdf=['..',SLASH,'results',SLASH,'global advantage effect Distance Metric Comparison'];
layerwise_mi_figures(mean_data,sem_data,file_name_pdf,reference_mi,reference_name,dist_types,'Global Advantage Index');
%% ************** SUBFUNCTIONS *********************************
function d=distance_calculation_matrix(X,type)
switch type
    case 'Euclidean'
        d=pdist(X,'euclidean');
    case 'CityBlock'
        d=pdist(X,'cityblock');
    case 'Cosine'
        d=pdist(X,'cosine');
    case 'pearson'
        d=pdist(X,'correlation');
    case 'spearman' 
         d=pdist(X,'spearman');
    otherwise
          d=NAN;  
end
end


