function mi_3d=check_3D(features,dist_types)
    nSet=2;
    nL=length(features{1})-1;% Skipping the last layers
    mi_3d=zeros(2,nL);
    %% Analysis
    mi_3d_raw1=zeros(nL,2);mi_3d_raw2=zeros(nL,2);
    for layers=1:nL
        for set=1:nSet
            img_index=(set-1)*6+[1:6];
            f1=vec(features{img_index(1)}(layers).x);
            f2=vec(features{img_index(2)}(layers).x);
            f3=vec(features{img_index(3)}(layers).x);
            f4=vec(features{img_index(4)}(layers).x);
            f5=vec(features{img_index(5)}(layers).x);
            f6=vec(features{img_index(6)}(layers).x);
            % comparing Y and Cuboid
            dI12=distance_calculation(f1,f2,dist_types);
            dI34=distance_calculation(f3,f4,dist_types);
            mi_3d_raw1(layers,set)=(dI34-dI12)./(dI34+dI12);
            
            % Comparing Square+Y and Cuboid
            dI56=distance_calculation(f5,f6,dist_types);
            mi_3d_raw2(layers,set)=(dI56-dI34)./(dI56+dI34);
        end  
    end
     mi_3d(1,:)=nanmean(mi_3d_raw1,2);
     mi_3d(2,:)=nanmean(mi_3d_raw2,2);
end