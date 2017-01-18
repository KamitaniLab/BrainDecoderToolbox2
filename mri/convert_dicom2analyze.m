function convert_dicom2analyze(home_dir, t2_dir, run_dir_list, slice_num, base_filename, start_id, out_home)
% convert_dicom2analyze    Converts DICOM files to Analyze files
%
% This file is a part of BrainDecoderToolbox2
%
% Inputs:
%
% - home_dir      : DICOM directory
% - t2_dir        : The directory name which contains T2structure DICOM files. If empty, doesn't make T2structure.
% - run_dir_list  : List of directories which contains EPI DICOM files. If empty, doesn't make EPIs.
% - slice_num     : Slice num of EPIs. If empty, use N^2 calculated from DICOM header.
% - base_filename : Base- base file name part (default: 'home_dir').
% - start_id      : The first postfix alphabet letter indicating run ID (default: 'a').
% - out_home      : 1 -> output all files to 'Home Directory' [default], 0 -> output files to each 'n' directory
%
% Created  By: Satoshi MURATA (1),   satoshi-m@atr.jp  08/03/07
% Modified By: Yoichi Miyawaki (1),  yoichi_matr.jp    09/03/05
% Arranged By: Satoshi MURATA (1),   satoshi-m@atr.jp  09/03/09  
% Modified By: Shuntaro C. Aoki (1), aoki@atr.jp       16/10/12
%
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check args:
if exist('home_dir','var')==0 || isempty(home_dir)
    dirname = uigetdir(pwd, 'Select ''Home Directory''');
    if dirname==0,  return;     end
    home_dir = dirname;
end

if exist('t2_dir','var')==0 || isempty(t2_dir)
    t2_dir = [];
else
    if isnumeric(t2_dir)
        t2_dir = int2str(t2_dir);
    end
    t2_dir = fullfile(home_dir, t2_dir);
    if exist(t2_dir,'dir')==0
        dname = uigetdir(home_dir, 'Select directory for T2structure');
        if dname==0
            t2_dir = [];
        else
            t2_dir = dname;
        end
    end
end

if exist('run_dir_list','var')==0 || isempty(run_dir_list)
    run_dir_list = [];
else
    if ~iscell(run_dir_list)
        error('run_dir_list should be a list (cell array) of directory namese');
    end
    num_run = length(run_dir_list);
end

if exist('slice_num','var')==0 || isempty(slice_num)
    slice_num = 0;
end

if exist('base_filename','var')==0 || isempty(base_filename)
    home_dir2 = home_dir;
    if home_dir2(end)=='\' || home_dir2(end)=='/'
        home_dir2(end)=[];
    end
    [dummy base_filename] = fileparts(home_dir2);
    clear dummy home_dir2;
end

if exist('start_id','var')==0 || isempty(start_id)
    start_id = 'a';
end

if exist('out_home','var')==0 || isempty(out_home)
    out_home = 1;
end


%% Addpath SPM5
str = which('spm_defaults');
if isempty(str)
    dirname = uigetdir(pwd, 'Select ''SPM5''');
    if dirname==0
        return;
    end
    addpath(dirname);
end

spm_defaults;


%% Make T2structure
if isempty(t2_dir)~=1
    fprintf('Make T2structure\n');
    
    % get filenames
    fnames = dir(fullfile(t2_dir, '*.dcm'));
    slnum  = length(fnames);
    
    % read DICOM headers
    fnames   = makeFilenames(t2_dir, fnames);
    hdr_dcms = spm_dicom_headers_sm(fnames);
    
    % convert headers DICOM to Analyze(NIFTI)
    hdr_t2 = convert_hdr_dcm2nifti_t2(hdr_dcms{1}, slnum);
    
    % sort DICOM files
    inumber = zeros(slnum,1);
    for itf=1:slnum
        inumber(itf) = hdr_dcms{itf}.InstanceNumber;
    end
    [inumber, index] = sort(inumber, 'descend');
    
    % read DICOM data
    dcmData = zeros(hdr_t2.dime.dim(2), hdr_t2.dime.dim(3), slnum);
    for itf=1:slnum
        fp = fopen(hdr_dcms{index(itf)}.Filename);
        if fseek(fp, hdr_dcms{index(itf)}.StartOfPixelData, 'bof')==-1
            error('DICOM file #%d cannot fseek!', itf);
        end
        data = fread(fp, inf, 'int16');
        dcmData(:,:,slnum-itf+1) = reshape(data, [hdr_t2.dime.dim(2), hdr_t2.dime.dim(3)]);
        fclose(fp);
    end

    % convert DICOM to Analyze:
    analyze = zeros(hdr_t2.dime.dim(2), hdr_t2.dime.dim(3), slice_num);
    for itf=1:slnum
        plane = dcmData(:,:,itf);
        
        if isfield(hdr_dcms{itf},'RescaleSlope')
            plane = plane*hdr_dcms{itf}{1}.RescaleSlope;
        end
        if isfield(hdr_dcms{itf},'RescaleIntercept')
            plane = plane+hdr_dcms{itf}.RescaleIntercept;
        end
        plane = fliplr(plane);
        
        analyze(:,:,itf) = plane;
    end

    % output the Analze(3D) file:
    if out_home,
        pth = home_dir;
    else
        pth = t2_dir;
    end

    % hdr file
    write_nifti_hdr(hdr_t2, fullfile(pth, 'T2structure.hdr'))

    % img file
    fp = fopen(fullfile(pth, 'T2structure.img'), 'w');
    if fp==-1
        error('Cannot open T2 img file.');
    end
    fwrite(fp, analyze, 'int16');
    fclose(fp);
