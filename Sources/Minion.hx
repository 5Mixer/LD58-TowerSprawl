package ;

import kha.Assets;
import kha.graphics2.Graphics;
import kha.math.Vector2i;

enum MinionState {
    Sleep;
    Idle;
    Working(at: Vector2i);
    Walking(targetState: MinionState);
}

class Minion {
    public var pos: Vector2i;
    public var state: MinionState = Idle;
    public var bedPosition: Vector2i;
    var speed = 1;
    var mapPos: Vector2i; // Decoupled from pos as rounding/flooring jumps ahead during path finding

    public function new(pos: Vector2i) {
        this.mapPos = pos;
        this.pos = pos.mult(Game.TILE_SIZE);
        bedPosition = pos;
    }

    public function render(g: Graphics, t = 0) {
        g.drawSubImage(
            Assets.images.spritesheet,
            pos.x,
            pos.y,
            t * Game.TILE_SIZE,
            2 * Game.TILE_SIZE,
            Game.TILE_SIZE,
            Game.TILE_SIZE
        );
    }

    function walkTo(destination: Vector2i, map: TileMap, onArrival: () -> Void) {
        var path = map.pathfind(mapPos, destination);
        if (path.length > 1) {
            var delta = path[0].mult(Game.TILE_SIZE).sub(pos);
            if (delta.x > 0) pos.x += speed;
            if (delta.x < 0) pos.x -= speed;
            if (delta.y > 0) pos.y += speed;
            if (delta.y < 0) pos.y -= speed;
            if (delta.x == 0 && delta.y == 0) mapPos = path[0];
        } else {
            onArrival();
        }
    }

    public function update(map: TileMap) {
        switch (state) {
            case Sleep: {}
            case Idle: {}
            case Working(_): {}
            case Walking(targetState): {
                switch(targetState) {
                    case Working(location): walkTo(location, map, () -> { state = targetState; });
                    case Sleep: walkTo(bedPosition, map, () -> { state = targetState; });
                    default: { state = targetState; };
                }
            }
        }
    }
}