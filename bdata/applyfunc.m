function [dataSet, metaData] = applyfunc(dataSet, metaData, func, keylist, varargin)
% applyfunc    Apply `func` to `dataSet` and `metaData`
%
% Inputs:
%
% - dataSet, metaData          : BrainDecoderToolbox2 data
% - func     [function handle] : Hanle of a function to be applied
% - keylist  [str]             : Metadata key(s) for the input/output of `func`
% - varargin                   : The rest of arguments are given to `func`
%
% You can specify several metadata keys separated by commas in `keylist`.
% Example:
%
%     [dataSet, metaData] = applyfunc(dataSet, metaData, ...
%                                     @shift_sample, 'VoxelData, MotionParameter', ...
%                                     'Group', runs, 'ShiftSize', 2)
%
% Outputs:
%
% - dataSet, metaData : BrainDecoderToolbox2 data
%

keys = parse_keylist(keylist);

selector = '';
for i = 1:length(keys)
    selector = [selector, keys{i} ' = 1'];
    if i ~= length(keys)
        selector = [selector, ' | '];
    end
end

[x, xcol] = select_dataset(dataSet, metaData, selector);
a = dataSet(:, ~xcol);

numoutput = nargout(func);

if numoutput == 1
    % No index remapping
    y = func(x, varargin{:});

    if size(x) ~= size(y)
        error('Data size was changed without index mapping')
    end

    indrow  = [1:size(x, 1)]';
    indcolx = [1:size(x, 2)];

    dataSet(:, xcol) = y;
else
    % Index remapping
    [y, indmap] = func(x, varargin{:});

    if size(indmap, 2) == 1
        % Index mapping in sample dimension (row)
        indcolx = 1:size(x, 2);
        indrow = indmap;
    elseif size(indmap, 1) == 1
        % Index mapping in feature dimension (column)
        indcolx = indmap;
        indrow = [1:size(x, 1)]';
    else
        error('Invalid index map');
    end

    % Create new dataSet
    newDataSetRowNum = size(indrow, 1);
    newDataSetColNum = size(indcolx, 2) + size(a, 2);
    dataSet = nan(newDataSetRowNum, newDataSetColNum);

    % Column index conversion
    xcolindex = find(xcol);
    acolindex = find(~xcol);
    xcolindex = xcolindex(indcolx);
    colindexmap = sort([xcolindex, acolindex]); % Old dataSet/metaData --> new dataSet/metaData
    xcolnew = xcol(colindexmap); % x columns index in the new dataSet

    % Insert data into the new dataSet
    dataSet(:, xcolnew) = y;
    dataSet(:, ~xcolnew) = a(indrow, :);

    % Update metaData
    metaData.value = metaData.value(:, colindexmap);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function keys = parse_keylist(str)
% Parse `str` into keys (cell array)
%

% Remove whitespaces in `str`
str = strrep(str, ' ', '');

% Lexical analyze
keys = {};
buf = '';
for i = 1:length(str)
    if strcmp(str(i), ',')
        % Operator
        if length(buf) ~= 0
            keys{end+1} = buf;
            buf = '';
        end
    elseif i == length(str)
        % String terminal
        buf(end+1) = num2str(str(i));
        if length(buf) ~= 0
            keys{end+1} = buf;
            buf = '';
        end
    else
        buf(end+1) = str(i);
    end
end
