local module = {}
export type UILoad = {
    stickPos: Vector2,
    stickRaw: Vector2,
    stickTime: number,
    stickMult: number,
    lockedAxes: {
        x: number,
        y: number
    },
    rot: Vector2,
    orient: {
        yaw: number,
        pitch: number,
        roll: number
    },
    pos: Vector3,
    HUD: Vector3,
    crosshair: Vector3,
    inCamera: boolean,
}

return module