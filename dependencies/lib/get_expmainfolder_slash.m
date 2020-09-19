function [main_folder,SLASH]=get_expmainfolder_slash()
% This code works on windows and Linux
if(ispc),SLASH='\';end
if(isunix),SLASH='/';end

% main folder
if(~exist('main_folder','var'))
    xx=pwd;xx=strsplit(xx,SLASH);
    main_folder =[];if(isunix),main_folder=SLASH;end
    for i =1:(length(xx)-2)
        main_folder=[main_folder,xx{i},SLASH];
    end
end
end