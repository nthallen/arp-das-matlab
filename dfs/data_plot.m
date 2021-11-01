classdef data_plot < handle
  % data_plot defines a single pane trend plot from which
  % one or more data_fig/data_axis combinations can be
  % instantiated.
  properties
    ID % The unique ID
    isgroup % boolean
    % struct containing options. This is done to simplify
    % handling the input arguments
    %   vars: cell array of var_names
    %   plots: cell array of plot IDs
    %   linestyle: ultimately
    %   label: if defined, will produce a menu label
    %   ylabel: ylabel
    % plots and vars are mutually exclusive. groups have plots, plots have
    % vars. Defining both or neither is an error.
    opts
  end
  methods
    function plt = data_plot(ID,varargin)
      plt.ID = ID;
      plt.isgroup = false;
      plt.opts.vars = {};
      plt.opts.plots = {};
      plt.opts.linestyle = '-';
      plt.opts.label = '';
      plt.opts.ylabel = '';
      for i = 1:2:length(varargin)
        fld = varargin{i};
        if isfield(plt.opts, fld)
          plt.opts.(fld) = varargin{i+1};
        else
          error('MATLAB:LE:badopt', 'Invalid option: "%s"', fld);
        end
      end
      if isempty(plt.opts.vars)
        if isempty(plt.opts.plots)
          error('Must define either vars or plots');
        else
          plt.isgroup = true;
        end
      else
        if isempty(plt.opts.plots)
          plt.isgroup = false;
        else
          error('Cannot define both vars and plots');
        end
      end
    end
  end
end
