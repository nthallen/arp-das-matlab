function axestoolbarsvisibility(on_off, parent_fig)
% axestoolbarsvisibility([on_off, [parent_fig]])
% on_off: either 'on' or 'off'. If omitted, defaults to 'off'
% parent_fig: The graphics handle. If omitted, will affect all figures
%  with the 'eng_ui' Tag.
if nargin < 2
    parent_fig = findobj('Type', 'Figure', 'Tag', 'eng_ui');
    if nargin < 1
        on_off = 'off';
    end
end
Nfigs = length(parent_fig);
for fi = 1:Nfigs
    ax = findobj(parent_fig, 'Type', 'Axes');
    Nax = length(ax);
    for ai = 1:Nax
        ax(ai).Toolbar.Visible = on_off;
    end
end
