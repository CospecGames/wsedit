/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsedit.widgets.pathbox;
import gtk.Box;
import gtk.Button;
import gtk.Entry;
import gtk.FileChooserDialog;
import gtk.Window;
import wsedit.helpers;

class WSPathBox : Box {
private:
    Button browseButton;
    Entry browseEntry;
    string defaultPlaceholder = "";

public:
    this(FileChooserAction mode, string placeholder = "", string title = "Browse...", Window parent = null) {
        super(Orientation.HORIZONTAL, 0);
        this.getStyleContext().addClass("linked");

        if (placeholder.length == 0) {
            placeholder = buildPathForScene("Unnamed");
        }

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