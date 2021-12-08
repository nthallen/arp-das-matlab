classdef data_field < handle
  % data_field represents two text objects,
  % a label and the value display, and the corresponding
  % data stream
  properties(GetAccess = public)
    dfs % The parent data_fields object
    var_name
    fmt
    lbl_name
    lbl % uilabel object for label
    txt % uilabel object for data
    units % uilabel object for units
    opts
    lbl_width % obsolete?
    txt_width % obsolete?
    fld_height % obsolete?
  end
  methods
    function df = data_field(dfs, var_name, fmt, varargin)
      signed = true;
      df.dfs = dfs;
      df.fmt = fmt;
      df.var_name = var_name;
      df.lbl_name = [var_name '_lbl'];
      opts.label = [ df.var_name ':'];
      opts.units = '';

      for i = 1:2:length(varargin)
        fld = varargin{i};
        if isfield(opts, fld)
          opts.(fld) = varargin{i+1};
        else
          error('MATLAB:LE:badopt', 'Invalid option: "%s"', fld);
        end
      end

      cntx = dfs.ctx;
      if isempty(cntx.Row) || isempty(cntx.Column)
        error('MATLAB:LE:Bad Context', 'data_field() must be gridded');
      end
      df.lbl = uilabel(dfs.ctx.parent, 'Text',opts.label, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', dfs.opts.Color, ...
        'FontWeight', 'bold', ...
        'tag', df.lbl_name, ...
        'uicontextmenu', dfs.dfuicontextmenu, ...
        'userdata', df);
      df.lbl.Layout.Row = cntx.Row;
      df.lbl.Layout.Column = cntx.Column + 1;
%       df.lbl = uicontrol(flds.fig, ...
%         'Style', 'text', 'String', lbltxt, ...
%         'HorizontalAlignment', 'left', ...
%         'BackgroundColor', flds.figbgcolor, ...
%         'FontWeight', 'bold', ...
%         'tag', df.lbl_name, ...
%         'uicontextmenu', flds.dfuicontextmenu, ...
%         'userdata', df);
%      df.lbl_width = df.lbl.Extent(3);
      str = df.txt_convert(0);
      if signed
        str = [ '-' str ];
      end
      df.txt = uilabel(dfs.ctx.parent, ...
        'Text', str, ...
        'HorizontalAlignment', 'right', ...
        'BackgroundColor', [1 1 1], ...
        'FontName', dfs.opts.txt_font, ...
        'FontSize', dfs.opts.txt_fontsize, ...
        'tag', df.var_name);
      df.txt.Layout.Row = cntx.Row;
      df.txt.Layout.Column = cntx.Column + 2;
%       df.txt = uicontrol(flds.fig, ...
%         'Style', 'text', 'String', str, ...
%         'HorizontalAlignment', 'right', ...
%         'BackgroundColor', [1 1 1], ...
%         'FontName', flds.opts.txt_font, ...
%         'FontSize', flds.opts.txt_fontsize, ...
%         'tag', df.var_name);
%      df.txt_width = df.txt.Extent(3);
%      df.fld_height = max(df.lbl.Position(4), df.txt.Position(4));
      if ~isempty(opts.units)
        df.units = uilabel(dfs.ctx.parent, 'Text',opts.units, ...
          'HorizontalAlignment', 'left', ...
          'BackgroundColor', dfs.opts.Color, ...
          'userdata', df);
        df.units.Layout.Row = cntx.Row;
        df.units.Layout.Column = cntx.Column + 3;
      end
      dfs.ctx.Row = dfs.ctx.Row+1;
    end
    
    function str = txt_convert(obj, val)
      if isnumeric(obj.fmt)
        str = num2str(val,obj.fmt);
      else
        str = sprintf(obj.fmt,val);
      end
    end
  end
end
