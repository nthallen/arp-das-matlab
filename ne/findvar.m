function f = findvar( files, varargin );
% f = findvar( files, varargin );

delim = max(findstr( files, '\' ));
if isempty(delim)
  fdir = '.';
else
  fdir = files([1:delim-1]);
end
D = dir(files);
f = {};
for varstr = varargin
  var = strtok( char(varstr), '/*+-' );
  found = '';
  for file = { D.name };
    cfile = [ fdir '\' char(file) ];
    vars = who('-file', cfile );
    if any(strcmpi( var, vars ))
      found = cfile;
    end
	if length(found) > 0
	  break;
	end
  end
  f = { f{:} found }';
  if length(found) == 0
    errordlg([ 'Unable to locate variable ''' char(var) ''' in directory ''' ...
              fdir '''' ] );
  end
end
% f = lower(f);
% f = strrep(lower(f),'.mat','');
f = strrep( f,'.mat','');
f = strrep( f, '.MAT', '');