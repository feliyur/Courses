function res=plindp(filename)

if ispc
    spl = strsplit(filename, '/'); 
else
    spl = strsplit(filename, '\'); 
end
    
res = fullfile(spl{:}); 
