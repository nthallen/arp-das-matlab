function f = ne_listdirs( f, pdir, max_rows )
[~,rem] = strtok(pdir,'\/');
if isempty(rem)
  set(f.fig, 'visible', 'off');
  pdir = ne_load_runsdir(pdir, 2);
end
files = dir( pdir );
[ ~, ifiles ] = sort({files.name});
if size(ifiles,2) > 1
  ifiles = ifiles';
end
files = files(flipud(ifiles));
row = max_rows;
dflt_set = 0;
for file = files'
  if file.isdir && file.name(1) >= '0' && file.name(1) <= '9'
    if row == max_rows
      f = ne_dialg(f, 'newcol');
      row = 0;
    end
    datadir = [ pdir filesep file.name ];
    logfile = [ datadir filesep 'saverun.log' ];
    tooltip = {};
    if exist(logfile, 'file')
        logtext = fileread(logfile);
        if ~isempty(logtext)
            trim = find(~isspace(logtext));
            if isempty(trim)
                logtext = '';
            else
                logtext = logtext(trim(1):trim(end));
            end
        end
        if ~isempty(logtext)
            tooltip = { 'TooltipString', logtext };
        end
    end
    f = ne_dialg(f, 'add', 0, ( -1 - dflt_set ), ...
      [ 'ne_setdir(''' datadir ''');' ], file.name, tooltip{:} );
    if ~dflt_set
      set( f.fig, 'UserData', datadir, 'tag', 'eng_ui' );
      dflt_set = 1;
    end
    row = row + 1;
  end
end
