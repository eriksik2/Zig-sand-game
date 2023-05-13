const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");
const Cell = @import("../Cell.zig");

const levelUtils = @import("../levelUtils.zig");

const Ember = @This();

pub fn update(self: Cell, x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
    var rnd = game.rnd;
    if (rnd.float(f32) < 0.01) {
        level.setCellType(x, y, .Empty);
        return;
    }

    const Pos = struct { dx: i32, dy: i32 };
    var check1: [4]Pos = .{
        .{ .dx = 0, .dy = 1 },
        .{ .dx = 0, .dy = -1 },
        .{ .dx = 1, .dy = 0 },
        .{ .dx = -1, .dy = 0 },
    };
    rnd.shuffle(Pos, &check1);
    for (check1) |c| {
        var cell = level.getCell(x + c.dx, y + c.dy);
        if (cell.type == .Water) {
            level.setCellType(x, y, .Empty);
            return;
        }
        if (cell.type == .Empty) {
            level.setCellType(x + c.dx, y + c.dy, .{
                .Ember = .{},
            });
        }
    }

    var check2: [3]Pos = .{
        .{ .dx = 0, .dy = 1 },
        .{ .dx = -1, .dy = 1 },
        .{ .dx = 1, .dy = 1 },
    };
    rnd.shuffle(Pos, &check2);
    for (check2) |c| {
        var cell = level.getCell(x + c.dx, y + c.dy);
        if (cell.type == .Empty or cell.type == .Ember) {
            level.setCell(x, y, cell);
            level.setCell(x + c.dx, y + c.dy, self);
            return;
        }
    }
}
