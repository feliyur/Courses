function [vertices, faces] = read_obj_file(filename)

    vertices = [];
    faces = [];
    fp = fopen( filename, 'r' );
    type = fscanf( fp, '%s', 1 );
    while strcmp( type, '' ) == 0
        if strcmp( type, 'v' ) == 1
            v = fscanf( fp, '%g %g %g\n' );
            vertices = [vertices; v'];
        elseif strcmp( type, 'vt')
            v = fscanf( fp, '%g %g %g\n' );
        elseif strcmp( type, 'f' ) == 1
            line = fgets(fp);
            [t, count] = sscanf(line, '%d/%d/%d %d/%d/%d %d/%d/%d %d/%d/%d %d/%d/%d');

            if (count>2)
                t = t(1:3:end);
            else
                [t, count] = sscanf(line, '%d/%d %d/%d %d/%d %d/%d %d/%d');
                if (count>2)
                    t = t(1:2:end);
                else
                    [t, count] = sscanf( line, '%d %d %d %d %d %d %d %d %d %d %d\n' );
                end
            end
            faces = [faces; t'];
        elseif strcmp( type, '#' ) == 1
            fscanf( fp, '%s\n', 1 );
        end
        type = fscanf( fp, '%s', 1 );
    end
    fclose( fp );
%     vertices = vertices';
%     faces = faces';
end
