const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");

const levelUtils = @import("../levelUtils.zig");

const Steam = @This();

pub fn update(self: Steam, x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
    var rnd = game.rnd;
    const thresh = levelUtils.invLerpVar(level.getTemp(x, y), 50.0, 50.0);
    if (rnd.float(f32) > thresh) {
        level.setCell(x, y, .Water);
        return;
    }
    const Pos = struct { dx: i32, dy: i32 };
    var check1: [3]Pos = .{
        .{ .dx = -1, .dy = -1 },
        .{ .dx = 1, .dy = -1 },
        .{ .dx = 0, .dy = -1 },
    };
    rnd.shuffle(Pos, &check1);
    for (check1) |c| {
        var cell = level.getCell(x + c.dx, y + c.dy);
        if (cell == .Empty or cell == .Water) {
            level.setCell(x, y, cell);
            level.setCell(x + c.dx, y + c.dy, self);
            return;
        }
    }
    var check2: [5]Pos = .{
        .{ .dx = -1, .dy = 0 },
        .{ .dx = 1, .dy = 0 },
        .{ .dx = -1, .dy = 1 },
        .{ .dx = 0, .dy = 1 },
        .{ .dx = 1, .dy = 1 },
    };
    rnd.shuffle(Pos, &check2);
    for (check2) |c| {
        var cell = level.getCell(x + c.dx, y + c.dy);
        if (cell == .Empty) {
            level.setCell(x, y, cell);
            level.setCell(x + c.dx, y + c.dy, self);
            return;
        }
    }
}
