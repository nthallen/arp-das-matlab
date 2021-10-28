classdef data_fields < handle
  % data_fields currently encompasses all the data fields in a project,
  % all assumed to be on the same page. This will need to be augmented
  % to support multiple panes or figures. Possibly a higher-level
  % class to encompass multiple pages.
  %
  % This class will keep track of the position of fields on the figure.
  properties
    fig % The graphics handle of the main figure
    n_figs
    figbgcolor

    % struct containing various options. These can be modified by passing
    % option, value pairs in to the data_fields constructor:
    %       min_y
    %       max_y
    %       min_x
    %       max_x
    %       v_padding % space at top and bottom of column
    %       v_leading % space between rows
    %       h_padding % space between edge and outer columns
    %       h_leading % space between label and text and unit
    %       col_leading % horizontal space between columns
    %       txt_padding
    opts
    cur_x
    cur_y
    records % data_records object

    % fields are indexed like records, i.e.
    % dfs.fields.(rec).vars.(var) will be an array of data_field
    % objects, allowing a variable to appear in more than one
    % location. If a field is created before the variable's record has been
    % identified, it will be placed under
    % dfs.fields.unassociated.vars.(var)
    fields
    % struct mapping var_name to struct with details
    %   rec_name: The record containing the variable
    %   w: The variable width for arrays. Defaults to 0 (undefined)
    %   interp: boolean
    % If a variable reports multiple values in each record, there are two
    % possible interpretations. If interp is false, each value is treated
    % as an independent variable and plotted as multiple lines. If interp
    % is true, the values are treated as multiple readings of the same
    % sensor at a faster rate than the record is reported.
    varinfo
    figbyrec % struct mapping rec_name to graph_figs index

    % cur_col will record fields in the current column
    % We need to keep this until the column is closed, so we can
    % adjust the column widths.
    % cur_col.fields will be a cell array of data_field objects
    % cur_col.n_rows will be a scalar count of elements in fields
    % cur_col.max_lbl_width will be the current maximum label width
    % cur_col.max_txt_width will be the current maximum text width
    cur_col
    graph_figs % cell array of data_fig objects
    dfuicontextmenu % uicontextmenu for data_field lables
    connectmenu % connect menu
    gimenu % The 'Graph in:' submenu
    data_conn % The tcpip connection
  end
  methods
    function dfs = data_fields(varargin)
      dfs.fig = figure;
      set(dfs.fig,'color',[.8 .8 1]);
      dfs.n_figs = 0;
      set(dfs.fig,'units','pixels');
      d = get(dfs.fig,'Position');
      dfs.opts.min_x = 0;
      dfs.opts.max_x = d(3);
      dfs.opts.min_y = d(4);
      dfs.opts.max_y = d(4);
      dfs.opts.v_padding = 10;
      dfs.opts.v_leading = 3;
      dfs.opts.h_padding = 20;
      dfs.opts.h_leading = 0;
      dfs.opts.col_leading = 15;
      dfs.opts.txt_padding = 5;
      dfs.opts.txt_font = 'Courier New';
      dfs.opts.txt_fontsize = 10;
      dfs.data_conn.n = 0;
      dfs.data_conn.t = [];
      dfs.data_conn.connected = 0;
      for i = 1:2:length(varargin)
        fld = varargin{i};
        if isfield(dfs.opts, fld)
          dfs.opts.(fld) = varargin{i+1};
        else
          error('MATLAB:LE:badopt', 'Invalid option: "%s"', fld);
        end
      end
      dfs.cur_x = dfs.opts.min_x + dfs.opts.h_padding;
      dfs.cur_y = dfs.opts.max_y;
      dfs.records = data_records(dfs);
      dfs.figbgcolor = get(dfs.fig,'Color');
      dfs.graph_figs = {};
      dfs.dfuicontextmenu = uicontextmenu(dfs.fig);
      dfs.gimenu = uimenu(dfs.dfuicontextmenu,'Label','Graph in:');
      uimenu(dfs.gimenu,'Label','New figure', ...
        'Callback', { @data_fields.context_callback, "new_fig"}, ...
        'Interruptible', 'off');
      dfs.connectmenu = [];
      set(dfs.fig,'CloseRequestFcn', @dfs.closereq);
    end
    
    function start_col(dfs)
      dfs.cur_col.fields = {};
      dfs.cur_col.groups = {};
      dfs.cur_col.plots = {};
      dfs.cur_col.n_rows = 0;
      dfs.cur_col.max_lbl_width = 0;
      dfs.cur_col.max_txt_width = 0;
      dfs.cur_col.max_grp_width = 0;
      dfs.cur_col.max_plt_width = 0;
      dfs.cur_y = dfs.opts.max_y - dfs.opts.v_padding;
      % dfs.cur_x = dfs.cur_x + dfs.opts.col_leading;
    end
    
    function end_col(dfs)
      % reposition txt fields according to max widths
      % txt fields are all right-justified
      %  cur_x is the left of the lbl field
      %  cur_x + max_lbl_width is the right edge of the lbl col
      %  cur_x + max_lbl_width + h_padding is left edge of txt col
      r_edge = dfs.cur_x + dfs.cur_col.max_lbl_width + ...
        dfs.opts.h_leading + dfs.cur_col.max_txt_width;
      for i=1:length(dfs.cur_col.fields)
        fld = dfs.cur_col.fields{i};
        pos = fld.txt.Position;
        pos(1) = r_edge - pos(3);
        fld.txt.Position = pos;
      end
      % update cur_x to the right edge of righthand fields
      % plus col_leading, so left of new column
      dfs.cur_x = r_edge + dfs.opts.col_leading;
      dfs.cur_col.fields = {};
      dfs.cur_col.groups = {};
      dfs.cur_col.plots = {};
    end

    function rec_name_out = check_recname(dfs, var_name, rec_name)
      if isfield(dfs.varinfo, var_name)
        if nargin >= 3 && ~strcmp(rec_name, dfs.varinfo.(var_name).rec_name)
          warning('Var %s found in rec %s, but field def said %s', ...
            var_name, dfs.varinfo.(var_name).rec_name, rec_name);
        end
        rec_name_out = dfs.varinfo.(var_name).rec_name;
      else
        rec_name_out = 'unassociated';
      end
    end

    function df = field(dfs, var_name, fmt, signed)
      % df = dfs.field(var_name, fmt, signed)
      % rec_name is a sanity check for the moment, then will be eliminated
      % var_name is the variable name
      % fmt is printf format string for the display
      % signed is a boolean, defaults to false
      if nargin < 5
        signed = false;
      end
      rec_name = dfs.check_recname(var_name);
      if ~isfield(dfs.fields, rec_name) || ...
          ~isfield(dfs.fields.(rec_name).vars,var_name)
        dfs.fields.(rec_name).vars.(var_name) = {};
      end
      df_int = data_field(dfs, var_name, fmt, signed);
      dfs.fields.(rec_name).vars.(var_name){end+1} = df_int;
      dfs.cur_col.fields{end+1} = df_int;
      dfs.cur_col.n_rows = dfs.cur_col.n_rows+1;
      if df_int.lbl_width > dfs.cur_col.max_lbl_width
        dfs.cur_col.max_lbl_width = df_int.lbl_width;
      end
      df_int.txt_width = df_int.txt_width + dfs.opts.txt_padding;
      if df_int.txt_width > dfs.cur_col.max_txt_width
        dfs.cur_col.max_txt_width = df_int.txt_width;
      end
      dfs.cur_y = dfs.cur_y - df_int.fld_height;
      df_int.lbl.Position = ...
        [ dfs.cur_x, dfs.cur_y, df_int.lbl_width, df_int.fld_height];
      df_int.txt.Position = ...
        [ dfs.cur_x + df_int.lbl_width + dfs.opts.h_leading, dfs.cur_y, ...
        df_int.txt_width, ...
        df_int.fld_height];
      dfs.cur_y = dfs.cur_y - dfs.opts.v_leading;
      if dfs.cur_y < dfs.opts.min_y
        dfs.opts.min_y = dfs.cur_y;
      end
      if nargout > 0; df = df_int; end
    end
    
    function resize(dfs)
      pos = dfs.fig.Position;
      pos(3) = dfs.cur_x;
      pos(4) = dfs.opts.max_y - dfs.opts.min_y;
      dfs.fig.Position = pos;
      dfs.fig.Resize = 'Off';
      % set(dfs.fig,'Resize','Off');
      c = findobj(dfs.fig,'type','uicontrol')';
      dy = dfs.opts.min_y-dfs.opts.v_padding;
      for ctrl = c
        ctrl.Position(2) = ctrl.Position(2)-dy;
      end
      dfs.opts.max_y = dfs.opts.max_y - dy;
      dfs.opts.min_y = dfs.opts.min_y - dy;
    end
    
    function process_record(dfs,rec_name,str)
      % dfs.process_record(rec_name, str)
      % rec_name is the record name
      % str is the decoded json data
      % str is currently optional, in which case
      % data_records.process_record is not called, but it is not entirely
      % clear when this would be called. I guess it could be called when
      % a graph is created.
      if nargin >= 3
        was_new = dfs.records.process_record(rec_name,str);
        if was_new
          % First update dfs.varinfo with the new record
          if isfield(dfs.records.records,rec_name) % and it better be!
            dr = dfs.records.records.(rec_name);
            vars = fieldnames(dr.data);
            for i=1:length(vars)
              dfs.varinfo.(vars{i}).rec_name = rec_name;
            end
          end
          if isfield(dfs.fields,'unassociated')
            % Go through our unassociated vars in fields and figures and
            % reclassify them if they are now defined
            dr = dfs.records.records.(rec_name);
            vars = fieldnames(dr.data);
            for i=1:length(vars)
              if isfield(dfs.fields.unassociated.vars,vars{i})
                dfs.fields.(rec_name).vars.(vars{i}) = ...
                  dfs.fields.unassociated.vars.(vars{i});
                dfs.fields.unassociated.vars = ...
                  rmfield(dfs.fields.unassociated.vars, vars{i});
                fprintf(1,'Field Var %s associated with rec %s\n', ...
                  vars{i}, rec_name);
              end
            end
          end
          % Now go through figs with unassociated variables
          if isfield(dfs.figbyrec,'unassociated')
            reindex = false;
            figi = dfs.figbyrec.unassociated;
            for i = 1:length(figi)
              dfig = dfs.graph_figs{figi(i)};
              if isfield(dfig.recs,'unassociated')
                vars = fieldnames(dfig.recs.unassociated.vars);
                for j = 1:length(vars)
                  var_name = vars{j};
                  new_rec_name = dfs.check_recname(var_name);
                  if ~strcmp(new_rec_name, 'unassociated')
                    % now move this record from:
                    %   dfig.recs.unassociated.vars.(var_name) to
                    %     dfig.recs.(new_rec_name).vars.(var_name)
                    dfig.recs.(new_rec_name).vars.(var_name) = ...
                      dfig.recs.unassociated.vars.(var_name);
                    dfig.recs.unassociated.vars = ...
                      rmfield(dfig.recs.unassociated.vars, var_name);
                  end
                  fprintf(1,'fig(%d) Var %s associated with rec %s\n', ...
                    i, vars{j}, new_rec_name);
                  reindex = true;
                end
              end
            end
            if reindex; dfs.index_figs; end
          end
        end
      end
      % Now go through fields and update text
      if isfield(dfs.fields,rec_name)
        flds = dfs.fields.(rec_name);
        vars = fieldnames(flds.vars);
        for i=1:length(vars)
          if isfield(str,vars{i})
            fs = flds.vars.(vars{i});
            for j = 1:length(fs)
              set(fs{j}.txt,'String', ...
                fs{j}.txt_convert(str.(vars{i})));
            end
          end
        end
      end
      % Now go through graph_figs
      if nargin >= 3
        if isempty(dfs.figbyrec) || ~isfield(dfs.figbyrec,rec_name)
          fn = [];
        else
          fn = dfs.figbyrec.(rec_name);
        end
      else
        fn = 1:length(dfs.graph_figs);
      end
      for i=fn
        dfs.graph_figs{i}.update(rec_name);
      end
    end
    
    function dfig = new_graph_fig(dfs)
      dfs.n_figs = dfs.n_figs+1;
      dfig = data_fig(dfs, dfs.n_figs);
    end
    
    function index_figs(dfs)
      % dfs.index_figs;
      % Looks through graph_figs, and maps rec_name to figs,
      % updating figsbyrec.
      fbr = [];
      for i = 1:length(dfs.graph_figs)
        dfig = dfs.graph_figs{i};
        if ~isempty(dfig.recs)
          recs = fieldnames(dfig.recs);
          for j = 1:length(recs)
            rec_name = recs{j};
            if isempty(fbr) || ~isfield(fbr, rec_name)
              fbr.(rec_name) = i;
            else
              fbr.(rec_name) = unique([fbr.(rec_name) i]);
            end
          end
        end
      end
      dfs.figbyrec = fbr;
    end
    
    function fignum = new_graph(dfs, var_name, mode, fignum, axisnum)
      % fignum = dfs.new_graph(rec_name, var_name, mode, fign, axisnum)
      % rec_name is the variables record. Currently a placeholder
      % var_name is the variable name
      % mode is one of 'new_fig', 'cur_axes' or 'new_axes'
      % fign is the fignum previously returned by new_graph(...,'new_fig').
      %   Required except for mode 'new_fig'
      % axisnum is the axis number within an existing figure.
      %   Required for mode 'cur_axes'
      % fignum is the figure number (index into dfs.graph_figs)
      
      if mode == "new_fig"
        dfig = dfs.new_graph_fig();
        axisnum = 0;
      else
        dfig = dfs.graph_figs{fignum};
        if mode ~= "cur_axes"
          axisnum = 0;
        end
      end
      rec_name = dfs.check_recname(var_name);
      dfig.new_graph(rec_name, var_name, mode, axisnum);
      fignum = dfig.fignum;
      if mode == "new_fig"
        dfs.graph_figs{dfig.fignum} = dfig;
      end
      dfs.index_figs;
    end
    
    function m = add_menu(dfs, title)
      m = uimenu(dfs.fig,'Text',title);
      set(dfs.fig,'Interruptible','on');
    end
    
    function add_userdata(dfs, datum)
      set(dfs.fig,'userdata',datum);
    end
    
    function datum = get_userdata(dfs)
      datum = get(dfs.fig,'userdata');
    end
    
    function set_interp(dfs, var_name, val)
      dfs.varinfo.(var_name).interp = val;
    end
    
    function set_connection(dfs, hostname, port)
      % dfs.set_connection(hostname, port)
      % Establishes the 'Connect' menu.
      if isempty(dfs.connectmenu)
        m = uimenu(dfs.fig,'Text','DFS');
        dfs.connectmenu = uimenu(m, 'Text', 'Connect', ...
          'Callback', @(s,e)do_connect(dfs,s,e,hostname,port), ...
          'Interruptible', 'off');
      end
    end
    
    function connect(dfs, hostname, hostport)
      % dfs.connect(hostname, hostport)
      % Internal function. Connection details should be
      % established with dfs.set_connection() with the
      % connect/disconnect logic handled by dfs.do_connect()
      if dfs.data_conn.connected == 1
        return;
      end
      dfs.data_conn.n = 0;
      dfs.data_conn.t = tcpip(hostname, hostport, 'Terminator', '}', ...
        'InputBufferSize', 65536);
      dfs.data_conn.t.BytesAvailableFcn = @dfs.BytesAvFcn;
      dfs.data_conn.t.BytesAvailableFcnMode = 'terminator';
      fopen(dfs.data_conn.t);
      dfs.data_conn.connected = 1;
    end
    
    function do_connect(dfs, ~, ~, hostname, port)
      % dfs.do_connect(~,~,hostname,port)
      % Handles connect/disconnect logic for Connect
      % menu.
      if nargin < 5
        if isempty(dfs.connectmenu)
          error('do_connect() before set_connection()');
        end
        feval(get(dfs.connectmenu,'Callback'),[],[]);
      else
        if dfs.data_conn.connected
          dfs.disconnect();
        else
          dfs.connect(hostname, port);
        end
        if dfs.data_conn.connected
          dfs.connectmenu.Checked = 'On';
        else
          dfs.connectmenu.Checked = 'Off';
        end
      end
    end
    
    % BytesAvFcn(dfs, src, eventdata)
    function BytesAvFcn(dfs,~,~)
      if dfs.data_conn.connected == 0
        return;
      end
      s = fgets(dfs.data_conn.t);
      if isempty(s)
        dfs.data_conn.connected = 0;
      else
        dp = loadjson(s);
        dfs.data_conn.n = dfs.data_conn.n+1;
        if isfield(dp,'Record')
          rec = dp.Record;
          dp = rmfield(dp, 'Record');
          dfs.process_record(rec, dp);
        end
      end
    end
    
    function disconnect(dfs)
      if dfs.data_conn.connected == 0
        return;
      end
      dfs.data_conn.connected = 0;
      fclose(dfs.data_conn.t);
      delete(dfs.data_conn.t);
      dfs.data_conn.t = [];
    end
    
    function closereq(dfs,~,~)
      % close each of the graph_figs
      if dfs.data_conn.connected
        dfs.disconnect();
      end
      for i = 1:length(dfs.graph_figs)
        df = dfs.graph_figs{i};
        if ~isempty(df.fig)
          close(df.fig);
        end
      end
      delete(dfs.fig);
      dfs.fig = [];
    end
  end
  methods(Static)
    function context_callback(~,~, mode, fignum, axisnum)
      % lbl is the variable's label. The data_field object
      %   should be the label's userdata
      % mode is one of:
      %   'new_fig' - create graph in new figure
      %   'new_axes' - create graph in new axis in figure # fn
      %   'cur_axes' - create graph in existing axis # an in figure # fn
      if mode == "new_fig"
        fignum = 0;
        axisnum = 0;
      elseif mode == "new_axes"
        axisnum = 0;
      end
      lbl = gco;
      df = get(lbl,'userdata');
      % rec_name = df.rec_name;
      var_name = df.var_name;
      dfs = df.flds;
      dfs.new_graph(var_name, mode, fignum, axisnum);
    end
  end
end
