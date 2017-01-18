function viewvolume(varargin)
% viewvolume    View volume data
%
% This file is a part of BrainDecoderToolbox2.
%

%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt = bdt_getoption(varargin, ...
                    {{'VolumeFiles', 'cell', {}}, ...
                     {'VolumeColor', 'cell', {}}, ...
                     {'Overlays', 'cell', {}}, ...
                     {'OverlaysXyz', 'cell', {}}, ...
                     {'OverlaysLabels', 'cell', {}}, ...
                     {'OverlaysColor', 'cell', {}}, ...
                     {'Position', 'vector', [0, 0, 0]}});

volFiles = opt.VolumeFiles;
volColors = opt.VolumeColor;
overlays = opt.Overlays;
overlaysXyz = opt.OverlaysXyz;
overlaysLabels = opt.OverlaysLabels;
overlaysColor = opt.OverlaysColor;

position = opt.Position;

%% Load volumes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(volFiles)
    fprintf('Loading %s\n', volFiles{i});

    spmv = spm_vol(volFiles{i});
    [v, xyz] = spm_read_vols(spmv);

    vols(i).xyz = xyz;
    vols(i).val = v(:)';
    vols(i).color = volColors{i};
    vols(i).alpha = 1;
end

%% Load overlays
for j = 1:length(overlays)
    vols(i+j).val = overlays{j};
    vols(i+j).xyz = overlaysXyz{j};
    vols(i+j).color = overlaysColor{j};
    vols(i+j).alpha = 0.5;
end

%% Convert vectors to images
for i = 1:length(vols)
    [img, imgX, imgY, imgZ] = convert_vec2img(vols(i).val, vols(i).xyz);

    vw(i).img = img;
    vw(i).imgX = imgX;
    vw(i).imgY = imgY;
    vw(i).imgZ = imgZ;
    vw(i).alpha = vols(i).alpha;
end

%% Generate colormap
dispcolormap = [];
for i = 1:length(vols)
    switch vols(i).color
      case 'gray'
        cm = [linspace(0, 1, 256)', linspace(0, 1, 256)', linspace(0, 1, 256)'];
      case 'red'
        cm = [linspace(0, 1, 256)', zeros(256, 2)];
      case 'green'
        cm = [zeros(256, 1), linspace(0, 1, 256)', zeros(256, 1)];
      case 'blue'
        cm = [zeros(256, 2), linspace(0, 1, 256)'];
      case 'yellow'
        cm = [linspace(0, 1, 256)', linspace(0, 1, 256)', zeros(256, 1)];
      case 'cyan'
        cm = [zeros(256, 1), linspace(0, 1, 256)', linspace(0, 1, 256)'];
      case 'magenta'
        cm = [linspace(0, 1, 256)', zeros(256, 1), linspace(0, 1, 256)'];
    end

    dispcolormap = [dispcolormap; cm];
end

%% Draw images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert image intensity to color index [b * 1, b * 256]
normoff = @(x, b) 255 .* (x - min(x(:))) ./ (max(x(:)) - min(x(:))) + (b - 1) * 256 + 1;
normoffuni = @(x, b) 255 .* x ./ max(x(:)) + (b - 1) * 256 + 1;
isuni = @(x) max(x(:)) == min(x(:));

hf = makefigure();

%% Coronal
subplot(2, 2, 1);
hold on;
for i = 1:length(vw)
    [dist, ind] = min(abs(vw(i).imgY - position(2)));
    dispImage = squeeze(vw(i).img(:, ind, :))';
    if isuni(dispImage)
        dispImage = normoffuni(dispImage, i);
    else
        dispImage = normoff(dispImage, i);
    end
    hi = image(dispImage, 'XData', vw(i).imgX, 'YData', vw(i).imgZ);

    alphamap = zeros(size(dispImage));
    alphamap(~isnan(dispImage)) = vw(i).alpha;
    set(hi, 'AlphaData', alphamap);
end

axis image;
title(sprintf('y = %f', position(2)));
colormap(dispcolormap);

%% Sagital
subplot(2, 2, 2);
hold on;
for i = 1:length(vw)
    [dist, ind] = min(abs(vw(i).imgX - position(1)));
    dispImage = squeeze(vw(i).img(ind, :, :))';
    if isuni(dispImage)
        dispImage = normoffuni(dispImage, i);
    else
        dispImage = normoff(dispImage, i);
    end
    hi = image(dispImage, 'XData', vw(i).imgY, 'YData', vw(i).imgZ);

    alphamap = zeros(size(dispImage));
    alphamap(~isnan(dispImage)) = vw(i).alpha;
    set(hi, 'AlphaData', alphamap);
end

axis image;
title(sprintf('x = %f', position(1)));
colormap(dispcolormap);

%% Transverse
subplot(2, 2, 3);
hold on;
for i = 1:length(vw)
    [dist, ind] = min(abs(vw(i).imgZ - position(3)));
    dispImage = squeeze(vw(i).img(:, :, ind))';
    if isuni(dispImage)
        dispImage = normoffuni(dispImage, i);
    else
        dispImage = normoff(dispImage, i);
    end
    hi = image(dispImage, 'XData', vw(i).imgX, 'YData', vw(i).imgY);

    alphamap = zeros(size(dispImage));
    alphamap(~isnan(dispImage)) = vw(i).alpha;
    set(hi, 'AlphaData', alphamap);
end
axis image;
title(sprintf('z = %f', position(3)));
colormap(dispcolormap);

subplot(2, 2, 4);
hold on;
axis off;

for i = 1:length(volFiles)
    volFileName = 'Volume(s):';
    
    while length(volFiles{i}) > 40
        volFileName = sprintf('%s\n%s', volFileName, volFiles{i}(1:40));
        volFiles{i} = volFiles{i}(41:end);
    end
    volFileName = sprintf('%s\n%s', volFileName, volFiles{i});

    text(0, 1 - (i - 1) * 0.1, ...
         volFileName, 'Interpreter', 'none', 'FontSize', 12);
end

text(0, 0.8 - i * 0.1, 'Overlay(s):', 'FontSize', 12);
for j = 1:length(overlaysLabels)
    vpos = 0.8 - i * 0.1 - j * 0.1;

    rectangle('Position', [0, vpos - 0.02, 0.08, 0.04], 'FaceColor', overlaysColor{j}, 'EdgeColor', 'none');
    text(0.1, vpos, ...
         sprintf('%s', overlaysLabels{j}), 'Interpreter', 'none', 'FontSize', 12);
end
xlim([0, 1]);
ylim([0, 1]);
