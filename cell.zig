const Level = @import("Level.zig");
const LevelUpdater = @import("LevelUpdater.zig");
const Game = @import("Game.zig");

pub const Cell = enum(u8) {
    Empty = 0,
    Sand = 1,
    Wall = 2,
    Water = 3,
    Steam = 4,

    pub fn update(cell: Cell, x: i32, y: i32, game: *Game, updater: *LevelUpdater) void {
        inline for (@typeInfo(Cell).Enum.fields) |field| {
            const tag = @intToEnum(Cell, field.value);
            if (cell == tag) {
                return @call(.auto, @field(Cell, "update" ++ field.name), .{ x, y, game, updater });
            }
        }
        unreachable;
    }

    fn updateEmpty(_: i32, _: i32, _: *Game, _: *LevelUpdater) void {}
    fn updateWall(_: i32, _: i32, _: *Game, _: *LevelUpdater) void {}

    fn updateSand(x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
        var rnd = game.rnd;
        var below = level.getCell(x, y + 1);
        if (below == .Empty or below == .Water) {
            level.setCell(x, y, below);
            level.setCell(x, y + 1, .Sand);
            return;
        }
        var first: i32 = -1;
        var second: i32 = 1;
        if (rnd.boolean()) {
            first = 1;
            second = -1;
        }
        var cellFirst = level.getCell(x + first, y + 1);
        if (cellFirst == .Empty) {
            level.setCell(x, y, cellFirst);
            level.setCell(x + first, y + 1, .Sand);
            return;
        }
        var cellSecond = level.getCell(x + second, y + 1);
        if (cellSecond == .Empty) {
            level.setCell(x, y, cellSecond);
            level.setCell(x + second, y + 1, .Sand);
            return;
        }
    }

    fn updateWater(x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
        var rnd = game.rnd;
        var below = level.getCell(x, y + 1);
        if (below == .Empty) {
            level.setCell(x, y, below);
            level.setCell(x, y + 1, .Water);
            return;
        }
        var first: i32 = -1;
        var second: i32 = 1;
        if (rnd.boolean()) {
            first = 1;
            second = -1;
        }
        var cellFirst = level.getCell(x + first, y + 1);
        if (cellFirst == .Empty) {
            level.setCell(x, y, cellFirst);
            level.setCell(x + first, y + 1, .Water);
            return;
        }
        var cellSecond = level.getCell(x + second, y + 1);
        if (cellSecond == .Empty) {
            level.setCell(x, y, cellSecond);
            level.setCell(x + second, y + 1, .Water);
            return;
        }
        cellFirst = level.getCell(x + first, y);
        if (cellFirst == .Empty or cellFirst == .Sand) {
            level.setCell(x, y, cellFirst);
            level.setCell(x + first, y, .Water);
            return;
        }
        cellSecond = level.getCell(x + second, y);
        if (cellSecond == .Empty or cellSecond == .Sand) {
            level.setCell(x, y, cellSecond);
            level.setCell(x + second, y, .Water);
            return;
        }
    }

    fn updateSteam(x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
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
};
