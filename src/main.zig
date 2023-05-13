const std = @import("std");
const RndGen = std.rand.DefaultPrng;

const sdl = @import("sdl2");

const Level = @import("Level.zig");
const LevelUpdater = @import("LevelUpdater.zig");
const Game = @import("Game.zig");
const Cell = @import("cell.zig").Cell;

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
        640,
        480,
        .{ .vis = .shown },
    );
    defer window.destroy();

    var renderer = try sdl.createRenderer(window, null, .{ .accelerated = true });
    defer renderer.destroy();

    var game = try Game.init(&allocator);
    defer game.deinit(&allocator);

    var paused = false;
    var lmouseDown = false;
    var rmouseDown = false;
    var mouseX: c_int = 0;
    var mouseY: c_int = 0;
    var spawnCell: Cell = .{
        .Steam = .{},
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
                        //.z => spawnCell = @intToEnum(Cell, @mod(@enumToInt(spawnCell) + 1, @typeInfo(Cell).Enum.fields.len)),
                        //.x => spawnCell = @intToEnum(Cell, @mod((@intCast(i32, @enumToInt(spawnCell)) - 1), @intCast(i32, @typeInfo(Cell).Enum.fields.len))),
                        else => {},
                    }
                    try out.print("{s}\n", .{@tagName(spawnCell)});
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
            game.level.setCell(mouseCellX, mouseCellY, spawnCell);
        }
        if (rmouseDown) {
            game.level.setCell(mouseCellX, mouseCellY, .Empty);
        }

        if (!paused) try game.tick(&allocator);

        try renderer.setColorRGB(0xF7, 0xA4, 0x1D);
        try renderer.clear();

        try game.render(&renderer);

        renderer.present();
        std.time.sleep(10 * std.time.ns_per_ms);
    }
}
