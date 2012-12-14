function run = getrundir(co)
run = '';
% Special case for engineering plots: check for UserData in
% the figure containing the callbackobject. Fails for
% scan_viewer with a listener on slider value since the value
% object does not have a type nor a parent.
if nargin < 1
    co = gcbo;
end
while ~isempty(co)
    try
      t = [ get(co,'type') '/' get(co,'tag') ];
      if strcmp(t, 'figure/eng_ui') || strcmp(t, 'figure/scan_viewer')
        run = get(co, 'UserData');
        break;
      end
      co = get(co, 'Parent');
    catch err
      break;
    end
end
% Otherwise, use the current directory
if isempty(run)
  run = pwd;
end
