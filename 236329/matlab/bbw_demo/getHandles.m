function [C,BE,CE] = getHandles(filename)
  C = [];
  BE = [];
  CE = [];
  fp = fopen(filename,'r');
  line = fscanf(fp,' %[^\n]s');
  while(line(1,1) ~= '---')
    [control_line,num_of_elements] = sscanf(line,'%d %g %g %g',4);
    control_line = control_line(2:num_of_elements);
    C = [C;control_line'];
    line = fscanf(fp,' %[^\n]s');
  end
  line = fscanf(fp,' %[^\n]s');
  while(sum(size(line)) > 0 && line(1,1) ~= '#')
    [e,num_of_elements] = sscanf(line,'%d %d %d %d %d',5);
    if num_of_elements >= 3 && e(3)
      BE = [BE;e(1:2)'];
    end
    % bone edges trump cage edges
    if num_of_elements >= 5 && e(5) && ~e(3)
      CE = [CE;e(1:2)'];
    end
    line = fscanf(fp,' %[^\n]s');
  end
  
  fclose( fp );
end
