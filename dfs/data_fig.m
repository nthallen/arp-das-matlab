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
      dfig.mymenu = ...
        uimenu(dfs.gimenu,'Text',sprintf('Figure %d', fignum));
      uimenu(dfig.mymenu,'Text','New axes', ...
        'Callback', { @data_fields.context_callback, ...
        "new_axes", fignum });
      set(dfig.fig,'CloseRequestFcn', @dfig.closereq);
    end
    
    function axnum = new_graph(dfig, rec_name, dl, mode, axisnum)
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
        the_axis = data_axis(dfig, dl.name);
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
      n = the_axis.add_line(rec_name, dl);
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
    
    function update(dfig, rec_name)
      if isempty(dfig.fig)
        return;
      end
      % update data for each line of each graph
      if isfield(dfig.recs,rec_name) % if we are plotting any data
        dr = dfig.drs.records.(rec_name);
        [T,V] = dr.time_vector(200);
        % go through df.recs.(rec_name).vars
        if isfield(dfig.recs.(rec_name), 'vars') && ...
            isstruct(dfig.recs.(rec_name).vars)
          vars = dfig.recs.(rec_name).vars;
          var_names = fieldnames(vars);
          for i=1:length(var_names)
            var = var_names{i};
            axn = vars.(var);
            
            D = dr.data_vector(var,V);
            w = size(D,2);
            % May need to be more careful accessing varinfo here
            if w == 1 || dfig.dfs.varinfo.(var).interp == 0
              TI = T - dfig.drs.max_time;
              DI = D;
            else % doing time interpolation
              h = size(D,1)-1;
              if h > 0
                I = ((1:h*w)-1)/w+1;
                TI = interp1(1:h+1,T,I)-dfig.drs.max_time;
                DI = reshape(D(2:end,:)',[],1);
              end
            end
            for axi=1:size(axn,1)
              ax = dfig.axis_vec(axn(axi,1));
              n = axn(axi,2);
              lns = findobj(ax,'type','line','parent',ax);
              if n > 0 && n <= length(lns)
                set(lns(n),'XData',TI,'YData',DI);
              else
                % warning('Line %d not in axis', n);
                % It makes sense that this line is not here when
                % we are redrawing. Disable the warning, since it is
                % ugly and not helpful
              end
            end
          end
        end
      end
    end
    
    function closereq(dfig, ~, ~)
      f = dfig.fig;
      dfig.fig = [];
      dfig.axis_vec = [];
      dfig.axes = {};
      dfig.recs = [];
      set(dfig.mymenu,'enable','off','visible','off');
      delete(f);
    end
  end
end
