function mirror_confusion_index=CheckMirrorConfusion(features)
% Here I assume the Stimuli is arrange in a particulr order
% 100 unique stimuli, followed by 100 mirror about y-axis, followed by 100 mirror about x-axis 
N=100; % There are 100 unique stimuli
nL=length(features{1})-1;% Skipping the last layers
mirror_confusion_index=zeros(N,nL); % Horizonatal , Vertical
for img=1:N
    img_numbers=[img,N+img,2*N+img];
    for L=1:nL
        fi=squeeze(features{img_numbers(1)}(L).x);
        fYm=squeeze(features{img_numbers(2)}(L).x);
        fXm=squeeze(features{img_numbers(3)}(L).x);
        dYm=norm(fYm(:)-fi(:),2);% MIRROR ABOUT X-axis
        dXm=norm(fXm(:)-fi(:),2);% MIRROR ABOUT Y-axis
        mirror_confusion_index(img,L)=(dXm-dYm)./(dXm+dYm);
    end
end
end