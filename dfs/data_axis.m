classdef data_axis < handle
  properties
    lines
    % recs
    dfig
    axis % axes
    label
  end
  methods
    function da = data_axis(dfig, label)
      da.dfig = dfig;
      % da.recs = dfig.recs;
      da.axis = axes(dfig.fig,'visible','on');
      if isfield(da.axis,'Toolbar') && isfield(da.axis.Toolbar,'Visible')
        da.axis.Toolbar.Visible = 'Off';
      end
      da.label = strrep(label,'_','\_');
    end
    
    function n = add_line(da, rec_name, dl)
      % returns the line index
      da.lines{end+1} = struct('rec',rec_name,'line',dl);
      da.redraw();
      n = length(da.lines);
    end
    
    function redraw(da)
      cla(da.axis);
      % fprintf(1,'redraw()\n');
      for i=1:length(da.lines)
        rec_name = da.lines{i}.rec;
        dl = da.lines{i}.line;
        if isfield(da.dfig.drs.records, rec_name)
          dr = da.dfig.drs.records.(rec_name);
          [T,V] = dr.time_vector(200);
          D = dl.num_convert(dr.data_vector(var_name,V));
          T0 = da.dfig.drs.max_time;
          if isempty(T) || isempty(T0)
            if isempty(T0)
              warning('T0 is empty');
            end
            % fprintf(1,'%d: %s - empty plot\n', i, var_name);
            plot(da.axis, nan, nan);
          else
            % fprintf(1,'%d: %s - non-empty plot\n', i, var_name);
            plot(da.axis, T-T0, D);
          end
        else
          % fprintf(1,'%d: %s - empty plot\n', i, var_name);
          plot(da.axis,nan,nan);
        end
        hold(da.axis,'on');
      end
      hold(da.axis,'off');
      set(da.axis,'xlim',[-200 0]);
      ylabel(da.axis,da.label);
      % drawnow;
    end
  end
end
