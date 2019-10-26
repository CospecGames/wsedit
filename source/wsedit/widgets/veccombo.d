module wsedit.widgets.veccombo;
import gtk.SpinButton;
import gtk.Box;
import gtk.Adjustment;
import dazzle.EntryBox;
import gtk.Label;
import std.traits;

enum WSDimension : ubyte {
    X = 0,
    Y = 1
}

/**
    A 2d vector combo
*/
class WSVecCombo : Box {
private:
    Box xBox;
    EntryBox xLabelBox;
    SpinButton x;

    Box yBox;
    EntryBox yLabelBox;
    SpinButton y;

    double defaultValue;

public:
    /**
        Creates a new Vector Combo box

        Shows 2 spinners for X and Y.
    */
    this(uint digits, string xText = "X", string yText = "Y", bool allowNegative = false, double defaultValue = 0) {
        super(Orientation.HORIZONTAL, 16);
        this.defaultValue = defaultValue;

        /**
            X coordinate set
        */

        xBox = new Box(Orientation.HORIZONTAL, 0);
        xBox.getStyleContext.addClass("linked");

        Adjustment rangeX = new Adjustment(
            defaultValue,
            allowNegative ? int.min : uint.min,
            allowNegative ? int.max : uint.max,
            1,
            1,
            5
        );

        x = new SpinButton(rangeX, 0.5, digits);
        x.setUpdatePolicy(SpinButtonUpdatePolicy.ALWAYS);
        xLabelBox = new EntryBox();
        Label xLabel = new Label(xText);
        xLabelBox.packStart(xLabel, false, false, 0);

        xBox.packStart(xLabelBox, true, true, 0);
        xBox.packStart(x, false, false, 0);

        /**
            Y coordinate set
        */

        yBox = new Box(Orientation.HORIZONTAL, 0);
        yBox.getStyleContext.addClass("linked");

        Adjustment rangeY = new Adjustment(
            defaultValue,
            allowNegative ? int.min : uint.min,
            allowNegative ? int.max : uint.max,
            1,
            1,
            5
        );

        y = new SpinButton(rangeY, 0.5, digits);
        y.setUpdatePolicy(SpinButtonUpdatePolicy.ALWAYS);
        yLabelBox = new EntryBox();
        Label yLabel = new Label(yText);
        yLabelBox.packStart(yLabel, false, false, 0);

        yBox.packStart(yLabelBox, true, true, 0);
        yBox.packStart(y, false, false, 0);

        /**
            Final step
        */
        this.packStart(xBox, false, false, 0);
        this.packEnd(yBox, false, false, 0);
    }

    void setXIncrement(double increment, double altIncrement = 1) {
        this.x.setIncrements(increment, altIncrement);
    }

    void setYIncrement(double increment, double altIncrement = 1) {
        this.y.setIncrements(increment, altIncrement);
    }

    void setX(T)(T x) if (isNumeric!T) {
        this.x.setValue(cast(double)x);
    }

    T getX(T)() if (isNumeric!T) {
        static if (isFloatingPoint!T) {
            return this.x.getValue();
        } else {
            return this.x.getValueAsInt();
        }
    }

    void setY(T)(T y) if (isNumeric!T) {
        this.y.setValue(cast(double)y);
    }

    T getY(T)() if (isNumeric!T) {
        static if (isFloatingPoint!T) {
            return this.y.getValue();
        } else {
            return this.y.getValueAsInt();
        }
    }

    /**
        Adds a signal when either the X or Y coordinate slider is changed
    */
    gulong[2] addOnChanged(void delegate(WSDimension) func) {
        gulong[2] values = new gulong[2];

        values[0] = this.x.addOnChanged((_) {
            func(WSDimension.X);
        });

        values[1] = this.y.addOnChanged((_) {
            func(WSDimension.Y);
        });

        return values;
    }

    /**
        Resets the values of the vector combos to 0.
    */
    void reset() {
        setX(this.defaultValue);
        setY(this.defaultValue);
    }
}