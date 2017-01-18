function viewdata(dataSet, metaData)
% viewdata    A simple viewer for `dataSet` and `metaData`
%
% This file is a part of BrainDecoderToolbox2.
%

%% Main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize data
d.dataSet = dataSet;
d.metaData = metaData;

clear dataSet;
clear metaData;


%% Viewer parameters
p.modeList = {'dataSet', 'metaData', 'volume'};
p.mode = p.modeList{1};
p.filterList = { 'None', d.metaData.key{:} };
p.filter = p.filterList{1};
p.filterCond = '== 1';

%p.colormapList = {'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', 'copper', 'pink', 'lines', 'colorcube', 'prism', 'flag', 'white'};
p.colormapList = {'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', 'copper', 'pink', 'lines'};
p.colormap = p.colormapList{1};

p.keyV = 'VoxelData';
p.keyX = 'voxel_x';
p.keyY = 'voxel_y';
p.keyZ = 'voxel_z';

p.volumeNum = 0;
p.volumeShow = 0;
p.sliceNum = 0;
p.sliceShow = [0];
p.maskList = { 'No mask', 'dataSet',  d.metaData.key{:} };
p.mask = p.maskList{1};
p.planeModeList = {'transverse', 'coronal', 'sagital'};
p.planeMode = p.planeModeList{1};

p = init_volumeparameters(p, d);

%% UI settings
p.ui.wndTitle = 'BrainDecoderToolbox2: viewdata';
p.ui.scrnSize = get(0, 'ScreenSize');
p.ui.wndSize = [ 1024, 768 ];

p.ui.uiArea = [ 0, 0, 0.1, 1]; % Normalized


%% Initialize GUI

bgColor = [ 0.97, 0.97, 0.97 ];
fgColor = [ 0, 0, 0 ];

% Init figure
hf = figure('Name', p.ui.wndTitle, ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'Position', [ p.ui.scrnSize(3) / 2 - p.ui.wndSize(1) / 2, ...
                          p.ui.scrnSize(4) - p.ui.wndSize(2), ...
                          p.ui.wndSize ], ...
            'DeleteFcn', @cb_delete, ...
            'Color', bgColor, ...
            'Visible', 'off');

% Init UI controls
ui{1} = uicontrol('Style', 'pushbutton', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                  'String', 'Exit', ...
                  'Position', [ 10, 10, 60, 20 ], ...
                  'Callback', {@cb_exit, hf});
ui{2} = NaN; % Obsoleted UIs ('Clear view')

% Mode selection
ui{3} = uicontrol('Style', 'text', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                  'String', 'Mode', ...
                  'Position', [ 10, 10, 100, 20 ], ...
                  'HorizontalAlignment', 'left');
ui{4} = uicontrol('Style', 'popup', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                  'String', p.modeList, ...
                  'Position', [ 10, 10, 100, 20 ], ...
                  'Callback', {@cb_set, 'Mode'});

% Filter selection
ui{5} = uicontrol('Style', 'text', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                  'String', 'Filter', ...
                  'Position', [ 10, 10, 100, 20 ], ...
                  'HorizontalAlignment', 'left');
ui{6} = uicontrol('Style', 'popup', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                  'String', p.filterList, ...
                  'Position', [ 10, 10, 100, 20 ], ...
                  'Callback', {@cb_set, 'Filter'});
ui{7} = uicontrol('Style', 'edit', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                  'String', p.filterCond, ...
                  'Position', [ 10, 10, 100, 20 ], ...
                  'Callback', {@cb_set, 'FilterCond'});

% Volume settings
ui{8} = uicontrol('Style', 'text', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                  'String', 'Plane', ...
                  'Position', [ 10, 10, 100, 20 ], ...
                  'HorizontalAlignment', 'left');
ui{9} = uicontrol('Style', 'popup', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                  'String', p.planeModeList, ...
                  'Position', [ 10, 10, 100, 20 ], ...
                  'Callback', {@cb_set, 'PlaneMode'});
ui{10} = uicontrol('Style', 'text', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                   'String', 'Volume', ...
                   'Position', [ 10, 10, 100, 20 ], ...
                   'HorizontalAlignment', 'left');
ui{11} = uicontrol('Style', 'slider', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                   'Min', 1, ...
                   'Max', p.volumeNum, ...
                   'Value', p.volumeShow, ...
                   'SliderStep', [ 1 / p.volumeNum, 1 / p.volumeNum ], ...
                   'Position', [ 10, 10, 100, 20 ], ...
                   'Callback', {@cb_set, 'ShowVolume'});
