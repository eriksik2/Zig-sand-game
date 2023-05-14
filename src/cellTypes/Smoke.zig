const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");
const Cell = @import("../Cell.zig");

const levelUtils = @import("../levelUtils.zig");

const Smoke = @This();

pub const materialProps: Cell.MaterialProps = .{
    .state = .Gas,
    .density = -50.0,
};

pub fn update(self: Cell, x: i32, y: i32, game: *Game, level: *LevelUpdater) bool {
    _ = self;
    var rnd = game.rnd;
    if (rnd.float(f32) < 0.02) {
        level.setCellType(x, y, .Empty);
        return true;
    }
    return false;
}
