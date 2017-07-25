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
    model.epidir  = 'epi';
    model.taskdir = 'task';
end

if ~isfield(model, 'epidir'),      model.epidir      = 'epi';  end
if ~isfield(model, 'taskdir'),     model.taskdir     = 'task'; end
if ~isfield(model, 'epifilefmt'),  model.epifilefmt  = '';     end
if ~isfield(model, 'taskfilefmt'), model.taskfilefmt = '';     end

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
    epifilesAll = getfileindir(fullfile(entry{i}, model.epidir), 'nii');
    taskfilesAll = getfileindir(fullfile(entry{i}, model.taskdir), 'mat');

    if isempty(model.epifilefmt)
        epifilefmt = get_epifilefmt(epifilesAll);
    else
        epifilefmt = model.epifilefmt;
    end

    taskfilefmt = model.taskfilefmt;

    epifiles = get_filelist(epifilesAll, epifilefmt);
    taskfiles = get_filelist(taskfilesAll, taskfilefmt);

    fprintf('Detected EPI files (%d files):\n', length(epifiles));
    for j = 1:length(epifiles)
        fprintf('%s\n', epifiles{j});
    end
    fprintf('Detected task files (%d files):\n', length(taskfiles));
    for j = 1:length(taskfiles)
        fprintf('%s\n', taskfiles{j});
    end

    sesEpi  = split_sessions(epifiles);
    sesTask = split_sessions(taskfiles);

    % Get SPM realign parameter files
    spmrpfiles = get_spmrpfiles(fullfile(entry{i}, model.epidir));

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
                builder.ses(sesnum).run(r).epifile{n, 1} = fullfile(entry{i}, model.epidir, sesEpi{s}{r}{n});
            end
            for n = 1:length(sesTask{s}{r})
                builder.ses(sesnum).run(r).taskfile{n, 1} = fullfile(entry{i}, model.taskdir, sesTask{s}{r}{n});
            end

            % Add SPM realign parameters as supplement data
            if ~isempty(mpses)
                runlen = length(spm_vol(builder.ses(sesnum).run(r).epifile{1, 1}));

                mp = mpses(1:runlen, :);
                mpses(1:runlen, :) = [];

                builder.ses(sesnum).run(r).supplement(1).name = 'MotionParameter';
                builder.ses(sesnum).run(r).supplement(1).data = mp;
            end
        end

        sesnum = sesnum + 1;
    end
end

%% Add design (not implemented yet)
for i = 1:length(builder.ses)
for j = 1:length(builder.ses(i).run)
    %builder.ses(i).run(j).design = taskhandler(builder.ses(i).run(j).taskfile);
    builder.ses(i).run(j).design = [];
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

sesnumlst = [];
runnumlst = [];
filenumlst = [];
for i = 1:length(filelist)
    tk = regexp(filelist{i}, '.*_ses-([0-9]+)_run-([0-9]+)_.*', 'tokens');

    sesnumlst(i) = str2num(tk{1}{1});
    runnumlst(i) = str2num(tk{1}{2});

    if i > 1
        if sesnumlst(i) == sesnumlst(i - 1) && runnumlst(i) == runnumlst(i - 1)
            filenumlst(i) = filenumlst(i - 1) + 1;
        else
            filenumlst(i) = 1;
        end
    else
        filenumlst(i) = 1;
    end
end

ses = {};
sesnumset = unique(sesnumlst);
runnumses = [];
for i = 1:length(sesnumset)
    ses{end+1} = {};
    runnumses(end+1) = max(runnumlst(sesnumlst == sesnumset(i)));
    for j = 1:runnumses(end)
        ses{end}{end+1} = {};
    end
end

for i = 1:length(filelist)
    sind = sesnumset == sesnumlst(i);
    rind = 1:runnumses(sind) == runnumlst(i);
    find = filenumlst(i);

    ses{sind}{rind}{find} = filelist{i};
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

function pat = get_epifilefmt(filelist)
% Returns a file name pattern
%

rapat = '^ra.+_.*_bold\.nii';
rpat  = '^r[^m]+_.*_bold\.nii';

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
    fprintf('Preprocessing type: stc + realign + coreg + resliced\n');
    pat = rapat;
  case 2
    fprintf('Preprocessing type: realign + coreg + resliced\n');
    pat = rpat;
  otherwise
    error('Unrecognizable file name pattern');
end
