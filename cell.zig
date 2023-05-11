const Level = @import("Level.zig");
const Game = @import("Game.zig");

pub const Cell = enum(u8) {
    Empty = 0,
    Sand = 1,
    Wall = 2,
    Water = 3,

    pub fn update(cell: Cell, x: i32, y: i32, game: *Game) void {
        var level = game.level;
        var rnd = game.rnd;
        switch (cell) {
            .Sand => blk: {
                var below = level.getCell(x, y + 1);
                if (below == .Empty or below == .Water) {
                    level.setCell(x, y, below);
                    level.setCell(x, y + 1, .Sand);
                    break :blk;
                }
                var first: i32 = -1;
                var second: i32 = 1;
                if (rnd.random().boolean()) {
                    first = 1;
                    second = -1;
                }
                var cellFirst = level.getCell(x + first, y + 1);
                if (cellFirst == .Empty) {
                    level.setCell(x, y, cellFirst);
                    level.setCell(x + first, y + 1, .Sand);
                    break :blk;
                }
                var cellSecond = level.getCell(x + second, y + 1);
                if (cellSecond == .Empty) {
                    level.setCell(x, y, cellSecond);
                    level.setCell(x + second, y + 1, .Sand);
                    break :blk;
                }
            },
            .Water => blk: {
                var below = level.getCell(x, y + 1);
                if (below == .Empty) {
                    level.setCell(x, y, below);
                    level.setCell(x, y + 1, .Water);
                    break :blk;
                }
                var first: i32 = -1;
                var second: i32 = 1;
                if (rnd.random().boolean()) {
                    first = 1;
                    second = -1;
                }
                var cellFirst = level.getCell(x + first, y + 1);
                if (cellFirst == .Empty) {
                    level.setCell(x, y, cellFirst);
                    level.setCell(x + first, y + 1, .Water);
                    break :blk;
                }
                var cellSecond = level.getCell(x + second, y + 1);
                if (cellSecond == .Empty) {
                    level.setCell(x, y, cellSecond);
                    level.setCell(x + second, y + 1, .Water);
                    break :blk;
                }
                cellFirst = level.getCell(x + first, y);
                if (cellFirst == .Empty or cellFirst == .Sand) {
                    level.setCell(x, y, cellFirst);
                    level.setCell(x + first, y, .Water);
                    break :blk;
                }
                cellSecond = level.getCell(x + second, y);
                if (cellSecond == .Empty or cellSecond == .Sand) {
                    level.setCell(x, y, cellSecond);
                    level.setCell(x + second, y, .Water);
                    break :blk;
                }
            },
            else => {},
        }
    }
};
