 % Create Stimuli to test Webers Law.
 % GJ
% Length % Intensity 
%% Intensity
allclear;
load L2_I.mat;

% parameters
% r = unique(L2_str.data(:,2) );
r=[0.3000,0.3750,0.4688,0.5800,0.7300];
baseline = [96,150];
%baseline =linspace(150,200,6);
%$baseline = [96 150];
%baseline = 50:25:100;
% 
% r=[0.8,0.8^2,0.8^3,0.8^4,0.8^5];

barlen = 160;
barwid = 20;

Correction_to_Intensity=0;%117.43;%117.43;%117.43+20;%117.43

count = 1;
intimages = [];
for bid = 1:length(baseline)
    for rid = 1:length(r)
        del = round((baseline(bid)+Correction_to_Intensity)*r(rid));
        if isodd(del), 
            del1 = floor(del/2); del2 = ceil(del/2); 
        else
            del1 = del/2; del2 = del/2;
        end
        img1 = single(zeros(224)); img1(112-barwid/2:111+barwid/2, 112-barlen/2:111+barlen/2) = baseline(bid)-del1;
        img1 = repmat(img1,1,1,3);
        img2 = single(zeros(224)); img2(112-barwid/2:111+barwid/2, 112-barlen/2:111+barlen/2) = baseline(bid)+del2;
        img2 = repmat(img2,1,1,3);
        imgs.int{count,1} = img1; imgs.int{count,2} = img2;
           
        reldel.int(count,1) = del/(baseline(bid)+Correction_to_Intensity);%r(rid);
        absdel.int(count,1) = del;
        count = count + 1;
    end
end

npairs = size(imgs.int,1);
corrplot(reldel.int,absdel.int);
xlabel('Relative');
ylabel('Absolute');


%% Length
load L2_L.mat;

% parameters
%r = unique(L2_str.data(:,2));
r=[0.3000,0.3750,0.4688,0.5800,0.7300];
baseline = [64 100];
barwid = 20;

count = 1;
for bid = 1:length(baseline)
    for rid = 1:length(r)
        del = round(baseline(bid)*r(rid));
        if isodd(del), 
            del1 = floor(del/2); del2 = ceil(del/2); 
        else
            del1 = del/2; del2 = del/2;
        end
        barlen1 = baseline(bid)-del1; 
        if isodd(barlen1), lendel1 = floor(barlen1/2); lendel2 = ceil(barlen1/2); else lendel1 = barlen1/2; lendel2 = barlen1/2; end
        
        img1 = single(zeros(224)); img1(112-barwid/2:111+barwid/2, 112-lendel1:111+lendel2) = 255;% 255
        img1 = repmat(img1,1,1,3);
        barlen2 = baseline(bid)+del2;
        if isodd(barlen2), lendel1 = floor(barlen2/2); lendel2 = ceil(barlen2/2); else lendel1 = barlen2/2; lendel2 = barlen2/2; end
        img2 = single(zeros(224)); img2(112-barwid/2:111+barwid/2, 112-lendel1:111+lendel2) = 255; %255
        img2 = repmat(img2,1,1,3);
        imgs.len{count,1} = img1; imgs.len{count,2} = img2;
        reldel.len(count,1) = r(rid);
        absdel.len(count,1) = del;
        count = count + 1;
    end
end
npairs = size(imgs.len,1);
save('webers_images_GJ','imgs','reldel','absdel');


