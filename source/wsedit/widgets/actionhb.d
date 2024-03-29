/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsedit.widgets.actionhb;
import gtk.HeaderBar;
import gtk.Button;
import gtk.Image;
import gtk.Box;
import gtk.Label;

import wsedit;
import wsedit.widgets;
import wsedit.helpers;
import wsedit.windows.appwin;

class WSActionHeader : HeaderBar {
private:
    WSEditWindow appwin;
    Button backButton;
    
public:
    /// Constructor
    this(WSEditWindow appwin) {
        this.appwin = appwin;

        this.setShowCloseButton(true);

        backButton = new Button();

        backButton.setImage(new Image("go-previous-symbolic", IconSize.MENU));
        this.packStart(backButton);
    }

    /**
        Calls the specified back function when released
    */
    void addOnBackReleased(void delegate() func) {
        backButton.addOnReleased((_) {
            func();
        });
    }
}