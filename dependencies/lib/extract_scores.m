function scores=extract_scores(stim,type,dagg_flag,run_path)
run(run_path);
if (dagg_flag==0) % SIMPLE NN Network
    net = load(type) ;
    net = vl_simplenn_tidy(net);
    nimages=length(stim);
    scores=cell(nimages,1);
    Src=net.meta.normalization.imageSize(1:2);% size of the normalized image
    rgb_values=net.meta.normalization.averageImage;rgb_values=rgb_values(:);
    average_image=ones(Src(1),Src(2),3);
    for i=1:3,average_image(:,:,i)=rgb_values(i);end
    
    for i=1:nimages
        bimage_ip=single(stim{i});
        if size(bimage_ip,3)==1, bimage_ip = repmat(bimage_ip,1,1,3); end
        cimage=imresize(bimage_ip,Src);
        features=vl_simplenn(net,cimage);
        scores{i}=squeeze(gather(features(end).x)) ;
    end
end
if (dagg_flag==1) % DAGG Network
        net = dagnn.DagNN.loadobj(load(type)) ;
    net.mode = 'test' ;
    nimages=length(stim);
    features={nimages,1};
    net.conserveMemory=0;
    nL=length(net.layers)-1;
    for i=1:nimages
        bimage_ip=single(stim{i});
        cimage=imresize(bimage_ip,net.meta.normalization.imageSize(1:2));
        cimage = bsxfun(@minus, cimage, net.meta.normalization.averageImage) ;
        net.eval({'data', cimage})
        scores{i} = vec(net.vars(end).value);
    end
end
end