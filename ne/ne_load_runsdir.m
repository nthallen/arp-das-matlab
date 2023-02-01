function runsdir = ne_load_runsdir(pdir, depth)
% runsdir = ne_load_runsdir(funcname);
% runsdir = ne_load_runsdir(funcname, depth);
% Returns the location of the directory containing run
% directories of engineering data.
%
% If funcname exists in the path, evaluate it.
% Otherwise, bring up a dialog and create the function
% for future use. The function is stored in the directory
% where the caller's function is stored.
% depth, if present, indicates how far up the call
% chain we should look. The default is 1, which means
% store the file not in the directory where ne_load_runsdir.m
% is found but where the function calling ne_load_runsdir()
% is found. Higher numbers are used for deeper nesting.
if nargin < 2
    depth = 1;
end
if exist(pdir,'file')
    newpdir = eval(pdir);
    if ~exist(newpdir,'dir')
        warning('HUARP:GENUI', 'Function "%s" did not return a directory', pdir);
        return;
    end
    runsdir = newpdir;
else
    newpdir = uigetdir([], ...
        'Where are run directories for engineering data located?');
    if isnumeric(newpdir)
        warning('HUARP:GENUI', 'No directory selected, no data will be viewable');
        return;
    end
    if ~exist(newpdir,'dir')
        warning('HUARP:GENUI', 'uigetdir did not return a directory: %s', newpdir);
        return;
    end
    ST = dbstack(depth,'-completenames');
    if isempty(ST)
        exppath = '.';
    else
        exppath = fileparts(ST(1).file);
    end
    write_ne_runsdir(pdir, exppath, newpdir)
    runsdir = newpdir;
end
