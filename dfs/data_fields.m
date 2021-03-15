classdef data_fields < handle
  % data_fields currently encompasses all the data fields in a project,
  % all assumed to be on the same page. This will need to be augmented
  % to support multiple panes or figures. Possibly a higher-level
  % class to encompass multiple pages.
  %
  % This class will keep track of the position of fields on the figure.
  properties
    fig
    n_figs
    figbgcolor
    opts
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
    cur_x
    cur_y
    records % data_records object
    fields
    % fields will be indexed like records, i.e.
    % obj.fields.(rec).vars.(var) will be an array of data_field
    % objects, allowing a variable to appear in more than one
    % location
    cur_col
    % cur_col will record fields in the current column
    % We need to keep this until the column is closed, so we can
    % adjust the column widths.
    % cur_col.fields will be a cell array of data_field objects
    % cur_col.n_rows will be a scalar count of elements in fields
    % cur_col.max_lbl_width will be the current maximum label width
    % cur_col.max_txt_width will be the current maximum text width
    graph_figs % cell array of data_fig objects
    dfuicontextmenu % uicontextmenu for data_field lables
    connectmenu % connect menu
    gimenu % The 'Graph in:' submenu
    data_conn % The tcpip connection
  end
  methods
    function dfs = data_fields(fig_in, varargin)
      dfs.fig = fig_in;
      dfs.n_figs = 0;
      % verify that fig is an object
      % record dimensions
      set(dfs.fig,'units','pixels');
      d = get(dfs.fig,'Position');
      dfs.opts.min_x = 0;
      dfs.opts.max_x = d(3);
      dfs.opts.min_y = 0;
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
      dfs.records = data_records();
      dfs.figbgcolor = get(dfs.fig,'Color');
      dfs.graph_figs = {};
      dfs.dfuicontextmenu = uicontextmenu(fig_in);
      dfs.gimenu = uimenu(dfs.dfuicontextmenu,'Label','Graph in:');
      uimenu(dfs.gimenu,'Label','New figure', ...
        'Callback', { @data_fields.context_callback, "new_fig"}, ...
        'Interruptible', 'off');
      dfs.connectmenu = [];
    end
    
    function start_col(dfs)
      dfs.cur_col.fields = {};
      dfs.cur_col.n_rows = 0;
      dfs.cur_col.max_lbl_width = 0;
      dfs.cur_col.max_txt_width = 0;
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
    end
    
    function df = field(dfs, rec_name, var_name, fmt, signed)
      if nargin < 5
        signed = false;
      end
      dfs.records.add_record(rec_name);
      if ~isfield(dfs.fields, rec_name) || ...
          ~isfield(dfs.fields.(rec_name).vars,var_name)
        dfs.fields.(rec_name).vars.(var_name) = {};
      end
      df_int = data_field(dfs, rec_name, var_name, fmt, signed);
      dfs.fields.(rec_name).vars.(var_name){end+1} = df_int;
      if dfs.cur_y - df_int.fld_height < dfs.opts.min_y + dfs.opts.v_padding
        dfs.end_col();
        dfs.start_col();
        % we assume one row will always fit
      end
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
      if nargout > 0; df = df_int; end
    end
    
    function set_connection(dfs, hostname, port)
      if isempty(dfs.connectmenu)
        dfs.connectmenu = uimenu(dfs.fig, 'Text', 'Connect', ...
          'Callback', @(s,e)do_connect(dfs,s,e,hostname,port), ...
          'Interruptible', 'off');
      end
    end
    
    function process_record(dfs,rec_name,str)
      if nargin >= 3
        dfs.records.process_record(rec_name,str);
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
        for i=1:length(dfs.graph_figs)
          dfs.graph_figs{i}.update(rec_name);
        end
      end
    end
    function dfig = new_graph_fig(dfs)
      dfs.n_figs = dfs.n_figs+1;
      dfig = data_fig(dfs, dfs.n_figs);
    end
    function new_graph(dfs, rec_name, var_name, mode, fignum, axisnum)
      dfs.records.add_record(rec_name);
      if mode == "new_fig"
        dfig = dfs.new_graph_fig();
        axisnum = 0;
      else
        dfig = dfs.graph_figs{fignum};
        if mode ~= "cur_axes"
          axisnum = 0;
        end
      end
      dfig.new_graph(rec_name, var_name, mode, axisnum);
      if mode == "new_fig"
        dfs.graph_figs{dfig.fignum} = dfig;
      end
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
    function set_interp(dfs, recname, datum, val)
      dr = dfs.records.records.(recname);
      dr.datainfo.(datum).interp = val;
    end
    
    function connect(dfs, hostname, hostport)
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
    
    function do_connect(dfs, ~, ~, hostname, port)
      if dfs.data_conn.connected
        dfs.disconnect();
      else
        dfs.connect(hostname, port);
      end
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
      rec_name = df.rec_name;
      var_name = df.var_name;
      dfs = df.flds;
      dfs.new_graph(rec_name, var_name, mode, fignum, axisnum);
    end
  end
end
