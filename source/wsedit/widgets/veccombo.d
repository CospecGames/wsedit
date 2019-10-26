/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsedit.widgets.veccombo;
import gtk.SpinButton;
import gtk.Box;
import gtk.Adjustment;
import dazzle.EntryBox;
import gtk.Label;
import std.traits;
import gtk.ToggleButton;
import gtk.Image;
import gtk.EntryBuffer;

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

    ToggleButton lock;
    bool lockedTogether = false;
    bool isChanging = true;

    double defaultValue;

public:
    /**
        Creates a new Vector Combo box

        Shows 2 spinners for X and Y.
    */
    this(uint digits, string xText = "X", string yText = "Y", bool allowNegative = false, double defaultValue = 0, double minVal = double.infinity, double maxVal = double.infinity) {
        super(Orientation.HORIZONTAL, 16);
        this.defaultValue = defaultValue;

        /**
            X coordinate set
        */

        xBox = new Box(Orientation.HORIZONTAL, 0);
        xBox.getStyleContext.addClass("linked");

        double min = minVal == double.infinity ? (allowNegative ? int.min : uint.min) : minVal;
        double max = maxVal == double.infinity ? (allowNegative ? int.max : uint.max) : maxVal+1;

        Adjustment rangeX = new Adjustment(
            defaultValue,
            min,
            max,
            1,
            1,
            1
        );

        x = new SpinButton(rangeX, 0.5, digits);
        x.setUpdatePolicy(SpinButtonUpdatePolicy.ALWAYS);
        xLabelBox = new EntryBox();
        Label xLabel = new Label(xText);
        xLabelBox.packStart(xLabel, false, false, 0);

        xBox.packStart(xLabelBox, false, false, 0);
        xBox.packStart(x, true, true, 0);

        /**
            Y coordinate set
        */

        yBox = new Box(Orientation.HORIZONTAL, 0);
        yBox.getStyleContext.addClass("linked");

        Adjustment rangeY = new Adjustment(
            defaultValue,
            min,
            max,
            1,
            1,
            1
        );

        y = new SpinButton(rangeY, 0.5, digits);
        y.setUpdatePolicy(SpinButtonUpdatePolicy.ALWAYS);
        yLabelBox = new EntryBox();
        Label yLabel = new Label(yText);
        yLabelBox.packStart(yLabel, false, false, 0);

        yBox.packStart(yLabelBox, false, false, 0);
        yBox.packStart(y, true, true, 0);

        /**
            Final step
        */

        lock = new ToggleButton();
        lock.setImage(new Image("changes-allow-symbolic", IconSize.MENU));
        lock.addOnReleased((_) {
            lockedTogether = !lockedTogether;
            (cast(Image)lock.getImage()).setFromIconName(lockedTogether ? "changes-prevent-symbolic" : "changes-allow-symbolic", IconSize.MENU);
        });

        x.addOnChanged((_) {
            if (lockedTogether && !isChanging) {
                isChanging = true;
                y.setText(x.getText);
                return;
            }

            isChanging = false;
        });
        
        y.addOnChanged((_) {
            if (lockedTogether && !isChanging) {
                isChanging = true;
                x.setText(y.getText);
                return;
            }

            isChanging = false;
        });

        this.packStart(xBox, true, true, 0);
        this.packStart(yBox, true, true, 0);
        this.packEnd(lock, false, false, 0);
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