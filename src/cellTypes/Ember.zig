const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");
const Cell = @import("../Cell.zig");

const levelUtils = @import("../levelUtils.zig");

const Ember = @This();

burn: f32 = 1.0,

pub const materialProps: Cell.MaterialProps = .{
    .state = .None,
    .density = -100.0,
};

pub fn update(self: Cell, x: i32, y: i32, game: *Game, level: *LevelUpdater) bool {
    var rnd = game.rnd;

    var self2 = self;
    self2.type.Ember.burn -= rnd.float(f32) / 10;
    self2.temp = 300.0;
    level.setCell(x, y, self2);

    if (self.type.Ember.burn <= 0.0) {
        level.setCellType(x, y, .{
            .Smoke = .{},
        });
        return true;
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
        if (cell.type == .Empty or cell.type == .Smoke) {
            level.setCell(x, y, cell);
            level.setCell(x + c.dx, y + c.dy, self2);
            return true;
        }
    }
    return false;
}
