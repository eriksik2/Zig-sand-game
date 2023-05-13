const Level = @import("Level.zig");
const LevelUpdater = @import("LevelUpdater.zig");
const Game = @import("Game.zig");

const Cell = @This();

pub const CellType = union(enum) {
    Empty: void,
    Sand: @import("cellTypes/Sand.zig"),
    Wall: void,
    Water: @import("cellTypes/Water.zig"),
    Steam: @import("cellTypes/Steam.zig"),
    HeatGenerator: @import("cellTypes/HeatGenerator.zig"),
    ColdGenerator: @import("cellTypes/ColdGenerator.zig"),
    Ember: @import("cellTypes/Ember.zig"),
    Fire: @import("cellTypes/Fire.zig"),
    Wood: @import("cellTypes/Wood.zig"),
};

temp: f32,
type: CellType,

pub fn update(cell: Cell, x: i32, y: i32, game: *Game, updater: *LevelUpdater) void {
    const typeInfo = @typeInfo(CellType).Union;
    inline for (typeInfo.fields) |field| {
        const tag = @field(typeInfo.tag_type.?, field.name);
        const fieldType = field.type;

        if (cell.type == tag) {
            if (fieldType == void) {
                return;
            }
            return @call(.auto, @field(fieldType, "update"), .{ cell, x, y, game, updater });
        }
    }
    unreachable;
}
