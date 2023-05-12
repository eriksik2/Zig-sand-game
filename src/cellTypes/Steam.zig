const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");

const Steam = @This();

pub fn update(self: Steam, x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
    _ = self;
    var rnd = game.rnd;
    const Pos = struct { dx: i32, dy: i32 };
    var check: [4]Pos = .{
        .{ .dx = -1, .dy = 0 },
        .{ .dx = 1, .dy = 0 },
        .{ .dx = 0, .dy = -1 },
        .{ .dx = 0, .dy = 1 },
    };
    rnd.shuffle(Pos, &check);
    for (check) |c| {
        var cell = level.getCell(x + c.dx, y + c.dy);
        if (cell == .Empty) {
            level.setCell(x, y, cell);
            level.setCell(x + c.dx, y + c.dy, .Steam);
            return;
        }
    }
}
