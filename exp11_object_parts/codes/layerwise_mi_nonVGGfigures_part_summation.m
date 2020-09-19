function layerwise_mi_nonVGGfigures_part_summation(mean_data,sem_data,file_name,reference_mi,reference_name,legend_name,y_label,shaded_region_name,y_limits)
% GJ, 20-07-2020

% INPUTS
% mean_data  : expects means data across layers (matrix N x 37 with values in the range -1 to 1)
% sem_data   : expects standard error of data (matrix N x 37 )
% file_name  : expects a string, generated figure will be saved in this name

% INPUTS  (optional)
% reference_mi       : Scale value between -1 and 1
% reference_name     : String, Reference from which the behavior was taken.
% legend_name        : Cell of strings of size N x1
% y_label            : String, y axis label 
% shaded_region_name : String, meaning of the shaded region (default = 'Human perception')

% OUTPUT
% Pdf in the specififed "file_name" will be generated.

%% Example Function Call
% N=2;nL=152;
% legend_name={'A','B'};
% mean_data=rand(N,nL);
% sem_data=0.1*ones(N,nL);
% file_name='testing';
% reference_mi=0.2;
% reference_name='Author1 & Author2, YEAR';
% y_label='XXX';
% shaded_region_name='Human Perception';
% layerwise_mi_nonVGGfigures(mean_data,sem_data,file_name,reference_mi,reference_name,legend_name,y_label,shaded_region_name);
%***************************************************************************
if(~exist('y_limits','var')||isempty(y_limits))
    y_limits=[-1,1];
end
figure('Units','centimeters')
FontSize=6;
nL=size(mean_data,2);
% drawing the human perception rectangle
rS=1/y_limits(2); % relative scale to adjust the plots according to y-limits
xL=1;xU=nL;yL=y_limits(1);yU=y_limits(2); dx=nL/200;dy=0.005;
%% Drawing the Rectangle
rectangle_color=[0.8,0.8,0.8];
rectangle('Position',[1+dx,0+dy,nL-dx,1-dy],'FaceColor',rectangle_color,'Edgecolor','none'); hold on;

%% Plotting the Data
line_colour = colormap('Lines');
marker_size=1;
layer_ind=1:nL;
for ind=1:size(mean_data,1)
    if(exist('sem_data')&& (~isempty(sem_data)))
        shadedErrorBar(1:nL,mean_data(ind,:),sem_data(ind,:),'lineprops',{'-','markerfacecolor',line_colour(ind,:),...
            'color',line_colour(ind,:),'LineWidth',0.5},'transparent',true,'patchSaturation',0.3);hold on;
    else
        plot(1:nL,mean_data(ind,:),'o-','MarkerSize',marker_size,'markerfacecolor',line_colour(ind,:),...
            'color',line_colour(ind,:),'LineWidth',0.5);hold on;
    end
end
%% Visual search modulation index
if(exist('reference_mi')&& (~isempty(reference_mi)))
    if(length(reference_mi)==1)
        line([1 nL],[reference_mi reference_mi],'Marker','none','LineStyle','--','LineWidth',0.5, 'Color',[0 0 0]);
        text(2,reference_mi+0.1,reference_name,'FontSize',6)
    else
        for i=1:length(reference_mi)
            line([1 nL],[reference_mi(i) reference_mi(i)],'Marker','none','LineStyle','--','LineWidth',0.5, 'Color',[0 0 0]);
            text(2,reference_mi(i)+0.1,reference_name{i},'FontSize',6)
        end
    end
end
%% Naming the Shaded region
if(exist('shaded_region_name')&& (~isempty(shaded_region_name)))
    text(3,0.9, shaded_region_name,'FontSize',6);
else
    text(3,0.9, 'Human perception','FontSize',6);
end
%% Correcting the plot
set(gcf,'position',[5,5,6.4,4]); % Setting the size of the plot
xlim([xL,xU]);ylim([yL,yU]); % Setting x and y limits
H = gca; set(H,'XTick',[1 nL],'XTickLabel',[1 nL],'YTick',[yL,0,yU],'YTickLabel',[yL,0,yU]); %Limiting X and Y Ticks.
ylabel(y_label);xlabel('VGG-16, layers')
% Legends
h=get(gca,'Children'); % grab all the axes handles at once
N=size(mean_data,1);Nh=length(h);
sel_legends=zeros(N,1);for i=1:N,sel_legends(i)=Nh-(i);end
legend(h(sel_legends),legend_name,'FontSize',6,'Location','best','Box','off');
set_fig_fonts(FontSize)
print(gcf,'-dpdf',[file_name,'.pdf']) % Saving the pdf
end