end


%% Make EPIs
if isempty(run_dir_list)~=1
    fprintf('Make EPIs\n');

    offset_runname = int16(start_id) - 97;
    
    for itr=1:num_run
        % get filenames
        dirname  = fullfile(home_dir, run_dir_list{itr});
        files    = dir(fullfile(dirname, '*.dcm'));
        num_file = length(files);

        % read DICOM headers
        fnames = makeFilenames(dirname, files);
        hdr_dcms = spm_dicom_headers_sm(fnames);

        % sort DICOM files
        inumber = zeros(num_file,1);
        for itf=1:num_file
            inumber(itf) = hdr_dcms{itf}.InstanceNumber;
        end
        [inumber, index] = sort(inumber);
        
        
        for itf=1:num_file
            % convert headers DICOM to Analyze(NIFTI)
            hdr = convert_hdr_dcm2nifti_epi(hdr_dcms{index(itf)}, slice_num);
            
            % read DICOM data
            fp = fopen(hdr_dcms{index(itf)}.Filename);
            if fseek(fp, hdr_dcms{index(itf)}.StartOfPixelData, 'bof')==-1
                error('DICOM file #%d cannot fseek!', itf);
            end
            dcmData = fread(fp, inf, 'int16');
            fclose(fp);
            
            % convert DICOM to Analyze
            analyze2d = convert_mosaic(dcmData, hdr.dime.dim(2:4));
            analyze3d = convertImage2Dto3D(analyze2d, hdr.dime.dim(2:4));
            
            % output Analyze file
            if out_home
                pth = home_dir;
            else
                pth = dirname;
            end
            filename = sprintf('%s%s%04d', base_filename, makeRunName(itr + offset_runname), itf);
            % hdr file
            write_nifti_hdr(hdr, fullfile(pth, [filename '.hdr']));
            
            % img file
            fp = fopen(fullfile(pth, [filename '.img']), 'w');
            if fp==-1
                error('Cannot open EPI img file.');
            end
            fwrite(fp, analyze3d, 'int16');
            fclose(fp);
            
            fprintf('.');
        end
        fprintf('\n');
    end
end


%% ---------------------------------------------------------------

function analyze3d = convertImage2Dto3D(analyze2d, dimensions)
% convert the image data(2D) to Analyze(3D)

height    = dimensions(1);
width     = dimensions(2);
number    = dimensions(3);
analyze2d = analyze2d(:);

analyze3d = reshape(analyze2d, [height,width,number]);


%% ---------------------------------------------------------------

function pre_analyze = convert_mosaic(dcmData, dimensions)
% This function converts mosaic to analyze2d

imgNum      = ceil(sqrt(dimensions(3)));
dcmData     = reshape(dcmData, dimensions(1:2)*imgNum);
volume      = zeros(dimensions);
pre_analyze = zeros(dimensions);

for i=1:dimensions(3),
    img = dcmData((1:dimensions(1))+dimensions(1)*rem(i-1,imgNum), (dimensions(2):-1:1)+dimensions(2)*floor((i-1)/(imgNum)));
    if ~any(img(:)),
        volume = volume(:,:,1:(i-1));
        break;
    end
    volume(:,:,i) = img;
end

for i=1:size(volume,3)
    pre_analyze(:,:,i) = volume(:,:,i);
end


%% ---------------------------------------------------------------

function fnames = makeFilenames(dname, files)
% This function make filenames without using 'for-loop'

% Set delimiter
if ispc,    delimiter = '\';
else        delimiter = '/';
end

if strcmp(dname(end), delimiter)==0
    dname = [dname delimiter];
end

dname = repmat(dname, [length(files), 1]);
fname = char(files.name);

fnames = [dname fname];


%% ---------------------------------------------------------------

function run_name = makeRunName(run_num)
% This function convert run_number to run_name (postfix alphabet letter)
% if run_num > 798 ('zz'), return error

if run_num > 798
    error('run_num is too big to convert run_name');
end

run_name = char(mod(run_num - 1,26)+97);

temp = fix(double(run_num - 1) / 26);
if temp
    run_name = [char(temp+96) run_name];
end


%% ---------------------------------------------------------------

