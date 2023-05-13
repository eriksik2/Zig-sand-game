const std = @import("std");
const Sdk = @import("SDL.zig/Sdk.zig"); // Import the Sdk at build time

pub fn build(b: *std.Build.Builder) !void {
    // Determine compilation target
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .Debug,
    });

    // Create a new instance of the SDL2 Sdk
    const sdk = Sdk.init(b, null);

    // Create executable for our example
    const demo_basic = b.addExecutable(.{
        .name = "zig-falling-sand",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = mode,
        //.link_libc = true,
    });

    sdk.link(demo_basic, .dynamic); // link SDL2 as a shared library

    // Add "sdl2" package that exposes the SDL2 api (like SDL_Init or SDL_CreateWindow)
    demo_basic.addModule("sdl2", sdk.getWrapperModule());

    // Install the executable into the prefix when invoking "zig build"
    b.installArtifact(demo_basic);
}
