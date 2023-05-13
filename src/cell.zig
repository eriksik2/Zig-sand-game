const Level = @import("Level.zig");
const LevelUpdater = @import("LevelUpdater.zig");
const Game = @import("Game.zig");

pub const Cell = union(enum) {
    Empty: void,
    Sand: @import("cellTypes/Sand.zig"),
    Wall: void,
    Water: @import("cellTypes/Water.zig"),
    Steam: @import("cellTypes/Steam.zig"),
    HeatGenerator: @import("cellTypes/HeatGenerator.zig"),
    ColdGenerator: @import("cellTypes/ColdGenerator.zig"),

    pub fn update(cell: Cell, x: i32, y: i32, game: *Game, updater: *LevelUpdater) void {
        const typeInfo = @typeInfo(Cell).Union;
        inline for (typeInfo.fields) |field| {
            const tag = @field(typeInfo.tag_type.?, field.name);
            const fieldType = field.type;

            if (cell == tag) {
                if (fieldType == void) {
                    return;
                }
                const cellValue = @field(cell, field.name);
                return @call(.auto, @field(fieldType, "update"), .{ cellValue, x, y, game, updater });
            }
        }
        unreachable;
    }
};
