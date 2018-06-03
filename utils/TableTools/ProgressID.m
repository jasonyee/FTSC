function [ProgressIDs] = ProgressID(ClusterIDs, cluster_id_progress, file_path)
%PROGRESSID converts the non-informative ClusterIDs to the 
%   [improved-0, stable-1, worse-2] ProgressIDs and save to the mat file.
%
%Input:
%   -ClusterIDs: the non-informative ids output by FTSC
%   -cluster_id_progress: ['improved', 'stable', 'worse']
%       cluster_id_progress(1) = 2: improved cluster is cluster with id 2.
%   -file_path: a string showing the path for the target mat file.
%Output:
%   -ProgressIDs: 0-improved, 1-stable, 2-worse.

ProgressIDs = zeros(size(ClusterIDs));

ProgressIDs(ClusterIDs == cluster_id_progress(2)) = 1;

ProgressIDs(ClusterIDs == cluster_id_progress(3)) = 2;

variableInfo = who('-file', file_path);

if ~ismember('ProgressIDs', variableInfo)
    save(file_path, 'ProgressIDs', '-append')
end

end

