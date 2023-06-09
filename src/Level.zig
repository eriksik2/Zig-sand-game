const std = @import("std");
const Cell = @import("Cell.zig");

const Level = @This();

width: u32,
height: u32,
cells: []Cell,

pub fn init(allocator: *std.mem.Allocator, width: u32, height: u32) !*Level {
    var self: *Level = try allocator.create(Level);
    errdefer allocator.destroy(self);
    self.* = undefined;
    self.width = width;
    self.height = height;

    self.cells = try allocator.alloc(Cell, width * height);
    errdefer allocator.free(self.cells);
    @memset(self.cells, .{ .temp = 20, .type = .Empty });

    return self;
}

pub fn deinit(self: *Level, allocator: *std.mem.Allocator) void {
    allocator.free(self.cells);
    allocator.destroy(self);
}

fn getIndex(self: *const Level, x: u32, y: u32) u64 {
    std.debug.assert(x < self.width);
    std.debug.assert(y < self.height);
    return x + y * self.width;
}

fn getPosition(self: *const Level, index: u64) struct { x: u32, y: u32 } {
    std.debug.assert(index < self.width * self.height);
    return .{
        .x = index % self.width,
        .y = index / self.width,
    };
}

pub fn setTemp(self: *Level, x: i32, y: i32, temp: f32) void {
    if (x < 0 or y < 0 or x >= self.width or y >= self.height) {
        return;
    }
    self.cells[self.getIndex(@intCast(u32, x), @intCast(u32, y))].temp = temp;
}

pub fn getCell(self: *const Level, x: i32, y: i32) Cell {
    if (x < 0 or y < 0 or x >= self.width or y >= self.height) {
        return .{ .temp = 20, .type = .Wall };
    }
    return self.cells[self.getIndex(@intCast(u32, x), @intCast(u32, y))];
}

pub fn setCell(self: *Level, x: i32, y: i32, cell: Cell) void {
    if (x < 0 or y < 0 or x >= self.width or y >= self.height) {
        return;
    }
    self.cells[self.getIndex(@intCast(u32, x), @intCast(u32, y))] = cell;
}

pub fn setCellType(self: *Level, x: i32, y: i32, cell: Cell.CellType) void {
    if (x < 0 or y < 0 or x >= self.width or y >= self.height) {
        return;
    }
    self.cells[self.getIndex(@intCast(u32, x), @intCast(u32, y))].type = cell;
}

pub fn makeCell(data: anytype) Cell {
    const DataType = @TypeOf(data);
    if (DataType == Cell) return data;
    if (DataType == @TypeOf(.enum_literal)) return data;
    const typeInfo = @typeInfo(Cell).Union;
    inline for (typeInfo.fields) |field| {
        if (field.type == DataType) {
            return @unionInit(Cell, field.name, data);
        }
    }
    @compileError("Invalid cell type: " ++ @typeName(DataType));
}
