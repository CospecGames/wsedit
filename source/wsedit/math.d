module wsedit.math;

/**
    A point in 2D space
*/
struct Vector2 {

    /**
        X coordinate
    */
    double x = 0.0;

    /**
        Y coordinate
    */
    double y = 0.0;
}

/**
    A point in 2D space
*/
struct Vector2i {

    /**
        X coordinate
    */
    int x = 0;

    /**
        Y coordinate
    */
    int y = 0;

}

/**
    A rectangle
*/
struct Rectangle {
    /**
        X
    */
    int x;

    /**
        Y
    */
    int y;

    /**
        Width
    */
    int width;

    /**
        Height
    */
    int height;

    /// The left side
    int left() { return x; }

    /// The right side
    int right() { return x+width; }

    /// The top
    int top() { return y; }

    /// The bottom
    int bottom() { return y+height; }

    /**
        Gets wether this rectangle intersects an other Rectangle
    */
    bool intersects(Rectangle other) {
        return !(
            other.left >= this.right ||
            other.right <= this.left ||
            other.top >= this.bottom ||
            other.bottom <= this.top
        );
    }

    /**
        Gets wether this rectangle intersects an other Vector
    */
    bool intersects(Vector2 other) {
        return !(
            other.x >= this.right ||
            other.x <= this.left ||
            other.y >= this.bottom ||
            other.y <= this.top
        );
    }

    /**
        Gets wether this rectangle intersects an other Vector
    */
    bool intersects(Vector2i other) {
        return !(
            other.x >= this.right ||
            other.x <= this.left ||
            other.y >= this.bottom ||
            other.y <= this.top
        );
    }

    /**
        Gets the cetner of this rectangle
    */
    Vector2 center() {
        return Vector2(cast(double)x+cast(double)(width/2), cast(double)y+cast(double)(height/2));
    }
}