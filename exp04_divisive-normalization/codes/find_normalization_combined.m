function [coeff_combined]= find_normalization_combined(Fcombined,Fsum)
% combined normalization
fc_max=max(Fcombined(:));
fsum_max=max(Fsum(:));
C=max(fc_max,fsum_max);
coeff_combined=regress(Fcombined(:)/C,[Fsum(:)/C, ones(length(Fsum(:)),1)]);
end