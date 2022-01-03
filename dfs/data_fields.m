classdef data_fields < handle
  % data_fields currently encompasses all the data fields in a project,
  % all assumed to be on the same page. This will need to be augmented
  % to support multiple panes or figures. Possibly a higher-level
  % class to encompass multiple pages.
  %
  % This class will keep track of the position of fields on the figure.
  properties
    fig % The graphics handle of the main uifigure
    context % ctx stack
    % ctx (struct with parent, tab_group, Row, Column)
    ctx % current context
    n_figs % Number of data_figs

    % struct containing various options. These can be modified by passing
    % option, value pairs in to the data_fields constructor:
    %       v_padding % space at top and bottom of column
    %       v_leading % space between rows
    %       h_padding % space between edge and outer columns
    %       h_leading % space between label and text and unit
    %       title
    %       grid_cols_per_col
    %       Color
    opts
    records % data_records object

    % fields are indexed like records, i.e.
    % dfs.fields.(rec_name).vars.(var_name) will be an array of data_field
    % objects, allowing a variable to appear in more than one
    % location. If a field is created before the variable's record has been
    % identified, it will be placed under
    % dfs.fields.unassociated.vars.(var_name)
    % Note convention that var_name refers to the TM variable name as it
    % appears in the json record rec_name. The field 'name' may be
    % different.
    fields
    % struct mapping var_name to struct with details
    %   rec_name: The record containing the variable
    %   w: The variable width for arrays. Defaults to 0 (undefined)
    % If a variable reports multiple values in each record, there are two
    % possible interpretations. If interp is false, each value is treated
    % as an independent variable and plotted as multiple lines. If interp
    % is true, the values are treated as multiple readings of the same
    % sensor at a faster rate than the record is reported.
    varinfo
    figbyrec % struct mapping rec_name to graph_figs index
    graph_figs % cell array of data_fig objects
    line_defs % map data_line.name to data_line objects
    plot_defs % map plot IDs to data_plot objects

    axbyrec % map rec_name to array of axes indices
    axes % cell array of data_axis objects

    dfuicontextmenu % uicontextmenu for data_field lables
    connectmenu % connect menu
    gimenu % The 'Graph in:' submenu
    data_conn % The tcpip connection
  end
  methods
    function dfs = data_fields(varargin)
      dfs.opts.v_padding = 10;
      dfs.opts.v_leading = 3;
      dfs.opts.h_padding = 20;
      dfs.opts.h_leading = 5;
      dfs.opts.txt_font = 'Courier New';
      dfs.opts.txt_fontsize = 10;
      dfs.opts.btn_font = 'Arial';
      dfs.opts.btn_fontsize = 12;
      dfs.opts.title = '';
      dfs.opts.grid_cols_per_col = 3;
      dfs.opts.Color = [];

      dfs.data_conn.n = 0;
      dfs.data_conn.t = [];
      dfs.data_conn.connected = 0;
      dfs.set_opts(varargin{:});

      dfs.fig = uifigure('WindowStyle','normal','Resize','off');
      dfs.fig.Units = 'pixels';
      if isempty(dfs.opts.Color)
        dfs.opts.Color = dfs.fig.Color;
      else
        dfs.fig.Color = dfs.opts.Color;
      end

      dfs.context.level = 1;
      dfs.context.stack = struct('parent',dfs.fig,'tabgroup',[], ...
        'Row',[],'Column',[],'layoutready',false);
      dfs.ctx = dfs.context.stack;

      dfs.n_figs = 0;
      dfs.records = data_records(dfs);
      dfs.graph_figs = {};
      dfs.plot_defs = [];

      dfs.axbyrec.unassociated = [];
      dfs.axes = {};

      dfs.dfuicontextmenu = uicontextmenu(dfs.fig);
      dfs.gimenu = uimenu(dfs.dfuicontextmenu,'Label','Graph in:');
      uimenu(dfs.gimenu,'Label','New figure', ...
        'Callback', { @data_fields.context_callback, "new_fig"}, ...
        'Interruptible', 'off');
      dfs.connectmenu = [];
      dfs.fig.CloseRequestFcn = @dfs.closereq;
    end

    function set_opts(dfs, varargin)
      for i = 1:2:length(varargin)
        fld = varargin{i};
        if isfield(dfs.opts, fld)
          dfs.opts.(fld) = varargin{i+1};
        else
          error('MATLAB:LE:badopt', 'Invalid option: "%s"', fld);
        end
      end
    end

    function push_context(dfs, parent, tabgroup, Row, Column, layoutready)
      % context defines where new ui objects should be inserted.
      % data_plot and data_field objects should only be inserted in
      % layoutready contexts. layoutready is established in start_col().
      if nargin < 6
        layoutready = false;
        if nargin < 5
          Column = [];
          if nargin < 4
            Row = [];
            if nargin < 3
              tabgroup = [];
            end
          end
        end
      end
      dfs.ctx.parent = parent;
      dfs.ctx.tabgroup = tabgroup;
      dfs.ctx.Row = Row;
      dfs.ctx.Column = Column;
      dfs.ctx.layoutready = layoutready;
      dfs.context.level = dfs.context.level+1;
      dfs.context.stack(dfs.context.level) = dfs.ctx;
    end

    function pop_context(dfs, lvl)
      if nargin < 2
        lvl = dfs.context.level - 1;
      end
      if lvl > 0 &&  lvl < dfs.context.level
        dfs.context.level = lvl;
        dfs.ctx = dfs.context.stack(dfs.context.level);
      end
    end
    
    function ctx_lvl = rt_init(dfs)
      ctx_lvl = dfs.context.level;
      gl = uigridlayout(dfs.ctx.parent,[3,1], ...
        'BackgroundColor', dfs.opts.Color);
      if ~isempty(gl.Layout)
        gl.Layout.Row = dfs.ctx.Row;
        gl.Layout.Column = dfs.ctx.Column;
      end
      ttl = uilabel(gl,'Text',dfs.opts.title, ...
        'HorizontalAlignment','center', ...
        'FontWeight','bold');
      ttl.Layout.Row = 1;
      ttl.Layout.Column = 1;

      gl3 = uigridlayout(gl,[1,3], ...
        'BackgroundColor', dfs.opts.Color);
      gl3.Layout.Row = 3; gl3.Layout.Column = 1;
      h = uibutton(gl3,'Text','Graph Selected', ...
           'ButtonPushedFcn',@(~,~)graph_selected(dfs));
      h.Layout.Row = 1; h.Layout.Column = 2;
      gl3.RowHeight{1} = 'fit';
      gl3.ColumnWidth{1} = '1x';
      gl3.ColumnWidth{2} = 'fit';
      gl3.ColumnWidth{3} = '1x';
      gl3.UserData.LayoutSet = true;
      for i=1:3; gl.RowHeight{i} = 'fit'; end
      gl.ColumnWidth{1} = 'fit';
      gl.UserData.LayoutSet = true;

      dfs.push_context(gl,[], 2,1);
    end

    function start_tab(dfs,name)
      cntx = dfs.ctx;
      if isempty(cntx.tabgroup)
        tabgroup = uitabgroup(cntx.parent);
        if ~isempty(tabgroup.Layout)
          tabgroup.Layout.Row = cntx.Row;
          tabgroup.Layout.Column = cntx.Column;
        end
        dfs.push_context(tabgroup,tabgroup);
      else
        tabgroup = cntx.tabgroup;
      end
      tab = uitab(tabgroup,'Title',name);
      dfs.push_context(tab);
    end

    function end_tab(dfs)
      % dfs.end_tab
      % Pops the context until at the tabgroup level
      while isempty(dfs.ctx.tabgroup)
        dfs.pop_context;
      end
    end

    function start_col(dfs)
      cntx = dfs.ctx;
      if cntx.layoutready
        dfs.ctx.Row = 1;
        dfs.ctx.Column = cntx.Column + dfs.opts.grid_cols_per_col;
      else
        gl = uigridlayout(cntx.parent,[1,1], ...
          'BackgroundColor', dfs.opts.Color, ...
          'ColumnSpacing', dfs.opts.h_leading, ...
          'RowSpacing', dfs.opts.v_leading ...
          );
        gl.UserData.LayoutSet = false;
        dfs.push_context(gl,[],1,0,true);
        if ~isempty(cntx.Row) && ~isempty(cntx.Column)
          gl.Layout.Row = cntx.Row;
          gl.Layout.Column = cntx.Column;
        end
      end
    end
    
    function end_col(dfs)
      % dfs.end_col
      % Clears the current context Row to indicate we are outside any
      % column.
      dfs.ctx.Row = [];
    end

    function rec_name_out = check_recname(dfs, var_name, rec_name)
      if isfield(dfs.varinfo, var_name)
        rec_name_out = dfs.varinfo.(var_name).rec_name;
        if nargin >= 3 && ...
            ~strcmp(rec_name,'unassociated') && ...
            ~strcmp(rec_name, rec_name_out)
          warning('Var %s found in rec %s, but field def said %s', ...
            var_name, rec_name_out, rec_name);
        end
      else
        rec_name_out = 'unassociated';
      end
    end

    function df = field(dfs, var_name, fmt, varargin)
      % df = dfs.field(var_name, fmt, ...)
      % var_name is the variable name
      % fmt is printf format string for the display
      % option/value pairs can follow for:
      %  label: default is var_name
      %  units: no default
      df_int = data_field(dfs, var_name, fmt, varargin{:});
      dfs.ctx.Row = dfs.ctx.Row+1;
      if nargout > 0; df = df_int; end
    end

    function dl_out = data_line(dfs,varargin)
      % dl = dfs.data_line(name);
      % dl = dfs.data_line('name', name ...);
      % Creates a new data_line object or augments an existing one.
      % Updates dfs.line_defs to point to the new object
      if length(varargin)==1 && iscell(varargin{1})
        varargin = varargin{1};
      end
      switch length(varargin)
        case 0
          error('dfs.data_line() requires arguments');
        case 1
          name = varargin{1};
          varargin = {'name',name};
        otherwise
          if strcmp(varargin{1},'name')
            name = varargin{2};
          else
            error('dfs.data_line() expected ''name'' as first argument');
          end
      end
      if isfield(dfs.line_defs,name)
        dl = dfs.line_defs.(name);
        dl.update(varargin{:});
      else
        dl = data_line(varargin{:});
        dfs.line_defs.(name) = dl;
      end
      if nargout > 0
        dl_out = dl;
      end
    end

    function plot(dfs,ID,varargin)
      plt = data_plot(ID,dfs,varargin{:});
      dfs.plot_defs.(ID) = plt;
      if ~isempty(plt.opts.label)
        cntx = dfs.ctx;
        % make a pushbutton to invoke the group or plot
        callback = @(~,~)show_plot(dfs,ID);
        h = uibutton(cntx.parent, 'Text', plt.opts.label, ...
          'ButtonPushedFcn', callback, ...
          'HorizontalAlignment', 'left', ...
          'Interruptible', 'off', ...
          'FontName', dfs.opts.btn_font, ...
          'FontSize', dfs.opts.btn_fontsize);
        h.Layout.Row = cntx.Row;
        gcpc = dfs.opts.grid_cols_per_col;
        if plt.isgroup
          h.Layout.Column = cntx.Column + [1,gcpc];
        else
          if gcpc > 2
            pcol = [2,gcpc];
          else
            pcol = 2;
          end
          h.Layout.Column = cntx.Column + pcol;
          cb = uicheckbox(cntx.parent, 'Text', '', 'Tag', ID, 'Value', 0);
          cb.Layout.Row = cntx.Row;
          cb.Layout.Column = cntx.Column + 1;
        end
        dfs.ctx.Row = dfs.ctx.Row + 1;
      end
    end

    function [fignum, axnum] = show_plot(dfs,ID,fign_in)
      % dfig = dfs.show_plot(ID[, dfin])
      % Displays the specified plot or group in a new data_fig.
      % dfs is a data_fields object
      % ID is the unique string identify the previously defined data_plot
      %   object.
      % fign_in is for internal use only (for adding another
      %   pane to an existing data_fig in a group)
      % fignum is the index of the newly created data_fig object (or the
      %   one passed in)
      % fprintf(1,'show_plot(%s)\n', ID);
      plt = dfs.plot_defs.(ID);
      if plt.isgroup
        if nargin >= 4
          warning('Cannot include a group (%s) in a group',ID);
          return;
        end
        plots = plt.opts.plots;
        if isempty(plots); return; end
        [fignum,axnum] = dfs.show_plot(plots{1});
        for i=2:length(plots)
          dfs.show_plot(plots{i},fignum);
        end
      else
        if isempty(plt.lines); return; end
        if nargin >= 3
          [fignum,axnum] = dfs.new_graph(plt.lines{1},'new_axes',fign_in);
        else
          [fignum,axnum] = dfs.new_graph(plt.lines{1},'new_fig');
        end
        for i = 2:length(plt.lines)
          dfs.new_graph(plt.lines{i},'cur_axes',fignum,axnum);
        end
        df = dfs.graph_figs{fignum};
        da = df.axes{axnum};
        if length(da.lines) ~= length(plt.lines)
          fprintf(1,'data_axis has %d data_lines, plt has %d\n', ...
            length(da.lines), length(plt.lines));
        end
        if length(da.lns) ~= length(plt.lines)
          fprintf(1,'data_axis has %d lines, plt has %d\n', ...
            length(da.lns), length(plt.lines));
        end
        if length(da.axis.Children) ~= length(plt.lines)
          fprintf(1,'axis has %d lines, plt has %d\n', ...
            length(da.axis.Children), length(plt.lines));
        end
      end
      % fprintf(1,'show_plot(%s) return\n', ID);
    end

    function graph_selected(dfs)
      % fprintf(1,'graph_selected()\n');
      h = findobj(dfs.fig,'Type','uicheckbox','value', 1);
      plots = {h.Tag};
      if isempty(plots); return; end
      fignum = dfs.show_plot(plots{1});
      for i=2:length(plots)
        dfs.show_plot(plots{i},fignum);
      end
    end

    function resize(dfs, lvl)
      if nargin < 2
        lvl = 1;
      end
      dfs.pop_context(lvl);
      gls = findobj(dfs.fig,'Type','uigridlayout');
      for igls=1:length(gls)
        w = gls(igls);
        if ~isfield(w.UserData,'LayoutSet') || ~w.UserData.LayoutSet
          for i=1:length(w.RowHeight); w.RowHeight{i} = 'fit'; end
          for i=1:length(w.ColumnWidth); w.ColumnWidth{i} = 'fit'; end
          w.UserData.LayoutSet = true;
        end
      end
      dfs.resize_widget(dfs.fig);
    end
    
    function record_axis(dfs, da, rec_name)
      % record the data_axis object and note [one of] the record(s)
      % it is associated with.
      if isempty(da.axis_index)
        dfs.axes{end+1} = da;
        da.axis_index = length(dfs.axes);
      elseif ~strcmp(rec_name,'unassociated')
        dfs.axbyrec.unassociated = ...
          setdiff(dfs.axbyrec.unassociated, da.axis_index);
      end
      if isfield(dfs.axbyrec,rec_name)
        dfs.axbyrec.(rec_name) = ...
          unique([dfs.axbyrec.(rec_name) da.axis_index]);
      else
        dfs.axbyrec.(rec_name) = da.axis_index;
      end
    end

    function dereference_axis(dfs, da)
      if ~isempty(da.linesbyrec) && ~isempty(da.axis_index)
        recs = fieldnames(da.linesbyrec);
        for i=1:length(recs)
          rec_name = recs{i};
          if isfield(dfs.axbyrec,rec_name)
            dfs.axbyrec.(rec_name) = ...
              setdiff(dfs.axbyrec.(rec_name),da.axis_index);
          end
        end
        dfs.axes{da.axis_index} = [];
        da.axis_index = [];
      end
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
%                 fprintf(1,'Field Var %s associated with rec %s\n', ...
%                   vars{i}, rec_name);
              end
            end
          end
          % Now go through axes with unassociated variables
          if isfield(dfs.axbyrec,'unassociated')
            axi_s = dfs.axbyrec.unassociated;
            for i = axi_s
              da = dfs.axes{i};
              if ~isempty(da)
                da.new_record(rec_name);
              end
            end
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
              set(fs{j}.txt,'Text', ...
                fs{j}.dl.txt_convert(str.(vars{i})));
            end
          end
        end
      end
      % Now go through graph_figs
      if isfield(dfs.axbyrec,rec_name)
        for axn = dfs.axbyrec.(rec_name)
          if ~dfs.axes{axn}.updating
            dfs.axes{axn}.update(rec_name)
          end
        end
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
        if ~isempty(dfig) && ~isempty(dfig.recs)
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
    
    function [fignum, axnum] = new_graph(dfs, dl, mode, fignum, axisnum)
      % [fignum, axnum] = dfs.new_graph(dl, mode, fign, axisnum)
      % dl is the data_line object
      % mode is one of 'new_fig', 'cur_axes' or 'new_axes'
      % fign is the fignum previously returned by new_graph(...,'new_fig').
      %   Required except for mode 'new_fig'
      % axisnum is the axis number within an existing figure.
      %   Required for mode 'cur_axes'
      % fignum is the figure number (index into dfs.graph_figs)
      % axnum is the axis number (index into df.axes)
      
      if mode == "new_fig"
        dfig = dfs.new_graph_fig();
        axisnum = 0;
      else
        dfig = dfs.graph_figs{fignum};
        if mode ~= "cur_axes"
          axisnum = 0;
        end
      end
      dl.rec_name = dfs.check_recname(dl.var_name, dl.rec_name);
      axisnum = dfig.new_graph(dl.rec_name, dl, mode, axisnum);
      fignum = dfig.fignum;
      if mode == "new_fig"
        dfs.graph_figs{dfig.fignum} = dfig;
      end
      dfs.index_figs;
      if nargout > 1
        axnum = axisnum;
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
    
