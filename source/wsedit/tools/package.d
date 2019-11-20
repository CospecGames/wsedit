module wsedit.tools;
public import wsedit.workspace;
public import wsedit.subsystem.wsrenderer;
public import wsedit.subsystem.mouse;

public import wsedit.tools.tiletool;
public import wsedit.tools.selecttool;
public import wsedit.tools.erasetool;

/**
    A tool provides functionality on the canvas
*/
class Tool {
protected:
    Workspace workspace;

    this(string name, string iconName, Workspace workspace) {
        this.name = name;
        this.iconName = iconName;
        this.workspace = workspace;
    }

public:
    /**
        Name of the tool
    */
    immutable(string) name;

    /**
        Name of the tool's icon
    */
    immutable(string) iconName;

    /**
        Draw tool related UI on to the canvas
        Selections, etc.
    */
    abstract void draw(Renderer renderer);

    /**
        Update the tool
    */
    abstract void update(Mouse mouse);
}