function hdr = spm_dicom_headers_sm(P)
%S spm_dicom_headers version modified (optimized) to perform fast (real-time)
%S realignment, primarily by:
%S  1. eliminating: the user interface (GUI), plotting, logging, etc..
%S
%S Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  07/09/04
%S (1) ATR Intl. Computational Neuroscience Labs, Decoding Group
%
%
% Read header information from DICOM files
% FORMAT hdr = spm_dicom_headers(P)
% P   - array of filenames
% hdr - cell array of headers, one element for each file.
%
% Contents of headers are approximately explained in:
% http://medical.nema.org/dicom/2001.html
%
% This code will not work for all cases of DICOM data, as DICOM is an
% extremely complicated "standard".
%
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% John Ashburner
% $Id: spm_dicom_headers.m 810 2007-05-07 14:38:54Z john $


dict = readdict;
j    = 0;
hdr  = {};
%S if size(P,1)>1, spm_progress_bar('Init',size(P,1),'Reading DICOM headers','Files complete'); end;
for i=1:size(P,1),
    tmp = readdicomfile(P(i,:),dict);
    if ~isempty(tmp),
        j      = j + 1;
        hdr{j} = tmp;
    end;
%S    if size(P,1)>1, spm_progress_bar('Set',i); end;
end;
%S if size(P,1)>1, spm_progress_bar('Clear'); end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function ret = readdicomfile(P,dict)
ret = [];
P   = deblank(P);
fp  = fopen(P,'r','ieee-le');
if fp==-1, warning(['Cant open "' P '".']); return; end;

