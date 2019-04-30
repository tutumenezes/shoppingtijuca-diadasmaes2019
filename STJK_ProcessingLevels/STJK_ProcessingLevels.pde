// Imports
import processing.serial.*;
import ddf.minim.*;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
import processing.video.*;



// Objects
Minim minim;
AudioPlayer heartbeat1;
AudioPlayer heartbeat2;
AudioPlayer error;
AudioInput input;
Robot robot;
Serial myPort;
Movie movie0;
Movie movie1;
Movie movie2;
Movie movie3;
Movie movie4;
PImage heartImg;
PImage heartOutline;

// Levels and Variables
int videoId, notespeed, changenum, success, won, gamemode;
char response;
int bgcolor;          
int[] serialInArray = new int[2];    // Where we'll put what we receive — change the number for the number of variables incoming from Serial
int serialCount = 0;                 // A count of how many bytes we receive
int xpos, ypos;                      // Starting position of the ball (for debuggin purposes
int x, y;
boolean firstContact = false;        // Whether we've heard from the microcontroller
boolean[] keys;

// GH Variables
ArrayList tile = new ArrayList();
int score=10;


// The setup code below is executed once only.
void setup() {
  
  //*determine the size of the screen
  size(1280,600);
  
  // Set the starting position of the ball (middle of the stage) for debuggin purposes
  xpos = width/2;
  ypos = height/2;
   
  
  // Creates the robot that will press keyboard keys when arduino buttons are pressed
  try {
    robot = new Robot();
  } catch ( AWTException e) {
    e.printStackTrace();
    exit();
  }
  
  // Sets up keys to recognize multiple input
  keys=new boolean[2];
  keys[0]=false;
  keys[1]=false;
  
  // Sets up the heartbeat sound and elements
  minim = new Minim(this);
  error = minim.loadFile("error.wav");
  heartbeat1 = minim.loadFile("batida.wav");
  heartbeat1.loop(2);
  heartbeat2 = minim.loadFile("batida.wav");
  heartbeat2.loop(2);
  
  // Sets up the Movies
  movie0 = new Movie(this, "00_start.mov"); movie0.loop();
  movie1 = new Movie(this, "01_frase01.mov"); movie1.loop();
  movie2 = new Movie(this, "02_frase02.mov"); movie2.loop();
  movie3 = new Movie(this, "03_frase03.mov"); movie3.loop();
  movie4 = new Movie(this, "04_final.mov"); movie4.loop();
  
  // Sets up images
  heartImg = loadImage("heartImg.png");
  heartOutline = loadImage("heartOutline.png");
  
  // Open Serial port that you're using - change number to fit your port //printArray(Serial.list());
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
  
  
  // Game Section (start)
  notespeed = 1; //note speed, changing this will up the difficulity, putting it too high will make 
               
  changenum = 60; // % number of notes created. Biggest number == less notes
                  
  success = 0; // Will be set to one if a player successfully completes a level.
  won = 0; // Will be set to one if a player successfully completes all levels.
  gamemode = 2; // A value of 0 means player is busy with a level.
                // A value of 1 means the player has either won or lost a level 
                // and is deciding what to do next.
  response = 'x'; // This variable will carry the player's keyboard presses.
  
  // /Game Section (end)
 
}

