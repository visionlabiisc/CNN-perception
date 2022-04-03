
function set_fig_fonts(FontSize); 

FontName = 'Arial'; 
hax = findobj(gcf,'Type','Axes'); 
for i = 1:length(hax); 
    h = hax(i); 
    set(h,'FontSize',FontSize,'FontName',FontName);
    set(get(h,'XLabel'),'FontSize',FontSize,'FontName',FontName);
    set(get(h,'YLabel'),'FontSize',FontSize,'FontName',FontName);
    set(get(h,'Title'),'FontSize',FontSize,'FontName',FontName);
    h = findobj(h,'Type','Text'); set(h,'FontSize',FontSize,'FontName',FontName);
    h = findobj(h,'Type','Legend'); 
end

