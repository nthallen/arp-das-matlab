function ax = ne_time_fig(arg1)
  % ax = ne_time_fig(3);
  %   Create a figure with the specified number of axes.
  %   Returns an array of the axes handles
  % ne_time_fig(ax);
  %   Fixup the axes in the usual way.
  if nargout == 0
    if any(ishandle(arg1) == 0)
      error('Expected axes input to ne_time_plot');
    end
    N = length(arg1);
    for i=1:N-1
      axtype = get(arg1(i),'type');
      if ~strcmp(axtype,'axes')
        error('Expected axes input to ne_time_plot');
      end
      if mod(i+N,2)
        set(arg1(i),'YAxisLocation','Right');
      end
      if i < N
        set(arg1(i),'XTickLabel',[]);
      end
    end
    linkaxes(arg1,'x');
  else
    if length(arg1) ~= 1 || ~isnumeric(arg1) || round(arg1) ~= arg1 || ...
        arg1 < 1
      error('Expected scalar integer input to ne_time_plot');
    end
    fg = figure;
    hda = datacursormode(fg);
    set(hda, 'UpdateFcn', @ne_data_cursor_text_func);
    ax = zeros(arg1,1);
    for i=1:arg1
      ax(i) = nsubplot(arg1,1,i);
    end
  end
  
