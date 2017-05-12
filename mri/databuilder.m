function builder = databuilder(entry, model)
% load_dataset    Returns standard data builder for fMRI data
%
% Inputs:
%
% - entry [char or cell]     : Data entry. Currently, (a list of) data
%                              directory is supported.
% - model [struct, optional] : Data model (unsupported)
%
% Outputs:
%
% - builder [struct] : Standard data builder
%

if ~exist('model', 'var')
    % Default data model (Nifti-based dataset)
    model.epidir     = 'epi';
    model.taskdir    = 'task';
    model.epifilefmt = '^ra.*_ses-[0-9]+_run-[0-9]+_bold.nii';
end

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
    
    epifilesAll = getfileindir(fullfile(entry{i}, model.epidir), 'nii');
    taskfiles = getfileindir(fullfile(entry{i}, model.taskdir), 'mat');

    epifiles = {};
    for j = 1:length(epifilesAll)
        if regexp(epifilesAll{j}, model.epifilefmt)
            epifiles{end+1, 1} = epifilesAll{j};
        end
    end

    sesEpi  = split_sessions(epifiles);
    sesTask = split_sessions(taskfiles);

    for s = 1:length(sesEpi)
        builder.ses(sesnum).id = sprintf('ses-%02d', sesnum);

        for r = 1:length(sesEpi{s});
            builder.ses(sesnum).run(r).id = sprintf('run-%02d', r);

            for n = 1:length(sesEpi{s}{r})
                builder.ses(sesnum).run(r).epifile{n, 1} = fullfile(entry{i}, model.epidir, sesEpi{s}{r}{n});
            end
            for n = 1:length(sesTask{s}{r})
                builder.ses(sesnum).run(r).taskfile{n, 1} = fullfile(entry{i}, model.taskdir, sesTask{s}{r}{n});
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

function ses = split_sessions(filelist)
% Split a file list to sessions
%

ses = {};
for i = 1:length(filelist)
    tk = regexp(filelist{i}, '.*_ses-([0-9]+)_.*', 'tokens');

    sesnum = str2num(tk{1}{1});

    if length(ses) < sesnum
        ses{sesnum} = {{filelist{i}}};
    else
        ses{sesnum}{end+1} = {filelist{i}};
    end
end
