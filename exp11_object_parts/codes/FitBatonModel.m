%FitBatonModel     -> Fit standard baton model to data
% Required inputs
%    dobs          = npairs x 1 vector of observed dissimilarities
%    allparts      = npairs x 4 matrix containing partids as [obj1part1 obj1part2 obj2part1 obj2part2]
% Optional inputs:
%    sepflag       = if 1, separately estimate corresponding part coefficients (e.g. for global-local)
% Outputs:
%    dpred         = predicted dissimilarities from the baton model
%    b             = estimated part distances
%    X             = npairs x nparameters regression matrix
%    Lids          = columnids of X that represent corresponding left parts
%    Rids          = columnids of X that represent corresponding right parts
%    Aids          = columnids of X that represent across-object relations
%    Wids          = columnids of X that represent within-object relations
% Notes
%    The baton model takes the net dissimilarity between a pair of objects as
%    the weighted sum of distances between their corresponding parts, distance between parts across
%    locations in the two objects, and distance between parts within an object

% Credits: SPArun
% ChangeLog:
%    10/07/2017 - SPA     - first version

function [dpred,b,X,Lids,Rids,Aids,Wids] = FitBatonModel(dobs,allparts,sepflag)
if(~exist('sepflag')), sepflag = 1; end; % separate the two corresponding part terms by default

npairs = size(allparts,1);
nparts = length(unique(allparts(:)));
partpairs = nchoosek(1:nparts,2); npartpairs = size(partpairs,1);

% form regression matrix (this is the key step)
X = zeros(npairs,npartpairs*4+1);
Lids = 1:npartpairs; Rids = npartpairs+1:2*npartpairs;
Aids = [2*npartpairs+1:3*npartpairs]; Wids = [3*npartpairs+1:4*npartpairs];
for pid = 1:npairs
    parts = allparts(pid,:); L = parts([1 3]); R = parts([2 4]);
    Lid  = find( (partpairs(:,1)==L(1) & partpairs(:,2)==L(2)) | (partpairs(:,2)==L(1) & partpairs(:,1)==L(2)) );
    Rid  = find( (partpairs(:,1)==R(1) & partpairs(:,2)==R(2)) | (partpairs(:,2)==R(1) & partpairs(:,1)==R(2)) );
    Aid1 = find( (partpairs(:,1)==L(1) & partpairs(:,2)==R(2)) | (partpairs(:,2)==L(1) & partpairs(:,1)==R(2)) );
    Aid2 = find( (partpairs(:,1)==L(2) & partpairs(:,2)==R(1)) | (partpairs(:,2)==L(2) & partpairs(:,1)==R(1)) );
    Wid1 = find( (partpairs(:,1)==L(1) & partpairs(:,2)==R(1)) | (partpairs(:,2)==L(1) & partpairs(:,1)==R(1)) );
    Wid2 = find( (partpairs(:,1)==L(2) & partpairs(:,2)==R(2)) | (partpairs(:,2)==L(2) & partpairs(:,1)==R(2)) );
    
    X(pid,Lids(Lid)) = 1;
    X(pid,Rids(Rid)) = 1;
    X(pid,Aids([Aid1 Aid2])) = 1; if(Aid1==Aid2), X(pid,Aids(Aid1)) = 2; end;
    X(pid,Wids([Wid1 Wid2])) = 1; if(Wid1==Wid2), X(pid,Wids(Wid1)) = 2; end;
end
if(~sepflag), X(:,Lids) = X(:,Lids)+X(:,Rids); X(:,Rids) = []; Aids = Aids - npartpairs; Rids = Rids - npartpairs; end;
X(:,end) = 1; % add a constant term to model

% fit baton model
if(~isempty(dobs))
    b = regress(dobs,X); dpred = X*b;
else
    b=[];
    dpred=[];
end
return
