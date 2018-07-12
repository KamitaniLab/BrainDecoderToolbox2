function builder = databuilder(entry, model)
% load_dataset    Returns standard data builder for fMRI data
%
% Inputs:
%
% - entry [char or cell]     : Data entry. Currently, (a list of) data
%                              directory is supported.
% - model [struct, optional] : Data model
%
% Outputs:
%
% - builder [struct] : Standard data builder
%


if ~exist('model', 'var')
    % Default data model (Nifti-based dataset)
    model = struct();
end

if ~isfield(model, 'epi_dir'),         model.epi_dir         = 'epi';   end
if ~isfield(model, 'epi_prefix'),      model.epi_prefix      = 'r';     end
if ~isfield(model, 'epi_file_fmt'),    model.epi_file_fmt    = '';      end
if ~isfield(model, 'event_dir'),       model.event_dir       = 'event'; end
if ~isfield(model, 'event_file_type'), model.event_file_type = 'tsv';   end
if ~isfield(model, 'event_file_fmt'),  model.event_file_fmt  = '';      end

% Obsoleted model options
if isfield(model, 'epidir'),       model.epi_dir         = model.epidir;       end
if isfield(model, 'taskdir'),      model.event_dir       = model.taskdir;      end
if isfield(model, 'taskfiletype'), model.event_file_type = model.taskfiletype; end
if isfield(model, 'epiprefix'),    model.epi_prefix      = model.epi_prefix;   end
if isfield(model, 'epifilefmt'),   model.epi_file_fmt    = model.epifilefmt;   end
if isfield(model, 'taskfilefmt'),  model.event_file_fmt  = model.taskfilefmt;  end

%% Parse data directories
if ~iscell(entry)
    entry = {entry};
end

sesnum = 1;

for i = 1:length(entry)

    if ~exist(entry{i}, 'dir')
        fprintf('%s does not exist. Skipped.\n', entry{i});
        continue;
    end

    % Get EPI and task files
    epifilesAll = getfileindir(fullfile(entry{i}, model.epi_dir), 'nii');
    taskfilesAll = getfileindir(fullfile(entry{i}, model.event_dir), model.event_file_type);

    if isempty(model.epi_file_fmt)
        epifilefmt = get_epifilefmt(epifilesAll, model.epi_prefix);
    else
        epifilefmt = model.epi_file_fmt;
    end

    taskfilefmt = model.event_file_fmt;

    epifiles = get_filelist(epifilesAll, epifilefmt);
    taskfiles = get_filelist(taskfilesAll, taskfilefmt);

    fprintf('Detected EPI files (%d files):\n', length(epifiles));
    for j = 1:length(epifiles)
        fprintf('%s\n', epifiles{j});
    end
    fprintf('Detected task event files (%d files):\n', length(taskfiles));
    for j = 1:length(taskfiles)
        fprintf('%s\n', taskfiles{j});
    end

    sesEpi  = split_sessions(epifiles);
    sesTask = split_sessions(taskfiles);

    % Get SPM realign parameter files
    spmrpfiles = get_spmrpfiles(fullfile(entry{i}, model.epi_dir));

    % List files in each session
    for s = 1:length(sesEpi)
        builder.ses(sesnum).id = sprintf('ses-%02d', sesnum);

        actualsesnum = get_actualsesnum(sesEpi{s}{1}{1});

        % Load SPM realign parameters in the session
        if length(spmrpfiles) >= actualsesnum
            mpses = textread(spmrpfiles{actualsesnum});
        else
            mpses = [];
        end

        % List files in each run
        for r = 1:length(sesEpi{s});
            builder.ses(sesnum).run(r).id = sprintf('run-%02d', r);

            for n = 1:length(sesEpi{s}{r})
                builder.ses(sesnum).run(r).epifile{n, 1} = fullfile(entry{i}, model.epi_dir, sesEpi{s}{r}{n});
            end
            for n = 1:length(sesTask{s}{r})
                builder.ses(sesnum).run(r).taskfile{n, 1} = fullfile(entry{i}, model.event_dir, sesTask{s}{r}{n});
            end

            % Add SPM realign parameters as supplement data
            if ~isempty(mpses)
                runlen = length(spm_vol(builder.ses(sesnum).run(r).epifile{1, 1}));

                mp = mpses(1:runlen, :);
                mpses(1:runlen, :) = [];

                builder.ses(sesnum).run(r).supplement(1).name = 'MotionParameter';
                builder.ses(sesnum).run(r).supplement(1).description = 'Motion (realign) parameters estimated with SPM';
                builder.ses(sesnum).run(r).supplement(1).data = mp;
            end
        end

        sesnum = sesnum + 1;
    end
end

%% Load experimental design info from BIDS event files