fseek(fp,128,'bof');
dcm = char(fread(fp,4,'uint8')');
if ~strcmp(dcm,'DICM'),
    % Try truncated DICOM file fomat
    fseek(fp,0,'bof');
    tag.group   = fread(fp,1,'ushort');
    tag.element = fread(fp,1,'ushort');
    if isempty(tag.group) || isempty(tag.element),
        warning('Truncated file "%s"',P);
        return;
    end;
    %t          = dict.tags(tag.group+1,tag.element+1);
    if isempty(find(dict.group==tag.group & dict.element==tag.element,1)) && ~(tag.group==8 && tag.element==0),
        % entry not found in DICOM dict and not from a GE Twin+excite
        % that starts with with an 8/0 tag that I can't find any
        % documentation for.
        fclose(fp);
        warning(['"' P '" is not a DICOM file.']);
        return;
    else
        fseek(fp,0,'bof');
    end;
end;
ret = read_dicom(fp, 'il',dict);
ret.Filename = fopen(fp);
fclose(fp);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [ret,len] = read_dicom(fp, flg, dict,lim)
if nargin<4, lim=Inf; end;
%if lim==2^32-1, lim=Inf; end;
len = 0;
ret = [];
tag = read_tag(fp,flg,dict);
while ~isempty(tag) && ~(tag.group==65534 && tag.element==57357), % && tag.length==0),
    %fprintf('%.4x/%.4x %d\n', tag.group, tag.element, tag.length);
    if tag.length>0,
        switch tag.name,
            case {'GroupLength'},
                % Ignore it
                fseek(fp,tag.length,'cof');
            case {'PixelData'},
                ret.StartOfPixelData = ftell(fp);
                ret.SizeOfPixelData  = tag.length;
                ret.VROfPixelData    = tag.vr;
                fseek(fp,tag.length,'cof');
            case {'CSAData'}, % raw data
                ret.StartOfCSAData = ftell(fp);
                ret.SizeOfCSAData = tag.length;
                fseek(fp,tag.length,'cof');
            case {'CSAImageHeaderInfo', 'CSASeriesHeaderInfo','Private_0029_1210','Private_0029_1220'},
                dat  = decode_csa(fp,tag.length);
                ret.(tag.name) = dat;
            case {'TransferSyntaxUID'},
                dat = char(fread(fp,tag.length,'uint8')');
                dat = deblank(dat);
                ret.(tag.name) = dat;
                switch dat,
                    case {'1.2.840.10008.1.2'},      % Implicit VR Little Endian
                        flg = 'il';
                    case {'1.2.840.10008.1.2.1'},    % Explicit VR Little Endian
                        flg = 'el';
                    case {'1.2.840.10008.1.2.1.99'}, % Deflated Explicit VR Little Endian
                        warning(['Cant read Deflated Explicit VR Little Endian file "' fopen(fp) '".']);
                        flg = 'dl';
                        return;
                    case {'1.2.840.10008.1.2.2'},    % Explicit VR Big Endian
                        %warning(['Cant read Explicit VR Big Endian file "' fopen(fp) '".']);
                        flg = 'eb'; % Unused
                    otherwise,
                        warning(['Unknown Transfer Syntax UID for "' fopen(fp) '".']);
                        return;
                end;
            otherwise,
                switch tag.vr,
                    case {'UN'},
                        % Unknown - read as char
                        dat = fread(fp,tag.length,'uint8')';
                    case {'AE', 'AS', 'CS', 'DA', 'DS', 'DT', 'IS', 'LO', 'LT',...
                            'PN', 'SH', 'ST', 'TM', 'UI', 'UT'},
                        % Character strings
                        dat = char(fread(fp,tag.length,'uint8')');

                        switch tag.vr,
                            case {'UI','ST'},
                                dat = deblank(dat);
                            case {'DS'},
                                try
                                    dat = strread(dat,'%f','delimiter','\\')';
                                catch
                                    dat = strread(dat,'%f','delimiter','/')';
                                end
                            case {'IS'},
                                dat = strread(dat,'%d','delimiter','\\')';
                            case {'DA'},
                                dat     = strrep(dat,'.',' ');
                                [y,m,d] = strread(dat,'%4d%2d%2d');
                                dat     = datenum(y,m,d);
                            case {'TM'},
                                if any(dat==':'),
                                    [h,m,s] = strread(dat,'%d:%d:%f');
                                else
                                    [h,m,s] = strread(dat,'%2d%2d%f');
                                end;
                                if isempty(h), h = 0; end;
                                if isempty(m), m = 0; end;
                                if isempty(s), s = 0; end;
                                dat = s+60*(m+60*h);
                            case {'LO'},
                                dat = uscore_subst(dat);
                            otherwise,
                        end;
                    case {'OB'},
                        % dont know if this should be signed or unsigned
                        dat = fread(fp,tag.length,'uint8')';
                    case {'US', 'AT', 'OW'},
                        dat = fread(fp,tag.length/2,'uint16')';
                    case {'SS'},
                        dat = fread(fp,tag.length/2,'int16')';
                    case {'UL'},
                        dat = fread(fp,tag.length/4,'uint32')';
                    case {'SL'},
                        dat = fread(fp,tag.length/4,'int32')';
                    case {'FL'},
                        dat = fread(fp,tag.length/4,'float')';
                    case {'FD'},
                        dat = fread(fp,tag.length/8,'double')';
                    case {'SQ'},
                        [dat,len1] = read_sq(fp, flg,dict,tag.length);
                        tag.length = len1;
                    otherwise,
                        dat = '';
                        fseek(fp,tag.length,'cof');
                        warning(['Unknown VR [' num2str(tag.vr+0) '] in "'...
                            fopen(fp) '" (offset=' num2str(ftell(fp)) ').']);
                end;
                if ~isempty(tag.name),
                    ret.(tag.name) = dat;
                end;
        end;
    end;
    len = len + tag.le + tag.length;
    if len>=lim, return; end;
    tag = read_tag(fp,flg,dict);
end;
if ~isempty(tag),
    len = len + tag.le;

    % I can't find this bit in the DICOM standard, but it seems to
    % be needed for Philips Integra
    if tag.group==65534 && tag.element==57357 && tag.length~=0,
        fseek(fp,-4,'cof');
        len = len-4;
    end;
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [ret,len] = read_sq(fp, flg, dict,lim)
ret = {};
n   = 0;
len = 0;
while len<lim,
    tag.group   = fread(fp,1,'ushort');
    tag.element = fread(fp,1,'ushort');
    tag.length  = fread(fp,1,'uint');
    if isempty(tag.length), return; end;

    %if tag.length == 2^32-1, % FFFFFFFF
    %tag.length = Inf;
    %end;
    if tag.length==13, tag.length=10; end;

    len         = len + 8;
    if (tag.group == 65534) && (tag.element == 57344), % FFFE/E000
        [Item,len1] = read_dicom(fp, flg, dict, tag.length);
        len    = len + len1;
        n      = n + 1;
        ret{n} = Item;
    elseif (tag.group == 65279) && (tag.element == 224), % FEFF/00E0
        % Byte-swapped
        [fname,perm,fmt] = fopen(fp);
        flg1 = flg;
        if flg(2)=='b',
            flg1(2) = 'l';
        else
            flg1(2) = 'b';
        end;
        [Item,len1] = read_dicom(fp, flg1, dict, tag.length);
        len    = len + len1;
        n      = n + 1;
        ret{n} = Item;
        pos    = ftell(fp);
        fclose(fp);
        fp     = fopen(fname,perm,fmt);
        fseek(fp,pos,'bof');
    elseif (tag.group == 65534) && (tag.element == 57565), % FFFE/E0DD
        break;
    elseif (tag.group == 65279) && (tag.element == 56800), % FEFF/DDE0
        % Byte-swapped
        break;
    else
        warning([num2str(tag.group) '/' num2str(tag.element) ' unexpected.']);
    end;
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function tag = read_tag(fp,flg,dict)
tag.group   = fread(fp,1,'ushort');
tag.element = fread(fp,1,'ushort');
if isempty(tag.element), tag=[]; return; end;
if tag.group == 2, flg = 'el'; end;
%t          = dict.tags(tag.group+1,tag.element+1);
t           = find(dict.group==tag.group & dict.element==tag.element);
if t>0,
    tag.name = dict.values(t).name;
    tag.vr   = dict.values(t).vr{1};
else
    % Set tag.name = '' in order to restrict the fields to those
    % in the dictionary.  With a reduced dictionary, this could
    % speed things up considerably.
    % tag.name = '';
    tag.name = sprintf('Private_%.4x_%.4x',tag.group,tag.element);
    tag.vr   = 'UN';
end;

if flg(2) == 'b',
    [fname,perm,fmt] = fopen(fp);
    if strcmp(fmt,'ieee-le'),
        pos = ftell(fp);
        fclose(fp);
        fp  = fopen(fname,perm,'ieee-be');
        fseek(fp,pos,'bof');
    end;
end;

if flg(1) =='e',
    tag.vr      = char(fread(fp,2,'uint8')');
    tag.le      = 6;
    switch tag.vr,
        case {'OB','OW','SQ','UN','UT'}
            if ~strcmp(tag.vr,'UN') || tag.group~=65534,
                fseek(fp,2,0);
            end;
            tag.length = double(fread(fp,1,'uint'));
            tag.le     = tag.le + 6;
        case {'AE','AS','AT','CS','DA','DS','DT','FD','FL','IS','LO','LT','PN','SH','SL','SS','ST','TM','UI','UL','US'},
            tag.length = double(fread(fp,1,'ushort'));
            tag.le     = tag.le + 2;
        case char([0 0])
            if (tag.group == 65534) && (tag.element == 57357)
                % at least on GE, ItemDeliminationItem does not have a
                % VR, but 4 bytes zeroes as length
                tag.le    = 8;
                tag.length = 0;
                tmp = fread(fp,1,'ushort');
            else
                warning('Don''t know how to handle VR of ''\0\0''');
            end;
        otherwise,
            fseek(fp,2,0);
            tag.length = double(fread(fp,1,'uint'));
            tag.le     = tag.le + 6;
    end;
else
    tag.le =  8;
    tag.length = double(fread(fp,1,'uint'));
end;
if isempty(tag.vr) || isempty(tag.length),
    tag = [];
    return;
end;


if rem(tag.length,2),
    if tag.length==4294967295,
        tag.length = Inf;
        return;
    elseif tag.length==13,
        % disp(['Whichever manufacturer created "' fopen(fp) '" is taking the p***!']);
        % For some bizarre reason, known only to themselves, they confuse lengths of
        % 13 with lengths of 10.
        tag.length = 10;
    else
        warning(['Unknown odd numbered Value Length (' sprintf('%x',tag.length) ') in "' fopen(fp) '".']);
        tag = [];
    end;
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function dict = readdict(P)
if nargin<1, P = 'spm_dicom_dict.mat'; end;
try
    dict = load(P);
catch
    fprintf('\nUnable to load the file "%s".\n', P);
    if strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64'),
        fprintf('This may  be because of the way that the .tar.gz files\n');
        fprintf('were unpacked  when  the SPM software  was  installed.\n');
        fprintf('If installing on a Windows platform, then the software\n');
        fprintf('used  for  unpacking may  try to  be clever and insert\n');
        fprintf('additional  unwanted control  characters.   If you use\n');
        fprintf('WinZip,  then you  should  ensure  that TAR file smart\n');
        fprintf('CR/LF conversion is disabled  (under the Miscellaneous\n');
        fprintf('Configuration Options).\n\n');
    end;
    rethrow(lasterr);
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function dict = readdict_txt
file = textread('spm_dicom_dict.txt','%s','delimiter','\n','whitespace','');
clear values
i = 0;
for i0=1:length(file),
    words = strread(file{i0},'%s','delimiter','\t');
    if length(words)>=5 && ~strcmp(words{1}(3:4),'xx'),
        grp = sscanf(words{1},'%x');
        ele = sscanf(words{2},'%x');
        if ~isempty(grp) && ~isempty(ele),
            i          = i + 1;
            group(i)   = grp;
            element(i) = ele;
            vr         = {};
            for j=1:length(words{4})/2,
                vr{j}  = words{4}(2*(j-1)+1:2*(j-1)+2);
            end;
            name       = words{3};
            msk        = ~(name>='a' & name<='z') & ~(name>='A' & name<='Z') &...
                ~(name>='0' & name<='9') & ~(name=='_');
            name(msk)  = '';
            values(i)  = struct('name',name,'vr',{vr},'vm',words{5});
        end;
    end;
end;

tags = sparse(group+1,element+1,1:length(group));
dict = struct('values',values,'tags',tags);
dict = desparsify(dict);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function dict = desparsify(dict)
[group,element] = find(dict.tags);
offs            = zeros(size(group));
for k=1:length(group),
    offs(k) = dict.tags(group(k),element(k));
end;
dict.group(offs)   = group-1;
dict.element(offs) = element-1;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function t = decode_csa(fp,lim)
% Decode shadow information (0029,1010) and (0029,1020)
[fname,perm,fmt] = fopen(fp);
pos = ftell(fp);
if strcmp(fmt,'ieee-be'),
    fclose(fp);
    fp  = fopen(fname,perm,'ieee-le');
    fseek(fp,pos,'bof');
end;

c   = fread(fp,4,'uint8');
fseek(fp,pos,'bof');

if all(c'==[83 86 49 48]), % "SV10"
    t = decode_csa2(fp,lim);
else
    t = decode_csa1(fp,lim);
end;

if strcmp(fmt,'ieee-be'),
    fclose(fp);
    fp  = fopen(fname,perm,fmt);
end;
fseek(fp,pos+lim,'bof');
return;
%_______________________________________________________________________

%_______________________________________________________________________
function t = decode_csa1(fp,lim)
n   = fread(fp,1,'uint32');
if n>128 || n < 0,
    fseek(fp,lim-4,'cof');
    t = struct('name','JUNK: Don''t know how to read this damned file format');
    return;
end;
unused = fread(fp,1,'uint32')'; % Unused "M" or 77 for some reason
tot = 2*4;
for i=1:n,
    t(i).name    = fread(fp,64,'uint8')';
    msk          = find(~t(i).name)-1;
    if ~isempty(msk),
        t(i).name    = char(t(i).name(1:msk(1)));
    else
        t(i).name    = char(t(i).name);
    end;
    t(i).vm      = fread(fp,1,'int32')';
    t(i).vr      = fread(fp,4,'uint8')';
    t(i).vr      = char(t(i).vr(1:3));
    t(i).syngodt = fread(fp,1,'int32')';
    t(i).nitems  = fread(fp,1,'int32')';
    t(i).xx      = fread(fp,1,'int32')'; % 77 or 205
    tot          = tot + 64+4+4+4+4+4;
    for j=1:t(i).nitems
        % This bit is just wierd
        t(i).item(j).xx  = fread(fp,4,'int32')'; % [x x 77 x]
        len              = t(i).item(j).xx(1)-t(1).nitems;
        if len<0 || len+tot+4*4>lim,
            t(i).item(j).val = '';
            tot              = tot + 4*4;
            break;
        end;
        t(i).item(j).val = char(fread(fp,len,'uint8')');
        fread(fp,4-rem(len,4),'uint8');
        tot              = tot + 4*4+len+(4-rem(len,4));
    end;
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function t = decode_csa2(fp,lim)
unused = fread(fp,4,'uint8'); % Unused
unused = fread(fp,4,'uint8'); % Unused
n   = fread(fp,1,'uint32');
if n>128 || n < 0,
    fseek(fp,lim-4,'cof');
    t = struct('junk','Don''t know how to read this damned file format');
    return;
end;
unused = fread(fp,1,'uint32')'; % Unused "M" or 77 for some reason
for i=1:n,
    t(i).name    = fread(fp,64,'uint8')';
    msk          = find(~t(i).name)-1;
    if ~isempty(msk),
        t(i).name    = char(t(i).name(1:msk(1)));
    else
        t(i).name    = char(t(i).name);
    end;
    t(i).vm      = fread(fp,1,'int32')';
    t(i).vr      = fread(fp,4,'uint8')';
    t(i).vr      = char(t(i).vr(1:3));
    t(i).syngodt = fread(fp,1,'int32')';
    t(i).nitems  = fread(fp,1,'int32')';
    t(i).xx      = fread(fp,1,'int32')'; % 77 or 205
    for j=1:t(i).nitems
        t(i).item(j).xx  = fread(fp,4,'int32')'; % [x x 77 x]
        len              = t(i).item(j).xx(2);
        t(i).item(j).val = char(fread(fp,len,'uint8')');
        fread(fp,rem(4-rem(len,4),4),'uint8');
    end;
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function str_out = uscore_subst(str_in)
str_out = str_in;
pos = findstr(str_in,'+AF8-');
if ~isempty(pos),
    str_out(pos) = '_';
    str_out(repmat(pos,4,1)+repmat((1:4)',1,numel(pos))) = [];
end
return;
%_______________________________________________________________________


function hdr = convert_hdr_dcm2nifti_epi(hdr_dicm, slice_num)
% convert the DICOM header to Analyze(nifti) header

hdr.hk.sizeof_hdr    = 348;
hdr.hk.data_type     = char(zeros(1,10));
hdr.hk.db_name       = char(zeros(1,18));
hdr.hk.extents       = 0;
hdr.hk.session_error = 0;
hdr.hk.regular       = 'r';


% dim_info (hkey_un0)
if isfield(hdr_dicm, 'InPlanePhaseEncodingDirection')
    hdr_dicm.PhaseEncodingDirection = hdr_dicm.InPlanePhaseEncodingDirection;
end
if (strcmp(hdr_dicm.PhaseEncodingDirection(1:3), 'COL'))
    read_direction  = 1;
    phase_direction = 2;
else    % 'ROW'
    read_direction  = 2;
    phase_direction = 1; 
end
slice_direction     = 3;
dim_info            = read_direction + phase_direction*4 + slice_direction*16;

hdr.hk.hkey_un0     = char(dim_info);


% dim
height  = hdr_dicm.AcquisitionMatrix(1);
width   = hdr_dicm.AcquisitionMatrix(4);
ncolumn = hdr_dicm.Columns / height;
nrow    = hdr_dicm.Rows / width;
depth   = ncolumn * nrow;
if exist('slice_num','var') && isempty(slice_num)~=1 && slice_num~=0
    depth = slice_num;
end

%hdr.dime.dim       = [4, height, width, depth, 1, 1, 1, 1];
hdr.dime.dim       = [3, height, width, depth, 1, 1, 1, 1];


hdr.dime.vox_units = char(zeros(1,4));    % intent_p1
hdr.dime.cal_units = char(zeros(1,8));    % intent_p1, intent_p2
hdr.dime.unused1   = 0;       % intent_code
hdr.dime.datatype  = 4;
hdr.dime.bitpix    = 16;
hdr.dime.dim_un0   = 0;


% pixdim
pixdim    = zeros(1,8);
pixdim(1) = 1;
pixdim(2) = hdr_dicm.PixelSpacing(2);
pixdim(3) = hdr_dicm.PixelSpacing(1);
if (ncolumn ~= 1)
    pixdim(4) = hdr_dicm.SpacingBetweenSlices;
else
   pixdim(4) = hdr_dicm.SliceThickness;
end
pixdim(5) = hdr_dicm.RepetitionTime;
pixdim(6) = 1; % only 4D therefore irrelevant
pixdim(7) = 1; % only 4D therefore irrelevant
pixdim(8) = 1; % only 4D therefore irrelevant

hdr.dime.pixdim      = pixdim;


hdr.dime.vox_offset  = 0.0;
hdr.dime.funused1    = 1.0;     % scl_slope
hdr.dime.funused2    = 0.0;     % scl_inter
hdr.dime.funused3    = 0.0;     % slice_end, slice_code, xyzt_units
hdr.dime.cal_max     = 0.0;
hdr.dime.cal_min     = 0.0;
hdr.dime.compressed  = 0;
hdr.dime.verified    = 0;
hdr.dime.glmax       = 32767;
hdr.dime.glmin       = 0;


% descrip
descrip = zeros(1,80);
my_text = 'Siemens Dicom to nifti-1';
descrip(1:length(my_text)) = my_text;

hdr.hist.descrip     = descrip;


hdr.hist.aux_file    = char(zeros(1,24));
hdr.hist.orient      = char(0);
hdr.hist.origin      = [0 0 0 0 0];
hdr.hist.generated   = char(zeros(1,10));
hdr.hist.scannum     = char(zeros(1,10));
hdr.hist.patient_id  = char(zeros(1,10));
hdr.hist.exp_date    = char(zeros(1,10));
hdr.hist.exp_time    = char(zeros(1,10));
hdr.hist.hist_un0    = char(zeros(1,3));
hdr.hist.views       = 0;
hdr.hist.vols_added  = 0;
hdr.hist.start_field = 0;
hdr.hist.field_skip  = 0;
hdr.hist.omax        = 0;
hdr.hist.omin        = 0;
hdr.hist.smax        = 0;
hdr.hist.smin        = 0;


%% ---------------------------------------------------------------

function hdr = convert_hdr_dcm2nifti_t2(hdr_dicm, slice_num)
% convert the DICOM header to Analyze(nifti) header

hdr.hk.sizeof_hdr    = 348;
hdr.hk.data_type     = char(zeros(1,10));
hdr.hk.db_name       = char(zeros(1,18));
hdr.hk.extents       = 0;
hdr.hk.session_error = 0;
hdr.hk.regular       = 'r';


% dim_info (hkey_un0)
if isfield(hdr_dicm, 'InPlanePhaseEncodingDirection')
    hdr_dicm.PhaseEncodingDirection = hdr_dicm.InPlanePhaseEncodingDirection;
end
if (strcmp(hdr_dicm.PhaseEncodingDirection(1:3), 'COL'))
    read_direction  = 1;
    phase_direction = 2;
else    % 'ROW'
    read_direction  = 2;
    phase_direction = 1; 
end
slice_direction     = 3;
dim_info            = read_direction + phase_direction*4 + slice_direction*16;

hdr.hk.hkey_un0     = char(dim_info);


% dim
height  = hdr_dicm.Columns;
width   = hdr_dicm.Rows;
depth   = slice_num;

%hdr.dime.dim       = [4, height, width, depth, 1, 1, 1, 1];
hdr.dime.dim       = [3, height, width, depth, 1, 1, 1, 1];


hdr.dime.vox_units = char(zeros(1,4));    % intent_p1
hdr.dime.cal_units = char(zeros(1,8));    % intent_p1, intent_p2
hdr.dime.unused1   = 0;       % intent_code
hdr.dime.datatype  = 4;
hdr.dime.bitpix    = 16;
hdr.dime.dim_un0   = 0;


% pixdim
pixdim    = zeros(1,8);
pixdim(1) = 1;
pixdim(2) = hdr_dicm.PixelSpacing(2);
pixdim(3) = hdr_dicm.PixelSpacing(1);
%S if (ncolumn ~= 1)
    pixdim(4) = hdr_dicm.SpacingBetweenSlices;
%S else
%S    pixdim(4) = hdr_dicm.SliceThickness;
%S end
pixdim(5) = hdr_dicm.RepetitionTime;
pixdim(6) = 1; % only 4D therefore irrelevant
pixdim(7) = 1; % only 4D therefore irrelevant
pixdim(8) = 1; % only 4D therefore irrelevant

hdr.dime.pixdim      = pixdim;


hdr.dime.vox_offset  = 0.0;
hdr.dime.funused1    = 1.0;     % scl_slope
hdr.dime.funused2    = 0.0;     % scl_inter
hdr.dime.funused3    = 0.0;     % slice_end, slice_code, xyzt_units
hdr.dime.cal_max     = 0.0;
hdr.dime.cal_min     = 0.0;
hdr.dime.compressed  = 0;
hdr.dime.verified    = 0;
hdr.dime.glmax       = 32767;
hdr.dime.glmin       = 0;


% descrip
descrip = zeros(1,80);
my_text = 'Siemens Dicom to nifti-1';
descrip(1:length(my_text)) = my_text;

hdr.hist.descrip     = descrip;


hdr.hist.aux_file    = char(zeros(1,24));
hdr.hist.orient      = char(0);
hdr.hist.origin      = [0 0 0 0 0];
hdr.hist.generated   = char(zeros(1,10));
hdr.hist.scannum     = char(zeros(1,10));
hdr.hist.patient_id  = char(zeros(1,10));
hdr.hist.exp_date    = char(zeros(1,10));
hdr.hist.exp_time    = char(zeros(1,10));
hdr.hist.hist_un0    = char(zeros(1,3));
hdr.hist.views       = 0;
hdr.hist.vols_added  = 0;
hdr.hist.start_field = 0;
hdr.hist.field_skip  = 0;
hdr.hist.omax        = 0;
hdr.hist.omin        = 0;
hdr.hist.smax        = 0;
hdr.hist.smin        = 0;


%% ---------------------------------------------------------------

function write_nifti_hdr(hdr, fname)
% write the .hdr file

if strcmpi(fname(end-3:end), '.hdr')==0
    fname = [fname '.hdr'];
end

fp = fopen(fname, 'w');
if fp == -1
    warning('Cannot open hdr file.');
    return;
end

fwrite(fp, hdr.hk.sizeof_hdr,    'int32');
fwrite(fp, hdr.hk.data_type,     'char');
fwrite(fp, hdr.hk.db_name,       'char');
fwrite(fp, hdr.hk.extents,       'int32');
fwrite(fp, hdr.hk.session_error, 'int16');
fwrite(fp, hdr.hk.regular,       'char');
fwrite(fp, hdr.hk.hkey_un0,      'char');

fwrite(fp, hdr.dime.dim,         'int16');
fwrite(fp, hdr.dime.vox_units,   'char');
fwrite(fp, hdr.dime.cal_units,   'char');
fwrite(fp, hdr.dime.unused1,     'int16');
fwrite(fp, hdr.dime.datatype,    'int16');
fwrite(fp, hdr.dime.bitpix,      'int16');
fwrite(fp, hdr.dime.dim_un0,     'int16');
fwrite(fp, hdr.dime.pixdim,      'float');
fwrite(fp, hdr.dime.vox_offset,  'float');
fwrite(fp, hdr.dime.funused1,    'float');
fwrite(fp, hdr.dime.funused2,    'float');
fwrite(fp, hdr.dime.funused3,    'float');
fwrite(fp, hdr.dime.cal_max,     'float');
fwrite(fp, hdr.dime.cal_min,     'float');
fwrite(fp, hdr.dime.compressed,  'int32');
%fwrite(fp, hdr.dime.compressed,  'float');
fwrite(fp, hdr.dime.verified,    'int32');
%fwrite(fp, hdr.dime.verified,    'float');
fwrite(fp, hdr.dime.glmax,       'int32');
fwrite(fp, hdr.dime.glmin,       'int32');

fwrite(fp, hdr.hist.descrip,     'char');
fwrite(fp, hdr.hist.aux_file,    'char');
fwrite(fp, hdr.hist.orient,      'char');
fwrite(fp, hdr.hist.origin,      'int16');
%fwrite(fp, hdr.hist.origin,      'char');
fwrite(fp, hdr.hist.generated,   'char');
fwrite(fp, hdr.hist.scannum,     'char');
fwrite(fp, hdr.hist.patient_id,  'char');
fwrite(fp, hdr.hist.exp_date,    'char');
fwrite(fp, hdr.hist.exp_time,    'char');
fwrite(fp, hdr.hist.hist_un0,    'char');
fwrite(fp, hdr.hist.views,       'int32');
fwrite(fp, hdr.hist.vols_added,  'int32');
fwrite(fp, hdr.hist.start_field, 'int32');
fwrite(fp, hdr.hist.field_skip,  'int32');
fwrite(fp, hdr.hist.omax,        'int32');
fwrite(fp, hdr.hist.omin,        'int32');
fwrite(fp, hdr.hist.smax,        'int32');
fwrite(fp, hdr.hist.smin,        'int32');

fclose(fp);
