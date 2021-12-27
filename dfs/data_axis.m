classdef data_axis < handle
  properties
    % lines and lns are the same length
    % recs.(rec_name) is an array of indices into lines and lns
    axis_index % index into da.dfs.axes
    linesbyrec % struct mapping rec_name to indices into lines & lns
    lines % data_line objects
    lns % line graphics objects
    dfs % data_fields object
    axis % axes
    label
    timespan % seconds
  end
  methods
    function da = data_axis(dfs, parent, label)
      da.axis_index = [];
      da.dfs = dfs;
      da.linesbyrec = [];
      da.lines = {};
      da.lns = {};
      da.axis = axes(parent,'visible','on');
      if isfield(da.axis,'Toolbar') && isfield(da.axis.Toolbar,'Visible')
        da.axis.Toolbar.Visible = 'Off';
      end
      da.label = strrep(label,'_','\_');
      da.timespan = 200;
    end
    
    function n = add_line(da, dl)
      % returns the line index
      da.lines{end+1} = dl;
      if isfield(da.linesbyrec,dl.rec_name)
        da.linesbyrec.(dl.rec_name) = ...
          [da.linesbyrec.(dl.rec_name) length(da.lines)];
      else
        da.dfs.record_axis(da, dl.rec_name);
        da.linesbyrec.(dl.rec_name) = length(da.lines);
      end
      da.redraw();
      n = length(da.lines);
    end
    
    function redraw(da)
      recs = fieldnames(da.linesbyrec);
      for i=1:length(recs)
        rec_name = recs{i};
        if ~strcmp(rec_name,'unassociated')
          da.update(rec_name);
        end
      end
    end

    function new_record(da, rec_name)
      % da.new_record(rec_name)
      % Check to see if any of our unassociated variables are defined in
      % the new record.
      if isfield(da.linesbyrec,'unassociated')
        new_unassociated = [];
        found_new = false;
        for lnsi = da.linesbyrec.unassociated
          dl = da.lines{lnsi};
          new_rec_name = da.dfs.check_recname(dl.var_name);
          if ~strcmp(new_rec_name,'unassociated')
            if ~strcmp(new_rec_name, rec_name)
              warn('da.new_record found var %s in %s while checking %s', ...
                dl.name, new_rec_name, rec_name);
            end
            dl.rec_name = new_rec_name;
            if ~isfield(da.linesbyrec,new_rec_name)
              da.linesbyrec.(new_rec_name) = lnsi;
            else
              da.linesbyrec.(new_rec_name) = ...
                unique([da.linesbyrec.(new_rec_name) lnsi]);
            end
            found_new = true;
          else
            new_unassociated(end+1) = lnsi; %#ok<AGROW> 
          end
        end
        if found_new
          da.linesbyrec.unassociated = new_unassociated;
          da.dfs.record_axis(da,rec_name);
        end
      end
    end
    
    function update(da, rec_name)
      % update data for each line of each graph
      if isfield(da.linesbyrec,rec_name) % if we are plotting any data
        dr = da.dfs.records.records.(rec_name);
        [T,V] = dr.time_vector(da.timespan);

        for lnsi = da.linesbyrec.(rec_name)
          if lnsi <= length(da.lines)
            dl = da.lines{lnsi};
            if lnsi <= length(da.lns)
              ln = da.lns{lnsi};
            else
              ln = [];
            end
            D = dl.num_convert(dr.data_vector(dl.var_name,V));
            w = size(D,2);
            if w == 1 || dl.interp == 0
              TI = T - da.dfs.records.max_time;
              DI = D;
            else % doing time interpolation
              h = size(D,1)-1;
              if h > 0
                I = ((1:h*w)-1)/w+1;
                TI = interp1(1:h+1,T,I)-da.dfs.records.max_time;
                DI = reshape(D(2:end,:)',[],1);
              end
            end
            TI = seconds(TI);
            if isempty(ln)
              hold(da.axis,'on');
              da.lns{lnsi} = ...
                plot(da.axis, TI, DI,'DurationTickFormat','mm:ss');
              hold(da.axis,'off');
              set(da.axis,'xlim',seconds([-da.timespan 0]));
              ylabel(da.axis,da.label);
            else
              if length(ln) ~= size(DI,2)
                error('data_line %s ncols %d does not match nlines %d', ...
                  dl.name, size(DI,2), length(ln));
              end
              for lni = 1:length(ln)
                set(ln(lni),'XData',TI,'YData',DI(:,lni));
              end
            end
          end
        end
      end
    end

    function deconstruct(da)
      da.dfs.dereference_axis(da);
      delete(da.axis);
    end

  end
end
