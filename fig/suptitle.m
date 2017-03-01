function hout = suptitle(str)
% suptitle    Puts a title above all subplots
%
% This function was obsoleted and kept for backward compatibility.
% Please use `figtitle` instead.
%
% This file is a part of BrainDecoderToolbox2.
%

hout = figtitle(gcf, str, 'top');
