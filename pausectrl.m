function fig = pausectrl(pauseval, plotval);
% handles = pausectrl( pauseval, plotval );
% handles(1) is the figure handle
% handles(2) is the Pause checkbox
% handles(3) is the Plot checkbox
if nargin < 2
  plotval = 1;
  if nargin < 1
    pauseval = 1;
  end
end
ctrl = figure;
pf = get(ctrl,'Position');
h1 = uicontrol('Style','checkbox','string','Pause','value',pauseval);
p1 = get(h1,'Position');
h2 = uicontrol('Style','checkbox','string','Plot','value',plotval);
p2 = get(h2,'Position');
p2([1:2]) = [0 0];
pf([3:4]) = p2([1:2]) + p2([3:4]) + [ 0 20];
if pf(3) < 104
  p2(1) = (104 - pf(3))/2;
  pf(3) = 104;
end
p1([1:2]) = p2([1:2]) + [ 0 p2(4)];
set(h1,'Position',p1);
set(h2,'Position',p2);
set(ctrl,'Position',pf,'NumberTitle','off','WindowStyle','modal');
fig = [ ctrl h1 h2 ];
