classdef data_fig < handle
  properties(GetAccess = public)
    fig % figure
    fignum % The data_fig index in the data_fields object
    axes % cell array of data_axis
    dfs % data_fields object
    drs % data_records
    recs % maps rec_name to axes and line where specific vars are displayed
    axis_vec % just the axes
    mymenu % uimenu for this figure
    timespan % seconds
  end
  methods
    function dfig = data_fig(dfs, fignum)
      dfig.fig = figure;
      dfig.fignum = fignum;
      dfig.dfs = dfs;
      dfig.drs = dfs.records;
      dfig.recs = [];
      dfig.axes = {};
      dfig.axis_vec = [];
      dfig.timespan = 200;
      dfig.mymenu = ...
        uimenu(dfs.gimenu,'Text',sprintf('Figure %d', fignum));
      uimenu(dfig.mymenu,'Text','New axes', ...
        'Callback', { @data_fields.context_callback, ...
        "new_axes", fignum });
      set(dfig.fig,'CloseRequestFcn', @dfig.closereq);
      m = uimenu(dfig.fig,'Text','Timespan');
      for ts = [1:5 10 15 30 60 90 120 240] % minutes
        secs = ts*60;
        uimenu(m,'Text',sprintf('%d',ts), ...
          'Callback', @(s,e)set_timespan(dfig,secs), ...
          'Interruptible', 'off');
      end
    end
    
    function axnum = new_graph(dfig, rec_name, dl, mode, axisnum, axis_func)
      % axnum = new_graph(df, rec_name, dl, mode, axisnum)
      % use the figure's mode to decide where to put it
      % for starters, always create a new axis
      % @param dl: data_line object
      % @param mode: "new_fig", "new_axes", "cur_axes"
      if isempty(dfig.fig)
        warning('Attempt to add graph to closed data_fig');
        return;
      end
      if ~isfield(dfig.recs,rec_name)
        dfig.recs.(rec_name).vars = [];
      end
      if mode == "new_fig" || mode == "new_axes"
        if isempty(axis_func)
          axis_func = @data_axis;
        end
        the_axis = axis_func(dfig.dfs, dfig.fig, dl.name, dfig.timespan);
        dfig.axes{end+1} = the_axis;
        if isempty(dfig.axis_vec)
          dfig.axis_vec = dfig.axes{end}.axis;
        else
          dfig.axis_vec(end+1) = dfig.axes{end}.axis;
        end
        axisnum = length(dfig.axes);
        uimenu(dfig.mymenu,'Text',sprintf('Axis %d',axisnum), ...
          'Callback', { @data_fields.context_callback, ...
          "cur_axes", dfig.fignum, axisnum });
      else
        the_axis = dfig.axes{axisnum};
      end
      % fprintf(1,'axis %s add_line %s\n',the_axis.label,dl.name);
      n = the_axis.add_line(dl);
      if isfield(dfig.recs.(rec_name).vars, dl.name)
        dfig.recs.(rec_name).vars.(dl.name) = [
          dfig.recs.(rec_name).vars.(dl.name)
          axisnum n ];
      else
        dfig.recs.(rec_name).vars.(dl.name) = ...
          [ axisnum n ];
      end
      dfig.redraw();
      axnum = axisnum;
    end

    function redraw(dfig)
      % reallocate axes positions
      n_axes = length(dfig.axes);
      for i=1:n_axes
        pos = nsubpos(n_axes,1,i,1);
        ax = dfig.axes{i}.axis;
        ax.Position = pos;
        ax.Visible = 'on';
        if mod(i,2)
          ax.YAxisLocation = 'Left';
        else
          ax.YAxisLocation = 'Right';
        end
        if i < n_axes
          ax.XTickLabel = [];
        end
      end
      linkaxes(dfig.axis_vec,'x');
    end

    function set_timespan(dfig, ts)
      if ts ~= dfig.timespan
        dfig.timespan = ts;
        for i = 1:length(dfig.axes)
          da = dfig.axes{i};
          da.set_timespan(ts);
        end
      end
    end

    function closereq(dfig, ~, ~)
      f = dfig.fig;
      dfig.axis_vec = [];
      for i=1:length(dfig.axes)
        dfig.axes{i}.deconstruct;
      end
      dfig.axes = {};
      dfig.recs = [];
      set(dfig.mymenu,'enable','off','visible','off');
      delete(f);
      dfig.fig = [];
    end
  end
end
