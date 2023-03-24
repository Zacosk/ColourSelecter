PImage selectedImage, displayedImage, lock, icon;
Button loadButton, resetButton;
boolean locked, moving;
float scale;
PVector pixelPos, imagePos, mousePos;
int wwidth, hheight;
String filePath;

void setup()
{
  size(600, 600);
  surface.setTitle("Image Colour Detector");
  surface.setResizable(true);
  lock = loadImage("Lock.png");
  lock.resize(50, 50);
  icon = loadImage("Icon.png");
  surface.setIcon(icon);
  selectedImage = loadImage("NoImageLoaded.png");
  displayedImage = selectedImage;
  loadButton = new Button("Select Image", new PVector(width-25, height-25), "SelectFolder");
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
    pixelPos = new PVector(mouseX, mouseY);
  }
  
  //display selected image
  if (selectedImage != null)
  {
    push();
    imageMode(CENTER);
    translate(imagePos.x, imagePos.y);
    scale(scale);
    image(displayedImage, 0, 0);
    pop();
  }
  
  
  //display hex and colour values
  int r = int(red(get((int)pixelPos.x, (int)pixelPos.y)));
  int g = int(green(get((int)pixelPos.x, (int)pixelPos.y)));
  int b = int(blue(get((int)pixelPos.x, (int)pixelPos.y)));
  fill(255);
  rect(0, height-50, width, 50);
  fill (color(r, g, b));
  noStroke();
  rect(10, height-37, 25, 25);
  fill(0);
  
  textSize(20);
  textAlign(LEFT);
  text("RGB: " + r + ", " + g + ", " + b, 40, height - 25);
  text("HEX: " + hex(color(r, g, b)), 40, height-5);
  
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

void DetectWindowSizeChange()
{
  if (hheight != height || wwidth != width)
  {
    loadButton.ResetPosition(new PVector(width-25, height - 25));
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
  
  loadButton.ResetPosition(new PVector(width-25, height - 25));
}

void LoadImage(File selection)
{
  if (selection != null)
  {
    selectedImage = loadImage(selection.getAbsolutePath());
    displayedImage = selectedImage;
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
