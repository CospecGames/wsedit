module wsedit.subsystem.mouse;
import wsedit;

enum MouseButton {
    Left = 1,
    Middle = 2,
    Right = 4
}

/**
    Mouse within viewport
*/
class Mouse {
private:
    MouseButton pressedMask = cast(MouseButton)0;

public:
    /**
        Position of mouse within viewport
    */
    Vector2 position;

    /**
        Scroll amount
    */
    double scroll;

    /**
        Check if button is pressed
    */
    bool isButtonPressed(MouseButton button) {
        return (pressedMask & button) > 0;
    }
    /**
        Check if button is released
    */
    bool isButtonReleased(MouseButton button) {
        return !isButtonPressed(button);
    }

    /**
        Feed data to mouse
    */
    void feedScroll(double scroll) {
        this.scroll = scroll;
    }

    /**
        Feed data to mouse
    */
    void feedPosition(Vector2 position) {
        this.position = position;
    }

    /**
        Feed button presses
    */
    void feedPress(int button) {
        if (button == 1) pressedMask |= MouseButton.Left;
        if (button == 2) pressedMask |= MouseButton.Middle;
        if (button == 3) pressedMask |= MouseButton.Right; 
    }

    /**
        Feed button releases
    */
    void feedRelease(int button) {
        if (button == 1) pressedMask &= ~MouseButton.Left;
        if (button == 2) pressedMask &= ~MouseButton.Middle;
        if (button == 3) pressedMask &= ~MouseButton.Right; 
    }
}