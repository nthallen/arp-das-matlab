function f = ne_listdirs( f, pdir, max_rows );
[tok,rem] = strtok(pdir,'\/');
if length(rem) == 0
  if exist(pdir,'file')
    newpdir = eval(pdir);
    if ~exist(newpdir,'dir')
      error(sprintf('Function "%s" did not return a directory', pdir));
    end
    pdir = newpdir;
  else
    error(sprintf('You must define a function named "%s" to define the data directory', pdir));
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
