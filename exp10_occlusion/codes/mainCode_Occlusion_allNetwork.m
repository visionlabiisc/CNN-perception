%% Check the occlusion effect,
% based on the stimuli in Rensink 1997.
% Credits  : GJ 26/10/2018
clc;clear all;close all;
%% Main Code Directory location and SLASH of the OS
[main_folder,SLASH]=get_expmainfolder_slash();
%% Adding Path
addpath([main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24']);
addpath([main_folder,'dependencies',SLASH,'models']);
addpath([main_folder,'dependencies',SLASH,'lib']);
run_path=[main_folder,'dependencies',SLASH,'matconvnet-1.0-beta24',SLASH,'matlab',SLASH,'vl_setupnn'];
%% STIM
file_name_stim ='occlusion_set1.mat';
load(file_name_stim) % Images
for ind=1:length(stim)
    stim{ind}=stim{ind}(10:end-10,10:end-10,:);
end
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
short_name={'VGG-16','mat.VGG-16','VGG-16 randn','VGG-face','Alexnet','Goolgenet','ResNet 50','ResNet 152'};
%%
dist_types='Euclidean';
y_label_name='Occlusion Index';
%% Behavior Effect
reference_mi=zeros(2,1);
reference_name=cell(2,1);
reference_mi(1)=0.67; % Basic Effect
reference_name{1}='Rensink & Enns 1998';
reference_mi(2)=0.6;  % Depth Ordering
reference_name{2}='Rensink & Enns 1998';
%% EXTRACT FEATURES
time_taken=cell(length(type),1);
MI_across_layers=cell(length(type),1);
legend_name={'Occlusion Effect','Effect of depth Ordering'};
for iter=1:2%length(type)
    tstart=tic;
    fprintf('\n Extracting Features\n');
    features=extract_features(stim,type{iter},dagg_flag(iter),run_path);
    % Occlusion
    [mi_occlusion_mean,mi_occlusion_sem]=check_occlusion(features);
    MI_across_layers{iter,1}=mi_occlusion_mean;

    % Saving file
    file_name_pdf=['..',SLASH,'results',SLASH,'All_networks_Occlusion_Network=',type{iter}];
    
%     % Plotting and Saving
%     if(iter<=4) % Layer-wise plot for VGG-Network
%         layerwise_mi_figures(mi_occlusion_mean,[],file_name_pdf,reference_mi,reference_name,legend_name,y_label_name);
%     else % layer-wise plot for other network
%         layerwise_mi_nonVGGfigures(mi_occlusion_mean,[],file_name_pdf,reference_mi,reference_name,legend_name,y_label_name);
%     end
    time_taken{iter}=toc(tstart);
end
% %% PLotting the effect for two networks
% sel_index=[1,3];N=length(sel_index);
% mean_data=zeros(N,37);
% for ind=1:N
%     mean_data(2*(ind-1)+(1:2),:)=MI_across_layers{sel_index(ind),1};
% end
% sem_data=[];% zeros;
% legend_name={['BE ',short_name{sel_index(1)}],['DO ',short_name{sel_index(1)}],['BE ',short_name{sel_index(2)}],['DO ',short_name{sel_index(2)}]};
% file_name=['..',SLASH,'results',SLASH,'Main_figure_Occlusion Index'];
% % changing the order;
% order=[1,3,2,4];mean_data(order,:)=mean_data(order,:);legend_name(order)=legend_name;
% %plot
% layerwise_mi_figures(mean_data,sem_data,file_name,reference_mi,reference_name,legend_name,'Occlusion index');

%% Comparing VGG-16 versus VGG-16 Matconvenet
sel_index=[1,2];N=length(sel_index);
mean_data=zeros(N,37);
for ind=1:N
    mean_data(2*(ind-1)+(1:2),:)=MI_across_layers{sel_index(ind),1};
end
sem_data=[];% zeros;
legend_name={['BE ',short_name{sel_index(1)}],['DO ',short_name{sel_index(1)}],['BE ',short_name{sel_index(2)}],['DO ',short_name{sel_index(2)}]};
file_name=['..',SLASH,'results',SLASH,'Supp_figure_Occlusion Index_VGG16_versus_matconvnet'];
% changing the order;
order=[1,3,2,4];mean_data=mean_data(order,:);legend_name=legend_name(order);
%plot
layerwise_mi_figures(mean_data,sem_data,file_name,reference_mi,reference_name,legend_name,'Occlusion index');
