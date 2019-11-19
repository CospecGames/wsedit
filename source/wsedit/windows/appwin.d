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
import gtk.CssProvider;
import wsedit.widgets;
import wsedit.pages;
import wsedit.windows.about;
import wsedit.workspace;
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

    string getSuitablePage() {
        return workspaces.count > 0 ? "workspacesPage" : "initPage";
    }

    Stack stack;
    string[] pageStack;

public:
    /**
        The header bar
    */
    WSHeader header;

    /**
        The list of current open workspaces
    */
    WSWorkspacesPage workspaces;

    this(Application app) {
        super(app);
        // Update the state to point to this as the main window
        STATE.mainWindow = this;
        
        // Enable dark mode.
        this.addStylesheet(import("style.css"));
        this.getSettings().setProperty("gtk-application-prefer-dark-theme", true);

        setupActions();

        stack = new Stack();
        header = new WSHeader(this);


        workspaces = new WSWorkspacesPage(this);
        stack.addNamed(workspaces, "workspacesPage");
        stack.addNamed(new WSPageNew(this), "newScenePage");
        stack.addNamed(new WSPageInit(), "initPage");

        // Add the components and show them.
        this.setTitlebar(header);
        this.add(stack);
        this.setIconFromFile("res/logo.png");
        this.setWmclass("Wereshift Scene Editor", "WSEdit");
        this.setSizeRequest(800, 600);
        this.showAll();

        stack.setVisibleChildName("initPage");
        stack.setTransitionDuration(250);
    }

    /**
        Switches to screen and resets stack
    */
    void to(string screen) {
        pageStack.length = 0;
        stack.setTransitionType(StackTransitionType.CROSSFADE);
        stack.setVisibleChildName(screen);
    }

    /**
        Pushes screen to stack
    */
    void push(string screen) {
        if (pageStack.length > 0 && pageStack[$-1] == screen) return;
        stack.setTransitionType(StackTransitionType.CROSSFADE);
        pageStack ~= screen;
        stack.setVisibleChildName(screen);
    }

    /**
        Pops screen from stack
    */
    void pop() {
        if (pageStack.length > 0) pageStack.length--;
        stack.setTransitionType(StackTransitionType.UNDER_DOWN);
        stack.setVisibleChildName(pageStack.length == 0 ? getSuitablePage() : pageStack[$-1]);
    }

    /**
        Updates the window title
    */
    void updateTitle(string newProject) {
        header.title = newProject;
    }

    /**
        Add stylesheet to screen
    */
    void addStylesheet(string code) {
        this.getStyleContext().addProviderForScreen(this.getScreen(), styleFromString(code), STYLE_PROVIDER_PRIORITY_USER);
    }
}
/**
    Returns a CSS provider from a string of css data.
*/
CssProvider styleFromString(string styleSheet) {
    CssProvider provider = new CssProvider();
    provider.loadFromData(styleSheet);
    return provider;
}