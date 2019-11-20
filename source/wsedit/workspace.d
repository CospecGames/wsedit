/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsedit.workspace;
import wsedit.subsystem.wsrenderer;
import wsedit.subsystem.mouse;
import wsedit.fmt;
import wsedit.widgets;
import wsedit;
import wsedit.subsystem.tilemgr;

import gtk.Overlay;
import gtk.Widget;
import gtk.Revealer;
import gtk.Box;
import gtk.Image;
import gtk.Button;

/**
    A WSEdit workspace
*/
class Workspace : Box {
private:
    Overlay overlay;
    Sidebar sidebar;
    Button sidebarBtn;

public:
    /**
        Viewport
    */
    WSViewport viewport;

    /**
        Toolbox
    */
    Toolbox toolbox;

    /**
        The renderer
    */
    Renderer renderer;

    /**
        The project attached to this workspace
    */
    WSEProject project;

    /**
        The tile manager
    */
    TileManager tiles;

    /**
        The page number of this workspace
    */
    uint pageNumber;

    /**
        The camera
    */
    Camera2D camera;

    /**
        Mouse cursor
    */
    Mouse mouse;

    /**
        Creates a new workspace
    */
    this(WSEProject project) {
        super(Orientation.HORIZONTAL, 0);
        this.project = project;

        // Place camera at center of scene

        mouse = new Mouse();
        tiles = new TileManager();
        viewport = new WSViewport(this);
        renderer = new Renderer(viewport);
        overlay = new Overlay();
        toolbox = new Toolbox();
        toolbox.setValign(Align.START);
        toolbox.setHalign(Align.START);
        overlay.add(viewport);
        overlay.addOverlay(toolbox);
        
        GridConfig gridConfig;
        gridConfig.cellSizeX = project.sceneInfo.tileWidth;
        gridConfig.cellSizeY = project.sceneInfo.tileHeight;
        gridConfig.cellsX = project.sceneInfo.width;
        gridConfig.cellsY = project.sceneInfo.height;
        renderer.setGridConfig(gridConfig);

        // Test tool
        import wsedit.tools.tiletool;
        TileTool tiletool = new TileTool(this);

        import gtk.Widget : Widget;
        import gdk.FrameClock : FrameClock;
        viewport.addTickCallback((Widget, FrameClock) {
            viewport.update();
            tiletool.update(mouse);
            queueDraw();
            mouse.feedScroll(0);
            return true;
        });

        viewport.addOnSizeAllocate((req, _) {
            camera.origin = Vector2(req.width/2, req.height/2);
        });

        /* Mouse controls */
        viewport.addOnMotionNotify((GdkEventMotion* ev, _) {
            mouse.feedPosition(Vector2(ev.x, ev.y));
            return false;
        });

        viewport.addOnButtonPress((GdkEventButton* ev, Widget) {
            mouse.feedPosition(Vector2(ev.x, ev.y));
            mouse.feedPress(ev.button);
            return false;
        });

        viewport.addOnButtonRelease((GdkEventButton* ev, Widget) {
            mouse.feedPosition(Vector2(ev.x, ev.y));
            mouse.feedRelease(ev.button);
            return false;
        });

        viewport.addOnScroll((GdkEventScroll* ev, Widget) {
            mouse.feedPosition(Vector2(ev.x, ev.y));
            mouse.feedScroll(ev.direction == ScrollDirection.UP ? -1 : 1);
            return false;
        });

        /* Draw */
        import cairo.Context : Context;
        viewport.addOnDraw((Scoped!Context ctx, Widget _) {
            renderer.begin(ctx);
                renderer.applyCamera(camera);
                renderer.renderGrid();
            renderer.end();

            // Render tiles
            renderer.setAntiAlias(false);
            renderer.begin(ctx);
                renderer.applyCamera(camera);

                tiletool.draw(renderer);

            renderer.end();
            return false; 
        });

        sidebar = new Sidebar(this);
        sidebarBtn = new Button();
        sidebarBtn.setImage(new Image("go-previous-symbolic", IconSize.MENU));
        sidebarBtn.addOnReleased((_) {
            sidebarBtn.setImage(sidebar.toggle() ? new Image("go-next-symbolic", IconSize.MENU) : new Image("go-previous-symbolic", IconSize.MENU));
        });
        sidebarBtn.setValign(Align.START);
        sidebarBtn.setHalign(Align.END);
        sidebarBtn.setMarginTop(8);
        sidebarBtn.setMarginRight(8);
        overlay.addOverlay(sidebarBtn);

        this.packStart(overlay, true, true, 0);
        this.packEnd(sidebar, false, false, 0);


        if (tiles !is null) {
            tiles.add("res/x_tiles/simpleTileset_orange.png");
        }
    }

}