%     function set_interp(dfs, var_name, val)
%       dfs.varinfo.(var_name).interp = val;
%     end
    
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
    
    function BytesAvFcn(dfs,~,~)
      % BytesAvFcn(dfs, src, eventdata)
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
        dfig = dfs.graph_figs{i};
        if ~isempty(dfig) && ~isempty(dfig.fig)
          close(dfig.fig);
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
      cbfig = gcbf;
      field = cbfig.CurrentObject;
      df = field.UserData;
      % rec_name = df.rec_name;
      % var_name = df.dl.name;
      dfs = df.dfs;
      dfs.new_graph(df.dl, mode, fignum, axisnum);
    end

    function [P,resized_out] = resize_widget(w,resized)
      % [P,resized_out] = resize_widget(w,resized)
      % w is the widget
      % resized is a boolean indicating whether any sibling widgets
      % have been resized on this pass.
      % resized_out is set to true if resized was true or w has been resized.
      %
      % Returns the actual extents of the widget in the standard
      % [x y dx dy] format. For uigridlayout (and possibly other containers), we
      % will instead return [NaN NaN dx dy], i.e. only the size. x and y usually
      % represent the offset of a widget within the enclosing container, but for
      % uigridlayout widgets, we do not get that information, and may have to
      % construct it by other means.
      %
      % For simple containers, it will be the max extent of
      % all the contained widgets. Some container widgets however do not
      % support Position, or the Position may be unrelated to the included
      % widgets, so special care is needed.
      %
      % uigridlayout:
      %   The Position of widgets inside a uigridlayout are relative to
      %   the uigridlayout. The max extent of these is a lower bound for
      %   the max extent of the uigridlayout.
      %
      %   If another uigridlayout is nested inside, the max extent of doubly
      %   nested widgets will be the max extent within the nested uigridlayout,
      %   so will be <= the widgets max extent within the outer uigridlayout. If
      %   we know the grid row and/or column Position based on other widgets in
      %   adjacent rows or columns, then we can determine the max extent. If not,
      %   we should be able to determine the row/column Position by adding up the
      %   the max extents of other cells and row/column spacing.
      %
      %   Our concept is to in fact nest uigridlayouts freely to achieve a
      %   desired layout, so this is a realistic problem.
      if nargin < 2
        resized = false;
      end
      switch w.Type
        case {'uigridlayout'}
          uigrid_working = true;
          uigrid_resized = false;
