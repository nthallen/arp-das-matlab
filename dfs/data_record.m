classdef data_record < handle
  properties
    record_name
    time_name
    data
    n_alloc
    n_recd
    min_alloc
    n_flds
    ix
    max_time
    dfs
  end
  methods
    function dr = data_record(rec_name, dfs)
      dr.record_name = rec_name;
      dr.time_name = ['T' rec_name];
      dr.n_alloc = 0;
      dr.n_recd = 0;
      dr.min_alloc = 10000;
      dr.n_flds = 0;
      dr.max_time = [];
      dr.dfs = dfs;
    end
    
    function was_new = process_record(dr, str)
      % was_new = dr.process_record(str);
      % str is a struct decoded from a json string of data
      % was_new will be non-zero the first time this record is processed
      flds = fieldnames(str);
      if dr.n_flds == 0
        was_new = 1;
        dr.n_alloc = dr.min_alloc;
        dr.n_flds = length(flds);
        dr.ix = (1:dr.n_alloc)';
        for i = 1:dr.n_flds
          w = length(str.(flds{i}));
          dr.dfs.varinfo.(flds{i}).w = w;
%           if ~isfield(dr.dfs.varinfo.(flds{i}),'interp')
%             dr.dfs.varinfo.(flds{i}).interp = 1;
%           end
          dr.data.(flds{i}) = zeros(dr.min_alloc,w) * NaN;
        end
        if ~isfield(dr.data, dr.time_name)
          error('Structure for record %s missing time var %s', ...
            dr.record_name, dr.time_name);
        else
          dr.max_time = str.(dr.time_name);
        end
      else
        was_new = 0;
        if dr.n_flds ~= length(flds)
          error('Change in size of record %s', dr.record_name);
        end
        cur_time = str.(dr.time_name);
        % time should *really* be a scalar
        if cur_time(1) <= dr.max_time
          warning('Time is non-monotonic for record %s', dr.record_name);
          dr.n_recd = 0;
        end
        dr.max_time = cur_time(end);
      end
      for i = 1:dr.n_flds
        if ~isfield(dr.data, flds{i})
          error('Structure for record %s changed: %s is new', ...
            dr.record_name, flds{i});
        end
      end
      dr.n_recd = dr.n_recd+1;
      if dr.n_recd > dr.n_alloc
        for i = 1:length(flds)
          dr.data.(flds{i}) = [
            dr.data.(flds{i});
            zeros(dr.min_alloc,dr.dfs.varinfo.(flds{i}).w) * NaN ];
        end
        dr.n_alloc = dr.n_alloc + dr.min_alloc;
        dr.ix = (1:dr.n_alloc)';
      end
      for i = 1:dr.n_flds
        try
          dr.data.(flds{i})(dr.n_recd,:) = str.(flds{i});
        catch
          fprintf(1,'Assignment error for %s(%d): LHS:[%dx%d] RHS:[%dx%d]\n', ...
            flds{i}, dr.n_recd, size(dr.data.(flds{i})), size(str.(flds{i})));
          dr.data.(flds{i})(dr.n_recd,:) = NaN;
        end
      end
    end
    
    function [T,V] = time_vector(dr, duration)
      if isfield(dr.data, dr.time_name)
        T = dr.data.(dr.time_name);
        V = dr.ix <= dr.n_recd & T >= T(dr.n_recd) - duration;
        T = T(V);
      else
        T = [];
        V = [];
      end
    end
    
    function D = data_vector(dr, var_name, V)
      if isfield(dr.data, var_name)
        D = dr.data.(var_name)(V,:);
      else
        D = [];
      end
    end
  end
end