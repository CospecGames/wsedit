module wsedit.tools.camera;
import wsedit.tools;

public import wsedit.tools.camera.zonetool;

class CameraGroup : ToolGroup {
public:
    this(Workspace workspace) {
        super("Camera", "camera-video-symbolic", workspace);
        tools = [new ZoneTool(workspace, this)];
    }
}