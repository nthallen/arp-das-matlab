function ne_setdir( dir );
co = get(0,'callbackobject');
f = co;
while length(f) == 1
  t = get(f,'type');
  if strcmp( t, 'figure')
    set( f, 'UserData', dir );
    ch = findobj(f,'style','radiobutton')';
    for obj = ch;
      if obj ~= co, set(obj,'Value',0); end
    end
    break;
  end
  f = get( f, 'Parent' );
end