for i = 1:length(builder.ses)
for j = 1:length(builder.ses(i).run)
    builder.ses(i).run(j).design = [];
    if isequal(model.event_dir, 'event') && isequal(model.event_file_type, 'tsv')
        event_file = builder.ses(i).run(j).taskfile{1};
        events = load_task_events(event_file);

        tr = get_tr_epi(builder.ses(i).run(j).epifile{1});

        onset    = events(:).onset / tr;
        duration = events(:).duration / tr;

        labels_names = {};
        labels_matrix = [];

        fields = fieldnames(events);
        for k = 1:length(fields)
            if isequal(fields{k}, 'onset'), continue; end
            if isequal(fields{k}, 'duration'), continue; end

            labels_names{end + 1} = fields{k};
            labels_matrix = [labels_matrix, events(:).(fields{k})];
        end

        builder.ses(i).run(j).design = [onset, duration, labels_matrix];
        builder.ses(i).run(j).design_cols = labels_names;
    end
end
end

if ~exist('builder')
    builder = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function filelist = get_filelist(allfiles, fmt)
% Returns a list of files matching to 'fmt'

if isempty(fmt)
    filelist = allfiles;
else
    filelist = {};
    for i = 1:length(allfiles)
        if regexp(allfiles{i}, fmt)
            filelist{end+1, 1} = allfiles{i};
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ses = split_sessions(filelist)
% Split a file list to sessions
%

sesst = [];
for i = 1:length(filelist)
    tk = regexp(filelist{i}, '.*_ses-([0-9]+)_run-([0-9]+)_.*', 'tokens');

    sesnum = tk{1}{1};
    runnum = tk{1}{2};

    [sesst, sesind] = add_item_ifnot(sesst, sesnum, []);
    [sesst(sesind).value, runind] = add_item_ifnot(sesst(sesind).value, runnum, {});
    sesst(sesind).value(runind).value{end + 1, 1} = filelist{i};
end

ses = {};
for i = 1:length(sesst)
for j = 1:length(sesst(i).value)
    ses{i, 1}{j, 1} = sesst(i).value(j).value;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [s, ind] = add_item_ifnot(s, id, default_value)

if length(s) == 0
    ind = 1;
    s(ind).id = id;
    s(ind).value = default_value;
else
    newitem = true;

    for i = 1:length(s)
        if strcmp(s(i).id, id)
            ind = i;
            newitem = false;
            break;
        end
    end

    if newitem
        ind = length(s) + 1;
        s(ind).id = id;
        s(ind).value = default_value;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sesnum = get_actualsesnum(s)
% Returns actual ses num
%

tk = regexp(s, '.*_ses-([0-9]+)_.*', 'tokens');
sesnum = str2num(tk{1}{1});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function spmrpfiles = get_spmrpfiles(epidir)
% Returns SPM realign parameter files
%

spmrpfiles = {};
rpfiles = dir(fullfile(epidir, 'rp_*.txt'));
for k = 1:length(rpfiles)
    rpfilefull = fullfile(epidir, rpfiles(k).name);
    fprintf('SPM realign parameter file detected: %s\n', rpfilefull);
    spmrpfiles{k} = rpfilefull;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pat = get_epifilefmt(filelist, prefix)
% Returns a file name pattern
%

if ~exist('prefix', 'var')
    prefix = 'r';
end

rapat = ['^', prefix, 'a.+_.*_bold\.nii'];
rpat =  ['^', prefix, '[^m]+_.*_bold\.nii'];

% Analyze preprocessing type
ptype = 0;
for i = 1:length(filelist)
    if regexp(filelist{i}, rapat)
        ptype = 1;
        break;
    elseif regexp(filelist{i}, rpat)
        ptype = 2;
    end
end

switch ptype
  case 1
    pat = rapat;
  case 2
    pat = rpat;
  otherwise
    error('Unrecognizable file name pattern');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = load_task_events(file_name)
% Load a task event file
%

events = tdfread(file_name);

cols = fieldnames(events);
for i = 1:length(cols)
    if isnumeric(events(:).(cols{i}))
        continue;
    end

    a = events(:).(cols{i});
    b = [];

    for n = 1:size(a, 1)
        if strfind(a(n, :), 'n/a')
            b = [b; NaN];
        else
            b = [b; str2num(a(n, :))];
        end
    end

    events(:).(cols{i}) = b;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tr = get_tr_epi(file_name)
% Returns TR
%

[d, b, e] = fileparts(regexprep(basename(file_name), '^[aruw]+', ''));
epi_param_fname = [b, '.json'];
epi_param_fpath = fullfile(dirname(file_name), epi_param_fname);

json = fileread(epi_param_fpath);

[ind_start, ind_end] = regexp(json, '"RepetitionTime" *: *[0-9]+\.[0-9]*,');
k = strsplit(json(ind_start:ind_end), ':');

tr = str2num(k{2}) / 1000; % ms --> s
