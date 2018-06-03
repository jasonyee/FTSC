function demo_uncluster(struct_file, Options)
%DEMO_UNCLUSTER Shows the spaghetti plot for raw data
%
%Input:
%   -struct_file: stores the MAT-file data in a struct
%   -Options: stores the information for the plotting.

figure;
plot(struct_file.Threedif');
ylim([min(struct_file.Threedif(:))-1, max(struct_file.Threedif(:))+1])
xlim([0, 26])
title(Options.title);
ylabel(Options.ylabel)
xlabel(Options.xlabel);


end

