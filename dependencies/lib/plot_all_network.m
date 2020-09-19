function plot_all_network(MI_across_layers,file_name,figure_title,y_label_name,reference_mi,reference_name)
% MI_across_layers : This is the calculated modualtion index across layers  (Matrix of form, number of conditions x nL)
% file_name : Name by which the plot is saved (String, Example "abcd")
% figure_title : Name corresponding to each condition (Cell of String, number of conditions x 1) 
% ylabel : Y-Label, String

% Optional
% reference_mi : Modulation Index calculated from behavior effect (Scalar)
% reference_name : Reference Manuscript Citation (String)

s=size(MI_across_layers);
if(min(s(1:2))==1)
    nL=length(MI_across_layers);
else
    nL=size(MI_across_layers,2);    
end

sel_colour=colormap('Lines');
plot_aspect_ratio=1.4;
figure('Units','centimeters','PaperSize',[2.9,2.07])
rectangle('Position',[1.1,0,nL,1],'FaceColor',[.8,0.8,0.8],'EdgeColor','none');
text(2,0.9,'Human Perception')
hold on

if(size(MI_across_layers,1)==1)
plot(1:nL,MI_across_layers,'color',sel_colour(1,:))
else 
shadedErrorBar(1:nL,MI_across_layers,{@nanmean,@nansem},'lineprops',{'color',sel_colour(1,:)});
end

xlabel('Layers');ylabel(y_label_name);title(figure_title)
pbaspect([plot_aspect_ratio,1,2]);
ylim([-1,1]);xlim([1,nL]);
h=gca;h.XTick=[1,nL];h.YTick=[-1,0,1];

% Refernce line
if(~isempty(reference_mi))
line([1 nL],[reference_mi reference_mi],'Marker','none','LineStyle','--','LineWidth',0.5, 'Color',[0 0 0])
text(2,reference_mi+0.1,reference_name)
end
set_fig_fonts(6)

% saving the data
print(gcf,'-dpdf',[file_name,'.pdf'],'-fillpage')
end
