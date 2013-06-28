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
% chain we should look.
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
    exppath = fileparts(ST(1).file);
    newfile = fullfile(exppath, [ pdir '.m']);
    nfd = fopen(newfile,'w');
    fprintf(nfd,'function path = %s\n', pdir);
    fprintf(nfd,'%% path = %s;\n', pdir);
    fprintf(nfd,'path = ''%s'';\n', newpdir);
    fclose(nfd);
    runsdir = newpdir;
end
