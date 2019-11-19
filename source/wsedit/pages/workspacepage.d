module wsedit.pages.workspacepage;
import wsedit.workspace;
import wsedit.windows.appwin;
import gtk.Notebook;
import gtk.Label;
import gtk.Button;
import gtk.Box;
import gtk.Image;
import gtk.Widget;

class WSWorkspaceTabLabel : Box {
private:
    Workspace workspace;
    WSWorkspacesPage page;

    Label title;
    Button closeButton;

public:
    this(WSWorkspacesPage page, Workspace workspace) {
        super(Orientation.HORIZONTAL, 0);

        this.page = page;
        this.workspace = workspace;

        title = new Label(workspace.project.name);
        title.setHalign(Align.START);

        closeButton = new Button();
        closeButton.setHalign(Align.END);

        closeButton.setImage(new Image("window-close-symbolic", IconSize.MENU));
        closeButton.getStyleContext().addClass("close");
        closeButton.getStyleContext().addClass("titlebutton");
        closeButton.addOnReleased((_) {
            page.removePage(this.workspace.pageNumber);
        });

        this.packStart(title, true, true, 16);
        this.packEnd(closeButton, false, false, 0);
    }
}

/**
    Page that contains a list of workspaces, tabbed
*/
class WSWorkspacesPage : Notebook {
private:
    WSEditWindow window;

public:
    /**
        Counts the amount of workspaces
    */
    size_t count() {
        return this.getNPages();
    }

    this(WSEditWindow window) {
        this.window = window;

        this.setShowTabs(true);
        this.setShowBorder(false);
        this.setScrollable(true);
        this.setTabPos(PositionType.TOP);

        this.addOnPageRemoved((w, _, __) {
            Workspace workspace = cast(Workspace)w;
            workspace.project.save(workspace.project.path);

            // Update all the page numbers
            foreach(i; 0..this.getNPages()) {
                (cast(Workspace)this.getNthPage(i)).pageNumber = i;
            }
        });

        this.addOnPageReordered((w, i, _) {
            Workspace workspace = cast(Workspace)w;
            workspace.pageNumber = i;
        });

        this.addOnChangeCurrentPage((i, _) {
            Workspace workspace = cast(Workspace)getNthPage(i);
            window.updateTitle(workspace.project.name);
            return true;
        });
    }

    /**
        Add workspace to the tabs
    */
    void addWorkspace(Workspace workspace) {
        auto label = new WSWorkspaceTabLabel(this, workspace);
        workspace.showAll();
        label.showAll();
        int pageIndex = this.appendPage(workspace, label);
        this.setCurrentPage(this.getNthPage(pageIndex));
        workspace.pageNumber = pageIndex;
    }
}