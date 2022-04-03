% sparseness -> calculate the sparseness of responses to n stimuli
% s = sparseness(r)
% Required inputs
%    r             = ncells x nstim matrix of responses
% Outputs:
%    s             = ncells x 1 array of sparseness values
%    k             = effective number of stimuli to which the neuron responds. 
% Notes
%    Uses the formula described by Vinje et al (2000) 
%    If we assume that the neuron responds to k stimuli out of n, the sparseness formula
%    gives: s = (n-k)/(n-1). Based on this we can calculate for a given level of
%    sparseness, the effective number of stimuli that the neuron responds to. 

% SP Arun
% May 15 2012

function [s,k] = sparseness(r)
if(any(r(:)<0)), error('r has negative values!'); end; 
if(isvector(r)), r = r(:)'; end; 

n = size(r,2); % total number of stimuli 
s = (1 - (1/n)*sum(r,2).^2./sum(r.^2,2))/(1-1/n); % sparseness
k = n - (n-1)*s; % effective number of stimuli 

return;
