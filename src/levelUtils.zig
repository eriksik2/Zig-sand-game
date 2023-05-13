const Game = @import("Game.zig");
const Level = @import("Level.zig");
const Cell = @import("cell.zig").Cell;
const LevelUpdater = @import("LevelUpdater.zig");

const CellTag = @typeInfo(Cell).Union.tag_type.?;

fn assertLevel(level: anytype) void {
    switch (@TypeOf(level)) {
        Level, *const Level, *Level, LevelUpdater, *const LevelUpdater, *LevelUpdater => {},
        else => @compileError("Expected Level, got " ++ @typeName(@TypeOf(level))),
    }
}

pub fn countNeigborsOf(level: anytype, x: u32, y: u32, cell: CellTag) u32 {
    assertLevel(level);
    const Pos = struct { dx: i32, dy: i32 };
    const check: [4]Pos = .{
        .{ .dx = -1, .dy = 0 },
        .{ .dx = 1, .dy = 0 },
        .{ .dx = 0, .dy = -1 },
        .{ .dx = 0, .dy = 1 },
        .{ .dx = -1, .dy = -1 },
        .{ .dx = 1, .dy = -1 },
        .{ .dx = -1, .dy = 1 },
        .{ .dx = 1, .dy = 1 },
    };
    var count: u32 = 0;
    for (check) |neighbor| {
        if (level.getCell(x + neighbor.dx, y + neighbor.dy) == cell) {
            count += 1;
        }
    }
    return count;
}
