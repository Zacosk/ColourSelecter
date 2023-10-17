//Key Manager
void keyPressed() {
  if (key == 'x') {
    if (!captureActive) {
      mouseSelect = false;
      zoom = maxZoom;
      targetLerp = colourPreviewCornerPos;
      colourIndicatorLerping = true;
      captureHeight = 100;
    } else {
      captureHeight = 330;
      captureScreenShot();
    }
    captureActive = !captureActive;
  }
  if (key == 'z') {
    if (zoom == maxZoom) {
      zoom = maxZoom*2;
    } else {
      zoom = maxZoom;
    }
  }
  if (char(keyCode) == 'R') {
    if (controlPressed) {
      rgbKeyPressed = true;
    } else {
      zoom = maxZoom;
      imagePos = centrePoint;
    }
  }
  if (char(keyCode) == 'H') hexKeyPressed = true;

  if (key == CODED)
  {
    if (keyCode == CONTROL && !controlPressed) {
      controlPressed = true;
    }
    if (!captureActive)
    {
      if (keyCode == UP) panningUp = true;
      if (keyCode == DOWN) panningDown = true;
      if (keyCode == RIGHT) panningRight = true;
      if (keyCode == LEFT) panningLeft = true;
    }
  }
}

void keyReleased()
{
  if (char(keyCode) == 'H') hexKeyPressed = false;
  if (char(keyCode) == 'R') rgbKeyPressed = false;
  if (key == CODED)
  {
    if (keyCode == CONTROL)
    {
      controlPressed = false;
    }
    if (!captureActive)
    {
      if (keyCode == UP) panningUp = false;
      if (keyCode == DOWN) panningDown = false;
      if (keyCode == RIGHT) panningRight = false;
      if (keyCode == LEFT) {panningLeft = false;}
    }
  }
}

void mousePressed()
{
  if (mouseButton == LEFT)
  {
    //Buttons
    if (rgbButton.hover) copyToClipboard(red + ", " + green + ", " + blue);
    else if (hexButton.hover) 
    {
      String hash = "#";
      if (!hexCopyHashToggle.toggledOn) {
        hash = "";
      }
      copyToClipboard(hash + hex(color(red, green, blue), 6));
    }
    else if (settingsButton.hover) {
      displaySettings = !displaySettings;
      if (displaySettings) 
      {
        captureActive = false;
        DrawSettings(); 
      } else {
        if (!mouseSelect) {
          captureActive = true;
        }
      }
    }
    
    //Toggles
    else if (resizeOnHoverToggle.hover) {
      resizeOnHoverToggle.toggledOn = !resizeOnHoverToggle.toggledOn;
      SaveSettings();
    } else if (darkModeToggle.hover) {
      darkModeToggle.toggledOn = !darkModeToggle.toggledOn;
      SaveSettings();
      ToggleDarkMode();
    } else if (forceFullResToggle.hover) {
      forceFullResToggle.toggledOn = !forceFullResToggle.toggledOn;
      captureWidth = 330;
      captureHeight = 100;
      maxZoom = 1;
      zoom = maxZoom;
      SaveSettings();
    } else if (hexCopyHashToggle.hover) {
      hexCopyHashToggle.toggledOn = !hexCopyHashToggle.toggledOn;
      SaveSettings();
      
      //Else
    } else if (!captureActive && !displaySettings) {
      mouseSelect = !mouseSelect;
      if (mouseSelect) 
      {
        previousSelectedColour = selectedColour; 
        // targetLerp = colourPreviewMousePos; colourIndicatorLerping = true;
      }
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
  if (mouseButton == RIGHT) panning = false;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  zoom -= e * 0.5;
  if (zoom < maxZoom) {
    zoom = maxZoom;
  }
}

void CheckCopyKeys() {
  if (controlPressed) {
    if (hexKeyPressed) {
      String hash = "#";
      if (!hexCopyHashToggle.toggledOn) {
        hash = "";
      }
      copyToClipboard(hash + hex(color(red, green, blue), 6));
    } else if (rgbKeyPressed) {
      copyToClipboard(red + ", " + green + ", " + blue);
    }
  }
}
