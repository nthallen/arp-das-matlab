function f = findvar(files, varargin)
% f = findvar( files, varargin );

delim = find(files == filesep, 1, 'last');
if isempty(delim)
  fdir = '.';
else
  fdir = files(1:delim-1);
end
D = dir(files);
f = {};
for varstr = varargin
  var = strtok( char(varstr), '/*+-' );
  found = '';
  for file = { D.name }
    cfile = [ fdir filesep char(file) ];
    vars = who('-file', cfile );
    if any(strcmpi( var, vars ))
      found = cfile;
    end
	if ~isempty(found)
	  break;
	end
  end
  f = [ f {found} ];
  if isempty(found)
    fprintf(1, 'Unable to locate variable ''%s'' in directory ''%s''\n', char(var), fdir );
  end
end
% f = lower(f);
% f = strrep(lower(f),'.mat','');
f = strrep( f,'.mat','');
f = strrep( f, '.MAT', '');
f = f';
