function ne_print
% ne_print
% Callback routine to print selected figures
[~,fig] = gcbo;
k = findobj(fig,'style','checkbox');
kv = get(k,'value');
kv = [ kv{:} ]'; % convert to a double array
v = find(kv > 0);
k = k(v);
kv = kv(v);
[~,I] = sort(kv);
k = k(I)';
for i = k
  kt = char(get(i,'tag'));
  if nargout(kt) == 0
    p = [ kt '(''Printing''); f = gcf;' ];
  else
    p = [ 'f = ' kt '(''Printing'');' ];
  end
  % disp(p);
  eval(p);
  print( f, '-dwinc');
  delete(f);
end