void draw() {
  
  //----- Graphics Section (start)
  background(21, 93, 218); // Erase the screen for the next time around the loop.
  
  // Draw the Elipse shape
  //ellipse(xpos, ypos, 20, 20);
  
  // Draw the Scoring Area // ADJUST ACCORDING TO WINDOW HEIGHT
  image(heartOutline, 100, 470, 100, 100);
  image(heartOutline, 1080, 470, 100, 100);
  fill(#aa0000, 20);
  noStroke();
  rect(0, 450, width, 150);

  
 if (gamemode == 2) {
   image(movie0, 0, 0);
   movie0.play();
   if (keys[0] || keys[1]) { //press both keys to start
     gamemode=0;
   }
 }
 
 if (gamemode == 0) {
   
     //create tiles
    int randomNumber = int(random(0, 1.9));
    tiles til = new tiles(randomNumber);
    
    //set amount of notes generates per second, frameCount%10=6 notes/second
    //TODO: increase by X after every Stage Success
    if (frameCount%changenum==0) {            
      tile.add(til);
    } 
    //loop that creates the tiles and checks if you hit them at the right time/place
    for (int i=0; i<tile.size(); i++) {
      tiles ta = (tiles) tile.get(i);
      ta.run();
      ta.display();
      ta.move();
      if (key=='d'&&ta.location.y>430&&ta.location.x==100&&keyPressed) {  //d
        ta.gone=true;
      }
      if (key=='k'&&ta.location.y>430&&ta.location.x==1080&&keyPressed) {  //k
        ta.gone=true;
      }
      if (ta.location.y>600) { // GAME OVER
        //if you let a note go your score goes to zero
        tile.remove(i);
        score= 0;
        changenum = 60; // 
        notespeed = 1;  // 
      }
      if (ta.gone==true) {
        //scoring system(you get more points if you do better)
        score+=ta.location.y>530?30:ta.location.y>480?50:20;
        tile.remove(i); 
      }
    }
  }
  
  // Score - prints the score somewhere on the screen
  fill(255);
  textAlign(CENTER);
  textSize(30);
  text("Pontos: " + score, width/2, height-50);
  text("Level: " + notespeed, width/2, height/8);
  //----- Graphics Section (end)
 
  //----- Level Section (start)
  // Here is where we handle game levels.
 
  if (score >= 200) { // Success!
    gamemode = 1; // Switch to game mode in which player decides what to do.
    success = 1;
  
    if (notespeed==1) {
      image(movie1, 0, 0);
      movie1.play();
    }
    
    if (notespeed==2) {
      image(movie2, 0, 0);
      movie2.play();
    }
    
    if (notespeed==3) {
      image(movie3, 0, 0);
      movie3.play();
    }
    
    if (notespeed==4) {
      image(movie4, 0, 0);
      movie4.play();
      won=1;
    }
 
  } 
  
  if (score == 0) { // Game Over!
    gamemode = 1; // Switch to game mode in which player decides what to do.
    success = 0;
    error.play();
    delay(100);
    text("Oh No! Continue?",width/2,height/2);
  }
  if(keys[0] && keys[1]){
    if (won==1) {
      notespeed = 1;
      changenum = 60;  // Player wants to start the game over.
      score = 10; // Reset the score variable.
      success = 0;  // Reset the success variable.
      response = 'x'; // Reset the response variable.
      won = 0;
      delay(1000);
      gamemode = 2; // Go back into play mode.
    } else {
      if (gamemode==1) { 
        if (success == 1) { // Player wants to continue to next level.
          //changenum += 1; // makes notes appear slower
          notespeed += 1;  // makes notes roll much faster
        } else changenum = 60;  // Player wants to start the game over.
          score = 10; // Reset the score variable.
          success = 0;  // Reset the success variable.
          response = 'x'; // Reset the response variable.
          gamemode = 0; // Go back into play mode.
        } 
      }
    }
  //----- Level Section (end)
  
}

// The following functions are called any time a player lifts her finger off a keyboard key after pressing it.

void keyPressed() {
 if (key=='d')
   keys[0]=true;
 if (key=='k')
   keys[1]=true;
}

void keyReleased() {
  switch(key) {
    case ' ': 
        response = ' '; // Remember that a 'space' response has been given.
        break;
      case 'd': 
        response = 'd'; // Remember that a 'yes' response has been given.
        keys[0]=false;
        break;
      case 'k': 
        response = 'k'; // Remember that a 'no' response has been given.
        keys[1]=false;
        break;
      default: // Do nothing if any other key is pressed
        break;
    }
}


void serialEvent(Serial myPort) {
  int inByte = myPort.read();
  if (firstContact == false) {
    if (inByte == 'A') { 
      myPort.clear();          // clear the serial port buffer
      firstContact = true;     // you've had first contact from the microcontroller
      myPort.write('A');       // ask for more
    } 
  }
  else {
    // Add the latest byte from the serial port to array:
    serialInArray[serialCount] = inByte;
    serialCount++;

    // If we have 3 bytes:
    if (serialCount > 1 ) {
      xpos = serialInArray[0];
      ypos = serialInArray[1];
      
      //play the heartbeat sound
      if (xpos == 255) {
       
        //Hit D on the keyboard and play note
        robot.keyPress(KeyEvent.VK_D); 
        heartbeat1.play();
         
         
      } else {
        robot.keyRelease(KeyEvent.VK_D);
        heartbeat1.pause();
        heartbeat1.rewind();
        delay(50);
      }
      if (ypos == 255) {
        
        //Hit K on the keyboard and play note
        robot.keyPress(KeyEvent.VK_K); 
        heartbeat2.play();
         
        
      } else {
        robot.keyRelease(KeyEvent.VK_K);
        heartbeat2.pause();
        heartbeat2.rewind();
        delay(50);
      }
 

      // print the values (for debugging purposes only):
      //println(xpos + "\t" + ypos);

      // Send a capital A to request new sensor readings:
      myPort.write('A');
      // Reset serialCount:
      serialCount = 0;
    }
  }
}

void movieEvent(Movie m) {
  m.read();
}

class tiles {
  PVector location;
  Boolean gone=false;

  tiles(int i) {
    
    if (i == 0) {
      location = new PVector( 100 , 0 );
    } else if (i == 1) {
      location = new PVector( 1080, 0);
    } else {
      location = new PVector( width - i*width/4, 0);
    }
  }

  void run() {
    display();
    move();
  }

  void display() {
    image(heartImg, location.x, location.y, 100, 100);
  }

  void move() {
    location.y+=notespeed;     
  }                           
}
