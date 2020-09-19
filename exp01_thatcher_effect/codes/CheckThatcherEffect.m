function thatcherIndex=CheckThatcherEffect(features)
nL=length(features{1})-1;% Skipping the last layers
N=20;
features=reshape(features,[N,4]); % Expecting that there are 80 image in total always. 
thatcherIndex=zeros(N,nL);
for ind=1:length(features)
    for L=1:nL
        v1=features{ind,1}(L).x;
        v2=features{ind,2}(L).x;
        v3=features{ind,3}(L).x;
        v4=features{ind,4}(L).x;
        v12=norm(v1(:)-v2(:),2);
        v34=norm(v3(:)-v4(:),2);
        thatcherIndex(ind,L)=(v12-v34)./(v12+v34);
    end
end
end