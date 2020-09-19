  % Experiment-3: Incongruence Effect
% This code checks the presence of incongruent effect based on the feature
% feature distance of  congruent and incongruent scenes from the object
% category centroid.

% 21-08-2020

clc;clear all;close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();

%% LOADING STIM
% Munnekke Set
stim_file_name=sprintf('scenesConcInconc.mat');
stim_munnekke=load(stim_file_name);

% DavenportPotter Set
stim_file_name=sprintf('DavenportPotterSelected.mat');
stim_davenport=load(stim_file_name);

% Combining
stim=[stim_munnekke.stim;stim_davenport.stim];
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

%% Manually Mapped category labels for each of the images
selCat_davenport=[881	484	342	752	867	408	355	99	451	813	34	355	437	353	348	346	341,
    881	484	342	752	867	408	355	99	451	813	34	355	437	353	348	346	341];
selCat=[597	521	521	436	560	672	737	463	533	533	873	563	575	620	424	442	704	704	897	832	850	858	413;
    597	521	521	436	560	672	737	463	533	533	873	563	575	620	424	442	704	704	897	832	850	858	413];
selCat=[selCat,selCat_davenport];

%% Category Folder Mapping
[~, ~, cat_folder_mapping] = xlsread('LOC_synset_mapping.xls');
save_dir=sprintf('..%ssave_features%s',SLASH,SLASH); % ..\save_features\

%% Main Code
for net_index=1:length(type)
    current_dag_flag=dagg_flag(net_index);
    network_name=type{net_index};
    fprintf('\n Network name = %s\n',network_name);
    
    % Extracting Features
    xx=tic;
    features=extract_features(stim,network_name,current_dag_flag,run_path);
    fprintf('Time for features %.3f\n',toc(xx));
    nL=length(features{1})-1; % Number of feature layers excluding probability layer.
    
    % Running the Alternative distances only for VGG-16
    if(net_index==1)
        dist_types={'Euclidean','CityBlock','pearson','spearman'};
        %dist_types={'Euclidean','spearman' };
    else
        dist_types={'Euclidean'};
    end
    Data=cell(length(dist_types),1);% cell for storing different distances
    
    for dt=1:length(dist_types) % For various distances
        scene_incongruence=zeros(size(selCat,2),nL);
        fprintf('\n');
        for ind=1:size(selCat,2)
            fprintf('Pair %d,',ind)
            catIndex=selCat(1,ind);
            % Loading the precomputed centroid features for the
            % pre-computed category
            folder_name=cat_folder_mapping(catIndex,1);
            file_name=[save_dir,'_',type{net_index},'_centroid_',folder_name{1},'.mat'];
            load(file_name)
            
            % reading the features for congreunt and incongruent images.
            % calculate the scene incongruence using the distance of
            % congruent and incongruent feature vector with centroid
            conc_index=2*(ind-1)+1;inconc_index=2*(ind-1)+2;
            for L=1:nL
                X=[vec(features{conc_index}(L).x),features_category_centroid{L}]';dcc=distance_calculation_matrix(X,dist_types{dt});
                X=[vec(features{inconc_index}(L).x),features_category_centroid{L}]';dic=distance_calculation_matrix(X,dist_types{dt});
                scene_incongruence(ind,L)=(dic-dcc)/(dic+dcc);
            end
        end
        %% Storing the MI calculated for a distance metric
        Data{dt}=scene_incongruence;
    end
    %% Plotting the data
    % finding the mean and sem
    N=length(Data);mean_data=zeros(N,nL);sem_data=zeros(N,nL);
    for ind=1:N
        mean_data(ind,:)=nanmean(Data{ind},1);
        sem_data(ind,:)=nansem(Data{ind},1);
    end
    % Location for saving the plots
    %Saving_file_name=['../results/',network_name,'_scene_incongruence'];
    Saving_file_name=['..',SLASH,'results',SLASH,'Layerwise_MI, net = ',network_name];
    reference_mi=[];reference_name=[];
    y_label='Scene Incongruence Index';
    y_limit= [-0.2,0.2];
    if(net_index<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures(mean_data,sem_data,Saving_file_name,reference_mi,reference_name,dist_types,y_label,'Human Perception',y_limit);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures(mean_data,sem_data,Saving_file_name,reference_mi,reference_name,dist_types,y_label,'Human Perception',y_limit);
    end
end

