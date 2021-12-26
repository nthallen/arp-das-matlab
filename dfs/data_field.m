classdef data_field < handle
  % data_field represents two text objects,
  % a label and the value display, and the corresponding
  % data stream
  properties(GetAccess = public)
    dfs % The parent data_fields object
    dl % the data_line object
%     var_name
%     fmt
    lbl_name
    lbl % uilabel object for label
    txt % uilabel object for data
    units % uilabel object for units
    opts
  end
  methods
    function df = data_field(dfs, name, fmt, varargin)
      df.dfs = dfs;
      df.dl = dfs.data_line('name',name,'format',fmt,varargin{:});

%       df.fmt = fmt;
%       df.var_name = var_name;
      df.lbl_name = [df.dl.name '_lbl'];
      df.lbl = [];
      df.txt = [];
      df.units = [];
%       df.opts.label = [ df.var_name ':'];
%       df.opts.units = '';
% 
%       for i = 1:2:length(varargin)
%         fld = varargin{i};
%         if isfield(df.opts, fld)
%           df.opts.(fld) = varargin{i+1};
%         else
%           error('MATLAB:LE:badopt', 'Invalid option: "%s"', fld);
%         end
%       end

      cntx = dfs.ctx;
      Column = cntx.Column + 1;
      if isempty(cntx.Row) || isempty(cntx.Column)
        error('MATLAB:LE:BadContext', 'data_field() must be gridded');
      end
      if ~isempty(df.dl.label)
        df.lbl = uilabel(dfs.ctx.parent, 'Text',df.dl.label, ...
          'HorizontalAlignment', 'left', ...
          'BackgroundColor', dfs.opts.Color, ...
          'FontWeight', 'bold', ...
          'tag', df.lbl_name);
        df.lbl.Layout.Row = cntx.Row;
        df.lbl.Layout.Column = Column;
        Column = Column+1;
      end

      str = df.dl.txt_invalid;
      df.txt = uilabel(dfs.ctx.parent, ...
        'Text', str, ...
        'HorizontalAlignment', 'right', ...
        'BackgroundColor', [1 1 1], ...
        'FontName', dfs.opts.txt_font, ...
        'FontSize', dfs.opts.txt_fontsize, ...
        'uicontextmenu', dfs.dfuicontextmenu, ...
        'tag', df.dl.name, ...
        'userdata', df);
      df.txt.Layout.Row = cntx.Row;
      df.txt.Layout.Column = Column;
      % Column = Column+1;

      if ~isempty(df.dl.units)
        df.units = uilabel(dfs.ctx.parent, 'Text',df.dl.units, ...
          'HorizontalAlignment', 'left', ...
          'BackgroundColor', dfs.opts.Color, ...
          'userdata', df);
        df.units.Layout.Row = cntx.Row;
        df.units.Layout.Column = cntx.Column + 3;
      end
      rec_name = dfs.check_recname(df.dl.var_name,df.dl.rec_name);
      if ~isfield(dfs.fields, rec_name) || ...
          ~isfield(dfs.fields.(rec_name).vars,df.dl.var_name)
        dfs.fields.(rec_name).vars.(df.dl.var_name) = {};
      end
      dfs.fields.(rec_name).vars.(df.dl.var_name){end+1} = df;
    end
  end
end
