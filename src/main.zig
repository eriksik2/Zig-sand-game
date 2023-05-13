const std = @import("std");
const RndGen = std.rand.DefaultPrng;

const sdl = @import("sdl2");

const Level = @import("Level.zig");
const LevelUpdater = @import("LevelUpdater.zig");
const Game = @import("Game.zig");
const Cell = @import("Cell.zig");

pub fn main() !void {
    var out = std.io.getStdOut().writer();
    var allocator = std.heap.page_allocator;

    try sdl.init(.{
        .video = true,
        .events = true,
        .audio = true,
    });
    defer sdl.quit();

    var window = try sdl.createWindow(
        "SDL2 Wrapper Demo",
        .{ .centered = {} },
        .{ .centered = {} },
        640 * 2,
        480 * 2,
        .{ .vis = .shown },
    );
    defer window.destroy();

    var renderer = try sdl.createRenderer(window, null, .{ .accelerated = true });
    defer renderer.destroy();

    var game = try Game.init(&allocator);
    defer game.deinit(&allocator);

    const levelUtils = @import("levelUtils.zig");
    try out.print("{}\n", .{levelUtils.invLerpVar(50, 100, 50)});
    try out.print("{}\n", .{levelUtils.invLerpVar(60, 100, 50)});
    try out.print("{}\n", .{levelUtils.invLerpVar(100, 100, 50)});
    try out.print("{}\n", .{levelUtils.invLerpVar(140, 100, 50)});
    try out.print("{}\n", .{levelUtils.invLerpVar(150, 100, 50)});

    var paused = false;
    var lmouseDown = false;
    var rmouseDown = false;
    var mouseX: c_int = 0;
    var mouseY: c_int = 0;
    var spawnCell: Cell.CellType = .{
        .Sand = .{},
    };
    mainLoop: while (true) {
        while (sdl.pollEvent()) |ev| {
            switch (ev) {
                .quit => break :mainLoop,
                .mouse_button_down => |mb| {
                    switch (mb.button) {
                        .left => lmouseDown = true,
                        .right => rmouseDown = true,
                        else => {},
                    }
                    mouseX = mb.x;
                    mouseY = mb.y;
                },
                .mouse_button_up => |mb| {
                    switch (mb.button) {
                        .left => lmouseDown = false,
                        .right => rmouseDown = false,
                        else => {},
                    }
                },
                .mouse_motion => |mm| {
                    mouseX = mm.x;
                    mouseY = mm.y;
                },
                .key_up => |kb| {
                    switch (kb.keycode) {
                        .escape => break :mainLoop,
                        .space => paused = !paused,
                        .@"1" => game.setRenderMode(.Cells),
                        .@"2" => game.setRenderMode(.Temp),
                        .w => {
                            spawnCell = .Water;
                            try out.print("{s}\n", .{@tagName(spawnCell)});
                        },
                        .s => {
                            spawnCell = .Sand;
                            try out.print("{s}\n", .{@tagName(spawnCell)});
                        },
                        .a => {
                            spawnCell = .Wall;
                            try out.print("{s}\n", .{@tagName(spawnCell)});
                        },
                        .h => {
                            spawnCell = .HeatGenerator;
                            try out.print("{s}\n", .{@tagName(spawnCell)});
                        },
                        .c => {
                            spawnCell = .ColdGenerator;
                            try out.print("{s}\n", .{@tagName(spawnCell)});
                        },
                        //.z => spawnCell = @intToEnum(Cell, @mod(@enumToInt(spawnCell) + 1, @typeInfo(Cell).Enum.fields.len)),
                        //.x => spawnCell = @intToEnum(Cell, @mod((@intCast(i32, @enumToInt(spawnCell)) - 1), @intCast(i32, @typeInfo(Cell).Enum.fields.len))),
                        else => {},
                    }
                },
                else => {},
            }
        }

        var x: i32 = @intCast(i32, mouseX);
        var y: i32 = @intCast(i32, mouseY);
        const renderSize = try renderer.getOutputSize();
        const squareWidth = @divTrunc(renderSize.width_pixels, @intCast(c_int, game.level.width));
        const squareHeight = @divTrunc(renderSize.height_pixels, @intCast(c_int, game.level.height));

        var mouseCellX = @divTrunc(x, squareWidth);
        var mouseCellY = @divTrunc(y, squareHeight);

        if (lmouseDown) {
            if (game.renderMode == .Temp) {
                const temp = game.level.getCell(mouseCellX, mouseCellY).temp;
                game.level.setTemp(mouseCellX, mouseCellY, temp + 50.0);
            } else setCellsBrush(game.level, mouseCellX, mouseCellY, spawnCell);
        }
        if (rmouseDown) {
            if (game.renderMode == .Temp) {
                const temp = game.level.getCell(mouseCellX, mouseCellY).temp;
                game.level.setTemp(mouseCellX, mouseCellY, temp - 50.0);
            } else setCellsBrush(game.level, mouseCellX, mouseCellY, .Empty);
        }

        if (!paused) try game.tick(&allocator);

        try renderer.setColorRGB(0xF7, 0xA4, 0x1D);
        try renderer.clear();

        try game.render(&renderer);

        renderer.present();
        //std.time.sleep(10 * std.time.ns_per_ms);
    }
}

fn setCellsBrush(level: *Level, x: i32, y: i32, cell: Cell.CellType) void {
    const brushSize = 4;
    const hb = @divTrunc(brushSize, 2);
    var ix = x - hb;
    while (ix < x + hb) : (ix += 1) {
        var iy = y - hb;
        while (iy < y + hb) : (iy += 1) {
            level.setCellType(ix, iy, cell);
        }
    }
}
