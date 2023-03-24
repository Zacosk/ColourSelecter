PImage selectedImage, lock, icon;
Button loadButton, resetButton;
boolean locked, moving;
float scale;
PVector selectedPixelPos, imagePos, mousePos;
int wwidth, hheight;

void setup()
{
  size(600, 600);
  
  surface.setTitle("Image Colour Detector");
  surface.setResizable(true);
  
  icon = loadImage("Icon.png");
  surface.setIcon(icon);
  
  lock = loadImage("Lock.png");
  lock.resize(50, 50);
  selectedImage = loadImage("NoImageLoaded.png");
  
  loadButton = new Button("Select Image", new PVector(15, 15), "SelectFolder");
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
  DetectWindowSizeChange();
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
    image(lock, 0, 0);
  }
  loadButton.Run();
}

void ColourStats()
{
  //display hex and colour values
  int r = int(red(get((int)selectedPixelPos.x, (int)selectedPixelPos.y)));
  int g = int(green(get((int)selectedPixelPos.x, (int)selectedPixelPos.y)));
  int b = int(blue(get((int)selectedPixelPos.x, (int)selectedPixelPos.y)));
  stroke(1);
  fill(255);
  rect(-1, -1, width+1, 31);
  fill (color(r, g, b));
  noStroke();
  rect(10, height-37, 25, 25);
  fill(0);
  
  textSize(20);
  textAlign(LEFT);
  text("RGB: " + r + ", " + g + ", " + b, 40, 20);
  text("HEX: " + hex(color(r, g, b)), 220, 20);
}

void DetectWindowSizeChange()
{
  if (hheight != height || wwidth != width)
  {
    loadButton.ResetPosition(new PVector(15, 15));
  }
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

void mousePressed()
{ 
  if (mouseButton == LEFT) {
    if (loadButton.hover)
    {
      selectInput("Select a file to process:", "LoadImage");
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
    imagePos = new PVector(25, 25);
  }
}
