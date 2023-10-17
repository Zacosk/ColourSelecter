public class Button
{
  String imageName;
  PShape icon;
  PVector position, size, scale;
  color darkCol, lightCol;
  public boolean hover;
  float timer;
  
  public Button(String text, PVector position, String imageName, PVector scale, PVector size)
  {
    this.position = position;
    this.imageName = imageName;
    
    this.darkCol = color(102);
    this.lightCol = color(255);
    
    this.icon = loadShape(imageName + ".svg");
    this.icon.scale(scale.x, scale.y);
    this.scale = scale;
    this.size = size;
  }
  
  public void Run()
  {
    Draw();
    CheckHover();
  }
  
  public void Draw()
  {
    push();
    translate(position.x, position.y);
    icon.setFill((darkModeToggle.toggledOn == false) ? lightCol : darkCol);
    //if (darkMode == true) ? icon.setFill(darkCol); : icon.setFill(lightCol);
    if (hover)
    {
      icon.setFill((darkModeToggle.toggledOn == false) ? lightCol + color(205) : darkCol + color(35));
    }
    shape(icon, 0, 0);
    pop();
  }
  
  //Popup with the name of the button if the user 
  //mouses over it for a set amount of time
  public void PopupTimer()
  {
    if (!hover)
    {
      timer = 0;
      return;
    } else {
      timer += 1;
    }
    if (timer >= 80)
    {
      //Background
      fill(255);
      rect(mouseX + 15, mouseY-5, 110, 20);
      //Popup Text
      fill(0);
      textAlign(LEFT);
      textSize(20);
      text(imageName,mouseX + 17, mouseY+10);
    }
  }
  
  public void ResetPosition(PVector position)
  {
    this.position = position;
  }
  
  public void CheckHover()
  {
    hover = false;
    if (mouseX <= (position.x-1) + (size.x) && mouseX >= (position.x+1))
    {
      if (mouseY <= (position.y-1) + (size.y) && mouseY >= (position.y+1))
      {
        hover = true;
      }
    }
  }
  
  public void UpdateImg(boolean darkMode)
  {
    if (darkMode)
    {
      icon.setFill(darkCol);
      icon.setStroke(lightCol);
    } else {
      icon.setFill(lightCol);
      icon.setStroke(darkCol);
    }
  } 
}
