// This software lets you encrypt/decrypt an image by left-clicking on the screen and save it after right-clicking on the screen.

// import the tools we need
import arsd.image : loadImageFromFile;
import arsd.png : writePng;
import arsd.simpleaudio : AudioOutputThread;
import arsd.simpledisplay : Color, Image, MouseButton, MouseEvent, MouseEventType, Point, SimpleWindow;
import std.conv : to;
import std.math : ceil;
import std.random : uniform;
import std.stdio : readf, writeln;

// this function creates the key to do the encryption/decryption, the key is an array of random numbers, the image must be at most 1500x850 pixels
ubyte[] createKey(ulong originalSeed)
{
    // create the array which will hold all randomly generated numbers, we need 3 numbers for the RGB of each of the 1,275,000 pixels, thus 3,825,000
    ubyte[] randomNumbers = new ubyte[3_825_000];
    // 'lowerBound' will be used to find the middle of the number in the loop below and 'seedSize' will be used to store the size of the seed
    int lowerBound, seedSize = cast(int) to!string(originalSeed).length;
    // this variable will contain the seed when we are iterating below
    ulong seed = originalSeed;

    // start a loop to create each element of the key
    foreach (i; 0 .. 3_825_000)
    {
        // create a key element with a random number, using the Middle Squares Method, we only need a number up until 256, hence the mod operation
        randomNumbers[i] = cast(ubyte) (seed % 256);
        // calculate the square of the seed
        seed ^^= 2;

        // if the square of the current seed is still bigger than the size of the original seed
        if (to!string(seed).length > seedSize)
        {
            // calculate the lower bound, so we get the middle of the squared number
            lowerBound = cast(int) ceil((to!string(seed).length - seedSize) / 2.0);
            // update the value of the seed, we get the number in the middle and turn it into a 'ulong'
            seed = to!ulong(to!string(seed)[lowerBound .. lowerBound + seedSize]);

            // if the period has been reached
            if (seed == originalSeed)
                // start over with the number next to the original seed
                seed = originalSeed + 1;
        }
        // if the seed ended up becoming too small
        else
            // start over with the number next to the original seed
            seed = originalSeed + 1;
    }

    // return the array with the key elements
    return randomNumbers;
}

// this function produces a new image with the encrypted or decrypted binary
Image encrypt(Image img, ubyte[] key)
{
    // this will be the pixel of the image
    Color pixel;
    // this will be used in the loop below to access the array of key elements
    int i;

    // start a loop to go through all y coordinates
    foreach (y; 0 .. img.height)
        // start a loop to go through all x coordinates
        foreach (x; 0 .. img.width)
        {
            // get the pixel at those x and y coordinates
            pixel = img.getPixel(x, y);
            // change the color of the pixel by doing an XOR operation between the pixel's RGB numbers and the next 3 key elements
            pixel.r ^= key[i++], pixel.g ^= key[i++], pixel.b ^= key[i++];
            // change the pixel in the image
            img.putPixel(x, y, pixel);
        }

    // return the new image
    return img;
}

// this will be the data type of the sound files imported into the program
alias memory = immutable ubyte[];

// start the program
void main()
{
    // this will be the name of the image file
    string imgName;
    // this will be the seed to create the random numbers
    int seed;
    // this will be the image to be encrypted or decrypted
    Image img;
    // this boolean will tell the GUI when to stop
    bool running = true;
    // import the sound files
    memory change = cast(memory) import("change.ogg"), save = cast(memory) import("save.ogg");
    // this will be the window for the GUI
    SimpleWindow window;
    // this will be the audio thread to play sounds
    AudioOutputThread sounds = AudioOutputThread(true);

    // tell the user what to type
    writeln("Type the seed:");
    // read the seed which the user typed
    readf("%d\n", seed);
    // tell the user what is happening
    writeln("Creating the encryption key, please wait.");

    // create the array with the key to encrypt or decrypt the image
    ubyte[] key = createKey(seed);

    // keep running until the user press Enter
    while (running)
    {
        // tell the user what to type
        writeln("Type the name of the image file (must be .png) or press Enter to exit:");
        // read the name which the user typed
        readf("%s\n", imgName);

        // if the user just press Enter instead of typing the name of the image
        if (imgName == "")
            // end the loop and therefore the program
            break;

        // load the image from the file
        img = Image.fromMemoryImage(loadImageFromFile(imgName));
        // create the window for the GUI
        window = new SimpleWindow(img.width, img.height, "Image cryptography");

        // start the event loop
        window.eventLoop(500,
        {
            // draw the image
            window.draw().drawImage(Point(0, 0), img);
        },
        // check for mouse events
        (MouseEvent event)
        {
            // if you click with the mouse
            if (event.type == MouseEventType.buttonPressed)
                // if it is a left-click
                if (event.button == MouseButton.left)
                {
                    // encrypt or decrypt the image
                    img = encrypt(img, key);
                    // play the image change sound
                    sounds.playOgg(change);
                }
                // if it is a right-click
                else if (event.button == MouseButton.right)
                {
                    // save the image as PNG, we get the name without the ".png" part and then concatenate it with " copy.png"
                    writePng(imgName[0 .. $ - 4] ~ " copy.png", img.toTrueColorImage());
                    // play the image save sound
                    sounds.playOgg(save);
                }
        });
    }
}
