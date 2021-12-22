classdef data_line < handle
  properties
    name
    var_name
    format
    label
    units
    bit_mask
    scale
    offset
    discrete % cell array of labels
    ndiscrete % length of discrete array
    line_attrs
    numtype % 'raw','scaled','bit'
    txttype % 'format','discrete','undefined'
    txtwidth % number of characters
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
      dl.bit_mask = [];
      dl.scale = [];
      dl.offset = [];
      dl.discrete = {};
      dl.line_attrs = {};
      dl.update(varargin{:});
    end

    function update(dl, varargin)
      for i = 1:2:length(varargin)-1
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
            dl.bit_mask = 2^arg;
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
      end
      if isempty(dl.name); error('data_line object requires name'); end
      if isempty(dl.label); dl.label = [dl.name ':']; end
      if isempty(dl.var_name); dl.var_name = dl.name; end
      if ~isempty(dl.bit_mask)
        dl.numtype = 'bit';
      elseif ~isempty(dl.scale)
        dl.numtype = 'scaled';
        if isempty(dl.offset); dl.offset = 0; end
      elseif ~isempty(dl.offset)
        dl.numtype = 'scaled';
        dl.scale = 1;
      else
        dl.numtype = 'raw';
      end
      if ~isempty(dl.discrete)
        dl.txttype = 'discrete';
        dl.txtwidth = max(cellfun(@length,dl.discrete));
        dl.ndiscrete = length(dl.discrete);
      elseif ~isempty(dl.format)
        dl.txttype = 'format';
        dl.txtwidth = sscanf(dl.format,'%%%d');
      else
        dl.txttype = 'undefined';
        dl.txtwidth = 0;
      end
    end
    
    function str = txt_convert(dl, val)
      switch dl.txttype
        case 'format'
          str = sprintf(dl.format,dl.num_convert(val));
        case 'discrete'
          n = round(dl.num_convert(val));
          if n >= 0 && n < dl.ndiscrete
            str = dl.discrete{n};
          else
            str = dl.txt_invalid;
            return;
          end
      end
      if length(str) > dl.txtwidth
        str = dl.txt_invalid;
      end
    end

    function str = txt_invalid(dl)
      str = char('*' * ones(1,dl.txtwidth));
    end

    function num = num_convert(dl, val)
      switch dl.numtype
        case 'raw'
          num = val;
        case 'scaled'
          num = val * dl.scale + dl.offset;
        case 'bit'
          num = double(bitand(val,dl.bit_mask) > 0);
      end
    end
  end
end
