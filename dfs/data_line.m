classdef data_line < handle
  properties
    name
    var_name
    format
    label
    units
    bit_number
    scale
    offset
    discrete
    attrs
  end
  methods
    function dl = data_line(varargin)
      % dl = data_line(param, value ...)
      % parameters supported include:
      %   name: the name of the displayed data (unique)
      %   format: '%6s'
      %   label: 'B:'
      %   units: 'V'
      %   var_name: the name of the source TM variable
      %   bit_number: if specified, the bit number within var_name
      %   scale: multiplier
      %   offset: offset
      %   discrete: { name, value }
      % *bit_number is incompatible with scale/offset.
      % *scale or offset may be specified alone.
      %
      % Any other parameters are assumed to be line parameters, and will be
      % passed on to plot(). These might include LineStyle, Marker, etc.
      dl.name = '';
      dl.var_name = '';
      dl.format = '';
      dl.label = '';
      dl.units = '';
      dl.bit_number = [];
      dl.scale = [];
      dl.offset = [];
      dl.discrete = {};
      dl.line_attrs = {};
      for i = 1:2:length(varargin)
        fld = varargin{i};
        arg = varargin{i+1};
        switch fld
          case 'name'
            dl.name = arg;
          case 'var_name'
            dl.var_name = arg;
          case 'format'
            dl.format = arg;
          case 'label'
            dl.label = arg;
          case 'units'
            dl.units = arg;
          case 'bit_number'
            dl.bitnumber = arg;
          case 'scale'
            dl.scale = arg;
          case 'offset'
            dl.offset = arg;
          case 'discrete'
            dl.discrete = arg;
          case 'line_attrs'
            dl.line_attrs = arg;
          otherwise
            error('MATLAB:LE:badopt', 'Invalid data_line option: "%s"', fld);
        end
        if isempty(dl.name); error('data_line object requires name'); end
        if isempty(dl.label); dl.label = [dl.name ':']; end
        if isempty(dl.var_name); dl.var_name = dl.name; end
      end
    end
  end
end
