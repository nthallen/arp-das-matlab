function addzoom;
% addzoom
% Adds some zoom control menus and a 'MatchX' menu item to
% the current figure.
h = uimenu('label','Zoom');
uimenu(h,'label','On','Callback','zoom off; zoom on;');
uimenu(h,'label','Off','Callback','zoom off;');
uimenu(h,'label','X','Callback','zoom off; zoom xon;');
uimenu(h,'label','Y','Callback','zoom off; zoom yon;');
uimenu('label','MatchX','Callback','matchx;');
