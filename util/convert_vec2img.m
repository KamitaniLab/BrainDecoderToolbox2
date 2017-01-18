function [img, varargout] = convert_vec2img(imgVec, imgCoords)
% convert_vec2img    Convert an image vector to an array
%
% Inputs:
%
% - imgVec    : Image vector
% - imgCoords : Coordinates of each element in the image vector
%
% Outputs:
%
% - img       : Image array
% - varargout : Coordinates vectors
%

imgDim = size(imgCoords, 1);

for i = 1:imgDim
    coords{i, 1} = unique(imgCoords(i, :));
    imgSize{i, 1} = length(coords{i, 1});

    [ism, sub] = ismember(imgCoords(i, :), coords{i, 1});
    subs{i} = sub;
end

img = nan(imgSize{:});
img(sub2ind(size(img), subs{:})) = imgVec;

for i = 1:imgDim
    varargout{i} = coords{i};
end
