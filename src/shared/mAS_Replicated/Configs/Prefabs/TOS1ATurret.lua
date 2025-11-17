local SPEED_MULT = 4

return {
    TurretBase = {
        turretName = "TOS-1A 'Solntsepyok'";
        salvoIntervals = {1, 2};
        timeIntervals = {0.5, 1, 2};
        FCUAttached = false;
    };

    Turret = {
        rotLimited = false,
        rotSpeed = 6 * SPEED_MULT,
        pitchMax = 48,
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
        "TOS220Short",
    };
    -- empty configs, just for clarity (dev)
    AttachSelector = {};
    AttachServerController = {};
    UIHandler = {};
    OrientationReader = {};
    TurretPlayerControls = {};
}