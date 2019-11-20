/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsedit;
import gtk.Window;
import wsf.spec.scene;
import wsedit.subsystem.tilemgr;
import wsedit.fmt;

/**
    The currently "selected" index
*/
struct Selection {
    /**
        X index
    */
    double x;

    /**
        Y index
    */
    double y;

    /**
        X-end index
    */
    double toX;

    /**
        Y-end index
    */
    double toY;
}

/**
    A point in 2D space
*/
struct Vector2 {

    /**
        X coordinate
    */
    double x = 0.0;

    /**
        Y coordinate
    */
    double y = 0.0;
}

/**
    The 2D camera in the workspace
*/
struct Camera2D {
    /**
        Position of camera
    */
    Vector2 position;

    /**
        Origin of camera transform on-screen
    */
    Vector2 origin;

    /**
        Zoom level
    */
    double zoom = 1;

    /**
        Translates from cordinates from camera coordinates to scene coordinates
    */
    Vector2 toScene(Vector2 coords) {
        return Vector2(
            ((coords.x/zoom)-(origin.x == 0.0 ? 0 : origin.x/zoom))-position.x,
            ((coords.y/zoom)-(origin.y == 0.0 ? 0 : origin.y/zoom))-position.y
        );
    }
}

/**
    The model where the state is stored in
*/
struct StateModel {

    /// The main app window
    Window mainWindow;

    /// Wether the app is in fullscreen mode
    bool fullscreen;
}

/**
    The global application state
*/
__gshared StateModel STATE;