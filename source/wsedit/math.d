module wsedit.math;
public import std.math;
public import std.algorithm.comparison : clamp;
import std.format;

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

    /**
        Gets wether a vector is within a circle

        center = center of circle
        radius = radius of circle
    */
    bool isInCircle(Vector2 center, double radius) {
        return sqrt(pow(center.x-x, 2) + pow(center.y - y, 2)) <= radius;
    }

    string toString() {
        return "[x=%f, y=%f]".format(x, y);
    }
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

    string toString() {
        return "[x=%d, y=%d]".format(x, y);
    }
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
            other.left > this.right ||
            other.right < this.left ||
            other.top > this.bottom ||
            other.bottom < this.top
        );
    }

    /**
        Gets wether this rectangle intersects an other Vector
    */
    bool intersects(Vector2 other) {
        return !(
            other.x > this.right ||
            other.x < this.left ||
            other.y > this.bottom ||
            other.y < this.top
        );
    }

    /**
        Gets wether this rectangle intersects an other Vector
    */
    bool intersects(Vector2i other) {
        return !(
            other.x > this.right ||
            other.x < this.left ||
            other.y > this.bottom ||
            other.y < this.top
        );
    }

    Rectangle expand(int x, int y) {
        return Rectangle(this.x-x, this.y-y, this.width+(x*2), this.height+(y*2));
    }

    /**
        Gets the cetner of this rectangle
    */
    Vector2 center() {
        return Vector2(cast(double)x+cast(double)(width/2), cast(double)y+cast(double)(height/2));
    }

    string toString() {
        return "[x=%d, y=%d, w=%d, h=%d]".format(x, y, width, height);
    }
}