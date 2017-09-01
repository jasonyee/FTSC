%% ShouldStop
%  ShouldStop controls whether the loop in KFClustering should halt

function TOF = ShouldStop(NSwitches, loopNum, MAX_LOOP)
%Input:
%   -Swithes: # of subject switches in each loop.
%   -loopNum: # of loops
%   -MAX_LOOP: the maximum number of loops before end.
%Ouput:
%   -TOF: logical value determines whether looping should end.

    NoSwitches = (NSwitches == 0);
    OverLoop = (loopNum >= MAX_LOOP);
    TOF = (NoSwitches | OverLoop);

end

