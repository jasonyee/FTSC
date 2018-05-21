function SensTable = ThreeCatSensPlot(Members1, assign1, name1, Members2, assign2, name2)
%Input:
%   -Members: {d} is an array contains the members in cluster d
%   -assign: [1-improved, 2-stable, 3-worse]
%   -name: name of the clustering

    SensMX = zeros(3, 3);
    for progress1=1:3
        for progress2=1:3
        cluster1 = assign1 == progress1;
        cluster2 = assign2 == progress2;
        commMembers = intersect(Members1{cluster1}, Members2{cluster2});
        SensMX(progress1, progress2) = length(commMembers);
        end
    end
    
    % get variable names: members1
    RowNames = {strcat(name1, '_improved'),...
                strcat(name1, '_stable'),...
                strcat(name1, '_worse')};
    
    % get row names: members2
    ColNames = {strcat(name2, '_improved'),...
                strcat(name2, '_stable'),...
                strcat(name2, '_worse')};

    SensTable = ...
array2table(SensMX, 'VariableNames', ColNames, 'RowNames', RowNames);


end

