module wsedit.widgets.sidebar;
import gtk.Box;
import gtk.Widget;
import gtk.ScrolledWindow;
import gtk.Revealer;
import dazzle.DockBin;

class Sidebar : Revealer {
public:

    this() {
    }

    void open() {
        this.setRevealChild(true);
    }

    void close() {
        this.setRevealChild(false);
    }

}
