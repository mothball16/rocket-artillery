local SPEED_MULT = 4
local PRELOAD_RKT = "9M27F"
return {
    TurretBase = {
        turretName = 'BM-27 "Ураган"';
        salvoIntervals = {1, 2};
        timeIntervals = {0.5, 1, 2};
        preSelect = PRELOAD_RKT;
        FCUAttached = false;
    };

    Turret = {
        rotLimited = true,
        rotSpeed = 6 * SPEED_MULT,
        rotMin = -30,
        rotMax = 30,
        pitchMax = 55,
        pitchMin = 0,
        pitchSpeed = 2.2 * SPEED_MULT,
        maxStep = 1.5,
    };

    Joystick = {
        sens = 1.5;
        enabled = false;
    };

    ForwardCamera = {
        minFOV = 30;
        maxFOV = 60;
    };

    RangeSheets = {
        "9M27F",
    };

    TurretServerController = {
        initWith = PRELOAD_RKT,
    };
    -- empty configs, just for clarity (dev)
    AttachSelector = {};
    AttachServerController = {};
    UIHandler = {};
    OrientationReader = {};
    TurretPlayerControls = {};
}