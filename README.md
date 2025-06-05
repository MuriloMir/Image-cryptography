# image-cryptography
A software which allows you to encrypt images.

It asks you for a number, which is your private key, this number is used to create a long list of numbers, which are then used to change the binary of the original image, thus creating a new image which is totally messy and nonsense, therefore you can transfer images privately.

Just type your private key and then type the name of the image, make sure the software is running inside the folder where the image is, it allows you to do both ways, you may encrypt and decrypt the image with the same private key. Left-click to encrypt (or decrypt) and right-click to save the new image file.

You can compile this code with the DMD compiler by typing "dmd source.d -m64 -i -J. -O -g". Just make sure the dependencies files extracted into the same folder as the source code file.
