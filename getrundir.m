function run = getrundir;
run = '';
co = get(0,'callbackobject');
while length(co) == 1
  t = [ get(co,'type') '/' get(co,'tag') ];
  if strcmp( t, 'figure/eng_ui')
    run = get( co, 'UserData' );
    break;
  end
  co = get( co, 'Parent' );
end
if length(run) == 0
  run = pwd;
end
