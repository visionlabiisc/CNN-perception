% This code is written to check Selectivitiy of Neural Networks
% Selectivity Analsyis using Morphlines
% Selectivity Analysis using textures and Shapes.
clc;clear all;close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];
%% Loading Stimuli
stim_name='seltol';load([stim_name,'.mat']);stim=stim(1:44);
stim_name='shapes';stim_shapes=load([stim_name,'.mat']);stim_shapes=stim_shapes.stim;
stim_name='textures';stim_textures=load([stim_name,'.mat']);stim_textures=stim_textures.stim;
conditions_ST=50;stim_ST=[stim_shapes(1:conditions_ST);stim_textures(1:conditions_ST)];
%% Networks to be tested
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
%% Effect Reference Level
reference_mi_morph=0.73; %
reference_mi_shapetexture=0.68; %
reference_name='Zhivago and Arun, 2016';


for iter=1:length(type)
    tstart=tic;
    % Morphlines
    % Extracting Features
    fprintf('\n Extracting Features\n');
    features=[];
    features=extract_features(stim,type{iter},dagg_flag(iter),run_path);
    corr_max_sparsness_ref=find_selectivity_morphlines(features);
    MI_across_layers{iter,1}=corr_max_sparsness_ref;
    
    % Shape vs Textures
    fprintf('\n Extracting Features\n');
    features=[];
    features=extract_features(stim_ST,type{iter},dagg_flag(iter),run_path);
    corr_sparsness_texture=find_selectivity_textures_shapes(features,conditions_ST);
    MI_across_layers{iter,2}=corr_sparsness_texture;
    
    %% Plotting the data
    % Morphlines
    y_label='Correlations between sparsness of reference set and maximum sparsness along morphlines';
    Saving_file_name=['..',SLASH,'results',SLASH,'Exp05-SeltolMorphlines,net = ',network_short_name{iter}];
    if(iter<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures(MI_across_layers{iter,1},[],Saving_file_name,reference_mi_morph,reference_name,network_short_name{iter},y_label);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures(MI_across_layers{iter,1},[],Saving_file_name,reference_mi_morph,reference_name,network_short_name{iter},y_label);
    end
    % Shape versus Textures
    y_label='Correlations between sparsness neuros to texture set versus shapes set';
    Saving_file_name=['..',SLASH,'results',SLASH,'Exp05-Shapes_versus_textures,net = ',network_short_name{iter}];
    if(iter<=4) % Layer-wise plot for VGG-Network
        layerwise_mi_figures(MI_across_layers{iter,2},[],Saving_file_name,reference_mi_shapetexture,reference_name,network_short_name{iter},y_label);
    else % layer-wise plot for other network
        layerwise_mi_nonVGGfigures(MI_across_layers{iter,2},[],Saving_file_name,reference_mi_shapetexture,reference_name,network_short_name{iter},y_label);
    end
    time_taken{iter}=toc(tstart);
end
%% PLotting the effect of VGG-16 versurs random network
sel_index=[1,3];
mean_data_morph=zeros(2,37);
mean_data_shapetexture=zeros(2,37);
for ind=1:2
    mean_data_morph(ind,:)=MI_across_layers{sel_index(ind),1};
    mean_data_shapetexture(ind,:)=MI_across_layers{sel_index(ind),2};
end
% Morphlines
Saving_file_name_morph=['..',SLASH,'results',SLASH,'Exp05-Mainfigure_Morphlines_VGG16'];
y_label_morph='Correlations between sparsness of reference set and maximum sparsness along morphlines';
layerwise_mi_figures(mean_data_morph,[],Saving_file_name_morph,reference_mi_morph,reference_name,network_short_name(sel_index),y_label_morph);

% Shape versus Texture
Saving_file_name_shape=['..',SLASH,'results',SLASH,'Exp05-Mainfigure_ShapeTexture_VGG16'];
y_label_shape='Correlations between sparsness neuros to texture set versus shapes set';
layerwise_mi_figures(mean_data_shapetexture,[],Saving_file_name_shape,reference_mi_shapetexture,reference_name,network_short_name(sel_index),y_label_shape);

%% Plotting the effect of VGG-16 versus VGG-16 matconvnet
sel_index=[1,2];
mean_data_morph=zeros(2,37);
mean_data_shapetexture=zeros(2,37);
for ind=1:2
    mean_data_morph(ind,:)=MI_across_layers{sel_index(ind),1};
    mean_data_shapetexture(ind,:)=MI_across_layers{sel_index(ind),2};
end
% Morphlines
Saving_file_name_morph=['..',SLASH,'results',SLASH,'Exp05-suppfigure_Morphlines_VGG16matconvnet'];
y_label_morph='Correlations between sparsness of reference set and maximum sparsness along morphlines';
layerwise_mi_figures(mean_data_morph,[],Saving_file_name_morph,reference_mi_morph,reference_name,network_short_name(sel_index),y_label_morph);

% Shape versus Texture
Saving_file_name_shape=['..',SLASH,'results',SLASH,'Exp05-suppfigure_ShapeTexture_VGG16matconvnet'];
y_label_shape='Correlations between sparsness neuros to texture set versus shapes set';
layerwise_mi_figures(mean_data_shapetexture,[],Saving_file_name_shape,reference_mi_shapetexture,reference_name,network_short_name(sel_index),y_label_shape);



