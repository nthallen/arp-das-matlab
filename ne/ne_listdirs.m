function f = ne_listdirs( f, pdir, max_rows );
[tok,rem] = strtok(pdir,'\/');
if length(rem) == 0
  if exist(pdir,'file')
    newpdir = eval(pdir);
    if ~exist(newpdir,'dir')
      warning(sprintf('Function "%s" did not return a directory', pdir));
      return;
    end
    pdir = newpdir;
  else
    set(f.fig, 'visible', 'off');
    newpdir = uigetdir([], 'Where are run directories located?');
    set(f.fig, 'visible', 'on');
    if isnumeric(newpdir)
      warning('No directory selected, no data will be viewable');
      return;
    end
    if ~exist(newpdir,'dir')
      warning(sprintf('uigetdir did not return a directory', pdir));
      return;
    end
    ST = dbstack(1,'-completenames');
    [exppath,n,e,] = fileparts(ST.file);
    newfile = fullfile(exppath, [ pdir '.m']);
    nfd = fopen(newfile,'w');
    fprintf(nfd,'function path = %s\n', pdir);
    fprintf(nfd,'%% path = %s;\n', pdir);
    fprintf(nfd,'path = ''%s'';\n', newpdir);
    fclose(nfd);
    pdir = newpdir;
    % error(sprintf('You must define a function named "%s" to define the data directory', pdir));
  end
end
files = dir( pdir );
[ sfiles ifiles ] = sort({files.name});
if size(ifiles,2) > 1
  ifiles = ifiles';
end
files = files(flipud(ifiles));
row = max_rows;
dflt_set = 0;
for file = files'
  if file.isdir & file.name(1) >= '0' & file.name(1) <= '9'
    if row == max_rows
      f = ne_dialg(f, 'newcol');
      row = 0;
    end
    f = ne_dialg(f, 'add', 0, ( -1 - dflt_set ), ...
      [ 'ne_setdir(''' pdir filesep file.name ''');' ], file.name );
    if ~dflt_set
      set( f.fig, 'UserData', [ pdir filesep file.name ], 'tag', 'eng_ui' );
      dflt_set = 1;
    end
    row = row + 1;
  end
end
