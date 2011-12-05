% Class construction to carry OCT data and avoid copies across function
% calls, this is better than global as the handle will be localized in the
% function
classdef C_OCTVolume < handle 
   properties
      data = [];
      dims=[];
      max_val = 1;
      min_val = 0;
   end
   methods
      function v = C_OCTVolume(size)
         v.data = zeros(size);
         v.dims=size;
      end 
      function saveint16(obj,name)
        Hstruct3D=fopen(name,'w');
        fwrite(Hstruct3D, obj.dims,'int16');
        fwrite(Hstruct3D, obj.data,'int16');
        fclose(Hstruct3D);
      end
      function openint16(obj,name)
        Hstruct3D=fopen(name,'r');
        obj.dims=fread(Hstruct3D, 3,'int16');
        obj.dims=obj.dims';
        obj.data=fread(Hstruct3D, inf,'int16');
        obj.data=reshape(obj.data,obj.dims);
        fclose(Hstruct3D);
      end      
      function set_maxmin(obj,max_val,min_val)
        obj.max_val = max_val;
        obj.min_val = min_val;
      end      
   end
end