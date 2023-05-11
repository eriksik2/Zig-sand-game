const std = @import("std");
const RndGen = std.rand.DefaultPrng;

const sdl = @import("sdl2");

const Level = @import("Level.zig");

const Game = @This();

level: *Level,
rnd: RndGen,

pub fn init(allocator: *std.mem.Allocator) !*Game {
    var game: *Game = try allocator.create(Game);
    errdefer allocator.destroy(game);

    game.level = try Level.init(allocator, 128, 128);
    errdefer game.level.deinit(allocator);

    game.rnd = RndGen.init(0);

    return game;
}

pub fn deinit(game: *Game, allocator: *std.mem.Allocator) void {
    game.level.deinit(allocator);
    allocator.destroy(game);
}

pub fn tick(game: *Game) void {
    var oddness = game.rnd.random().boolean();
    var y: i32 = @intCast(i32, game.level.height) - 1;
    while (y >= 0) : (y -= 1) {
        var i: i32 = 0;
        while (i < game.level.width) : (i += 1) {
            var odd = @mod(i, 2) == 1;
            var x: i32 = i;
            if (odd) {
                x = @intCast(i32, game.level.width) - i;
            }
            if (oddness) {
                x = @mod(x + 1, @intCast(i32, game.level.width));
            }
            var cell = game.level.getCell(x, y);
            cell.update(x, y, game);
        }
    }
}

pub fn render(game: *Game, renderer: *sdl.Renderer) !void {
    const renderSize = try renderer.getOutputSize();
    const squareWidth = @divTrunc(renderSize.width_pixels, @intCast(c_int, game.level.width));
    const squareHeight = @divTrunc(renderSize.height_pixels, @intCast(c_int, game.level.height));

    for (game.level.cells.items, 0..) |cell, i| {
        const x = @mod(@intCast(c_int, i), @intCast(c_int, game.level.width));
        const y = @divTrunc(@intCast(c_int, i), @intCast(c_int, game.level.width));

        var rect = sdl.Rectangle{
            .x = x * squareWidth,
            .y = y * squareHeight,
            .width = squareWidth,
            .height = squareHeight,
        };

        switch (cell) {
            .Empty => {
                try renderer.setColor(sdl.Color{ .r = 0, .g = 0, .b = 0, .a = 255 });
            },
            .Wall => {
                try renderer.setColor(sdl.Color{ .r = 255, .g = 255, .b = 255, .a = 255 });
            },
            .Sand => {
                try renderer.setColor(sdl.Color{ .r = 255, .g = 255, .b = 0, .a = 255 });
            },
            .Water => {
                try renderer.setColor(sdl.Color{ .r = 0, .g = 0, .b = 255, .a = 255 });
            },
        }

        try renderer.fillRect(rect);
    }
}
