function f = ne_listdirs( f, pdir, max_rows )
[~,rem] = strtok(pdir,'\/');
if isempty(rem)
  if exist(pdir,'file')
    newpdir = eval(pdir);
    if ~exist(newpdir,'dir')
      warning('HUARP:GENUI', 'Function "%s" did not return a directory', pdir);
      return;
    end
    pdir = newpdir;
  else
    set(f.fig, 'visible', 'off');
    newpdir = uigetdir([], 'Where are run directories located?');
    set(f.fig, 'visible', 'on');
    if isnumeric(newpdir)
      warning('HUARP:GENUI', 'No directory selected, no data will be viewable');
      return;
    end
    if ~exist(newpdir,'dir')
      warning('HUARP:GENUI', 'uigetdir did not return a directory: %s', newpdir);
      return;
    end
    ST = dbstack(1,'-completenames');
    exppath = fileparts(ST.file);
    newfile = fullfile(exppath, [ pdir '.m']);
    nfd = fopen(newfile,'w');
    fprintf(nfd,'function path = %s\n', pdir);
    fprintf(nfd,'%% path = %s;\n', pdir);
    fprintf(nfd,'path = ''%s'';\n', newpdir);
    fclose(nfd);
    pdir = newpdir;
  end
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
