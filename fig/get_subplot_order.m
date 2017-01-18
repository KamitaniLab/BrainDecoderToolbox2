function [ord, nrow, ncol] = get_subplot_order(numPlot, direction, off, centeroff)
% get_subplot_order    Set the nrow and ncol for square
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - numPlot   : Number of plots (scalar or [numRow, nCol])
% - direction : Direction of order (default: 'ltr')
%               'ltr': left-top-right
%               'ltd': left-top-down
%               'rtl': right-top-left
%               'rtd': right-top-down
%               'lbr': left-bottom-right
%               'lbu': left-bottom-up
%               'rbl': right-bottom-left
%               'rbu': right-bottom-up
% - off       : Num of removed outframe ([row, col])
% - centeroff : Num of removed centerremove center: n of remove
%               remove, 1:column, 2:row, 3:both
%
% Outputs:
%
% - ord  : Order of subplot indexes
% - nrow : Number of rows
% - ncol : Number of colmns
%
% Note:
%
% Originally developed as `setrc2` by Tomoyasu Horikawa <horikawa-t@atr.jp> on 2010-07-28
%

if length(numPlot) == 2
    nrow = numPlot(1);
    ncol = numPlot(2);
else
    nrow = floor(numPlot / ceil(sqrt(numPlot)));
    ncol = ceil(numPlot / floor(numPlot / ceil(sqrt(numPlot))));
end

if ~exist('direction','var') || isempty(direction)
    direction='ltr';
end

mat=makeM(1:(nrow*ncol),[nrow,ncol],2);
if exist('off','var') && ~isempty(off) && any(off~=0)
    if length(off)==1
        for i=1:off(1)
            mat(1,:)=[];
            mat(end,:)=[];
            mat(:,1)=[];
            mat(:,end)=[];
        end
    else
        for i=1:off(1)
            mat(1,:)=[];
            mat(end,:)=[];
        end
        for i=1:off(2)
            mat(:,1)=[];
            mat(:,end)=[];
        end
    end
end
if exist('centeroff','var') && ~isempty(centeroff) && centeroff~=0
    [cr,cc]=size(mat);
    switch centeroff
        case 1
            mat(:,ceil(cc/2))=[];
        case 2
            mat(ceil(cr/2),:)=[];
        case 3
            mat(ceil(cr/2),:)=[];
            mat(:,ceil(cc/2))=[];
    end
end
switch direction
    case 'ltr'% left-top-right
        ord=asvector(mat,2);
    case 'ltd'% left-top-down
        ord=asvector(mat,1)';
    case 'rtl'% right-top-left
        matx=mat(:,end:-1:1);
        ord=asvector(matx,2);
    case 'rtd'% right-top-down
        matx=mat(:,end:-1:1);
        ord=asvector(matx,1)';
    case 'lbr'% left-bottom-right
        matx=mat(end:-1:1,:);
        ord=asvector(matx,2);
    case 'lbu'% left-bottom-up
        matx=mat(end:-1:1,:);
        ord=asvector(matx,1)';
    case 'rbl'% right-bottom-left
        matx=mat(end:-1:1,end:-1:1);
        ord=asvector(matx,2);
    case 'rbu'% right-bottom-up
        matx=mat(end:-1:1,end:-1:1);
        ord=asvector(matx,1)';
end


function V=asvector(B,direction)
% asvector --  converts matrix to vector
% function V=asvector(B,direction)
% 
% [Inputs]
% B:matrix
% direction:direction ==1 ??direction ==2 -> (default=1)
%
% example:
% A={ 1 2 3
%     4 5 6 }
%   B=asvector(A,1)=[1 4 2 5 3 6]' modified by horikawa 090827 transpose
%   B=asvector(A,2)=[1 2 3 4 5 6]
% created by HORIKAWA tomoyasu 09/09/03
% modified by HORIKAWA tomoyasu 12/09/18
if exist('direction','var')==0
    direction=1;
end

switch direction
    case 1
        V=B(:);
    case 2
        b=B';
        V=b(:)';
    otherwise
        error('Invalid input.')
end

function B=makeM(A,rowcol,direction)
% makeM -- builds the matrix which consist of component of vecor A
% function B=makeM(A,rowcol,direction)
% Input
%   A: vector.
%   rowcol: two components vector[row col]
%           size(B) where B is matrix can be directly applied
%   direction: direction of setting component. direction ==1 ↓　direction ==2 -> (default=1)
% The components are entered from left to right, not top to bottom
% e.g.,
%  B=makeM(1:10,[2,5],2)
%   B =
%      1     2     3     4     5
%      6     7     8     9    10
%   A=makeM(1:10,size(B),2)
%   A =
%      1     2     3     4     5
%      6     7     8     9    10
%   A=makeM(1:10,size(B),1)
%      1     3     5     7     9
%      2     4     6     8    10
%
%
% created by  HORIKAWA tomoyasu 09/09/03
% modified by HORIKAWA tomoyasu 09/09/03
% modified by HORIKAWA tomoyasu 09/10/23 switch the direction 1<->2
switch direction
    case 1
        for i=1:rowcol(2)
            B(:,i)=A((1:rowcol(1))+(i-1)*rowcol(1));
        end
    case 2
        for i=1:rowcol(1)
            B(i,:)=A((1:rowcol(2))+(i-1)*rowcol(2));
        end
    otherwise
end
