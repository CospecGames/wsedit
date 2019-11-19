/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsedit.widgets.headerbar;
import gtk.HeaderBar;
import gtk.Box;
import gtk.Button;
import gtk.Image;
import gtk.Widget;
import gtk.StyleContext;
import gtk.EventBox;
import gtk.Label;
import gtk.Revealer;
import gdk.Event;
import gtk.Popover;
import dazzle.EntryBox;
import dazzle.PriorityBox;
import dazzle.ApplicationWindow;
import dazzle.MenuButton;

import gio.Menu;
import gio.MenuItem;
import gio.SimpleAction;

import gdk.Event;

import wsedit;
import wsedit.widgets;
import wsedit.helpers;
import wsedit.windows.appwin;

class WSHeader : HeaderBar {
private:
    WSEditWindow appwin;

    /* I/O Section */
    Button newButton;
    MenuButton openButton;
    Button saveButton;
    Box ioBox;

    /* Info Section */
    EventBox titleEventBox;
    EntryBox titleBox;
    Label titleLabel;
    Button buildButton;
    Button runButton;

    /* Config Section */
    MenuButton settingsMenuButton;
    Button fullscreenButton;

    /* Helper functions */

    void buildLeftSection() {
        ioBox = new Box(Orientation.HORIZONTAL, 0);
        ioBox.getStyleContext().addClass("linked");

        Menu openMenu = new Menu();

        newButton = genButton("document-new-symbolic");
        newButton.addOnReleased((Button btn) {
            appwin.push("newScenePage");
        });


        openButton = new MenuButton("document-open-symbolic", openMenu);
        saveButton = genButton("document-save-symbolic");

        ioBox.packStart(newButton, false, false, 0);
        ioBox.packStart(openButton, false, false, 0);
        ioBox.packStart(saveButton, false, false, 0);

        this.packStart(ioBox);
    }

    Widget buildMidsection() {

        // First we generate all the changable widgets.
        buildButton = genButton("package-x-generic-symbolic");
        runButton = genButton("media-playback-start-symbolic");
        titleLabel = new Label("");

        // Add the text entry (the box around the label)
        titleEventBox = new EventBox();
        titleBox = new EntryBox();
        titleBox.packStart(titleEventBox, false, false, 0);

        titleEventBox.addOnButtonRelease((GdkEventButton* btn, Widget _) {
            
            if (btn.button == 1) {
                MessageBox.show("This feature is not implemented, <i>yet</i>.");
            }

            return true;
        });

        titleEventBox.add(titleLabel);

        // Create the priority box, add the linked style class to make the buttons and the entry box merge together.
        PriorityBox priority = new PriorityBox();
        priority.getStyleContext.addClass("linked");

        // Pack it up and return it.
        priority.packStart(buildButton, false, false, 0);
        priority.packStart(titleBox, false, false, 0);
        priority.packStart(runButton, false, false, 0);
        return priority;
    }

    void buildRightSection() {

        fullscreenButton = genButton("view-fullscreen-symbolic");
        fullscreenButton.addOnReleased((Button _) {
            appwin.setFullscreen(!appwin.getFullscreen());
            STATE.fullscreen = appwin.getFullscreen();
            this.setShowCloseButton(!appwin.getFullscreen());
            (cast(Image)fullscreenButton.getImage()).setFromIconName(appwin.getFullscreen ? "view-restore-symbolic" : "view-fullscreen-symbolic", IconSize.MENU);
        });

        Menu hamburgerModel = new Menu();
        hamburgerModel.append("About", "win.about-open");
        settingsMenuButton = new MenuButton("open-menu-symbolic", hamburgerModel);
        settingsMenuButton.setFocusOnClick(false);
        settingsMenuButton.setPopover(new Popover(settingsMenuButton, hamburgerModel));

        this.packEnd(fullscreenButton);
        this.packEnd(settingsMenuButton);
    }

    Button genButton(string imgSym) {
        Button btn = new Button();
        btn.setImage(new Image(imgSym, IconSize.MENU));
        return btn;
    }

public:
    /// Constructor
    this(WSEditWindow appwin) {
        this.appwin = appwin;
        this.setShowCloseButton(true);

        // Build all the window controls
        this.buildLeftSection();
        this.setCustomTitle(buildMidsection());
        this.buildRightSection();

        title = "";

        this.showAll();
    }

    /**
        Gets the current window title
    */
    @property string title() {
        return titleLabel.getText();
    }

    /**
        Sets the current window title
    */
    @property void title(string name) {
        string wname = name.length == 0 ? "Wereshift Scene Editor" : "Wereshift Scene Editor: " ~ name;

        // Set the systemwide window title
        appwin.setName(wname);
        appwin.setTitle(wname);

        // Set the title label.
        titleLabel.setText(name.length == 0 ? "Wereshift Scene Editor" : name);
    }
}