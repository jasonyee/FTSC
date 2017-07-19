%% ShouldStop
%  ShouldStop controls whether the loop in KFClustering should halt

function TOF = ShouldStop(Switches, loopNum, MAX_LOOP)
%Input:
%   -Swithes: # of subject switches in each loop.
%   -loopNum: # of loops
%   -MAX_LOOP: the maximum number of loops before end.
%Ouput:
%   -TOF: logical value determines whethter looping should end.

    NoSwitches = (Switches == 0);
    OverLoop = (loopNum >= MAX_LOOP);
    TOF = (NoSwitches | OverLoop);

end

