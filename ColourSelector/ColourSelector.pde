import java.awt.*;
import java.awt.datatransfer.*;

PImage selectedImage, lock, icon;
Button loadButton, RGBButton, HEXButton;
boolean locked, moving;
float scale;
PVector selectedPixelPos, imagePos, mousePos;
int wwidth, hheight, r, g, b;

void setup()
{
  size(600, 600);
  
  surface.setTitle("Image Colour Detector");
  surface.setResizable(true);
  
  icon = loadImage("Icon.png");
  surface.setIcon(icon);
  
  lock = loadImage("Lock.png");
  lock.resize(30, 30);
  selectedImage = loadImage("NoImageLoaded.png");
  smooth();
  
  loadButton = new Button("Select Image", new PVector(15, 15), "SelectFolder", new PVector(30, 30));
  RGBButton = new Button("Copy RGB", new PVector(115, 15), "BlankButton", new PVector(160, 30));
  HEXButton = new Button("Copy HEX", new PVector(257, 15), "BlankButton", new PVector(120, 30));
  ResizeForImage();
  imagePos = new PVector(width/2, height/2);
  scale = 1;
  //pixelDensity(displayDensity());
  
  smooth(6);
  wwidth = width;
  hheight = height;
}

void draw()
{ 
  background(255);
  
  if (!locked)
  {
    selectedPixelPos = new PVector(mouseX, mouseY);
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
  
  ColourStats();
  
  if (moving)
  {
    imagePos = new PVector(imagePos.x + (mousePos.x - mouseX) * -1, imagePos.y + (mousePos.y - mouseY) * -1);
    mousePos = new PVector(mouseX, mouseY);
  }
  if (locked)
  {
    image(lock, width-30, 0);
  }
  loadButton.Run();
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
  noStroke();
  rect(320, 3, 25, 25);
  fill(0);
  
  textSize(20);
  textAlign(LEFT);
  RGBButton.Run();
  HEXButton.Run();
  text("RGB: " + r + ", " + g + ", " + b, 40, 22);
  text("HEX: #" + hex(color(r, g, b), 6), 200, 22);
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
  
  loadButton.ResetPosition(new PVector(15, 15));
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

void mousePressed()
{
  if (mouseButton == LEFT) {
    if (loadButton.hover)
    {
      selectInput("Select a file to process:", "LoadImage");
    } else if (RGBButton.hover) {
      copyToClipboard(r + ", " + g + ", " + b);
    } else if (HEXButton.hover) {
      copyToClipboard("#" + hex(color(r, g, b), 6));
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
