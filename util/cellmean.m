function meanofX=cellmean(X)
% cellmean    Average all the cell component 
% 
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - X : Cell
% 
% Outputs:
%
% - meanofX : Mean of the input
%
% Note:
%
% Originally developed by Tomoyasu Horikawa <horikawa-t@atr.jp> on 2009-12-16
% 

[row,col,dim]=size(X{1});
meanofX=double(X{1});
for i=1:dim
    for itr=2:numel(X)
        meanofX(:,:,i)=meanofX(:,:,i)+double(X{itr}(:,:,i));
    end
    meanofX(:,:,i)=meanofX(:,:,i)/numel(X);
end
