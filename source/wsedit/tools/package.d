module wsedit.tools;
public import wsedit.workspace;
public import wsedit.subsystem.wsrenderer;
public import wsedit.subsystem.mouse;

public import wsedit.tools.tiles;
public import wsedit.tools.camera;

/**
    A tool provides functionality on the canvas
*/
class Tool {
protected:
    Workspace workspace;

    this(string name, string iconName, ToolGroup parent, Workspace workspace) {
        this.name = name;
        this.iconName = iconName;
        this.workspace = workspace;
        this.parent = parent;
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
        The group this tool belongs to
    */
    ToolGroup parent;

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

/**
    A group of tools
*/
class ToolGroup {
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
        Tools in the tool group
    */
    Tool[] tools;
}