module wsedit.widgets.toolbox;
import gtk.ToggleButton;
import gtk.Label;
import gtk.Box;
import gtk.Image;
import gtk.Widget;
import dazzle.EntryBox;
import gtk.ButtonBox;
import wsedit.tools;
import gtk.Revealer;

/**
    A group button
*/
class GroupButton : ToggleButton {
private:
    Toolbox parent;
    ToolGroup group;
    ToolButton[] children;
    Revealer revealer;

    Box childrenBox;

    static bool isUpdating;

public:
    Toolbox getParentToolbox() {
        return parent;
    }

    ToolGroup getGroup() {
        return group;
    }

    ToolButton[] getChildrenButtons() {
        return children;
    }

    Revealer getRevealer() {
        return revealer;
    }

    Box getInsertableBox() {
        return childrenBox;
    }

    this(Toolbox toolbox, ToolGroup group) {
        this.parent = toolbox;
        this.group = group;
        this.revealer = new Revealer();
        this.revealer.setTransitionType(RevealerTransitionType.SLIDE_RIGHT);
        this.revealer.setTransitionDuration(200);
        this.revealer.getStyleContext().addClass("linked");

        this.addOnReleased((_) {
            if (!this.getActive()) {
                this.setActive(true);
                return;
            }
            foreach(grp; parent.groups) {
                if (grp == group) continue;
                grp.deactivateGroup();
            }
            this.activateGroup();
        });

        this.addOnEnter((_) {
            parent.updateLabel(group.name);
        });

        this.addOnLeave((_) {
            if (parent.getCurrentTool is null) return;
            parent.updateLabel(parent.getCurrentTool().name);
        });

        childrenBox = new Box(Orientation.HORIZONTAL, 0);
        childrenBox.getStyleContext().addClass("linked");
        childrenBox.setMarginLeft(4);
        childrenBox.setMarginRight(4);

        foreach(tool; group.tools) {
            ToolButton toolbtn = new ToolButton(this, tool);
            
            children ~= toolbtn;
            childrenBox.packStart(toolbtn, false, false, 0);
        }
        this.revealer.add(childrenBox);

        this.setName(group.name);
        this.setImage(new Image(group.iconName, IconSize.MENU));
        this.getStyleContext().addClass("suggested-action");
    }

    void activateGroup() {
        if (isUpdating) return;
        
        isUpdating = true;
        scope(exit) isUpdating = false;
        
        if (children.length == 0) return;
        parent.selectTool(children[0].getTool());
        parent.selectGroup(this.getGroup());
        children[0].setActive(true);
        revealer.setRevealChild(true);
        this.setActive(true);
    }

    void deactivateGroup() {

        isUpdating = true;
        scope(exit) isUpdating = false;

        foreach(child; children) {
            child.setActive(false);
        }
        revealer.setRevealChild(false);
        this.setActive(false);
    }
}

/**
    A button representing a tool
*/
class ToolButton : ToggleButton {
private:
    Tool tool;
    GroupButton parentGroupBtn;
    
    static bool isUpdating;

public:
    Tool getTool() {
        return tool;
    }

    GroupButton getParentButton() {
        return parentGroupBtn;
    }

    Toolbox getParentToolbox() {
        return getParentButton().getParentToolbox();
    }

    this(GroupButton group, Tool tool) {
        this.tool = tool;
        this.parentGroupBtn = group;
        this.setName(tool.name);
        this.setImage(new Image(tool.iconName, IconSize.MENU));


        this.addOnReleased((_) {
            if (!this.getActive()) {
                this.setActive(true);
                return;
            }

            this.setActive(true);
            foreach(child; this.getParentButton().getChildrenButtons()) {
                if (child == this) continue;
                child.setActive(false);
            }

            this.getParentToolbox().selectTool(tool);
        });

        this.addOnEnter((_) {
            this.getParentToolbox().updateLabel(tool.name);
        });

        this.addOnLeave((_) {
            this.getParentToolbox().updateLabel(this.getParentToolbox().getCurrentTool().name);
        });
    }
}

class Toolbox : Box {
private:
    Label nameLabel;
    Box groupList;

    GroupButton[] groups;
    
    ToolGroup currentGroup;
    Tool currentTool;

    bool isUpdating;

public:

    ToolGroup getCurrentGroup() {
        return currentGroup;
    }

    Tool getCurrentTool() {
        return currentTool;
    }

    this() {
        super(Orientation.VERTICAL, 0);
        this.setMarginTop(8);
        this.setMarginLeft(8);

        nameLabel = new Label("");

        groupList = new Box(Orientation.HORIZONTAL, 4);

        this.packStart(groupList, false, false, 0);
        this.packEnd(nameLabel, false, false, 0);
    }

    /**
        Add tile group to list
    */
    void addGroup(ToolGroup group) {
        Box mainBox = new Box(Orientation.HORIZONTAL, 0);

        GroupButton groupButton = new GroupButton(this, group);

        mainBox.packStart(groupButton, false, false, 0);
        mainBox.packStart(groupButton.getRevealer(), false, false, 0);

        groups ~= groupButton;

        groupList.packStart(mainBox, false, false, 0);
    }

    /**
        Updates the text on the tool label
    */
    void updateLabel(string text) {
        this.nameLabel.setText(text);
    }

    /**
        Select a tool as active
    */
    void selectTool(Tool tool) {
        this.currentTool = tool;
    }

    /**
        Select a group as active
    */
    void selectGroup(ToolGroup group) {
        this.currentGroup = group;
    }

}