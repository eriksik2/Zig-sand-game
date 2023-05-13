const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");

const ColdGenerator = @This();

pub fn update(self: ColdGenerator, x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
    _ = game;
    _ = self;
    const temp = level.getTemp(x, y);
    if (temp > -1000) {
        level.setTemp(x, y, -1500);
    }
}
