const Level = @import("Level.zig");
const LevelUpdater = @import("LevelUpdater.zig");
const Game = @import("Game.zig");

const Cell = @This();

pub const MaterialState = enum(u8) {
    SolidFixed,
    Solid,
    Liquid,
    Gas,
    None,
};

pub const MaterialProps = struct {
    state: MaterialState,
    density: f32,
    //heatTransfer: f32,
};

pub const CellType = union(enum) {
    Empty: void,
    Sand: @import("cellTypes/Sand.zig"),
    Wall: @import("cellTypes/Wall.zig"),
    Water: @import("cellTypes/Water.zig"),
    Steam: @import("cellTypes/Steam.zig"),
    HeatGenerator: @import("cellTypes/HeatGenerator.zig"),
    ColdGenerator: @import("cellTypes/ColdGenerator.zig"),
    Ember: @import("cellTypes/Ember.zig"),
    Fire: @import("cellTypes/Fire.zig"),
    Smoke: @import("cellTypes/Smoke.zig"),
    Wood: @import("cellTypes/Wood.zig"),
};

temp: f32,
type: CellType,

pub fn getMaterialProps(cell: Cell) MaterialProps {
    const typeInfo = @typeInfo(CellType).Union;
    inline for (typeInfo.fields) |field| {
        const tag = @field(typeInfo.tag_type.?, field.name);
        const fieldType = field.type;

        if (cell.type == tag) {
            if (fieldType == void) {
                return MaterialProps{
                    .state = .None,
                    .density = 0,
                };
            }
            return @field(fieldType, "materialProps");
        }
    }
    unreachable;
}

pub fn update(cell: Cell, x: i32, y: i32, game: *Game, updater: *LevelUpdater) void {
    const typeInfo = @typeInfo(CellType).Union;
    inline for (typeInfo.fields) |field| {
        const tag = @field(typeInfo.tag_type.?, field.name);
        const fieldType = field.type;

        if (cell.type == tag) {
            if (fieldType == void) {
                return;
            }
            const didMove = @call(.auto, @field(fieldType, "update"), .{ cell, x, y, game, updater });
            if (!didMove) {
                switch (cell.getMaterialProps().state) {
                    .SolidFixed => {},
                    .Solid => {},
                    .Liquid => updateLiquid(cell, x, y, game, updater),
                    .Gas => updateGas(cell, x, y, game, updater),
                    .None => {},
                }
            }
            return;
        }
    }
    unreachable;
}

pub fn updateLiquid(self: Cell, x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
    const rnd = game.rnd;
    const props = self.getMaterialProps();

    falling: {
        const fallDir: i32 = 1;
        var cellBelow = level.getCell(x, y + 1);
        const cellBelowProps = cellBelow.getMaterialProps();

        if (cellBelowProps.state == .SolidFixed) {
            break :falling;
        }
        if (fallDir < 0 and props.density >= cellBelowProps.density) {
            break :falling;
        }
        if (fallDir > 0 and props.density <= cellBelowProps.density) {
            break :falling;
        }
        level.setCell(x, y, cellBelow);
        level.setCell(x, y + fallDir, self);
        return;
    }

    const Pos = struct { dx: i32, dy: i32 };
    var check1: [2]Pos = .{
        .{ .dx = -1, .dy = 0 },
        .{ .dx = 1, .dy = 0 },
    };
    rnd.shuffle(Pos, &check1);
    for (check1) |c| {
        var cell = level.getCell(x + c.dx, y + c.dy);
        const cellProps = cell.getMaterialProps();
        if (cellProps.state == .SolidFixed) {
            continue;
        }
        level.setCell(x, y, cell);
        level.setCell(x + c.dx, y + c.dy, self);
        return;
    }
}

pub fn updateGas(self: Cell, x: i32, y: i32, game: *Game, level: *LevelUpdater) void {
    const rnd = game.rnd;
    const props = self.getMaterialProps();
    const Pos = struct { dx: i32, dy: i32 };
    var check2: [8]Pos = .{
        .{ .dx = -1, .dy = 0 },
        .{ .dx = 1, .dy = 0 },
        .{ .dx = -1, .dy = -1 },
        .{ .dx = 0, .dy = -1 },
        .{ .dx = 1, .dy = -1 },
        .{ .dx = -1, .dy = 1 },
        .{ .dx = 0, .dy = 1 },
        .{ .dx = 1, .dy = 1 },
    };
    rnd.shuffle(Pos, &check2);
    for (check2) |c| {
        var cell = level.getCell(x + c.dx, y + c.dy);
        const cellProps = cell.getMaterialProps();
        if (cellProps.state == .SolidFixed) {
            continue;
        }
        if (c.dy < 0 and props.density > cellProps.density) {
            continue;
        }
        if (c.dy > 0 and props.density < cellProps.density) {
            continue;
        }
        level.setCell(x, y, cell);
        level.setCell(x + c.dx, y + c.dy, self);
        return;
    }
}
