module wsedit.widgets.toolbox;
import gtk.ToggleButton;
import gtk.Label;
import gtk.Box;
import gtk.Image;
import gtk.Widget;
import dazzle.EntryBox;
import gtk.ButtonBox;

class Toolbox : Box {
private:
    Label titleBox;

    Box buttons;
    ToggleButton[] tools;
    ToggleButton activeTool;

    ToggleButton selectToolButton;
    ToggleButton tileToolButton;
    ToggleButton objectToolButton;
    ToggleButton parallaxRegionTool;
    bool isUpdating;

    bool toolHoverHandler(Widget widget) {
        titleBox.setText(widget.getName());
        return false;
    }

    bool toolLeaveHandler(Widget widget) {
        titleBox.setText(activeTool.getName());
        return false;
    }

    void activationHandler(ToggleButton button) {
        if (!isUpdating) {
            isUpdating = true;
            activeTool = button;
            
            foreach(tool; tools) {
                
                // You can't disable tools altogether.
                if (tool == button) {
                    tool.setActive(true);
                    continue;
                }

                tool.setActive(false);
            }

            isUpdating = false;
        }
    }
    

public:
    this() {
        super(Orientation.VERTICAL, 0);
        this.setMarginTop(8);
        this.setMarginLeft(8);

        titleBox = new Label("");

        buttons = new Box(Orientation.HORIZONTAL, 0);
        buttons.getStyleContext().addClass("linked");

        selectToolButton = new ToggleButton();
        selectToolButton.setName("Select Tool");
        selectToolButton.setImage(new Image("edit-select-all-symbolic", IconSize.MENU));
        selectToolButton.addOnEnterNotify((GdkEventCrossing*, _) { return toolHoverHandler(selectToolButton); });
        selectToolButton.addOnLeaveNotify((GdkEventCrossing*, _) { return toolLeaveHandler(selectToolButton); });
        selectToolButton.addOnToggled(&activationHandler);
        activeTool = selectToolButton;

        tileToolButton = new ToggleButton();
        tileToolButton.setName("Tile Tool");
        tileToolButton.setImage(new Image("view-grid-symbolic", IconSize.MENU));
        tileToolButton.addOnEnterNotify((GdkEventCrossing*, _) { return toolHoverHandler(tileToolButton); });
        tileToolButton.addOnLeaveNotify((GdkEventCrossing*, _) { return toolLeaveHandler(tileToolButton); });
        tileToolButton.addOnToggled(&activationHandler);

        objectToolButton = new ToggleButton();
        objectToolButton.setName("Actor Tool");
        objectToolButton.setImage(new Image("insert-object-symbolic", IconSize.MENU));
        objectToolButton.addOnEnterNotify((GdkEventCrossing*, _) { return toolHoverHandler(objectToolButton); });
        objectToolButton.addOnLeaveNotify((GdkEventCrossing*, _) { return toolLeaveHandler(objectToolButton); });
        objectToolButton.addOnToggled(&activationHandler);

        parallaxRegionTool = new ToggleButton();
        parallaxRegionTool.setName("Parallax Tool");
        parallaxRegionTool.setImage(new Image("insert-image-symbolic", IconSize.MENU));
        parallaxRegionTool.addOnEnterNotify((GdkEventCrossing*, _) { return toolHoverHandler(parallaxRegionTool); });
        parallaxRegionTool.addOnLeaveNotify((GdkEventCrossing*, _) { return toolLeaveHandler(parallaxRegionTool); });
        parallaxRegionTool.addOnToggled(&activationHandler);

        tools = [selectToolButton, tileToolButton, objectToolButton, parallaxRegionTool];

        buttons.packStart(selectToolButton, false, false, 0);
        buttons.packStart(tileToolButton, false, false, 0);
        buttons.packStart(objectToolButton, false, false, 0);
        buttons.packStart(parallaxRegionTool, false, false, 0);
        selectToolButton.setActive(true);


        this.packStart(buttons, false, false, 0);
        this.packEnd(titleBox, false, false, 0);

        // Activate select tool by default
        selectToolButton.setActive(true);
        titleBox.setText(activeTool.getName());
    }
}