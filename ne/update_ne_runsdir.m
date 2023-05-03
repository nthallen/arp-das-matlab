function update_ne_runsdir(runsdir_funcname, runsdir_funcpath)
% update_ne_runsdir(runsdir_funcname[, runsdir_funcpath]);
% Updates an existing runsdir location by prompting the user to select a new
% folder interactively.
P = which(runsdir_funcname);
if isempty(P)
  if nargin < 2
    error('Input file "%s" not found and no path specified', runsdir_funcname);
  end
  if ~exist(runsdir_funcpath,'dir')
    error('Specified runsdir_funcpath "%s" is not a directory', ...
      runsdir_funcpath);
  end
  old_runsdir = [];
else
  files = dir(P);
  if length(files) ~= 1
    error('HUARP:GENUI', 'Input function "%s" not found', runsdir_funcname);
  end
  if nargin > 1 && ~strcmp(runsdir_funcpath, files.folder)
    error('HUARP:GENUI', ...
      'Existing function %s is located in %s,\n  which differs from the supplied path %s', ...
      runsdir_funcname, files.folder, runsdir_funcpath);
  end
  runsdir_funcpath = files.folder;
  old_runsdir = eval(runsdir_funcname);
  if ~exist(old_runsdir,'dir')
    old_runsdir = [];
  end
end

new_runsdir = uigetdir(old_runsdir, ...
  sprintf('Where will engineering data be located (%s)?', ...
  runsdir_funcname));
if isnumeric(new_runsdir)
  warning('HUARP:GENUI', 'No directory selected, no data will be viewable');
  return;
end
if ~exist(new_runsdir, 'dir')
  warning('HUARP:GENUI', 'uigetdir did not return a directory: %s', ...
    new_runsdir);
  return;
end
write_ne_runsdir(runsdir_funcname, runsdir_funcpath, new_runsdir);