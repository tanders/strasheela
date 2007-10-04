
%% freq

{MUtils.keynumToFreq 69.0 12.0} == 440.0

{MUtils.keynumToFreq 6900.0 1200.0} == 440.0

{MUtils.freqToKeynum 440.0 12.0} == 69.0

{MUtils.freqToKeynum 440.0 72.0}


{MUtils.ratioToKeynumInterval 1#1 12.0} % 0.0

{MUtils.ratioToKeynumInterval 3#2 1200.0} % 701.955

{MUtils.keynumToPC 62.0 12.0} % 2.0

{MUtils.keynumToPC 62.5 12.0} % 2.5

{MUtils.keynumToPC 62.0*6.0 72.0} % 12.0

%% level

{MUtils.levelToDB 0.0 1.0} % ~inf

{MUtils.levelToDB 1.0 1.0} == 0.0

{MUtils.levelToDB 2.0 1.0} % 6.0206

{MUtils.levelToDB 0.5 1.0} % ~6.0206

{MUtils.dBToLevel ~6.0206 1.0} % 0.5

{MUtils.dBToLevel ~40.0 1.0}

{MUtils.dBToLevel ~60.0 1.0}

