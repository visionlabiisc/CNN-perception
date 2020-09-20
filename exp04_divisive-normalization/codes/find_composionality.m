function [r_mean, r_sem]=find_composionality(Fp,Fsum,F)
Nneuron=size(Fp,1);
Ncond=size(Fp,2);
NTr=round(0.6*Ncond);
NTe=Ncond-NTr;
Sel_Index=randperm(Ncond,Ncond);
sel_TR=Sel_Index(1:NTr);
sel_TE=Sel_Index(NTr+(1:NTe));
% training
for n=1:Nneuron
    % train
    XTR=[];
    for di=1:size(F,3)
        XTR=[XTR,vec(F(n,sel_TR,di))];
    end
    XTR=sum(XTR,2);
    
    XTR=[XTR, ones(NTr,1)];
    Res=vec(Fp(n,sel_TR));
    b=regress(Res,XTR);Res_pre=XTR*b;rTr(n)=nancorrcoef(Res_pre,Res);
    
    % test
  XTE=[];
    for di=1:size(F,3)
        XTE=[XTE,vec(F(n,sel_TE,di))];
    end
    XTE=sum(XTE,2);
    XTE=[XTE, ones(NTe,1)];
    Res=vec(Fp(n,sel_TE));
    b=regress(Res,XTE);Res_pre=XTE*b;rTe(n)=nancorrcoef(Res_pre,Res);
end
r_mean=[nanmean(rTr);nanmean(rTe)];
r_sem=[nansem(rTr,2);nansem(rTe,2)];

end