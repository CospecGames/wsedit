module wsedit.widgets.viewport;
import gtk.DrawingArea;
import wsedit;
import wsedit.subsystem.mouse;
import wsedit.workspace;

/**
    The editor viewport

    This does not handle any rendering; instead it handles all the updates
*/
class WSViewport : DrawingArea {
private:
    Workspace workspace;
    
    Vector2 startPosition;
    Vector2 startCameraPosition;
    bool isDragging;

    Mouse getMouse() {
        return workspace.mouse;
    }

    void updateDragging() {
        if (getMouse().isButtonPressed(MouseButton.Right)) {
            if (!isDragging) {
                isDragging = true;
                startPosition = getMouse().position;
                startCameraPosition = workspace.camera.position;
            }
        }

        if (isDragging) {
            workspace.camera.position = Vector2(
                startCameraPosition.x + ((getMouse().position.x - startPosition.x)/workspace.camera.zoom),
                startCameraPosition.y + ((getMouse().position.y - startPosition.y)/workspace.camera.zoom),
            );
        }

        if (getMouse().isButtonReleased(MouseButton.Right)) {
            isDragging = false;
        }

    }

    void updateZoom() {
        double scroll = getMouse().scroll;

        if (scroll > 0) workspace.camera.zoom += 0.2;
        else if (scroll < 0) workspace.camera.zoom -= 0.2;

        if (workspace.camera.zoom > 5) workspace.camera.zoom = 5;
        if (workspace.camera.zoom < 0.2) workspace.camera.zoom = 0.2;
    }

public:

    void update() {
        updateDragging();
        updateZoom();
    }

    /**
        Construct
    */
    this(Workspace workspace) {
        this.workspace = workspace;
        super(1, 1);
    }
}