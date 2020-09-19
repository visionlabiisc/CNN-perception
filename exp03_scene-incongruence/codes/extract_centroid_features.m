function [featues_centroid]=extract_centroid_features(stim,type,dagg_flag,run_path)
run(run_path);
if(dagg_flag==0)
    % Initializing the network
    net = load(type) ;
    net = vl_simplenn_tidy(net);
    
    % Geeting the size requirement fot the network
    Src=net.meta.normalization.imageSize(1:2);% size of the normalized image
    rgb_values=net.meta.normalization.averageImage;rgb_values=rgb_values(:) ;
    average_image=ones(Src(1),Src(2),3);for i=1:3,average_image(:,:,i)=rgb_values(i);end% Preparing the mean matrix
    
    Nimage=length(stim);
    for i=1:Nimage
        % Preparing the input image in the required size
        bimage_ip=single(stim{i});
        if size(bimage_ip,3)==1, bimage_ip = repmat(bimage_ip,1,1,3); end
        cimage=imresize(bimage_ip,Src);
        cimage=cimage-average_image; % substracting the average value.
        
        % extracting the features
        F=vl_simplenn(net,cimage);nL=length(F);Fv=cell(nL,1);
        for L=1:nL,Fv{L,1}=vec(F(L).x);end % vectorize
        
        % Adding the Feature to centroid
        if(i==1),featues_centroid=Fv;
        else,for L=1:nL,featues_centroid{L,1}=featues_centroid{L,1}+Fv{L};end;end
    end
    
    % Normalizing the features_centroid by 1/Nimage.
    for L=1:nL,featues_centroid{L,1}=featues_centroid{L,1}*(1/Nimage);end
    
elseif(dagg_flag==1)
    net = dagnn.DagNN.loadobj(load(type)) ;
    net.mode = 'test' ;
    Nimage=length(stim);
    Fv=cell(Nimage,1);
    net.conserveMemory=0;
    nL=length(net.vars);
    for i=1:Nimage
        bimage_ip=single(stim{i});
        cimage=imresize(bimage_ip,net.meta.normalization.imageSize(1:2));
        cimage = bsxfun(@minus, cimage, net.meta.normalization.averageImage) ;
        net.eval({'data', cimage})
        for L=1:nL
            Fv{L,1} = vec(net.vars(L).value);
        end        
        if(i==1)
            featues_centroid=Fv;
        else
            for L=1:nL,featues_centroid{L,1}=featues_centroid{L,1}+Fv{L};end
        end
        
    end
    % Normalizing the features_centroid by 1/Nimage.
    for L=1:nL
        featues_centroid{L,1}=featues_centroid{L,1}*(1/Nimage);
    end
end
end