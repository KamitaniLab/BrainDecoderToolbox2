function [hw, mu, sd, upper, lower, c] = cellci(X, p, side)
% cellci    Calc confidence interval across cells
% 
% This file is a part of BrainDecoderToolbox2
%
% Inputs:
%
% - X    : Cell 
% - p    : Confidence level
% - side : 'onesided' or 'twosided'
% 
% Outputs:
%
% - hw    : Half width of confidence interval
% - mu    : Mean
% - sd    : Standard deviation
% - upper : Upper limit
% - lower : Lower limit
% - c     : Cumulative probability
% 
% Note:
%
% Originally developed by Tomoyasu Horikawa <horikawa-t@atr.jp> on 2013-12-27.
% 

if ~exist('side','var')
    side='onesided';
end

if ~exist('p','var')
    p=0.95;
end

mu=cellmean(X);

n=length(X);
dif2=zeros(size(X{1}));
for i=1:n
    dif2=dif2+(X{i}-mu).^2;
end
sd=sqrt(dif2./(n-1));

switch side
    case 'onesided'
        c=tinv(p,n-1);
    case 'twosided'
        c=tinv((1+p)/2,n-1);
    otherwise
        error('Invalid ''side'' option.')
end
hw=c.*sd./sqrt(n);
upper=mu+hw;
lower=mu-hw;
