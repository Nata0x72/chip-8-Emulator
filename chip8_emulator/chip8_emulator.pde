import processing.sound.*;



IntDict km = new IntDict();
Pulse pulse;
Chip8 ch8;
                 //Ld V0, 255
int[] test_rom = {
  0x00,0xE0,0x63,0x80,0x64,0x00,0x65,0x00,0xA,0x00,0xF3,0x33,0xF2,0x65,0xF0,0x29,0xD4,
  0x55,0xF1,0x29,0x74,0x08,0xD4,0x55 ,0xF2,0x29 ,0x74,0x08 ,0xD4,0x55 ,0xF0,0x00}; 


/*
0x60FF, //0x200
0x7001, //0x202
0x620F, //0x204
0x610C, //0x206

0x3000, //0x208
0x1214, //0x20A

0xF229, //0x20C
0x00E0, //0x20E
0xD005, //0x210
0x1212, //0x212

0xF129, //0x214
0x00E0, //0x216
0xD005, // 0x218
0x121A  // 0x21A
*/

void setup(){
  
  size(64*8,32*8);

  
    km.set("1",1);
    km.set("2",2);
    km.set("3",3);
    km.set("4",0xC);  
    km.set("q",4);  
    km.set("w",5);  
    km.set("e",6);
    km.set("r",0xD);
    km.set("a",7);
    km.set("s",8);  
    km.set("d",9);  
    km.set("f",0xE);  
    km.set("z",10);  
    km.set("x",0);  
    km.set("c",11);  
    km.set("v",0xF);
    
    pulse = new Pulse(this);
    pulse.freq(400);
    
    ch8 = new Chip8();
    
    String ibm = "2-ibm-logo.ch8";
    String chip8 = "1-chip8-logo.ch8";
    String corax = "3-corax+.ch8";
      
    String flags = "4-flags.ch8";
    String quirk = "5-quirks.ch8";
    String keypad = "6-keypad.ch8";
    
    
    String tetris = "Tetris [Fran Dachille, 1991].ch8";
    String pong = "pong.rom";
    String space = "Space Invaders [David Winter].ch8";
    
    
    byte[] ROM = loadBytes(pong);
    
    ch8.load(ROM,0x200);
   
    
    frameRate(60);
    
    //noStroke();
    
    thread("updater");
    
  
  
}






void draw(){
  background(0);
  ch8.render();
  
}


 void updater(){
  float oldtime = millis();
  float newTime;
  float dt = 0; 
  float t  = 1000/500;  
   
  while(true){
    newTime = millis();
    dt += newTime - oldtime;
    if(dt >= t){
    ch8.update();
    dt = 0;
    }
    
    oldtime = newTime;
    
    
  }
}
