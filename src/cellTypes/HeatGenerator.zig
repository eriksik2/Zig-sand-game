const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");
const Cell = @import("../Cell.zig");

const HeatGenerator = @This();

pub fn update(self: Cell, x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
    _ = game;
    if (self.temp < 1000) {
        level.setTemp(x, y, 1500);
    }
}
