function opt = bdt_getoption(args, optDef)
% bdt_getoption    Get options from args
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - args   : Option arguments
% - optDef : Option definition
%
% Outputs:
%
% - opt : Option structure
%

nArgs = length(args);

if mod(nArgs, 2) ~= 0
    error('bdt_getoption:InvalidArgs', ...
          'Option arguments must be key-value pairs');
end

%% Initialize `opt` with default values
for n = 1:length(optDef)
    try
        optKey  = optDef{n}{1};
        optType = optDef{n}{2};
        optVal  = optDef{n}{3};
    catch
        error('bdt_getoption:InvalidOptDef', ...
              'Invalide option definition\n');
    end
    opt.(optKey) = optVal;
    optTypeDict.(optKey) = optType;
end

%% Load `args`
c = 1;
while c < nArgs
    key = args{c};
    val = args{c + 1};

    if ~isfield(opt, key)
        error('bdt_getoption:InvalidOptionKey', ...
              'Invalid option key %s\n', key);
    else
        opt.(key) = val;
    end

    c = c + 2;
end

%% Check type
keys = fieldnames(opt);
for i = 1:length(keys)
    opVal = opt.(keys{i});
    opType = optTypeDict.(keys{i});
    switch opType
      case {'scalar'}
        if ~(isscalar(opVal) || isempty(opVal))
            error('bdt_getoption:InvalidOptionType', ...
                  'Invalide option type\n');
        end
      case {'vector'}
        if ~(isvector(opVal) || isempty(opVal))
            error('bdt_getoption:InvalidOptionType', ...
                  'Invalide option type\n');
        end
      case {'matrix'}
        if ~(ndims(opVal) == 2 || isempty(opVal))
            error('bdt_getoption:InvalidOptionType', ...
                  'Invalide option type\n');
        end
      case {'char', 'string'}
        if ~ischar(opVal)
            error('bdt_getoption:InvalidOptionType', ...
                  'Invalide option type\n');
        end
      case {'cell'}
        if ~iscell(opVal)
            error('bdt_getoption:InvalidOptionType', ...
                  'Invalide option type\n');
        end
      case {'logical'}
        if ~islogical(opVal)
            error('bdt_getoption:InvalidOptionType', ...
                  'Invalide option type\n');
        end
      case {'onoff'}
        if ~islogical(opVal)
            switch opVal
              case 'on'
                opt.(keys{i}) = true;
              case 'off'
                opt.(keys{i}) = false;
              otherwise
                error('bdt_getoption:InvalidOptionType', ...
                      'Invalide option type\n');
            end
        end
      otherwise
        error('bdt_getoption:UnknownOptionType', ...
              'Unknown option type %s\n', opType);
    end
end
