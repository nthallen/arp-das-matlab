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
    % %     col_leading % horizontal space between columns
    % %     txt_padding
    %       title
    %       grid_cols_per_col
    %       Color
    opts
%     cur_x
%     min_x
%     max_x
%     cur_y
%     min_y
%     max_y
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
    % cur_col.groups will be a cell array of 
    % cur_col.btns
    % cur_col.n_rows will be a scalar count of elements in fields
    % cur_col.max_lbl_width will be the current maximum label width
    % cur_col.max_txt_width will be the current maximum text width
    % cur_col.max_btn_x is the rightmost extent of all buttons
    % replace above with:
    %   ctx (struct with parent, tab_group, Row, Column)
    % cur_col
    graph_figs % cell array of data_fig objects
    plot_defs % map plot IDs to data_plot objects
    dfuicontextmenu % uicontextmenu for data_field lables
    connectmenu % connect menu
    gimenu % The 'Graph in:' submenu
    data_conn % The tcpip connection
  end
  methods
    function dfs = data_fields(varargin)
%     d = get(dfs.fig,'Position');
%       dfs.min_x = 0;
%       dfs.max_x = 400;
%       dfs.min_y = d(4);
%       dfs.max_y = d(4);
      dfs.opts.v_padding = 10;
      dfs.opts.v_leading = 3;
      dfs.opts.h_padding = 20;
      dfs.opts.h_leading = 5;
      % dfs.opts.col_leading = 15;
      % dfs.opts.txt_padding = 5;
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

      dfs.fig = uifigure;
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
%     dfs.cur_col.n_rows = [];
%     dfs.cur_col.GridColumn = [];

      dfs.n_figs = 0;
%       dfs.cur_x = dfs.min_x + dfs.opts.h_padding;
%       dfs.cur_y = dfs.max_y;

      dfs.records = data_records(dfs);
      dfs.graph_figs = {};
      dfs.plot_defs = [];
      dfs.dfuicontextmenu = uicontextmenu(dfs.fig);
      dfs.gimenu = uimenu(dfs.dfuicontextmenu,'Label','Graph in:');
      uimenu(dfs.gimenu,'Label','New figure', ...
        'Callback', { @data_fields.context_callback, "new_fig"}, ...
        'Interruptible', 'off');
      dfs.connectmenu = [];
      % dfs.fig.CloseRequestFcn = @dfs.closereq;
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

    function pop_context(dfs)
      dfs.context.level = dfs.context.level-1;
      dfs.ctx = dfs.context.stack(dfs.context.level);
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
      h = uibutton(gl3,'Text','Graph Selected'); % , ...
         %  'ButtonPushedFcn',@(~,~)graph_selected(dfs));
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
%       if isempty(cntx.Row) && isempty(cntx.Column)
%         gl = uigridlayout(cntx.parent,[1,1]);
%         gl.UserData.LayoutSet = false;
%         dfs.push_context(gl,[],1,0);
%       elseif ~isempty(cntx.Row) && ~isempty(cntx.Column)
%         gl = uigridlayout(cntx.parent,[1,1]);
%         gl.UserData.LayoutSet = false;
%         gl.Layout.Row = cntx.Row;
%         gl.Layout.Column = cntx.Column;
%         dfs.push_context(gl,[],1,0);
%       else
%         dfs.ctx.Row = 1;
%         dfs.ctx.Column = cntx.Column + dfs.opts.grid_cols_per_col;
%       end
    end
    
    function end_col(dfs)
      dfs.ctx.Row = [];
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
      % dfs.cur_col.fields{end+1} = df_int;
      % dfs.cur_col.n_rows = dfs.cur_col.n_rows+1;
      % if df_int.lbl_width > dfs.cur_col.max_lbl_width
      %   dfs.cur_col.max_lbl_width = df_int.lbl_width;
      % end
      % df_int.txt_width = df_int.txt_width + dfs.opts.txt_padding;
      % if df_int.txt_width > dfs.cur_col.max_txt_width
      %   dfs.cur_col.max_txt_width = df_int.txt_width;
      % end
      % dfs.cur_y = dfs.cur_y - df_int.fld_height;
      % df_int.lbl.Position = ...
      %   [ dfs.cur_x, dfs.cur_y, df_int.lbl_width, df_int.fld_height];
      % df_int.txt.Position = ...
      %   [ dfs.cur_x + df_int.lbl_width + dfs.opts.h_leading, dfs.cur_y, ...
      %   df_int.txt_width, ...
      %   df_int.fld_height];
      % dfs.cur_y = dfs.cur_y - dfs.opts.v_leading;
      % if dfs.cur_y < dfs.min_y
      %   dfs.min_y = dfs.cur_y;
      % end
      if nargout > 0; df = df_int; end
    end

    function data_plot(dfs,ID,varargin)
      plt = data_plot(ID,varargin{:});
      dfs.plot_defs.(ID) = plt;
      % boxdim = 14; % size of a checkbox
      % boxwid = 20; % width required for checkbox (add to extent)
      bbg = dfs.opts.Color;
      if ~isempty(plt.opts.label)
        cntx = dfs.ctx;
