% nancorrcoef -> compute corrcoef after removing nans

function [r,p,rlo,rup] = nancorrcoef(x,y)
xname = inputname(1); yname = inputname(2); 
if(isempty(xname)),xname='x';end; 
if(isempty(yname)),yname='y';end; 

x = x(:); y = y(:); 
q = find(isnan(x)|isnan(y)); x(q) = []; y(q) = []; % remove nans
if(length(x)>1)
    [r,p,rlo,rup] = corrcoef(x,y);
    if(isvector(x))
        r = r(2); p = p(2); rlo = rlo(2); rup = rup(2);
    end
else
    r = NaN; p = NaN; 
    %fprintf('nancorrcoef: vectors have only one element! returning NaNs.. \n'); 
end

if(nargout==0)
    fprintf('%s vs %s (n = %d), r = %2.2f, p = %2.2g \n',xname,yname,length(x),r,p); 
end; 
return; 