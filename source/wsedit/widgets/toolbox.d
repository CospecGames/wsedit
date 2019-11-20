module wsedit.widgets.toolbox;
import gtk.ToggleButton;
import gtk.Label;
import gtk.Box;
import gtk.Image;
import gtk.Widget;
import dazzle.EntryBox;
import gtk.ButtonBox;
import wsedit.tools;

/**
    A button representing a tool
*/
class ToolButton : ToggleButton {
private:
    Tool tool;

public:
    Tool getTool() {
        return tool;
    }

    this(Tool tool) {
        this.tool = tool;
        this.setName(tool.name~" Tool");
        this.setImage(new Image(tool.iconName, IconSize.MENU));
    }
}

class Toolbox : Box {
private:
    Label titleBox;

    Box buttons;
    ToolButton[] tools;
    ToolButton activeTool;

    bool isUpdating;

    bool toolHoverHandler(Widget widget) {
        titleBox.setText(widget.getName());
        return false;
    }

    bool toolLeaveHandler(Widget widget) {
        titleBox.setText(activeTool is null ? "" : activeTool.getName());
        return false;
    }

    void activationHandler(ToolButton button) {
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

        this.packStart(buttons, false, false, 0);
        this.packEnd(titleBox, false, false, 0);
    }

    void addTool(Tool tool) {
        ToolButton button = new ToolButton(tool);
        button.addOnEnterNotify((GdkEventCrossing*, _) { return toolHoverHandler(button); });
        button.addOnLeaveNotify((GdkEventCrossing*, _) { return toolLeaveHandler(button); });
        button.addOnToggled((_) { activationHandler(button); });
        tools ~= button;
        buttons.packStart(button, false, false, 0);
    }

    void activateTool(uint index) {
        tools[index].setActive(true);
        activeTool = tools[index];
        titleBox.setText(activeTool.getName());
    }

    Tool currentTool() {
        return activeTool !is null ? activeTool.getTool() : null;
    }
}