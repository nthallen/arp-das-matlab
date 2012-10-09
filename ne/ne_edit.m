function ne_edit(funcname)
% ne_edit(funcname);
% Edits or creates a customization function for the specified
% source file.
src = which(funcname);
if isempty(src)
    errordlg(sprintf('Unable to locate function ''%s''', funcname));
    return;
end
[srcpath,cfunc,e] = fileparts(src);
if strncmp(cfunc, 'cust_', 5) == 0
    cfunc = ['cust_' cfunc];
end
dest = fullfile(srcpath, [cfunc '.m']);
if ~exist(dest,'file')
    ifd = fopen(src);
    ofd = fopen(dest,'w');
    fprintf(ofd, 'function %s(h)\n', cfunc);
    fprintf(ofd, '%% %s(h)\n', cfunc);
    fprintf(ofd, '%% Customize plot created by %s\n', funcname);
    fprintf(ofd, '\n');
    fprintf(ofd, '%% %s''s definition:\n\n', funcname);
    tline = fgetl(ifd);
    while ischar(tline)
        fprintf(ofd, '%% %s\n', tline);
        tline = fgetl(ifd);
    end
    fclose(ifd);
    fprintf(ofd, '\n');
    fprintf(ofd, '%% Example customizations include:\n');
	fprintf(ofd, ...
        [ '%%   set(h,''LineStyle'',''none'',''Marker'',''.'');\n' ...
		  '%%   ax = get(h(1),''parent'');\n' ...
		  '%%   set(ax,''ylim'',[0 800]);\n' ]);
    fclose(ofd);
end
edit(dest);
    