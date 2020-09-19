% Code to calculate the centroid of the selected categories.
% Cateogory names will be coming from the excel file.
% Centroid will be saved in a separate folder called as "save_features"

% Credits: GJ

clc;clear all;close all;
%% Parameters
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

%% Training Folder
training_dir=['..',SLASH,'stim',SLASH,'imagenet_val_directories_36cat',SLASH,];
d=dir([training_dir,'n*']);
Ndir=length(d);
%% folder category mapping
[~, ~, cat_folder_mapping] = xlsread('LOC_synset_mapping.xls');
%% Main Code
for net_index= 1:length(type)
    for dIndex=1:Ndir
        fprintf('\n Directory -%d\n',dIndex);
        network_name=type{net_index};           % Deep Neural Network Model Name
        current_dag_flag=dagg_flag(net_index);  % DAGG network/Simple NN network
        category_index=find(ismember(cat_folder_mapping(:,1),d(dIndex).name)); % Category Name
        c_dir=[d(dIndex).folder,SLASH,d(dIndex).name];% Currrent Directory
        d_image=dir([c_dir,SLASH,'*JPEG']); % Getting the input images in the directory
        Nimage=length(d_image); % Length of the image
        stim=cell(Nimage,1);
        
        %% Reading the image
        for iIndex=1:Nimage
            stim{iIndex}=imread([d_image(iIndex).folder,SLASH,d_image(iIndex).name]); % Reading the input image
        end
        
        %% Extracting Features
        xx=tic;  % start time
        features=cell(Nimage,1);           % Pre-defined cell to store features
        [features_category_centroid]=extract_centroid_features(stim,network_name,current_dag_flag,run_path); % Extracting the features
        fprintf('\n Time for extracting features %.4f\n',toc(xx))
        
        %% Saving the features
        xx=tic;
        file_name=sprintf('..%ssave_features%s_%s_centroid_%s.mat',SLASH,SLASH,network_name,d(dIndex).name);
        fprintf('\n File_Saving Time %.4f\n',toc(xx))
        save(file_name,'features_category_centroid', '-v7.3' )
    end
end
