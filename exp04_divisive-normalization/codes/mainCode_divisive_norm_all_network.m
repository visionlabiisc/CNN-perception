% Divisive Normalization
% Credits  : GEORGIN
clc;allclear; close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];

% stimuli
fprintf('\n Loading Stim File .... \n')
filename_stim = ['..',SLASH,'stim',SLASH,'natural_stim_GJ.mat'];
load(filename_stim);
VAR_THREHOLD=0.1;
Blank_ID=999;
% code to check for a reduced set of conditions.
NCOND=100;
pairs=pairs(1:NCOND);
triplets=triplets(1:NCOND);
imgpairs=imgpairs(1:NCOND,:);
imgtrips=imgtrips(1:NCOND,:);

stim=[singletons;pairs;triplets];

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

time_taken=cell(length(type),1);
MI_across_layers=cell(length(type),1);
%% Behavioral Effect
reference_mi(1)=0.5;
reference_name{1}='Zoccolan et. al. 2005, pairs';
reference_mi(2)=0.33;
reference_name{2}='Zoccolan et. al. 2005, triplets';
for iter=1:length(type)
    tstart=tic;
    fprintf('\n Network- %s \n',type{iter});
    %% Extracting Features
    fprintf('\n Extracting Features\n');
    % Extracting Features_singleton
    features_singleton=[];features_pairs=[];features_triplets=[];
    features_singleton=extract_features(singletons,type{iter},dagg_flag(iter),run_path);
    % Extracting features pairs
    features_pairs=extract_features(pairs,type{iter},dagg_flag(iter),run_path);
    
    %% finding visually active neurons
    fprintf('\n finding Visually active neruons\n');
    group=1:length(singletons);group=reshape(group,[length(singletons)/3,3]);
    [active_neurons, Nactive_neurons]=visually_active_neurons(features_singleton,group,VAR_THREHOLD);
    
    fprintf('\n Checking Divisive Normalization\n');
    model_coefficient_pairs=divisive_normalization(features_pairs,features_singleton,active_neurons,Nactive_neurons,imgpairs,imgsingles,Blank_ID);

    
    % Extracting features triplets
    features_pairs=[];
    features_triplets=extract_features(triplets,type{iter},dagg_flag(iter),run_path);
    model_coefficient_triplets=divisive_normalization(features_triplets,features_singleton,active_neurons,Nactive_neurons,imgtrips,imgsingles,Blank_ID);
    features_triplets=[];features_singleton=[]; % clearing memory
    MI_across_layers{iter}=[model_coefficient_pairs(1,:);model_coefficient_triplets(1,:)];
    %save exp4_temp MI_across_layers
   %% PLOTTING 
    y_label='Normalization';
    Saving_file_name=['..',SLASH,'results',SLASH,'Exp04-Divisive,net = ',network_short_name{iter}];
    if(iter<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures(MI_across_layers{iter},[],Saving_file_name,reference_mi,reference_name,{'pairs','triplets'},y_label);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures(MI_across_layers{iter},[],Saving_file_name,reference_mi,reference_name,{'pairs','triplets'},y_label);
    end
end
%% Saving the VGG-16 and Random-network in manuscript format
figure;
sel_index=[1,3];
mean_data=zeros(4,37);
sem_data=zeros(4,37);
for ind=1:2
    mean_data(2*(ind-1)+(1:2),:)=MI_across_layers{sel_index(ind)};
end
file_name_main_pdf=['..',SLASH,'results',SLASH,'Exp04_mainfigure_VGG_16 and Random Network'];
legend_name={'vgg-16,pairs','vgg16-triplets','vgg-16 random weights,pairs','vgg16 random weights-triplets'};
y_label='Correlation Coefficients';

% changing the order
mean_data=mean_data([1,3,2,4],:);
legend_name=legend_name([1,3,2,4]);
layerwise_mi_figures(mean_data,sem_data,file_name_main_pdf,reference_mi,reference_name,legend_name,y_label)

%% Saving the VGG-16 and matconvnet VGG-16 in manuscript format
figure;
sel_index=[1,2];
mean_data=zeros(4,37);
sem_data=zeros(4,37);
for ind=1:2
    mean_data(2*(ind-1)+(1:2),:)=MI_across_layers{sel_index(ind)};
end
file_name_main_pdf=['..',SLASH,'results',SLASH,'Exp04_mainfigure_VGG_16 and matconvenet VGG16'];
legend_name={'vgg-16,pairs','vgg16-triplets','vgg-16(matconvnet)-pairs','vgg16(matconvnet)-triplets'};
y_label='Correlation Coefficients';

% changing the order
mean_data=mean_data([1,3,2,4],:);
legend_name=legend_name([1,3,2,4]);
layerwise_mi_figures(mean_data,sem_data,file_name_main_pdf,reference_mi,reference_name,legend_name,y_label)



