ui{12} = uicontrol('Style', 'text', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                   'String', 'Slice', ...
                   'Position', [ 10, 10, 100, 20 ], ...
                   'HorizontalAlignment', 'left');
ui{13} = uicontrol('Style', 'slider', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                   'Min', 1, ...
                   'Max', p.sliceNum, ...
                   'Value', p.sliceNum, ...
                   'SliderStep', [ 1 / p.sliceNum, 1 / p.sliceNum ], ...
                   'Position', [ 10, 10, 100, 20 ], ...
                   'Callback', {@cb_set, 'ShowSliceNum'});
ui{14} = uicontrol('Style', 'text', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                   'String', 'Slice (min)', ...
                   'Position', [ 10, 10, 100, 20 ], ...
                   'HorizontalAlignment', 'left');
ui{15} = uicontrol('Style', 'slider', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                   'Min', min(p.sliceShow), ...
                   'Max', max(p.sliceShow), ...
                   'Value', min(p.sliceShow), ...
                   'SliderStep', [ 1 / length(p.sliceShow), 1 / length(p.sliceShow) ], ...
                   'Position', [ 10, 10, 100, 20 ], ...
                   'Callback', {@cb_set, 'ShowSliceMin'});
ui{16} = uicontrol('Style', 'text', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                  'String', 'Mask', ...
                  'Position', [ 10, 10, 100, 20 ], ...
                  'HorizontalAlignment', 'left');
ui{17} = uicontrol('Style', 'popup', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                  'String', p.maskList, ...
                  'Position', [ 10, 10, 100, 20 ], ...
                  'Callback', {@cb_set, 'SelectMask'});

% Colormap selection
ui{18} = uicontrol('Style', 'text', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                   'String', 'Colormap', ...
                   'Position', [ 10, 10, 100, 20 ], ...
                   'HorizontalAlignment', 'left');
ui{19} = uicontrol('Style', 'popup', ...
                  'BackgroundColor', bgColor, ...
                  'ForegroundColor', fgColor, ...
                   'String', p.colormapList, ...
                   'Position', [ 10, 10, 100, 20 ], ...
                   'Callback', {@cb_set, 'SelectColormap'});

% Align UI controls
align([ ui{1}, ...
        ui{19}, ui{18}, ...
        ui{17}, ui{16}, ui{15}, ui{14}, ui{13}, ui{12}, ui{11}, ui{10}, ui{9}, ui{8}, ...
        ui{7}, ui{6}, ui{5}, ui{4}, ui{3}], ...
      'Center', 'Fixed', 10);

% Init axes
ax = create_axes(p);

% Init view
draw_view(d, p, ui, ax);

% Refresh UIs
ui = refreshui(ui, p);

%% Add UI data
data.p = p;
data.d = d;
data.hf = hf;
data.ui = ui;
data.ax = ax;

guidata(hf, data);


%% Show figure window
set(hf, 'visible', 'on');


%% Callback functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cb_delete(h, c)
% Callback function for 'DeleteFcn'


function cb_figresize(h, c)
% Callback function for 'SizeChangeFcn'
data = guidata(h);
figPos = get(h, 'Position');

%for n = 1:length(data.ui)
%    set(data.ui{n}, 'Units', 'pixel', ...
%                    'Position', data.p.ui.uiPos{n}(figPos(3), figPos(4)), ...
%                    'Visible', 'on');
%end


function cb_exit(h, c, hf)
% Callback for 'Exit' button
cb_delete(h, c);
close(hf);


function cb_clearview(h, c)
% Callback function for 'Clear view' button
data = guidata(h);
clear_axes(data.ax);
guidata(h, data);


function cb_set(h, c, mode)
% Callback for parameter settings
data = guidata(h);

