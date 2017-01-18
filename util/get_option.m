function opt = get_option(args, optDef)
% get_option    Get options from args
%
% This file is a part of BrainDecoderToolbox2.
%

nArgs = length(args);

if mod(nArgs, 2) ~= 0
    error('get_option:InvalidArgs', ...
          'Option arguments must be key-value pairs');
end

% Initialize `opt` with default values
nOpt = length(optDef);

for n = 1:nOpt
    try
        optKey  = optDef{n}{1};
        optType = optDef{n}{2};
        optVal  = optDef{n}{3};
    catch
        error('get_option:InvalidOptDef', ...
              'Invalide option definition\n');
    end

    opt.(optKey) = optVal;
end

% Load `args`
c = 1;
while c < nArgs
    key = args{c};
    val = args{c + 1};

    if ~isfield(opt, key)
        error('get_option:InvalidKey', ...
              'Invalide key %s\n', key);
    else
        opt.(key) = val;
    end

    c = c + 2;
end
