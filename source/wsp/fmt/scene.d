/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsp.fmt.scene;
import wsp.fmt.tile;

/**
    The structure for a Wereshift scene
*/
struct WSEScene {
    WSETileLayer[] layers;
}

/**
    A layer of tiles
*/
struct WSETileLayer {
    /**
        ID of the layer.

        Positive = infront of player
        Negative = behind the player
    */
    int orderId;

    /**
        Parallax scrolling factor
    */
    float parallaxFactor = 1;

    /**
        List of tiles
    */
    WSETile[] tiles;

    /**
        place tile in to layer; overwriting tiles at the same position
    */
    void place(WSETile ntile) {
        foreach(i, tile; tiles) {
            if (tile.x == ntile.x && tile.y == ntile.y) {
                tiles[i] = ntile;
                return;
            }
        }
        tiles ~= ntile;
    }

    /**
        Removes a tile at the specified location
    */
    void removeTileAt(uint x, uint y) {
        foreach(i; 0..tiles.length) {
            if (tiles[i].x == x && tiles[i].y == y) {
                removeTileI(i);
                return;
            }
        }
    }

    /**
        Removes a tile at the specified index
    */
    void removeTileI(size_t index) {
        tiles = tiles[0..index] ~ tiles[index+1..$];
    }
}