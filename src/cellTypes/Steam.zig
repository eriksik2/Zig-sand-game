const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");
const Cell = @import("../Cell.zig");

const levelUtils = @import("../levelUtils.zig");

const Steam = @This();

pub const materialProps: Cell.MaterialProps = .{
    .state = .Gas,
    .density = -10.0,
};

pub fn update(self: Cell, x: i32, y: i32, game: *Game, level: *LevelUpdater) bool {
    var rnd = game.rnd;
    const thresh = levelUtils.invLerpVar(self.temp, 90.0, 50.0);
    if (rnd.float(f32) > thresh) {
        level.setCellType(x, y, .Water);
        return true;
    }
    return false;
}
