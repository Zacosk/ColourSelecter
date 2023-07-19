import java.awt.*;
import java.awt.datatransfer.*;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.MouseInfo;
import java.awt.Point;

//initialise screen shot variables
PImage screenshot, icon;
Robot robot;
BufferedImage capturedImage;
Rectangle screenshotSize;

//initialise mouse variables
Point mouse;

//Button variables
Button rgbButton, hexButton;

Boolean captureActive, mouseSelect, panning;
color selectedColour;
int r, g, b;
PVector centrePoint, detectionPoint, imagePos, mousePos;
float scale;

void setup(){
  //initialise window settings
  //pixelDensity(displayDensity());
  size(300, 130);
  smooth(8);
  surface.setTitle("Pixel Colour Selector");
  surface.setAlwaysOnTop(true);
  icon = loadImage("Icon.png");
  surface.setIcon(icon);
  
  captureActive = true;
  mouseSelect = false;
  panning = false;
  scale = 1;
  centrePoint = new PVector(width/2, 80);
  detectionPoint = centrePoint;
  imagePos = centrePoint;
  
  //New screen shot variables
  try
  {
    robot = new Robot();
    screenshot = new PImage();
  } catch (AWTException e){
    throw new RuntimeException("Unable to Initialize", e);
  }

  //Initialise buttons
  rgbButton = new Button("Copy RGB", new PVector(0, 0), "BlankButtonDark", new PVector(168, 30));
  hexButton = new Button("Copy HEX", new PVector(168, 0), "BlankButtonDark", new PVector(134, 30));
}
void draw(){
  background(0);
  if (captureActive) {
    captureScreenShot();
  }
  
  if (panning)
  {
    imagePos = new PVector(imagePos.x + (mousePos.x - mouseX) * -1, imagePos.y + (mousePos.y - mouseY) * -1);
    mousePos = new PVector(mouseX, mouseY);  
  }
  
  //Screen image
  push();
  translate(imagePos.x, imagePos.y);
  scale(scale);
  imageMode(CENTER);
  image(screenshot,0, 0);
  pop();
  
  GetPixelColour();
  
  DrawTopBar();
  DrawColourPreview();
  
  DetectionMode();
}

void captureScreenShot()
{
  mouse = MouseInfo.getPointerInfo().getLocation();
  
  screenshotSize = new Rectangle(mouse.x-150, mouse.y-150, 300, 300);
  capturedImage = robot.createScreenCapture(screenshotSize);//new Rectangle(Toolkit.getDefaultToolkit().getScreenSize()));
  screenshot = new PImage(capturedImage);
}

void GetPixelColour()
{
  r = int(red(get((int)detectionPoint.x, (int)detectionPoint.y)));
  g = int(green(get((int)detectionPoint.x, (int)detectionPoint.y)));
  b = int(blue(get((int)detectionPoint.x, (int)detectionPoint.y)));
  selectedColour = color(r, g, b);
}

void DetectionMode()
{
  if (captureActive)
  {
    detectionPoint = centrePoint;
    imagePos = centrePoint;
  } else if (mouseSelect){
    detectionPoint = new PVector(mouseX, mouseY);
  }
  //Crosshair
  noFill();
  stroke(color(255-r, 255-g, 255-b));
  strokeWeight(3);
  circle(detectionPoint.x, detectionPoint.y, 10);
}

void DrawTopBar() {
  //Draw buttons
  rgbButton.Run();
  hexButton.Run();
  
  //Draw text
  fill(255);
  textSize(20);
  text("RGB: " + formatNum(r) + ", " + formatNum(g) + ", " + formatNum(b), 8, 22);
  text("HEX: #" + hex(selectedColour, 6), 176, 22);
}

void DrawColourPreview()
{
  //Draw colour preview
  stroke(color(255-r, 255-g, 255-b));
  strokeWeight(2);
  fill(selectedColour);
  rect(width-32, height-32, 30, 30);
}

String formatNum(int num) 
{
  return String.format("%03d", num);
}

void mousePressed()
{
  if (mouseButton == LEFT)
  {
    if (rgbButton.hover) {
      copyToClipboard(r + ", " + g + ", " + b);
    } else if (hexButton.hover) {
      copyToClipboard("#" + hex(color(r, g, b), 6));
    } else if (!captureActive){
      mouseSelect = !mouseSelect;
    }
  }
  if (mouseButton == RIGHT)
  {
    if (!panning) {
      mousePos = new PVector(mouseX, mouseY);
      panning = true;
    }
  }
}

void mouseReleased()
{
  if (mouseButton == RIGHT)
  {
    panning = false;
  }
}

void copyToClipboard(String stringToCopy){
  StringSelection selection = new StringSelection(stringToCopy);
  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  clipboard.setContents(selection, selection);
}

void keyPressed() {
  if (key == 'x') {
    captureActive = !captureActive;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scale -= e * 0.5;
  if (scale < 1) {
    scale = 1;
  }
}
