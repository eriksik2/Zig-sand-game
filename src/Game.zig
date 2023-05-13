const std = @import("std");
const RndGen = std.rand.DefaultPrng;

const sdl = @import("sdl2");

const Level = @import("Level.zig");
const LevelUpdater = @import("LevelUpdater.zig");

const Game = @This();

const RenderMode = enum {
    Cells,
    Temp,
};

level: *Level,
rndGen: RndGen,
rnd: std.rand.Random,
tickCount: u64,

renderMode: RenderMode,

pub fn init(allocator: *std.mem.Allocator) !*Game {
    var game: *Game = try allocator.create(Game);
    errdefer allocator.destroy(game);

    game.level = try Level.init(allocator, 128, 128);
    errdefer game.level.deinit(allocator);

    game.rndGen = RndGen.init(0);
    game.rnd = game.rndGen.random();

    game.tickCount = 0;
    game.renderMode = .Cells;

    return game;
}

pub fn deinit(game: *Game, allocator: *std.mem.Allocator) void {
    game.level.deinit(allocator);
    allocator.destroy(game);
}

pub fn setRenderMode(game: *Game, mode: RenderMode) void {
    game.renderMode = mode;
}

pub fn tick(game: *Game, allocator: *std.mem.Allocator) !void {
    var updater = try LevelUpdater.init(allocator, game.level);
    defer updater.deinit(allocator);

    var oddness = game.rnd.boolean();
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
            if (updater.getDidWrite(x, y)) continue;
            var cell = game.level.getCell(x, y);

            if (@mod(game.tickCount, 2) == 0) {
                cell.update(x, y, game, updater);
                cell = game.level.getCell(x, y);
            }

            // Temp update
            const temp = cell.temp;
            const disipateTemp = temp * 0.3;
            game.level.setTemp(x, y, temp - disipateTemp);
            const Pos = struct { dx: i32, dy: i32 };
            const check: [8]Pos = .{
                .{ .dx = -1, .dy = 0 },
                .{ .dx = 1, .dy = 0 },
                .{ .dx = 0, .dy = -1 },
                .{ .dx = 0, .dy = 1 },
                .{ .dx = -1, .dy = -1 },
                .{ .dx = 1, .dy = -1 },
                .{ .dx = -1, .dy = 1 },
                .{ .dx = 1, .dy = 1 },
            };
            for (check) |square| {
                const sx = x + square.dx;
                const sy = y + square.dy;
                const sTemp = game.level.getCell(sx, sy).temp;
                game.level.setTemp(sx, sy, sTemp + disipateTemp / 8);
            }
        }
    }
    game.tickCount +%= 1;
}

pub fn render(game: *Game, renderer: *sdl.Renderer) !void {
    const renderSize = try renderer.getOutputSize();
    const squareWidth = @divTrunc(renderSize.width_pixels, @intCast(c_int, game.level.width));
    const squareHeight = @divTrunc(renderSize.height_pixels, @intCast(c_int, game.level.height));

    for (0..game.level.cells.len) |i| {
        const x = @mod(@intCast(c_int, i), @intCast(c_int, game.level.width));
        const y = @divTrunc(@intCast(c_int, i), @intCast(c_int, game.level.width));

        var rect = sdl.Rectangle{
            .x = x * squareWidth,
            .y = y * squareHeight,
            .width = squareWidth,
            .height = squareHeight,
        };

        const cell = game.level.cells[i];
        const temp = cell.temp;

        var finalColor = sdl.Color{ .r = 0, .g = 0, .b = 0, .a = 255 };
        switch (cell.type) {
            .Empty => {
                finalColor = sdl.Color{ .r = 0, .g = 0, .b = 0, .a = 255 };
            },
            .Wall => {
                finalColor = sdl.Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
            },
            .Sand => {
                finalColor = sdl.Color{ .r = 255, .g = 255, .b = 48, .a = 255 };
            },
            .Water => {
                finalColor = sdl.Color{ .r = 48, .g = 48, .b = 255, .a = 255 };
            },
            .Steam => {
                finalColor = sdl.Color{ .r = 128, .g = 128, .b = 128, .a = 255 };
            },
            .HeatGenerator => {
                finalColor = sdl.Color{ .r = 255, .g = 0, .b = 0, .a = 255 };
            },
            .ColdGenerator => {
                finalColor = sdl.Color{ .r = 0, .g = 0, .b = 255, .a = 255 };
            },
            .Ember => |ember| {
                var burn = ember.burn;
                if (burn > 1) burn = 1;
                if (burn < 0) burn = 0;
                finalColor = sdl.Color{ .r = @floatToInt(u8, 228 * burn), .g = @floatToInt(u8, 128 * burn), .b = 0, .a = 255 };
            },
            .Fire => {
                finalColor = sdl.Color{ .r = 255, .g = 128, .b = 0, .a = 255 };
            },
            .Smoke => {
                finalColor = sdl.Color{ .r = 28, .g = 28, .b = 28, .a = 255 };
            },
            .Wood => {
                finalColor = sdl.Color{ .r = 133, .g = 58, .b = 24, .a = 255 };
            },
        }

        // Temp color
        const blueTemp = -500;
        const redTemp = 500;
        var t = (temp - blueTemp) / (redTemp - blueTemp);
        if (t < 0) t = 0;
        if (t > 1) t = 1;
        const red = sdl.Color{ .r = 255, .g = 0, .b = 0, .a = 255 };
        const blue = sdl.Color{ .r = 0, .g = 0, .b = 255, .a = 255 };
        var tempColor = lerpColor(blue, red, t);
        finalColor = lerpColor(tempColor, finalColor, 0.8);

        try renderer.setColor(finalColor);

        try renderer.fillRect(rect);
    }
}

fn lerpColor(a: sdl.Color, b: sdl.Color, t: f32) sdl.Color {
    return sdl.Color{
        .r = @intCast(u8, @floatToInt(u8, @intToFloat(f32, a.r) * (1.0 - t) + @intToFloat(f32, b.r) * t)),
        .g = @intCast(u8, @floatToInt(u8, @intToFloat(f32, a.g) * (1.0 - t) + @intToFloat(f32, b.g) * t)),
        .b = @intCast(u8, @floatToInt(u8, @intToFloat(f32, a.b) * (1.0 - t) + @intToFloat(f32, b.b) * t)),
        .a = @intCast(u8, @floatToInt(u8, @intToFloat(f32, a.a) * (1.0 - t) + @intToFloat(f32, b.a) * t)),
    };
}
