const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");
const levelUtils = @import("../levelUtils.zig");
const Cell = @import("../Cell.zig");

const Water = @This();

pub const materialProps: Cell.MaterialProps = .{
    .state = .Liquid,
    .density = 10.0,
};

pub fn update(self: Cell, x: i32, y: i32, game: *Game, level: *LevelUpdater) bool {
    var rnd = game.rnd;
    if (rnd.float(f32) < levelUtils.invLerpVar(self.temp, 100, 50)) {
        level.setCellType(x, y, .Steam);
        return true;
    }
    return false;
}
