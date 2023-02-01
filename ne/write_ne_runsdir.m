function write_ne_runsdir(funcname, funcpath, datadir)
% write_ne_runsdir(funcname, funcpath, datadir)
% Creates the function m-file in the funcpath directory that
% points to datadir.
newfile = fullfile(funcpath, [ funcname '.m']);
nfd = fopen(newfile,'w');
fprintf(nfd,'function path = %s\n', funcname);
fprintf(nfd,'%% path = %s;\n', funcname);
fprintf(nfd,'path = ''%s'';\n', datadir);
fclose(nfd);
