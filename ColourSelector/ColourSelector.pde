import java.awt.*;
import java.awt.datatransfer.*;

PImage selectedImage, lock, icon;
Button loadButton, rgbButton, hexButton, pasteButton, helpButton;
boolean locked, moving, displayHelp;
float scale;
PVector selectedPixelPos, imagePos, mousePos;
int wwidth, hheight, r, g, b;

void setup()
{
  size(600, 600);
  smooth(8);
  //pixelDensity(displayDensity());
  
  surface.setTitle("Image Colour Detector");
  surface.setResizable(true);
  
  icon = loadImage("Icon.png");
  surface.setIcon(icon);
  
  lock = loadImage("Lock.png");
  lock.resize(30, 30);
  selectedImage = loadImage("NoImageLoaded.png");
  ResizeForImage();
  imagePos = new PVector(width/2, height/2);
  
  loadButton = new Button("Select Image", new PVector(16, 14), "SelectFolder", new PVector(30, 30));
  pasteButton = new Button("Paste Image", new PVector(48, 15), "PasteButton", new PVector(30, 30)); 
  rgbButton = new Button("Copy RGB", new PVector(146, 15), "BlankButton", new PVector(160, 30));
  hexButton = new Button("Copy HEX", new PVector(294, 15), "BlankButton", new PVector(124, 30));
  helpButton = new Button("Help", new PVector(width-16, 15), "InfoButton", new PVector(30, 30));
  
  scale = 1;
  
  wwidth = width;
  hheight = height;
}

void draw()
{ 
  background(255);
  
  if (!locked)
  {
    selectedPixelPos = new PVector(mouseX, mouseY);//map(mouseX, 0, width*displayDensity(), 0, width), map(mouseY, 0, height*displayDensity(), 0, height));
  }
  
  //display selected image
  if (selectedImage != null)
  {
    push();
    imageMode(CENTER);
    translate(imagePos.x, imagePos.y);
    scale(scale);
    image(selectedImage, 0, 0);
    pop();
  }
  
  if (displayHelp) {
    fill(0, 0, 0, 125);
    rect(0, 0, width, height);
    fill(255);
    textAlign(CENTER);
    text("This program is designed to assist with \nselecting colours from images.", width/2, 100);
  }
  
  ColourStats();
  
  if (moving)
  {
    imagePos = new PVector(imagePos.x + (mousePos.x - mouseX) * -1, imagePos.y + (mousePos.y - mouseY) * -1);
    mousePos = new PVector(mouseX, mouseY);
  }
  if (locked)
  {
    image(lock, width-30, height-30);
  }
  loadButton.Run();
  pasteButton.Run();
  helpButton.Run();
}

void ColourStats()
{
  //display hex and colour values
  r = int(red(get((int)selectedPixelPos.x, (int)selectedPixelPos.y)));
  g = int(green(get((int)selectedPixelPos.x, (int)selectedPixelPos.y)));
  b = int(blue(get((int)selectedPixelPos.x, (int)selectedPixelPos.y)));
  stroke(1);
  fill(255);
  rect(-1, -1, width+1, 31);
  fill (color(r, g, b));
  stroke(color(255-r, 255-g, 255-b));
  circle(selectedPixelPos.x + 25, selectedPixelPos.y + 25, 25);
  fill(0);
  
  textSize(20);
  textAlign(LEFT);
  rgbButton.Run();
  hexButton.Run();
  text("RGB: " + r + ", " + g + ", " + b, 69, 22);
  text("HEX: #" + hex(color(r, g, b), 6), 237, 22);
}

void ResizeForImage()
{ 
  //if the image is too big for the surface, resize surface to be slightly bigger
  surface.setSize(selectedImage.width + 50, selectedImage.height+100);
  if (width < 400 || (width >= 400 && height < 100))
  {
    surface.setSize(400, 400);
  } else if (width > 600 || height > 600) {
    surface.setSize(600, 600);
  }
}

void LoadImage(File selection)
{
  if (selection != null)
  {
    selectedImage = loadImage(selection.getAbsolutePath());
    ResizeForImage();
  }
}

void copyToClipboard(String stringToCopy){
  StringSelection selection = new StringSelection(stringToCopy);
  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  clipboard.setContents(selection, selection);
}

PImage getImageFromClipboard()
{
  Transferable transferable = Toolkit.getDefaultToolkit().getSystemClipboard().getContents(null);
  if (transferable != null && transferable.isDataFlavorSupported(DataFlavor.imageFlavor))
  {
    try
    {
      return new PImage((Image) transferable.getTransferData(DataFlavor.imageFlavor));
    }
    catch (Exception e)
    {
      
    }
  }
  return loadImage("NoImageLoaded.png");
}

void ToggleDisplayHelp() {
  if (displayHelp) {
    displayHelp = false;
  } else {
    displayHelp = true;
  }
}

void mousePressed()
{
  if (mouseButton == LEFT) {
    if (loadButton.hover)
    {
      selectInput("Select a file to process:", "LoadImage");
    } else if (rgbButton.hover) {
      copyToClipboard(r + ", " + g + ", " + b);
    } else if (hexButton.hover) {
      copyToClipboard("#" + hex(color(r, g, b), 6));
    } else if (pasteButton.hover) {
      selectedImage = getImageFromClipboard();
    } else if (helpButton.hover) {
      ToggleDisplayHelp();
    } else {
      if (!locked)
      {
        locked = true;
      } else {
        locked = false;
      }
    }
  } else if (mouseButton == RIGHT) {
    if (!moving) {
      mousePos = new PVector(mouseX, mouseY);
      moving = true;
    }
  }
}

void mouseReleased()
{
  if (mouseButton == RIGHT)
  {
    moving = false;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scale += e * 0.5;
  if (scale < 0) {
    scale = 0.25;
  }
}

void keyPressed() {
  if (key == 'r')
  {
    scale = 1;
    imagePos = new PVector(width/2, height/2);
  } else if (key =='a') {
    selectedImage = getImageFromClipboard();
  } else if (key == CODED) {
    if (keyCode == UP) {
      imagePos.y -= 5;
    }
    if (keyCode == DOWN) {
      imagePos.y += 5;
    }
    if (keyCode == LEFT) {
      imagePos.x -= 5;
    }
    if (keyCode == RIGHT) {
      imagePos.x += 5;
    }
  }
}
