/**
    Copyright © 2019, Cospec Games

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module wsedit.helpers;
import wsedit;
import gtk.Window;
public import gtk.MessageDialog;

/**
    Utility function to show message boxes

    Imitates C#'s message boxes a little bit
*/
class MessageBox {
static:
    /**
        Shows a message box.

        Pango Markup is supported.
        https://developer.gnome.org/pygtk/stable/pango-markup-language.html
    */
    int show(string message, GtkMessageType type = GtkMessageType.INFO, GtkButtonsType buttonType = GtkButtonsType.OK, Window win = null) {
        MessageDialog errDialog = new MessageDialog(
            win is null ? STATE.mainWindow : win, 
            GtkDialogFlags.MODAL, 
            type, 
            buttonType, 
            true,
            message);

        scope(exit) errDialog.destroy();
        return errDialog.run();
    }
}

/**
    Builds a viable file path for a level file
*/
string buildPathForScene(string name) {
    import std.format : format;
    import std.array : replace;
    return name.length == 0 ? "" : "%s.wsp".format(name.replace(" ", "_"));
}