function d=distance_calculation(f1,f2,type)
X=[f1';f2'];
switch type
    case 'Euclidean'
        d=norm(X(1,:)-X(2,:),2);
    case 'CityBlock'
        d=norm(X(1,:)-X(2,:),1);
    case 'Cosine'
        d=pdist(X,'cosine');
    case 'pearson'
        d=pdist(X,'correlation');
    case 'spearman' 
         d=pdist(X,'spearman');
    otherwise
          d=NAN;  
end
end