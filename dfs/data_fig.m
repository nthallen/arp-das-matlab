classdef data_fig < handle
  properties(GetAccess = public)
    fig % figure
    fignum % The data_fig index in the data_fields object
    axes % cell array of data_axis
    drs % data_records
    recs % maps rec_name to axes and line where specific vars are displayed
    axis_vec % just the axes
    mymenu % uimenu for this figure
  end
  methods
    function df = data_fig(dfs, fignum)
      df.fig = figure;
      df.fignum = fignum;
      df.drs = dfs.records;
      df.recs = [];
      df.axes = {};
      df.axis_vec = [];
      df.mymenu = ...
        uimenu(dfs.gimenu,'Text',sprintf('Figure %d', fignum));
      uimenu(df.mymenu,'Text','New axes', ...
        'Callback', { @data_fields.context_callback, ...
        "new_axes", fignum });
      set(df.fig,'CloseRequestFcn', @df.closereq);
    end
    
    function new_graph(df, rec_name, var_name, mode, axisnum)
      % use the figure's mode to decide where to put it
      % for starters, always create a new axis
      % @param mode: "new_fig", "new_axes", "cur_axes"
      if isempty(df.fig)
        warning('Attempt to add graph to closed data_fig');
        return;
      end
      if ~isfield(df.recs,rec_name)
        df.recs.(rec_name).vars = [];
      end
      if mode == "new_fig" || mode == "new_axes"
        the_axis = data_axis(df, var_name);
        df.axes{end+1} = the_axis;
        df.axis_vec(end+1) = df.axes{end}.axis;
        axnum = length(df.axes);
        uimenu(df.mymenu,'Text',sprintf('Axis %d',axnum), ...
          'Callback', { @data_fields.context_callback, ...
          "cur_axes", df.fignum, axnum });
      else
        the_axis = df.axes{axisnum};
      end
      n = the_axis.add_line(rec_name, var_name);
      if isfield(df.recs.(rec_name).vars, var_name)
        df.recs.(rec_name).vars.(var_name) = [
          df.recs.(rec_name).vars.(var_name)
          axisnum n ];
      else
        df.recs.(rec_name).vars.(var_name) = ...
          [ axisnum n ];
      end
      df.redraw();
    end
    
    function redraw(df)
      % reallocate axes positions
      n_axes = length(df.axes);
      for i=1:n_axes
        pos = nsubpos(n_axes,1,i,1);
        ax = df.axes{i}.axis;
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
      linkaxes(df.axis_vec,'x');
    end
    
    function update(df, rec_name)
      if isempty(df.fig)
        return;
      end
      % update data for each line of each graph
      if isfield(df.recs,rec_name) % if we are plotting any data
        dr = df.drs.records.(rec_name);
        [T,V] = dr.time_vector(200);
        % go through df.recs.(rec_name).vars
        if isfield(df.recs.(rec_name), 'vars') && ...
            isstruct(df.recs.(rec_name).vars)
          vars = df.recs.(rec_name).vars;
          var_names = fieldnames(vars);
          for i=1:length(var_names)
            var = var_names{i};
            axn = vars.(var);
            
            D = dr.data_vector(var,V);
            w = size(D,2);
            if w == 1 || dr.datainfo.(var).interp == 0
              TI = T - df.drs.max_time;
              DI = D;
            else % doing time interpolation
              h = size(D,1)-1;
              if h > 0
                I = ((1:h*w)-1)/w+1;
                TI = interp1(1:h+1,T,I)-df.drs.max_time;
                DI = reshape(D(2:end,:)',[],1);
              end
            end
            for axi=1:size(axn,1)
              ax = df.axis_vec{axn(axi,1)};
              n = axn(axi,2);
              lns = findobj(ax.axis,'type','line','parent',ax.axis);
              if n > 0 && n <= length(lns)
                set(lns(n),'XData',TI,'YData',DI);
              else
                warning('Line %d not in axis', n);
              end
            end
          end
        end
      end
    end
    
    function closereq(df, ~, ~)
      f = df.fig;
      df.fig = [];
      df.axis_vec = [];
      df.axes = {};
      df.recs = [];
      set(df.mymenu,'enable','off','visible','off');
      delete(f);
    end
  end
end