%           if ~isfield(w.UserData,'LayoutSet') || ~w.UserData.LayoutSet
%             for i=1:length(w.RowHeight); w.RowHeight{i} = 'fit'; end
%             for i=1:length(w.ColumnWidth); w.ColumnWidth{i} = 'fit'; end
%             w.UserData.LayoutSet = true;
%           end
          while uigrid_working
            drawnow;
            drawnow;
            uigrid_working = false;
            P = [NaN NaN 0 0];
            rowY = zeros(length(w.RowHeight)+1,1);
            rowheight = zeros(length(w.RowHeight)+1,1);
            rowY(end) = w.RowSpacing;
            colX = zeros(length(w.ColumnWidth)+1,1);
            colwidth = zeros(length(w.ColumnWidth)+1,1);
            colX(1) = w.ColumnSpacing; % Padding w.Padding(1)
            ch = w.Children;
            for i=1:length(ch)
              % indexes into rowY and rowheight are offset by 1, so
              % rowY(2) is the Y offset of row 1, the top row of the grid.
              row = ch(i).Layout.Row;
              row_m = min(row)+1;
              row_M = max(row)+1;
              col = ch(i).Layout.Column;
              col_m = min(col);
              col_M = max(col);
              [Pi,uigrid_resized] = ...
                data_fields.resize_widget(ch(i),uigrid_resized);
              % If we have full position, update P directly
              if ~any(isnan(Pi))
                P(3:4) = max(P(3:4),Pi(1:2)+Pi(3:4));
                colX(col_m) = max(colX(col_m),Pi(1));
                rowY(row_M) = max(rowY(row_M),Pi(2));
              end
              if isscalar(col)
                colwidth(col) = max(colwidth(col),Pi(3));
              end
              % Padding: don't calc colX here, just width
              colX(col_M+1) = max(colX(col_M+1), ...
                colX(col_m)+Pi(3)+w.ColumnSpacing);
              if isscalar(row)
                rowheight(row_m) = max(rowheight(row_m),Pi(4));
              end
              rowY(row_m-1) = max(rowY(row_m-1), ...
                rowY(row_M)+Pi(4)+w.RowSpacing);
              if uigrid_resized
                resized = true;
              else
                uigrid_working = false;
              end
            end
          end
          for i=(length(rowY)-1):-1:1
            rowY(i) = max(rowY(i),rowY(i+1)+rowheight(i+1)+w.RowSpacing);
          end
          P(4) = max(P(4),rowY(1));
          % Padding: use ColumnSpacing for 
          for i=2:length(colX)
            colX(i) = max(colX(i),colX(i-1)+colwidth(i-1)+w.ColumnSpacing);
          end
          P(3) = max(P(3),colX(end));
        case {'uitabgroup','uitab','uipanel','figure'}
          % determine size of children
          P = [];
          for i=1:length(w.Children)
            [Pi,resized] = data_fields.resize_widget(w.Children(i),resized);
            if isempty(Pi); continue; end
            if any(isnan(Pi(1:2)))
              assert(w.Children(i).Type == "uigridlayout");
              % uigridlayout fills its parent completely, so
              % position relative to parent is [1 1].
              Pi(1:2) = [1 1];
            end
            if isempty(P)
              P = Pi;
            else
              if Pi(1) < P(1)
                P(3) = P(3) + P(1) - Pi(1);
              end
              if Pi(2) < P(2)
                P(4) = P(4) + P(2) - Pi(2);
              end
              Pe = P(1:2)+P(3:4);
              Pie = Pi(1:2)+Pi(3:4);
              if Pie(1) > Pe(1)
                P(3) = Pie(1)-P(1);
              end
              if Pie(2) > Pe(2)
                P(4) = Pie(2) - P(2);
              end
            end
          end
          if isempty(P); P = [1 1 0 0]; end
          switch w.Type
            case 'uitabgroup'
              % Correct for tab heading, border
              if ~isempty(w.Children)
                P(3:4) = P(3:4) + w.Position(3:4) - w.Children(1).Position(3:4);
              end
            case 'uipanel'
              P(3:4) = P(3:4) + w.OuterPosition(3:4) - w.InnerPosition(3:4);
            case 'figure'
              P(1:2) = w.Position(1:2);
          end
          if w.Type ~= "uitabgroup" && w.Type ~= "uitab" ...
              && any(w.Position(3:4) ~= P(3:4))
            w.Position(3:4) = P(3:4);
            resized = true;
            if w.Type == "figure"
              movegui(w);
            end
          end
        case {'uicontextmenu','uimenu'}
          P = [];
        otherwise
          try
            P = w.Position;
          catch
            fprintf(1,'Could not read Position of type %s\n',w.Type);
            P = [0 0 0 0];
          end
      end
%       tag = w.Tag;
%       if isempty(tag)
%         tag = sprintf('Untagged %s',w.Type);
%       end
      % fprintf(1,'Pos of %s is [ %d %d %d %d]\n', tag, P);
      if nargout > 1
        resized_out = resized;
      end
    end
  end
end