switch mode
  case 'Mode'
    modeList = get(h, 'String');
    selNum = get(h, 'Value');
    selMode = modeList{selNum};

    % Rebuild axes and refresh UIs when mode was changed
    if ~strcmp(data.p.mode, selMode)
        data.p.mode = selMode;    
        clear_axes(data.ax);
        data.ax = create_axes(data.p);

        data.ui = refreshui(data.ui, data.p);
    end

    
  case 'Filter'
    filterList = get(h, 'String');
    selNum = get(h, 'Value');

    data.p.filter = filterList{selNum};

  case 'FilterCond'
    data.p.filterCond = get(h, 'String');

  case 'PlaneMode'
    pmList = get(h, 'String');
    selNum = get(h, 'Value');

    data.p.planeMode = pmList{selNum};

    data.p = init_volumeparameters(data.p, data.d);
    clear_axes(data.ax);
    data.ax = create_axes(data.p);

  case 'ShowVolume'
    data.p.volumeShow = round(get(h, 'Value'));

    disp(['Volume: ' num2str(data.p.volumeShow)]);
    
    data.p.volMask = data.d.dataSet(data.p.volumeShow, ...
                                    get_metadata(data.d.metaData, data.p.keyV, 'AsIndex', true));
    
  case 'ShowSliceNum'
    data.p.sliceShow = [ data.p.sliceShow(1):(data.p.sliceShow(1) + round(get(h, 'Value')) - 1) ];
    if data.p.sliceShow(1) + round(get(h, 'Value')) > data.p.sliceNum;
        data.p.sliceShow = [ data.p.sliceShow(1):data.p.sliceNum ];
    end

    clear_axes(data.ax);
    data.ax = create_axes(data.p);

  case 'ShowSliceMin'
    data.p.sliceShow = [ round(get(h, 'Value')):(round(get(h, 'Value')) + length(data.p.sliceShow) - 1) ];

    clear_axes(data.ax);
    data.ax = create_axes(data.p);

  case 'SelectMask'
    maskList = get(h, 'String');
    selNum = get(h, 'Value');

    data.p.mask = maskList{selNum};

    if strcmp(data.p.mask, 'No mask')
        % No mask
        data.p.volMask = zeros(1, size(p.volXyz, 2));
        p.bgValue = -Inf;
    elseif strcmp(data.p.mask, 'dataSet')
        % dataSet
        data.p.volMask = data.d.dataSet(data.p.volumeShow, ...
                                        get_metadata(data.d.metaData, data.p.keyV, 'AsIndex', true));
        p.bgValue = -Inf;
    else
        % Update mask
        data.p.volMask = get_metadata(data.d.metaData, data.p.mask, 'RemoveNan', true);
        p.bgValue = -1;
        % 'bgValue = -1' works fine for masks which contain values of [0, 1].
        % Different bgValue should be used for different masks.
        % It may be helpful to add bgValue setting UI.
    end

    data.p.volImg = get_3dimage(data.p.volXyz, data.p.volMask, p.bgValue);

  case 'SelectColormap'
    maskList = get(h, 'String');
    selNum = get(h, 'Value');

    data.p.colormap = maskList{selNum};

end

draw_view(data.d, data.p, data.ui, data.ax);

guidata(h, data);


%% Subfunctions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ax = create_axes(p)
% Create axes

viewArea = [ p.ui.uiArea(3), 0, 1 - p.ui.uiArea(3), 1 ];

if strcmp(p.mode, 'volume')
    numImage = length(p.sliceShow);

    nRow = floor(sqrt(numImage));
    nCol = ceil(sqrt(numImage));
else
    nRow = 1;
    nCol = 1;
end

hSize = viewArea(3) / nCol;
vSize = viewArea(4) / nRow;

switch p.planeMode
  case 'transverse'
    aspectRatio = [ p.volSize(1), p.volSize(2) ];
  case 'coronal'
    aspectRatio = [ p.volSize(3), p.volSize(1) ];
  case 'sagital'
    aspectRatio = [ p.volSize(3), p.volSize(2) ];
end

topBound  = 1 - p.ui.uiArea(3);
leftBound = 1 - p.ui.uiArea(4);

for ir = 1:nRow
for ic = 1:nCol
    n = (ir - 1) * nCol + ic;

    if n > length(p.sliceShow)
        break;
    end

    ax{n} = axes('Units', 'Normalize', ...
                 'OuterPosition', [ viewArea(1) + (ic - 1) * hSize, ...
                                    viewArea(4) - ir * vSize, ...
                                    hSize, ...
                                    vSize ]);
    set(ax{n}, 'DataAspectRatio', [ aspectRatio, 1 ]);
end
end


function clear_axes(ax)
% Clear axes

for n = 1:length(ax)
    %cla(ax{n})
    delete(ax{n});
end


function draw_view(d, p, ui, ax)
% Draw view

cmin = min(p.volImg(:));
cmax = max(p.volImg(:));

if cmax <= cmin
    cmax = cmin + 1;
end

