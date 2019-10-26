/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsedit.widgets.pages.newscene;
import gtk.Popover;
import gtk.Box;
import gtk.ButtonBox;
import gtk.Button;
import gtk.Widget;
import gtk.Entry;
import gtk.Viewport;
import gtk.Adjustment;
import handy.PreferencesPage;
import handy.ActionRow;
import handy.PreferencesGroup;
import dazzle.ThreeGrid;
import wsedit.windows.appwin;
import gtk.Label;
import gobject.Value;
import std.conv : text;
import std.format;
import wsedit.widgets;
import wsedit.helpers;
import wsedit;

/**
    Wereshift editor new scene Popover
*/
class WSPageNew : Viewport {
private:
    WSEditWindow window;

    ThreeGrid grid;

    Entry nameEntry;
    WSPathBox pathBox;
    WSVecCombo defaultSize;
    WSVecCombo sceneSize;

    Button createScene;
    Button cancelScene;

    void createSetup() {
        grid = new ThreeGrid();

        nameEntry = new Entry();
        nameEntry.setPlaceholderText("My New Scene");
        nameEntry.addOnChanged((_) {
            pathBox.setPlaceholder(buildPathForScene(nameEntry.getText));
        });

        pathBox = new WSPathBox(FileChooserAction.SAVE);

        defaultSize = new WSVecCombo(0, "Width", "Height", false, 1);
        defaultSize.addOnChanged((dim) {
            sceneSize.setXIncrement(defaultSize.getX!double);
            sceneSize.setYIncrement(defaultSize.getY!double);
        });
        sceneSize = new WSVecCombo(0, "Width", "Height", false, 1);

        createScene = new Button("Create");
        createScene.getStyleContext().addClass("suggested-action");
        createScene.addOnReleased((_) {
            import std.file : mkdirRecurse, write, exists;
            import std.path : dirName, baseName;
            string dir = dirName(pathBox.getDir());
            string file = pathBox.getDir();
            string fileName = baseName(pathBox.getDir());

            if (!exists(dir)) mkdirRecurse(dir);
            if (file.exists) {

                // If the user does NOT want to overwrite the file, don't.
                if (MessageBox.show("%s already exists, overwrite?".format(fileName), GtkMessageType.WARNING, ButtonsType.YES_NO) == ResponseType.NO) {
                    return;
                }
            }
            STATE.currentSceneFile = file;
            STATE.createScene(nameEntry.getText(), sceneSize.getX!int, sceneSize.getY!int);
            STATE.tileWidth = defaultSize.getX!int;
            STATE.tileHeight = defaultSize.getY!int;

            // Update window
            window.updateTitle(nameEntry.getText());
            window.workspace.queueDraw();
            window.stack.setVisibleChildName("workspace");
            reset();
        });

        cancelScene = new Button("Cancel");
        cancelScene.addOnReleased((_) {
            window.stack.setVisibleChildName("workspace");
            reset();
        });

        addOption(0, new Label("Scene Name"), nameEntry);
        addOption(1, new Label("Scene File"), pathBox);
        addOption(2, new Label("Default Tile Size"), defaultSize);
        addOption(3, new Label("Scene Size"), sceneSize);
        addButtons(4, cancelScene, createScene);

        grid.setRowSpacing(24);
        grid.setColumnSpacing(24);
        grid.setHalign(Align.FILL);
        grid.setMarginTop(72);
        this.add(grid);
    }

    void addOption(uint row, Label title, Widget child) {
        title.setHalign(Align.END);
        child.setHalign(Align.FILL);
        grid.addAt(title, row, ThreeGridColumn.LEFT);
        grid.addAt(child, row, ThreeGridColumn.CENTER);
    }

    void addButtons(uint row, Button buttonA, Button buttonB) {
        buttonA.setHalign(Align.END);
        buttonB.setHalign(Align.END);
        grid.addAt(buttonA, row, ThreeGridColumn.LEFT);
        grid.addAt(buttonB, row, ThreeGridColumn.CENTER);
    }

    void reset() {
        nameEntry.setText("");
        pathBox.setDir("");
        defaultSize.reset();
        sceneSize.reset();
    }

public:
    this(WSEditWindow win) {
        super(new Adjustment(512, 256, 1024, 1, 1, 1), new Adjustment(1024, 1024, 2048, 1, 1, 1));
        this.window = win;
        createSetup();
    }
}