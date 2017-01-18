function [y, indSelected] = select_feature(dataSet, metaData, expr)
% select_feature    Select features from dataSet
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     [y, indSelected] = select_feature(dataSet, metaData, expr)
%
% Inputs:
%
% - dataSet  : Dataset matrix
% - metaData : Metadata structure
% - expr     : Feature selection expression (see below)
%
% Outputs:
%
% - y           : Matrix of selected features
% - indSelected : Column index of `dataSet` for the selected features
%
% Examples of selection expression (`expr`):
%
% - 'ROI_A = 1' : Return features in ROI_A
% - 'ROI_A = 1 | ROI_B = 1' : Return features in the union of ROI_A and ROI_B
% - 'ROI_A = 1 & ROI_B = 1' : Return features in the intersect of ROI_A and ROI_B
% - 'Stat_P top 100' : Return the top 100 features for Stat_P value
% - 'Stat_P top 100 @ ROI_A = 1' : Return the top 100 features for Stat_P value within ROI_A
%

selectExpr = parse_selectexpr(expr);

results = {}; % Stack to store results
bufSel  = []; % Buffer to store num of featrures to be selected by 'top'
for n = 1:length(selectExpr)

    if strcmp(selectExpr{n}, '=')
        % 'A = B' => A is B
        [results, mdVal] = pop_stack(results);
        [results, mdKey] = pop_stack(results);

        md = get_metadata(metaData, mdKey);
        md(isnan(md)) = 0;
        
        results = push_stack(results, ...
                             get_metadata(metaData, mdKey) == str2num(mdVal));
    elseif strcmp(selectExpr{n}, 'top')
        % 'A top n'
        [results, topNum] = pop_stack(results);
        [results, mdKey] = pop_stack(results);

        mdVal = get_metadata(metaData, mdKey);
        mdVal(isnan(mdVal)) = -Inf;
        
        [ junk, ind ] = sort(mdVal, 'descend');

        order(ind) = 1:length(mdVal);
        
        results = push_stack(results, order);
        bufSel(end + 1) = str2num(topNum);
    elseif strcmp(selectExpr{n}, '@')
        % 'A @ B' => A in B
        [results, rightTerm] = pop_stack(results);
        [results, leftTerm] = pop_stack(results);

        leftTerm(~rightTerm) = NaN;

        [selectedInd, bufSel] = select_order(leftTerm, bufSel);

        results = push_stack(results, selectedInd);
    elseif strcmp(selectExpr{n}, '|') || strcmp(selectExpr{n}, '&')
        % 'A | B' => A or B
        % 'A & B' => A and B
        [results, rightTerm] = pop_stack(results);
        [results, leftTerm] = pop_stack(results);

        if ~islogical(rightTerm)
            [rightTerm, bufSel] = select_order(rightTerm, bufSel);
        end

        if ~islogical(leftTerm)
            [leftTerm, bufSel] = select_order(leftTerm, bufSel);
        end

        if strcmp(selectExpr{n}, '|')
            results = push_stack(results, leftTerm | rightTerm);
        elseif strcmp(selectExpr{n}, '&')
            results = push_stack(results, leftTerm & rightTerm);
        end
    else
        results = push_stack(results, selectExpr{n});
    end

end

[results, indSelected] = pop_stack(results);
if ~isempty(bufSel)
    indSelected = indSelected <= bufSel(end);
end
y = dataSet(:, logical(indSelected));

%------------------------------------------------------------------------------
function rpn = parse_selectexpr(expr)
% parse_selectexpr    Lexicial analyser and parser for feature selection expression
%

signs = {'(', ')'};
operators = {'=', '|', '&', '@', 'top'};

% Lexical analysis
buf    = [];
tokens = {};

for n = 1:length(expr)
    if strcmp(expr(n), ' ')
        continue;
    elseif sum(strcmp(expr(n), signs)) | sum(strcmp(expr(n), operators))
        if ~isempty(buf)
            tokens{end+1} = buf;
            buf = [];
        end
        tokens{end+1} = expr(n);
    else
        buf = [ buf, expr(n) ];
    end

    if length(buf) >= 3 && strcmp(buf(end-2:end), 'top')
        if length(buf) ~= 3
            tokens{end + 1} = buf(1:end-3);
        end
        tokens{end + 1} = 'top';
        buf = [];
    end
end

if ~isempty(buf)
    tokens{end+1} = buf;
    buf = [];
end

% Parser (shunting-yard)
outQue    = {};
opStack   = {};
opStackPt = 0;

for n = 1:length(tokens)
    if sum(strcmp(tokens{n}, operators))
        pp = true;
        while pp
            if opStackPt == 0
                pp = false;
            elseif strcmp(opStack{opStackPt}, '(') || strcmp(opStack{opStackPt}, ')')
                pp = false;
            elseif op_precede(tokens{n}, opStack{opStackPt})
                pp = false;
            else
                outQue{end + 1} = opStack{opStackPt};
                opStackPt = opStackPt - 1;
            end
        end

        opStackPt = opStackPt + 1;
        opStack{opStackPt} = tokens{n};
    elseif strcmp(tokens{n}, '(')
        opStackPt = opStackPt + 1;
        opStack{opStackPt} = tokens{n};
    elseif strcmp(tokens{n}, ')')
        pp = true;
        while pp
            if opStackPt == 0
                error('Parentheses mismatch');
            elseif strcmp(opStack{opStackPt}, '(')
                pp = false;
            else
                outQue{end + 1} = opStack{opStackPt};
                opStackPt = opStackPt - 1;
            end
        end
        opStackPt = opStackPt - 1;
    else
        outQue{end + 1} = tokens{n};
    end
end

for n = opStackPt:-1:1
    outQue{end + 1} = opStack{n};
end

% Output
rpn = outQue;

%------------------------------------------------------------------------------
function stack = push_stack(stack, element)
% push_stack    Push `element` to `stack`

stack{end + 1} = element;

%------------------------------------------------------------------------------
function [stack, element] = pop_stack(stack)
% pop_stack    Pop `element` from `stack`

element = stack{end};
stack = { stack{1:end-1} };

%------------------------------------------------------------------------------
function isPrecede = op_precede(a, b)
% op_precedence    Return true if operator precedence a > b

isPrecede = false;
switch a
  case {'=', 'top'}
    a_preced = 7;
  case {'&', '|'}
    a_preced = 5;
  case {'@'}
    a_preced = 3;
  otherwise
    error('op_precede:UnknwonOperator', ...
          [ 'Unknown operator: ', a ]);
end

switch b
  case {'=', 'top'}
    b_preced = 7;
  case {'&', '|'}
    b_preced = 5;
  case {'@'}
    b_preced = 3;
  otherwise
    error('op_precede:UnknwonOperator', ...
          [ 'Unknown operator: ', b ]);
end

isPrecede = a_preced > b_preced;

%------------------------------------------------------------------------------
function [ind, buf] = select_order(order, buf)
% select_order    Select `buf(end)` elements from order

numSel = buf(end);
buf = buf(1:end-1);

[junk, indOrder] = sort(order);

ind = false(size(order));
ind(indOrder(1:numSel)) = true;

