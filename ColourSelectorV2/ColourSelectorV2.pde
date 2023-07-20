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
Button rgbButton, hexButton, settingsButton;
ToggleButton resizeOnHoverToggle, darkModeToggle;

Boolean captureActive, mouseSelect, panning, panningUp, panningDown, panningLeft, panningRight, surfaceChanging, surfaceExpanded, displaySettings;
color selectedColour;
int r, g, b;
PVector centrePoint, detectionPoint, imagePos, mousePos;
float scale, currentTime, lastTime, deltaTime;

JSONObject settingsJSON;

void setup(){
  //initialise window settings
  //pixelDensity(displayDensity());
  size(330, 130);
  smooth(8);
  surface.setTitle("Pixel Colour Selector");
  surface.setAlwaysOnTop(true);
  icon = loadImage("Icon.png");
  surface.setIcon(icon);
  
  captureActive = true;
  panning = false;
  surfaceExpanded = false;
  mouseSelect = false;
  surfaceChanging = false;
  displaySettings = false;
  panningUp = false;
  panningDown = false;
  panningRight = false;
  panningLeft = false;
  
  scale = 1;
  centrePoint = new PVector(width/2, 80);
  detectionPoint = centrePoint;
  imagePos = centrePoint;
  lastTime = millis();
  
  //New screen capture variables
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
  settingsButton = new Button("Settings", new PVector(width-30, 0), "BlankButtonDark", new PVector(30, 30));

  LoadSettings();

  //Initialise toggles
  resizeOnHoverToggle = new ToggleButton(settingsJSON.getBoolean("expandOnHover"), new PVector(width-40, 45), "Expand on hover  -  ");
  darkModeToggle = new ToggleButton(settingsJSON.getBoolean("darkMode"), new PVector(width-40, 75), "Dark mode  -  ");
  
  ToggleDarkMode();
  SaveSettings();
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
  CalculateDeltaTime();
  CheckPanning();
  
  DetectionMode();
  
  if (displaySettings) 
  {
    DrawSettings(); 
  }
  
  if (resizeOnHoverToggle.toggledOn)
  {
    RunChangeSurfaceSize();
  }
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
  settingsButton.Run();
  
  //Draw text
  fill(0);
  if (darkModeToggle.toggledOn)
  {
    fill(255);
  }
  textSize(20);
  textAlign(LEFT);
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

void DrawSettings()
{
  noStroke();
  fill(255);
  if (darkModeToggle.toggledOn)
  {
    fill(56);
  }
  rect(0, 30, width, height-30);
  
  resizeOnHoverToggle.Run();
  darkModeToggle.Run();
}

String formatNum(int num) 
{
  return String.format("%03d", num);
}

void CalculateDeltaTime()
{
  currentTime = millis();
  
  deltaTime = (currentTime - lastTime);
  lastTime = currentTime;
}

void RunChangeSurfaceSize() 
{
  
  if (mouseSelect && !surfaceExpanded)
  {
    surface.setSize(width, height + (int)(1 * deltaTime));
    if (height >= 300) {
      surfaceExpanded = true;
      surface.setSize(width, 300);
      surfaceChanging = false;
    }
  } else if (captureActive && surfaceExpanded)
  {
    surface.setSize(width, height - (int)(1 * deltaTime));
    if (height <= 130) {
      surfaceExpanded = false;
      surface.setSize(width, 130);
      surfaceChanging = false;
    }
  }
}

void LoadSettings()
{
  if (checkFileExists("data/settings.json"))
  {
    settingsJSON = loadJSONObject("settings.json");
  } else {
    println("json not found, creating");
    settingsJSON = new JSONObject();
    settingsJSON.setBoolean("darkMode", true);
    settingsJSON.setBoolean("expandOnHover", false);
  }
}

void SaveSettings()
{
  settingsJSON.setBoolean("darkMode", darkModeToggle.toggledOn);
  settingsJSON.setBoolean("expandOnHover", resizeOnHoverToggle.toggledOn);
  saveJSONObject(settingsJSON, "data/settings.json");
}

boolean checkFileExists(String fileName) {
  File file = new File(sketchPath(fileName));
  return file.exists();
}

void ToggleDarkMode()
{
  rgbButton.UpdateImg(darkModeToggle.toggledOn);
  hexButton.UpdateImg(darkModeToggle.toggledOn);
  settingsButton.UpdateImg(darkModeToggle.toggledOn);
  
  darkModeToggle.UpdateTextColour(darkModeToggle.toggledOn);
  resizeOnHoverToggle.UpdateTextColour(darkModeToggle.toggledOn);
}

void mousePressed()
{
  if (mouseButton == LEFT)
  {
    if (rgbButton.hover) {
      copyToClipboard(r + ", " + g + ", " + b);
    } else if (hexButton.hover) {
      copyToClipboard("#" + hex(color(r, g, b), 6));
    } else if (settingsButton.hover) {
      displaySettings = !displaySettings;
    } else if (resizeOnHoverToggle.hover) {
      resizeOnHoverToggle.toggledOn = !resizeOnHoverToggle.toggledOn;
      SaveSettings();
    } else if (darkModeToggle.hover) {
      darkModeToggle.toggledOn = !darkModeToggle.toggledOn;
      SaveSettings();
      ToggleDarkMode();
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
    mouseSelect = false;
    scale = 1;
  }
  if (key == CODED && !captureActive)
  {
    if (keyCode == UP) {
      panningUp = true;
    }
    if (keyCode == DOWN) {
      panningDown = true;
    }
    if (keyCode == RIGHT) {
      panningRight = true;
    }
    if (keyCode == LEFT) {
      panningLeft = true;
    }
  }
}

void keyReleased()
{
  if (key == CODED && !captureActive)
  {
    if (keyCode == UP) {
      panningUp = false;
    }
    if (keyCode == DOWN) {
      panningDown = false;
    }
    if (keyCode == RIGHT) {
      panningRight = false;
    }
    if (keyCode == LEFT) {
      panningLeft = false;
    }
  }
}

void CheckPanning() {
  if (panningUp) {
    imagePos.y += 0.5f * deltaTime;
  }
  if (panningDown) {
    imagePos.y -= 0.5f * deltaTime;
  }
  if (panningLeft) {
    imagePos.x += 0.5f * deltaTime;
  }
  if (panningRight) {
    imagePos.x -= 0.5f * deltaTime;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scale -= e * 0.5;
  if (scale < 1) {
    scale = 1;
  }
}
