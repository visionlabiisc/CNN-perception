function layerwise_mi_figures_part_summation(mean_data,sem_data,file_name,reference_mi,reference_name,legend_name,y_label,shaded_region_name,y_limits)
% GJ 17-12-2018

% update log
% 1-1-19 : Specify the file to saves for layerwise modulation index data
% 9-1-19 : Adding legends
% 2-7-2020: Restructured
% 29-08-2020 : Corrected legend names, size of the pdf generated.

% INPUTS
% mean_data  : expects means data across layers (matrix N x 37 with values in the range -1 to 1)
% sem_data   : expects standard error of data (matrix N x 37 )
% file_name  : expects a string, generated figure will be saved in this name

% INPUTS  (optional)
% reference_mi      : Scale value between -1 and 1
% reference_name    : String, Reference from which the behavior was taken.
% legend_name       : Cell of strings of size N x1
% y_label           : String, y axis label
% shaded_region_name : String, meaning of the shaded region (default = 'Human perception')

% OUTPUT
% Pdf in the specififed "file_name" will be generated.
if(~exist('y_limits','var')||isempty(y_limits))
    y_limits=[-1,1];
end
    
figure('Units','centimeters')
% drawing the human perception rectangle
rS=1/y_limits(2); % relative scale to adjust the plots according to y-limits
nL=37;xL=1;xU=nL;yL=y_limits(1);yU=y_limits(2); dx=0.08;dy=0.005;FontSize=6;
%% Drawing the Rectangle
rectangle_color=[0.8,0.8,0.8];
h=rectangle('Position',[1+dx,0+dy,nL-dx,1-dy],'FaceColor',rectangle_color,'Edgecolor','none');
%% Naming the layers by drawing the bottom rectangles
layer_grouping=[1,6.45;6.55 11.45;11.55,18.45;18.55,25.45;25.55,32.45;32.55,37];
layer_colour=[repmat([0.8,0.8,0.8],5,1);0.5, 0.5,0.5];
box_width=0.2/rS;
% draw reactangles
for ind =1:size(layer_grouping,1)
    rectangle('Position',[layer_grouping(ind,1)+dx,yL+dy,layer_grouping(ind,2)-layer_grouping(ind,1)-dx,box_width-dy],...
        'FaceColor',layer_colour(ind,:),'Edgecolor','none');hold on
end
% write text over it
box_tex_position=[1.4,6.7,12.6,19.75,26.75,34.2];
box_name={'conv-1','conv-2','conv-3','conv-4','conv-5','fc'};
for ind =1:size(layer_grouping,1)
    text(box_tex_position(ind),double(yL)+box_width/2+dy,box_name{ind},'color','k','FontSize',6);
end

%% Plotting the data
% layer IDS
index_input=1;
index_conv=[2,4,7,9,12,14,16,19,21,23,26,28,30];
index_relu=[3,5,8,10,13,15,17,20,22,24,27,29,31,34,36];
index_pool=[6,11,18,25,32];
index_fc=[33,35,37];
line_colour = colormap('Lines');
%% Plotting the Data
marker_size=2;
layer_ind=1:nL;
for ind=1:size(mean_data,1)
    if(exist('sem_data')&& (~isempty(sem_data)))
        shadedErrorBar(1:nL,mean_data(ind,:),sem_data(ind,:),'lineprops',{'-','markerfacecolor',line_colour(ind,:),...
            'color',line_colour(ind,:),'LineWidth',0.5},'transparent',true,'patchSaturation',0.3);hold on;
    else
        plot(1:nL,mean_data(ind,:),'-','markerfacecolor',line_colour(ind,:),...
            'color',line_colour(ind,:),'LineWidth',0.5);hold on;
    end
    %     plot(layer_ind(index_input),mean_data(ind,index_input),'MarkerEdgeColor',line_colour(ind,:),'MarkerFaceColor',line_colour(ind,:),'MarkerSize',marker_size);hold on;
    plot(layer_ind(index_conv),mean_data(ind,index_conv),'o','MarkerSize',marker_size,'MarkerEdgeColor',line_colour(ind,:));
    plot(layer_ind(index_relu),mean_data(ind,index_relu),'o','MarkerSize',marker_size,'MarkerEdgeColor',line_colour(ind,:),'MarkerFaceColor',line_colour(ind,:));
    plot(layer_ind(index_pool),mean_data(ind,index_pool),'d','MarkerSize',marker_size,'MarkerEdgeColor',line_colour(ind,:),'MarkerFaceColor',line_colour(ind,:));
    plot(layer_ind(index_fc),mean_data(ind,index_fc),'s','MarkerSize',marker_size,'MarkerEdgeColor',line_colour(ind,:));
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
ylabel(y_label);xlabel('VGG-16 layers')
% Legends
h=get(gca,'Children'); % grab all the axes handles at once
N=size(mean_data,1);Nh=length(h);
sel_legends=zeros(N,1);for i=1:N,sel_legends(i)=Nh-(13+(i-1)*5);end
legend(h(sel_legends),legend_name,'FontSize',FontSize,'Location','best','Box','off');
set_fig_fonts(FontSize)
print(gcf,'-dpdf',[file_name,'.pdf']) % Saving the pdf
end