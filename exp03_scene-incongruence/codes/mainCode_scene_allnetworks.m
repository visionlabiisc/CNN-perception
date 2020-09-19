% Experiment-3: Scene Incongruence
% This main code calculates the incongrunce based on classification accuracy.

% Georgin, 10th June 2018
% Georgin, 27th December 2018
% Georgin, 1st,August 2020 : 1) Absolute -> Relative paths 2)Added the subfunction into the same m-file 

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

%% EXTRACT FEATURES
time_taken=cell(length(type),1);
MI_across_layers=cell(length(type),1);
for iter=1:length(type)
    tstart=tic;
    fprintf('\n Extracting Features\n');
    scores=extract_scores(stim,type{iter},dagg_flag(iter),run_path);
    
    % Extractting top-1 and top-5 categories
    [top_five,top_one]=get_top_cat(scores,selCat);
    
    % Finding congreunt and incogruent accuracies
    nimages=length(stim);
    top_five=reshape(top_five,[2,nimages/2]);% congruent ; Incongruent
    top_one=reshape(top_one,[2,nimages/2]);% congruent ; Incongruent
    cnn_mean_accuracy(1,1)=mean(top_five(1,:));% congruent
    cnn_std_accuracy(1,1)=nansem(top_five(1,:),2);% congruent
    cnn_mean_accuracy(1,2)=mean(top_five(2,:));% incongruent
    cnn_std_accuracy(1,2)=nansem(top_five(2,:),2);% incongruent
    % top one
    cnn_mean_accuracy(2,1)=mean(top_one(1,:));% congruent
    cnn_std_accuracy(2,1)=nansem(top_one(1,:),2);% congruent
    cnn_mean_accuracy(2,2)=mean(top_one(2,:));% incongruent
    cnn_std_accuracy(2,2)=nansem(top_one(2,:),2);% incongruent
    
    fprintf('\n Plotting..\n');
    figure('Units','centimeters')
    bar(cnn_mean_accuracy,1);hold on;
    errorbar([0.85,1.15;1.85,2.15],cnn_mean_accuracy,cnn_std_accuracy,'.');
    ylim([0,1])
    legend('Congruent','Incongruent','Location','NorthEast')
    set(gca, 'Xtick',[1,2],'XTickLabelRotation',0,'XTickLabel',{'Top-5','Top-1'},'Ytick',[0,1])
    ylabel('Accuracy');
    set(gcf,'position',[5,5,2.5,3]); % Setting the size of the plot
    title(['Network-',type{iter}])
%     plot_aspect_ratio=0.77;pbaspect([plot_aspect_ratio,1,2]);
    set_fig_fonts(6)
    % saving
    
    file_name=['..',SLASH,'results',SLASH,'Accuracy_Comparison_Barplot_scene_incongruence_Network=',type{iter}];
    print(gcf,'-dpdf',[file_name,'.pdf'])
    time_taken{iter}=toc(tstart);
end

%% Sub-functions
function  [top_five,top_one]=get_top_cat(scores,selCat)
% This fuction calculates the top-five and top-one accuracies for all images
% scores : cell of dimension nimage x 1, each cell contains the probability scores for 1000 categories 
% selCat : array of dimension nimages x 1, each element is the manually mapped category of that image.  
nimages=length(scores);
top_five=zeros(nimages,1);
top_one=zeros(nimages,1);
for i=1:nimages
    [bestScore, descending_order] = sort(scores{i},'descend') ;descending_order=descending_order';bestScore=bestScore';
    top_five(i)=~isempty(find(descending_order(1:5)==selCat(i),1));
    top_one(i)=~isempty(find(descending_order(1)==selCat(i),1));
end
end