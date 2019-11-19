module wsedit.widgets.sidebar;
import gtk.Box;
import gtk.Widget;
import gtk.ScrolledWindow;
import gtk.Revealer;
import dazzle.DockBin;
import wsedit.widgets.tilebox;
import gtk.Box;
import wsedit.workspace;

class Sidebar : Revealer {
private:
    Box widgetsBox;
    Workspace workspace;

public:
    TileBox tb;

    this(Workspace workspace) {
        this.workspace = workspace;

        widgetsBox = new Box(Orientation.VERTICAL, 8);
        tb = new TileBox(workspace);
        tb.setValign(Align.START);
        widgetsBox.packStart(tb, true, true, 0);
        this.add(widgetsBox);
        
        this.setTransitionType(GtkRevealerTransitionType.SLIDE_RIGHT);
        this.setTransitionDuration(200);

        this.close();
    }

    bool toggle() {
        this.setRevealChild(!this.getRevealChild());
        return this.getRevealChild();
    }

    void open() {
        this.setRevealChild(true);
    }

    void close() {
        this.setRevealChild(false);
    }

}
