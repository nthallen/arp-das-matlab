function ne_setpanel(n);
% ne_setpanel(n);
[h,fig] = gcbo;
f = guidata(fig);
if ~isempty(f)
    set(f.panel,'Visible','off');
    set(f.panel(n),'Visible','on');
    set(f.panelmenus,'Checked','off');
    set(f.panelmenus(n),'Checked','on');
end
