function cygfile = win2cyg( winfile );
% cygfile = win2cyg( winfile );
% Translates windows-syntax filename to cygwin syntax
nc = length(winfile);
if winfile(2) == ':'
    cygfile = [ '/cygdrive/' winfile([1 3:nc]) ];
    cygfile(cygfile == '\') = '/';
else
    cygfile = winfile;
end
