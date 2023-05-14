const std = @import("std");

const Game = @import("../Game.zig");
const LevelUpdater = @import("../LevelUpdater.zig");
const Cell = @import("../Cell.zig");

const Wood = @This();

pub const materialProps: Cell.MaterialProps = .{
    .state = .Solid,
    .density = 100.0,
};

pub fn update(self: Cell, x: i32, y: i32, game: *Game, level: *LevelUpdater) bool {
    _ = self;
    var rnd = game.rnd;

    const Pos = struct { dx: i32, dy: i32 };
    if (rnd.float(f32) < 0.05) {
        var check1: [4]Pos = .{
            .{ .dx = -1, .dy = 0 },
            .{ .dx = 1, .dy = 0 },
            .{ .dx = 0, .dy = -1 },
            .{ .dx = 0, .dy = 1 },
        };
        rnd.shuffle(Pos, &check1);
        for (check1) |c| {
            var cell = level.getCell(x + c.dx, y + c.dy);
            if (cell.type == .Fire or cell.type == .Ember) {
                if (rnd.float(f32) < 0.3) {
                    level.setCellType(x, y, .{
                        .Fire = .{},
                    });
                } else {
                    level.setCellType(x, y, .Empty);
                }
                return true;
            }
        }
    }
    return false;
}
