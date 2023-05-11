const std = @import("std");
const RndGen = std.rand.DefaultPrng;

const sdl = @import("sdl2");

const Level = @import("Level.zig");
const LevelUpdater = @import("LevelUpdater.zig");

const Game = struct {
    level: Level,
};

var rnd = RndGen.init(0);

fn updateLevel(allocator: *std.mem.Allocator, level: *Level) !void {
    _ = allocator;
    var updater = level;
    //defer updater.deinit(allocator);
    var oddness = rnd.random().boolean();
    var y: i32 = @intCast(i32, level.height) - 1;
    while (y >= 0) : (y -= 1) {
        var i: i32 = 0;
        while (i < level.width) : (i += 1) {
            var odd = @mod(i, 2) == 1;
            var x: i32 = i;
            if (odd) {
                x = @intCast(i32, level.width) - i;
            }
            if (oddness) {
                x = @mod(x + 1, @intCast(i32, level.width));
            }
            var cell = updater.getCell(x, y);
            //if (updater.getDidWrite(x, x)) continue;
            switch (cell) {
                .Sand => blk: {
                    var below = updater.getCell(x, y + 1);
                    if (below == .Empty or below == .Water) {
                        updater.setCell(x, y, below);
                        updater.setCell(x, y + 1, .Sand);
                        break :blk;
                    }
                    var first: i32 = -1;
                    var second: i32 = 1;
                    if (rnd.random().boolean()) {
                        first = 1;
                        second = -1;
                    }
                    var cellFirst = updater.getCell(x + first, y + 1);
                    if (cellFirst == .Empty) {
                        updater.setCell(x, y, cellFirst);
                        updater.setCell(x + first, y + 1, .Sand);
                        break :blk;
                    }
                    var cellSecond = updater.getCell(x + second, y + 1);
                    if (cellSecond == .Empty) {
                        updater.setCell(x, y, cellSecond);
                        updater.setCell(x + second, y + 1, .Sand);
                        break :blk;
                    }
                },
                .Water => blk: {
                    var below = updater.getCell(x, y + 1);
                    if (below == .Empty) {
                        updater.setCell(x, y, below);
                        updater.setCell(x, y + 1, .Water);
                        break :blk;
                    }
                    var first: i32 = -1;
                    var second: i32 = 1;
                    if (rnd.random().boolean()) {
                        first = 1;
                        second = -1;
                    }
                    var cellFirst = updater.getCell(x + first, y + 1);
                    if (cellFirst == .Empty) {
                        updater.setCell(x, y, cellFirst);
                        updater.setCell(x + first, y + 1, .Water);
                        break :blk;
                    }
                    var cellSecond = updater.getCell(x + second, y + 1);
                    if (cellSecond == .Empty) {
                        updater.setCell(x, y, cellSecond);
                        updater.setCell(x + second, y + 1, .Water);
                        break :blk;
                    }
                    cellFirst = updater.getCell(x + first, y);
                    if (cellFirst == .Empty or cellFirst == .Sand) {
                        updater.setCell(x, y, cellFirst);
                        updater.setCell(x + first, y, .Water);
                        break :blk;
                    }
                    cellSecond = updater.getCell(x + second, y);
                    if (cellSecond == .Empty or cellSecond == .Sand) {
                        updater.setCell(x, y, cellSecond);
                        updater.setCell(x + second, y, .Water);
                        break :blk;
                    }
                },
                else => {},
            }
        }
    }
    //updater.commit();
}

fn printLevel(level: *Level) !void {
    var out = std.io.getStdOut().writer();
    try out.print("\n", .{});
    try out.print("\n", .{});
    try out.print("\n", .{});
    var y: i32 = 0;
    var x: i32 = 0;
    try out.print("|", .{});
    while (x < level.width) : (x += 1) {
        try out.print("-", .{});
    }
    try out.print("|", .{});
    try out.print("\n", .{});
    x = 0;
    while (y < level.height) : (y += 1) {
        x = 0;
        try out.print("|", .{});
        while (x < level.width) : (x += 1) {
            var cell = level.getCell(x, y);
            switch (cell) {
                .Empty => try out.print(" ", .{}),
                .Sand => try out.print("s", .{}),
                .Water => try out.print("w", .{}),
                else => try out.print("?", .{}),
            }
        }
        try out.print("|", .{});
        try out.print("\n", .{});
    }
    x = 0;
    try out.print("|", .{});
    while (x < level.width) : (x += 1) {
        try out.print("-", .{});
    }
    try out.print("|", .{});
}

pub fn main() !void {
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

    mainLoop: while (true) {
        while (sdl.pollEvent()) |ev| {
            switch (ev) {
                .quit => break :mainLoop,
                else => {},
            }
        }

        try renderer.setColorRGB(0xF7, 0xA4, 0x1D);
        try renderer.clear();

        renderer.present();
    }

    var level = try Level.init(&allocator, 20, 10);
    defer level.deinit(&allocator);

    var t: i32 = 0;
    while (true) {
        if (t <= 50) {
            level.setCell(19, 0, .Water);
            level.setCell(0, 0, .Sand);
        }
        try printLevel(level);
        try updateLevel(&allocator, level);
        std.time.sleep(10 * std.time.ns_per_ms);
        t += 1;
    }
}
