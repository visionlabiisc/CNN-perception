function d=distance_calculation_matrix(X,type)
switch type
    case 'Euclidean'
        %d=pdist(X,'euclidean');
        d=norm(X(1,:)-X(2,:),2);
    case 'CityBlock'
        %d=pdist(X,'cityblock' );
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
