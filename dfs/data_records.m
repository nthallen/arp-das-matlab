classdef data_records < handle
    properties
        records
        max_time
    end
    methods
        function drs = data_records()
            drs.max_time = [];
        end
        
        function add_record(drs,rec_name)
            % data_records.add_record(rec_name)
            % May be called redundantly without harm.
            if ~isfield(drs.records, rec_name)
                drs.records.(rec_name) = data_record(rec_name);
            end
        end
        function process_record(drs,rec_name, str)
          if ~isfield(drs.records, rec_name)
            drs.add_record(rec_name);
          end
          dr = drs.records.(rec_name);
          dr.process_record(str);
          if isempty(drs.max_time) || dr.max_time > drs.max_time
            drs.max_time = dr.max_time;
          else
            recs = fieldnames(drs.records);
            newmax = [];
            for i=1:length(recs)
              rmax = drs.records.(recs{i}).max_time;
              if isempty(newmax) | rmax > newmax
                newmax = rmax;
              end
            end
            drs.max_time = newmax;
          end
        end
    end
end