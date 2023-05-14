const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");
const Cell = @import("../Cell.zig");

const Wall = @This();

pub const materialProps: Cell.MaterialProps = .{
    .state = .SolidFixed,
    .density = 99999999,
};

pub fn update(self: Cell, x: i32, y: i32, game: *Game, level: *LevelUpdater) bool {
    _ = level;
    _ = game;
    _ = y;
    _ = x;
    _ = self;
    return false;
}