switch p.mode
  case 'dataSet'
    % Draw dataSet in ax{1}

    if strcmp(p.filter, 'None')
        v = d.dataSet;
    else
        filterValue = get_metadata(d.metaData, p.filter);
        vInd = eval([ 'filterValue',  p.filterCond]);
        v = d.dataSet(:, vInd);
    end

    axes(ax{1});
    imagesc(v);
    axis off;
    colormap(ax{1}, p.colormap);

    colorbar('SouthOutside');

  case 'metaData'
    % Draw metaData in ax{1}
    if strcmp(p.filter, 'None')
        v = d.metaData.value;
    else
        filterValue = get_metadata(d.metaData, p.filter);
        vInd = eval([ 'filterValue',  p.filterCond]);
        v = d.metaData.value(:, vInd);
    end

    axes(ax{1});
    imagesc(v);
    axis off;
    colormap(ax{1}, p.colormap);
    
    colorbar('SouthOutside');

  case 'volume'
    % Volume view
    for n = 1:length(ax)
        if n > length(p.sliceShow)
            break;
        end

        sliceInd = p.sliceShow(n);

        switch p.planeMode
          case 'transverse'
            img = squeeze(p.volImg(:, :, sliceInd));
          case 'coronal'
            img = squeeze(p.volImg(:, sliceInd, :));
          case 'sagital'
            img = squeeze(p.volImg(sliceInd, :, :));
        end

        axes(ax{n});
        imagesc(img);
        axis off;
        set(ax{n}, 'Visible', 'off', 'CLim', [ cmin, cmax ]);
        colormap(ax{n}, p.colormap);

    end

  otherwise
end


function p = init_volumeparameters(p, d);
% Init volume parameters

p.volXyz = [ get_metadata(d.metaData, p.keyX, 'RemoveNan', true);
             get_metadata(d.metaData, p.keyY, 'RemoveNan', true);
             get_metadata(d.metaData, p.keyZ, 'RemoveNan', true) ];

if ~isfield(p, 'volMask')
    p.volMask = zeros(1, size(p.volXyz, 2));
end

if ~isfield(p, 'bgValue')
    p.bgValue = -Inf;
end

p.volImg = get_3dimage(p.volXyz, p.volMask, p.bgValue);
p.volSize = size(p.volImg);

switch p.planeMode
  case 'transverse'
    p.sliceNum = p.volSize(3);
  case 'coronal'
    p.sliceNum = p.volSize(2);
  case 'sagital'
    p.sliceNum = p.volSize(1);
end

p.sliceShow = [ 1:p.sliceNum ];

p.volumeNum = size(d.dataSet, 1);
p.volumeShow = 1;


function ui = refreshui(ui, p)
% Refresh UIs

switch p.mode
  case 'dataSet'
    set(ui{5}, 'Enable', 'on');
    set(ui{6}, 'Enable', 'on');
    set(ui{7}, 'Enable', 'on');

    set(ui{8}, 'Enable', 'off');
    set(ui{9}, 'Enable', 'off');
    set(ui{10}, 'Enable', 'off');
    set(ui{11}, 'Enable', 'off');
    set(ui{12}, 'Enable', 'off');
    set(ui{13}, 'Enable', 'off');
    set(ui{14}, 'Enable', 'off');
    set(ui{15}, 'Enable', 'off');
    set(ui{16}, 'Enable', 'off');
    set(ui{17}, 'Enable', 'off');
    
  case 'metaData'
    set(ui{5}, 'Enable', 'on');
    set(ui{6}, 'Enable', 'on');
    set(ui{7}, 'Enable', 'on');
    
    set(ui{8}, 'Enable', 'off');
    set(ui{9}, 'Enable', 'off');
    set(ui{10}, 'Enable', 'off');
    set(ui{11}, 'Enable', 'off');
    set(ui{12}, 'Enable', 'off');
    set(ui{13}, 'Enable', 'off');
    set(ui{14}, 'Enable', 'off');
    set(ui{15}, 'Enable', 'off');
    set(ui{16}, 'Enable', 'off');
    set(ui{17}, 'Enable', 'off');
    
  case 'volume'
    set(ui{5}, 'Enable', 'off');
    set(ui{6}, 'Enable', 'off');
    set(ui{7}, 'Enable', 'off');

    set(ui{8}, 'Enable', 'on');
    set(ui{9}, 'Enable', 'on');
    set(ui{10}, 'Enable', 'on');
    set(ui{11}, 'Enable', 'on');
    set(ui{12}, 'Enable', 'on');
    set(ui{13}, 'Enable', 'on');
    set(ui{14}, 'Enable', 'on');
    set(ui{15}, 'Enable', 'on');
    set(ui{16}, 'Enable', 'on');
    set(ui{17}, 'Enable', 'on');
    
end