%         parent = dfs.fig;
%         x = dfs.cur_x;
%         box_x = x;
%         if ~plt.isgroup
%           x = x + boxwid;
%         end
        % make a pushbutton to invoke the group or plot
        callback = @(~,~)show_plot(dfs,ID);
        h = uibutton(cntx.parent, 'Text', plt.opts.label); %, ...
%           'ButtonPushedFcn', callback);
%           'HorizontalAlignment', 'left', ...
%           'FontName', dfs.opts.btn_font, ...
%           'FontSize', dfs.opts.btn_fontsize, ...
%           'BackgroundColor', bbg);
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
%         h = uicontrol(parent, 'Style', 'PushButton', ...
%           'String', plt.opts.label, ...
%           'Callback', callback, 'HorizontalAlignment', 'left', ...
%           'FontName', dfs.opts.btn_font, ...
%           'FontSize', dfs.opts.btn_fontsize, ...
%           'BackgroundColor', bbg );
%         e = get(h,'Extent');
%         dims = e(3:4) + [dfs.opts.h_padding dfs.opts.v_padding];
%         dfs.cur_y = dfs.cur_y - dims(2);
%         set(h,'Position',[x dfs.cur_y dims]);
%         dfs.cur_col.btns{end+1} = h;

%         if ~plt.isgroup
%           box_y = dfs.cur_y + (dims(2)-boxdim)/2;
%           uicontrol(parent,'Style','Checkbox','Tag',ID, ...
%             'Position', [ box_x box_y boxdim boxdim ], ...
%             'Value', 0, 'Max', 1 );
%         end
%         x = x + dims(1);
%         if x > dfs.cur_col.max_btn_x
%           dfs.cur_col.max_btn_x = x;
%         end
%         dfs.cur_y = dfs.cur_y - dfs.opts.v_leading;
%         if dfs.cur_y < dfs.min_y
%           dfs.min_y = dfs.cur_y;
%         end
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
        vars = plt.opts.vars;
        if isempty(vars); return; end
        if nargin >= 3
          [fignum,axnum] = dfs.new_graph(vars{1},'new_axes',fign_in);
        else
          [fignum,axnum] = dfs.new_graph(vars{1},'new_fig');
        end
        for i = 2:length(vars)
          dfs.new_graph(vars{i},'cur_axes',fignum,axnum);
        end
      end
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
      while dfs.context.level > lvl
        dfs.pop_context;
      end
      dfs.resize_widget(dfs.fig);
%       h = uicontrol(dfs.fig,'String','Graph Selected', ...
%           'Callback',@(~,~)graph_selected(dfs));
% 
%       e = h.Extent;
%       dims = ceil(e(3:4)*1.1);
%       if dims(1) > dfs.max_x
%         dfs.max_x = dims(1);
%       end
%       x = (dfs.max_x - e(3))/2;
%       y = dfs.min_y - e(4) - 3*dfs.opts.v_padding;
%       dfs.min_y = y;
%       h.Position = [x y dims];
%       dfs.min_y = dfs.min_y-dfs.opts.v_padding;
% 
%       pos = dfs.fig.Position;
%       pos(2) = pos(2) + dfs.min_y;
%       pos(3) = dfs.max_x;
%       pos(4) = dfs.max_y - dfs.min_y;
%       dfs.fig.Position = pos;
%       dfs.fig.Resize = 'Off';
%       % set(dfs.fig,'Resize','Off');
%       c = findobj(dfs.fig,'type','uicontrol')';
%       for ctrl = c
%         ctrl.Position(2) = ctrl.Position(2)-dfs.min_y;
%       end
%       dfs.max_y = dfs.max_y - dfs.min_y;
%       dfs.min_y = 0;
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
    
    function [fignum, axnum] = new_graph(dfs, var_name, mode, fignum, axisnum)
      % [fignum, axnum] = dfs.new_graph(var_name, mode, fign, axisnum)
      % var_name is the variable name
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
      rec_name = dfs.check_recname(var_name);
      axisnum = dfig.new_graph(rec_name, var_name, mode, axisnum);
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
        if ~isempty(df) && ~isempty(df.fig)
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
          if ~isfield(w.UserData,'LayoutSet') || ~w.UserData.LayoutSet
            for i=1:length(w.RowHeight); w.RowHeight{i} = 'fit'; end
            for i=1:length(w.ColumnWidth); w.ColumnWidth{i} = 'fit'; end
            w.UserData.LayoutSet = true;
          end
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
            colX(1) = w.ColumnSpacing;
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
        case 'uicontextmenu'
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
