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

pub fn invLerpVar(value: anytype, mean: @TypeOf(value), variance: @TypeOf(value)) f32 {
    var cvalue: f32 = 0;
    var cmean: f32 = 0;
    var cvariance: f32 = 0;
    switch (@typeInfo(@TypeOf(value))) {
        .ComptimeFloat, .Float => {
            cvalue = @floatCast(f32, value);
            cmean = @floatCast(f32, mean);
            cvariance = @floatCast(f32, variance);
        },
        .ComptimeInt, .Int => {
            cvalue = @intToFloat(f32, value);
            cmean = @intToFloat(f32, mean);
            cvariance = @intToFloat(f32, variance);
        },
        else => @compileError("Expected float or int, got " ++ @typeName(@TypeOf(value))),
    }
    const a = cvalue - (cmean - cvariance);
    const b = a / (2 * cvariance);
    return b;
}
