module wsedit.pages.initpage;
import wsedit.subsystem.wsrenderer;
import gtk.DrawingArea;
import gdk.Cairo;
import cairo.Context;

/**
    The first page seen when the application is started
*/
class WSPageInit : DrawingArea {
private:
    Renderer renderer;

public:

    /**
        Creates the init page
    */
    this() {
        super(512, 512);
        renderer = new Renderer(this);

        this.addOnDraw((Scoped!Context ctx, _) {

            // Start and end the render
            renderer.begin(ctx);
            scope(exit) renderer.end();

            // Render the logo
            return renderer.renderLogo("No scene loaded!");
            
        });

        
    }
}