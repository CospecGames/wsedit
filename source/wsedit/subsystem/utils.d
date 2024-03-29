
module wsedit.subsystem.utils;
import ppc.types.image;
import std.algorithm.mutation : reverse;

/**
    Gets a subimage of an image
*/
Image getSubImage(Image img, size_t xorg, size_t yorg, size_t width, size_t height) {
    Image subImg;
    
    // Copy over the info
    subImg.info = img.info;

    // Move in the new size
    subImg.info.width = width;
    subImg.info.height = height;

    width *= 4;

    subImg.pixelData = new ubyte[width*height];
    foreach(y; 0..height) {
        size_t startx = (yorg*(img.width*4))+(y*(img.width*4))+(xorg*4);

        subImg.pixelData[(y*width)..(y*width)+width] = img.pixelData[startx..startx+width];
    }

    return subImg;
}

/**
    Clones an image
*/
Image clone(Image other) {
    Image clone;
    clone.info = other.info;
    clone.pixelData = new ubyte[other.pixelData.length];
    clone.pixelData[] = other.pixelData;
    return clone;
}

/**
    Premultiplies the alpha for the texture
*/
void premultiply(ref Image image) {
    premultiply(image.pixelData);
}

/**
    Premultiplies the alpha for the texture
*/
void premultiply(ref ubyte[] arr) {
    foreach(i; 0..arr.length/4) {
        size_t r = (i*4);
        size_t g = r+1;
        size_t b = r+2;
        size_t a = r+3;

        arr[r] = cast(ubyte)(arr[r] * arr[a] / 255);
        arr[g] = cast(ubyte)(arr[g] * arr[a] / 255);
        arr[b] = cast(ubyte)(arr[b] * arr[a] / 255);
    }
}

/**
    Ghostify texture by setting higher alpha to a specific value
*/
void ghostify(ref Image image) {
    ghostify(image.pixelData);
}

/**
    Ghostify texture by setting higher alpha to a specific value
*/
void ghostify(ref ubyte[] arr, ubyte ghostLevel = 128) {
    foreach(i; 0..arr.length/4) {
        size_t a = (i*4)+3;
        
        // Only apply to parts of the image that are more opaque than our ghostLevel
        if (arr[a] > ghostLevel) {
            arr[a] = cast(ubyte)(ghostLevel);
        }
    }
}

/**
    Cairo expects BGRA while imageformats loads as RGBA
    Reverses the RGB components.
*/
void rgbaToBgra(ref Image image) {
    rgbaToBgra(image.pixelData);
}

/**
    Cairo expects BGRA while imageformats loads as RGBA
    Reverses the RGB components.
*/
void rgbaToBgra(ref ubyte[] arr) {
    foreach(i; 0..arr.length/4) {
        size_t r = (i*4);
        size_t b = r+3;
        reverse(arr[r..b]);
    }
}

/**
    Flips the data vertically
*/
void flipVertical(ref ubyte[] arr, size_t width) {
    ubyte[] tmp;
    foreach_reverse(y; 0..arr.length/width) {
        size_t offset = y*width;
        tmp ~= arr[offset..offset+width];
    }
    // Flipping is complete
    arr = tmp;
}

/**
    Flips the data horizontally
*/
void flipHorizontal(ref ubyte[] arr, size_t width) {
    foreach_reverse(y; 0..arr.length/width) {
        size_t offset = y*width;
        reverse(arr[offset..offset+width]);
    }
}