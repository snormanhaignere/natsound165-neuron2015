function lb = read_label(lname)

fid = fopen(lname,'r');
lb.h = fgets(fid);
nverts = fscanf(fid,'%d\n',1);
x = textscan(fid,'%d%f%f%f%f\n',nverts);
lb.vnums = x{1};
lb.vras = [x{2} x{3} x{4}];
fclose(fid);