% nansem -> calculates standard error of the mean after removing nans

% Yet another in the category of why-doesn't-matlab-have-this-function

% SP Arun
% Created: 24/2/2013

function [sem,n] = nansem(x,dim)
if(isvector(x)), x = x(:); end
if(~exist('dim')),dim = 1; end

s = nanstd(x,[],dim); 
n = sum(~isnan(x),dim); 
sem = s./sqrt(n); 

return
