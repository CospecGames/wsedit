module wsedit.widgets.pathbox;
import gtk.Box;
import gtk.Button;
import gtk.Entry;
import gtk.FileChooserDialog;
import gtk.Window;

class WSPathBox : Box {
private:
    Button browseButton;
    Entry browseEntry;
    string defaultPlaceholder = "";

public:
    this(FileChooserAction mode, string placeholder = "Unnamed.lvl", string title = "Browse...", Window parent = null) {
        super(Orientation.HORIZONTAL, 0);
        this.getStyleContext().addClass("linked");

        browseButton = new Button("Browse...");
        browseEntry = new Entry(""); 
        setPlaceholder(placeholder);
        defaultPlaceholder = placeholder;

        this.browseButton.addOnReleased((Widget) {
            FileChooserDialog diag = new FileChooserDialog(title, parent, mode, ["Cancel", "Save"], [ResponseType.REJECT, ResponseType.OK]);
            scope(exit) diag.destroy();
            if (diag.run() == ResponseType.OK) {
                this.setDir(diag.getFile.getPath());
            }
        });

        int width, height;
        this.getSizeRequest(width, height);
        this.setSizeRequest(384, height);

        this.packStart(browseEntry, true, true, 0);
        this.packEnd(browseButton, false, false, 0);
    }

    void setPlaceholder(string placeholder) {
        browseEntry.setPlaceholderText(placeholder == "" ? defaultPlaceholder : placeholder);
    }

    void setDir(string dir) {
        browseEntry.setText(dir);
    }

    string getDir() {
        string entry = browseEntry.getText();
        return entry.length == 0 ? browseEntry.getPlaceholderText() : entry;
    }
}