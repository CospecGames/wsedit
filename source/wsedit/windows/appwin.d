/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsedit.windows.appwin;
import dazzle.ApplicationWindow;
import dazzle.Application;
import gtk.Box;
import gtk.Button;
import gtk.Stack;
import gio.SimpleAction;
import wsedit.widgets;
import wsedit.windows.about;
import wsedit.widgets.pages;
import wsedit;

/**
    The main editor window
*/
class WSEditWindow : ApplicationWindow {
private:
    void setupActions() {
        SimpleAction aboutAction = new SimpleAction("about-open", null);
        aboutAction.addOnActivate((Variant, SimpleAction) {
            auto about = new WSAboutDialog();
            scope(exit) about.destroy();
            about.run();
        });
        addAction(aboutAction);
    }

    Box workspaceBox;

public:
    WSHeader header;
    Workspace workspace;
    Stack stack;

    this(Application app) {
        super(app);
        // Update the state to point to this as the main window
        STATE.mainWindow = this;
        
        // Enable dark mode.
        //this.getSettings().setProperty("gtk-application-prefer-dark-theme", true);

        setupActions();

        stack = new Stack();
        header = new WSHeader(this);
        workspace = new Workspace();

        workspaceBox = new Box(Orientation.HORIZONTAL, 0);
        workspaceBox.packStart(workspace, true, true, 0);

        stack.addNamed(workspaceBox, "workspace");
        stack.addNamed(new WSPageNew(this), "newScene");
        stack.setTransitionType(StackTransitionType.CROSSFADE);

        stack.setVisibleChildName("workspace");

        // Add the components and show them.
        this.setTitlebar(header);
        this.add(stack);
        this.setIconFromFile("res/wereshift.png");
        this.setSizeRequest(800, 600);
        this.showAll();
    }

    /**
        Updates the window title
    */
    void updateTitle(string newProject) {
        header.title = newProject;
    }
}