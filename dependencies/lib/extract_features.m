function features=extract_features(stim,type,dagg_flag,run_path)
run(run_path);
if(dagg_flag==0)
    net = load(type) ;
    net = vl_simplenn_tidy(net);
    nimages=length(stim);
    features=cell(nimages,1);
    Src=net.meta.normalization.imageSize(1:2);% size of the normalized image
    rgb_values=net.meta.normalization.averageImage;rgb_values=rgb_values(:);
    average_image=ones(Src(1),Src(2),3);
    for ind=1:3,average_image(:,:,ind)=rgb_values(ind);end
    for ind=1:nimages
        bimage_ip=single(stim{ind});
        if size(bimage_ip,3)==1, bimage_ip = repmat(bimage_ip,1,1,3); end
        cimage=imresize(bimage_ip,Src);
        cimage=cimage-average_image;
        features{ind}=vl_simplenn(net,cimage);
    end
elseif(dagg_flag==1)
    net = dagnn.DagNN.loadobj(load(type)) ;
    net.mode = 'test' ;
    nimages=length(stim);
    features=cell(nimages,1);
    net.conserveMemory=0;
    nL=length(net.layers)-1;
    for i=1:nimages
        bimage_ip=single(stim{i});
        cimage=imresize(bimage_ip,net.meta.normalization.imageSize(1:2));
        cimage = bsxfun(@minus, cimage, net.meta.normalization.averageImage) ;
        %cimage=cimage-ones(1,1,3)*128; % abstract images
        net.eval({'data', cimage})
        for L=1:nL
            scores(L).x = vec(net.vars(L).value);
        end
        features{i}=scores;
    end
end
end