function cygfile = win2cyg( winfile );
% cygfile = win2cyg( winfile );
% Translates windows-syntax filename to cygwin syntax
nc = length(winfile);
if winfile(2) ~= ':'
  error('win2cyg: input arg must be fully-qualified with drive letter');
end
cygfile = [ '/cygdrive/' winfile([1 3:nc]) ];
cygfile(cygfile == '\') = '/';
