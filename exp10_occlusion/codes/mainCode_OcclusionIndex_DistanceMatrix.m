%% Check the occlusion effect, Distance Matrix
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
type='imagenet-vgg-verydeep-16';
short_name='VGG16';
dagg_flag=0;
y_label_name='Occlusion Index';
%% Behavior Effect
reference_mi=zeros(2,1);
reference_name=cell(2,1);
reference_mi(1)=0.67; % Basic Effect
reference_name{1}='Rensink & Enns 1998';
reference_mi(2)=0.6;  % Depth Ordering
reference_name{2}='Rensink & Enns 1998';
%% Extract Features
features=extract_features(stim,type,dagg_flag,run_path);

%% Calculate Part-Matching Index
dist_types={'Euclidean','CityBlock','pearson','spearman'};
N=length(dist_types);
MI_across_layers=cell(N,1);
legend_name={'Euclidean','CityBlock','pearson','spearman'};
for iter=1:N
    fprintf('\n Distance Metric = %s \n',dist_types{iter})
    MI_Occlusion=check_occlusion(features,dist_types{iter});
    
    mean_data_OE(iter,:)=MI_Occlusion(1,:);
    mean_data_DO(iter,:)=MI_Occlusion(2,:);
end
file_name_pdf=['..',SLASH,'results',SLASH,'Exp10_DistanceMetric_Occlusion_Network = ',short_name,'Occlusion Effect'];
layerwise_mi_figures(mean_data_OE,[],file_name_pdf,reference_mi,reference_name,legend_name,y_label_name);

file_name_pdf=['..',SLASH,'results',SLASH,'Exp10_DistanceMetric_Occlusion_Network = ',short_name,'Depth Ordering'];
layerwise_mi_figures(mean_data_DO,[],file_name_pdf,reference_mi,reference_name,legend_name,y_label_name);



function [mi_occlusion_mean,mi_occlusion_sem]=check_occlusion(features,dist_type)
nL=length(features{1})-1;% Skipping the last layers
%% check the basic effect (Stim in figure-1 of Rensink,1997)
M_basic_effect=[];
M_dept_ordering=[];
for L=1:nL
    % first set
    img1=vec(features{1}(L).x);
    img2=vec(features{2}(L).x);
    img3=vec(features{3}(L).x);
    d12=distance_calculation(img1,img2,dist_type);
    %d12=norm(img1-img2,1);
    d13=distance_calculation(img1,img3,dist_type);
    %d13=norm(img1-img3,1);
    M_basic_effect(L,1)=(d13-d12)./(d13+d12);
    % 180 degreee rotated set
    img4=vec(features{4}(L).x);
    img5=vec(features{5}(L).x);
    img6=vec(features{6}(L).x);
    %     d45=norm(img4-img5,1);
    %     d46=norm(img4-img6,1);
    d45=distance_calculation(img4,img5,dist_type);
    d46=distance_calculation(img4,img6,dist_type);
    M_basic_effect(L,2)=(d46-d45)./(d46+d45);
end

%% Check the effect of depth ordering

for L=1:nL
    % first control set
    img7=vec(features{7}(L).x);
    img8=vec(features{8}(L).x);
    img2=vec(features{2}(L).x);
    %     d78=norm(img7-img8,2);
    %     d72=norm(img7-img2,2);
    d78=distance_calculation(img7,img8,dist_type);
    d72=distance_calculation(img7,img2,dist_type);
    
    M_dept_ordering(L,1)=(d78-d72)./(d78+d72);
    % 180 degree rotated set
    img9=vec(features{9}(L).x);
    img10=vec(features{10}(L).x);
    img5=vec(features{5}(L).x);
    %     d910=norm(img9-img10,1);
    %     d95=norm(img9-img5,1);
    d910=distance_calculation(img9,img10,dist_type);
    d95=distance_calculation(img9,img5,dist_type);
    
    M_dept_ordering(L,2)=(d910-d95)./(d910+d95);
    
    % second control set
    img2=vec(features{2}(L).x);
    img7=vec(features{7}(L).x);
    img11=vec(features{11}(L).x);
    %     d27=norm(img2-img7,1);
    %     d211=norm(img2-img11,1);
    
    d27=distance_calculation(img2,img7,dist_type);
    d211=distance_calculation(img2,img11,dist_type);
    
    M_dept_ordering(L,3)=(d211-d27)./(d211+d27);
    
    % 180 rotated second control set
    img5=vec(features{5}(L).x);
    img9=vec(features{9}(L).x);
    img12=vec(features{12}(L).x);
    
    d59=distance_calculation(img5,img9,dist_type);
    d512=distance_calculation(img5,img12,dist_type);
    
    %     d59=norm(img5-img9,1);
    %     d512=norm(img5-img12,1);
    M_dept_ordering(L,4)=(d512-d59)./(d512+d59);
end
% %% Type of Completion
% for ind=1:nL
%     %first control_par1
%     img2=vec(features{2}(L).x);
%     img3=vec(features{3}(L).x);
%     img13=vec(features{13}(L).x);
%     d23=norm(img2-img3,1);
%     d213=norm(img2-img13,1);
%     M_type_of_completion(L,1)=(d213-d23)./(d23+d213);
%     % first control part_2
%     img2=vec(features{2}(L).x);
%     img3=vec(features{3}(L).x);
%     img11=vec(features{11}(L).x);
%     d23=norm(img2-img3,1);
%     d211=norm(img2-img11,1);
%     M_type_of_completion(L,2)=(d211-d23)./(d23+d211);
%
% end

mi_occlusion_mean=[];
mi_occlusion_sem=[];
mi_occlusion_mean(1,:)=nanmean(M_basic_effect,2);
mi_occlusion_mean(2,:)=nanmean(M_dept_ordering,2);

mi_occlusion_sem(1,:)=nansem(M_basic_effect,2);
mi_occlusion_sem(2,:)=nansem(M_dept_ordering,2);




end