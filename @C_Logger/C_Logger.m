% Class construction to carry OCT data and avoid copies across function
% calls, this is better than global as the handle will be localized in the
% function
classdef C_Logger < handle 
   properties
      file = 0;
      level = 0;
      fp=0;
   end
   methods
      function logger = C_Logger(filename,level)
         logger.file = filename;
         logger.level = level;
         logger.fp=fopen(filename,'w');
      end 
      function log_message(obj,level,message)
          if (level > obj.level )
            fwrite(obj.fp,[message, '\n']);
          end
      end
      function delete(obj)
          fclose(obj.fp);
      end
   end
end