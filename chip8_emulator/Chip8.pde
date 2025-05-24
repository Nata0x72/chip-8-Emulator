

int first(int ist){
  return (ist >> 12);
}

 int sec(int ist){
  return (0x0F00 & ist) >> 8;
}

int third(int ist){
  return (0x00F0 & ist) >> 4;
}

int fourth(int ist){
  return (0x000F & ist) >> 0;
}

int addr(int inst){
  return inst & 0x0FFF;
}

int first_byte(int inst){
  return (inst & 0xFF00) >> 8;
}

int sec_byte(int inst){
  return inst & 0x00FF;
}

int comb(int a, int b, int size){
    return (a << size) | b;
}

int xor(int a, int b){
  return (a & ~b) | (~a & b);
}


boolean[] keys = new boolean[16];

void keyPressed(){
  
  if(km.hasKey(key+"")){
    keys[km.get(key+"")] = true;
    
  }
  
 // printArray(keys);
  
  
}


void keyReleased(){
  
  if(km.hasKey(key+"")){
    keys[km.get(key+"")] = false;
    

  }
  //ch8.update(); 

}






int[][] font = {
{0xF0,0x90,0x90,0x90,0xF0},  // 0
{0x20,0x60,0x20,0x20,0x70},  // 1
{0xF0,0x10,0xF0,0x80,0xF0},  // 2 
{0xF0,0x10,0xF0,0x10,0xF0},  // 3
{0x90,0x90,0xF0,0x10,0x10},  // 4
{0xF0,0x80,0xF0,0x10,0xF0},  // 5
{0xF0,0x80,0xF0,0x90,0xF0},  // 6
{0xF0,0x10,0x20,0x40,0x40},  // 7
{0xF0,0x90,0xF0,0x90,0xF0},  // 8
{0xF0,0x90,0xF0,0x10,0xF0},  // 9
{0xF0,0x90,0xF0,0x90,0x90},  // A
{0xE0,0x90,0xE0,0x90,0xE0},  // B
{0xF0,0x80,0x80,0x80,0xF0},  // C
{0xE0,0x90,0x90,0x90,0xE0},  // D
{0xF0,0x80,0xF0,0x80,0xF0},  // E
{0xF0,0x80,0xF0,0x80,0x80}}; // F 




class Chip8 {
  
  private byte[] memory;
  private byte[] V_reg;
  private int[] stack;
  
  private byte delay_timer;
  private byte sound_timer;

  private int PC;  
  private int SP;
  private int I;
  
  private boolean[][] frame_buffer;
      public boolean pause;
  
  
  
  
  Chip8(){
    
    println("start");
    
    this.memory = new byte[4096];
    this.V_reg = new byte[16];
    this.stack = new int[16];
    
    this.delay_timer = 0;
    this.sound_timer = 0;
    
    this.PC = 0x200;
    this.SP = -1;
    
    this.I = 0;
    
    this.frame_buffer = new boolean[64][32];
    
    println("loading font");
    int f = 0;
    for(int i = 0x00; f < 16; i+=5){
      this.load(byte(font[f]),i);
      f++;
    }
    
    println("font loaded");
    
  }
  
  public void reset(){
    
    this.memory = new byte[4096];
    this.V_reg = new byte[16];
    this.stack = new int[16];
    
    this.delay_timer = 0;
    this.sound_timer = 0;
    
    this.PC = 0x200;
    this.SP = -1;
    
    this.frame_buffer = new boolean[64][32];
    
    int f = 0;
    for(int i = 0x00; f < 16; i+=5){
      this.load(byte(font[f]),i);
      f++;
    }
    
  }
  
  public void update(){
    
  //  println("upfate_start");
  
  
    

   // println("delay timers fine");
    
   // println("fetching");
    int instruction = this.fetch();
   // println("fetched");
    
   // println("PC = "+hex(this.PC));
  //  println("PC = "+hex(this.V_reg[0]));
    this.PC += 2;
    
     if(this.PC >= this.memory.length){
      this.reset();
    }
    
    
   // println("decoding");
    this.decode(instruction);     
  //  println("executed "+hex(instruction));
  //  println();
   // printArray(int(this.V_reg));
    
    
    
   // println("start rendering");
   // this.render();
   /// println("end rendering");
  
  }
  
 public void load(byte[] data, int start){
  
  for(int i = 0; i < data.length; i++){ 
      
      if((start+i) >= memory.length){break;} 
      this.memory[i + start] = data[i];
  }
 }
  
  
  
  private int fetch(){
    
    byte a = this.memory[this.PC];
    byte b = this.memory[this.PC+1];
    
    return (int(a) << 8 ) | int(b);  
    
  }
  
  private void decode(int inst){
    
    int Vx;
    int Vy;
    byte kk;
      
      switch(first(inst)){
        
        case 0:
          if(inst == 0x00E0){this.cls(); return;}
          else if( inst == 0x00EE){this.ret(); return;}
          
          else{return;}
            
          
        case 1:
          this.jump(addr(inst));
          return;
        
        case 2: 
          this.call(addr(inst));
          return;
          
        case 3:
              kk = byte(sec_byte(inst));
              Vx = sec(inst);
              this.SE(Vx,kk);
              return;
 
        case 4: 
              kk = byte(sec_byte(inst));
              Vx = sec(inst);
              this.SNE(Vx,kk);
              return;
              
        
        case 5:
              Vy = third(inst);
              Vx = sec(inst);
              this.SE_reg(Vx,Vy);
              return;
        
        case 6:
               kk = byte(sec_byte(inst));
               Vx = sec(inst);
               this.LD(Vx,kk);
               break;
        
        
        case 7:
              kk = byte(sec_byte(inst));
              Vx = sec(inst);
              this.Add(Vx,kk);
              break;
        
        case 8:
              int f = fourth(inst);
              Vx = sec(inst);
              Vy = third(inst);
              if(f == 0){this.LD0(Vx,Vy);}
              else if(f == 1){this.OR(Vx,Vy);}
              else if(f == 2){this.AND(Vx,Vy);}
              else if(f == 3){this.XOR(Vx,Vy);}
              else if(f == 4){this.Add_reg(Vx,Vy);}
              else if(f == 5){this.SUB_reg(Vx,Vy);}
              else if(f == 6){this.SHR(Vx,Vy);}
              else if(f == 7){this.SUBN(Vx,Vy);}
              else if(f == 0xE){SHL(Vx,Vy);}
              
              break;
        
        case 9:
              Vx = sec(inst);
              Vy = third(inst);
              this.SNE_reg(Vx,Vy);
            
            break;
        case 10:
            this.LD_I(addr(inst));
            break;
            
        case 11:
                this.jump_V0(addr(inst));
            
            break;
        case 12:
                Vx = sec(inst);
                kk = byte(sec_byte(inst));
                this.RND(Vx,kk);
            break;
            
        case 13:
              Vx = sec(inst);
              Vy = third(inst);
              this.DRW(Vx,Vy,fourth(inst));
          
            break;
            
        case 14:
               if(fourth(inst) == 0xE){
                 this.SKP(sec(inst));
               }
               
               else{
                 this.SKNP(sec(inst));
               }
              
       
            break;
            
        case 15:
              int s = sec_byte(inst);
              Vx = sec(inst);
              Vy = third(inst);
         
              if(s == 0x07){this.LD_DT(Vx);}
              else if(s == 0x0A){this.wait(Vx);}
              else if(s == 0x15){this.SET_DT(Vx);}
              else if(s == 0x18){this.SET_ST(Vx);}
              else if(s == 0x1E){this.Add_I(Vx);}
              else if(s == 0x29){this.LD_F(Vx);}
              else if(s == 0x33){this.BCD(Vx);}
              else if(s == 0x55){this.load_reg(Vx);}
              else if(s == 0x65){this.read_reg(Vx);}
            break;
        default:
            return;

        
      }
    
    
  }
  
  
  
  public void render(){
    
    if(this.delay_timer != 0) {this.delay_timer--;}
    
    if(this.sound_timer != 0) {this.sound_timer--; pulse.play();}
    else{pulse.stop();}
    
    
    int cols = this.frame_buffer.length;
    int rows = this.frame_buffer[0].length;
    
    for(int i = 0; i < rows; i++){
      for(int o = 0; o < cols; o++){
        
        if(this.frame_buffer[o][i]){
          fill(255);
        }
        
        else{fill(0);}
        
        square(8*o,8*i,8);
      
      }
    }
  }
  
  
  
  
  private void cls(){
   
    this.frame_buffer = new boolean[64][32];
  }
  
  private void ret(){
    this.PC = this.stack[SP];
    SP--;
  }
  
  private void jump(int nnn)  {this.PC = nnn;}
  
  private void call(int nnn) {
    SP++;
    this.stack[SP] = PC;
    this.jump(nnn);
  }
  
  private void SE(int Vx, byte kk){
    if(this.V_reg[Vx] == kk){
      this.PC += 2;
    }
  }
  
  private void SNE(int Vx, byte kk){
    if(this.V_reg[Vx] != kk){
      this.PC += 2;
    } 
  }
  
  private void SE_reg(int Vx, int Vy){
    if(this.V_reg[Vx] == this.V_reg[Vy]){
      this.PC += 2;
    }
  }
  
  private void LD(int Vx, byte kk){
    this.V_reg[Vx] = byte(kk);
  }
  
  
  private void Add(int Vx, byte kk){
    this.V_reg[Vx] = byte(this.V_reg[Vx] + kk);
  }
  
  
  private void LD0(int Vx, int Vy){
    this.V_reg[Vx] = byte(this.V_reg[Vy]);
  }
  
  
 private void OR(int Vx, int Vy){
   this.V_reg[Vx] = byte(this.V_reg[Vx] | this.V_reg[Vy]);
   this.V_reg[0xF] = 0;
  }
  
 private void AND(int Vx, int Vy){
   this.V_reg[Vx] = byte(this.V_reg[Vx] & this.V_reg[Vy]);
   this.V_reg[0xF] = 0;
  }
  
  
 private void XOR(int Vx, int Vy){
   this.V_reg[Vx] = byte(xor(this.V_reg[Vx],this.V_reg[Vy]));
   this.V_reg[0xF] = 0;
  }
  
  
  private void Add_reg(int Vx, int Vy){
    int a = int(this.V_reg[Vx]);
    int b = int(this.V_reg[Vy]);
    
    int s = a + b;
    
    this.V_reg[Vx] = byte(s);
    
    if(s > 255){this.V_reg[0xF] = byte(1);} 
    else       {this.V_reg[0xF] = byte(0);}
    
    
    
  }
  
  
  private void SUB_reg(int Vx, int Vy){
   
    byte a = this.V_reg[Vx];
    byte b = this.V_reg[Vy];    
  
    this.V_reg[Vx] = byte(int(a) - int(b));
    
    if(int(a) >= int(b)){this.V_reg[0xF] = byte(1);}
    else               {this.V_reg[0xF] = byte(0);}
    
  }
  
  
  private void SHR(int Vx){
    
    int bit = (int(this.V_reg[Vx])) & 0x01;
    
    this.V_reg[Vx] = byte(this.V_reg[Vx]/2);
    
    if(bit == 1){this.V_reg[0xF] = 1;}
    else        {this.V_reg[0xF] = 0;}
    
    
    
  }
  
    private void SHR(int Vx,int Vy){
    
    int bit = (int(this.V_reg[Vy])) & 0x01;
    
    this.V_reg[Vx] = byte(this.V_reg[Vy]/2);
    
    if(bit == 1){this.V_reg[0xF] = 1;}
    else        {this.V_reg[0xF] = 0;}
    
    
    
  }
  
  private void SUBN(int Vx, int Vy){
    
    int a = int(this.V_reg[Vx]);
    int b = int(this.V_reg[Vy]);
    
    this.V_reg[Vx] = byte(b - a);
  
    if(b >= a){this.V_reg[0xF] = byte(1);}
    else     {this.V_reg[0xF] = byte(0);}
    
    
    
    
  
  }
  
  
  private void SHL(int Vx){
    
    int bit = (int(this.V_reg[Vx])) >> 7;
    
    this.V_reg[Vx] = byte(this.V_reg[Vx]*2);
    
    if(bit == 1){this.V_reg[0xF] = 1;}
    else        {this.V_reg[0xF] = 0;}
   
  }
  
    private void SHL(int Vx,int Vy){
    
    int bit = (int(this.V_reg[Vy])) >> 7;
    
    this.V_reg[Vx] = byte(this.V_reg[Vy]*2);
    
    if(bit == 1){this.V_reg[0xF] = 1;}
    else        {this.V_reg[0xF] = 0;}
   
  }
  
  
  private void SNE_reg(int Vx, int Vy){
    if(this.V_reg[Vx] != this.V_reg[Vy]){
      this.PC += 2;
    }
  }
  
  
  private void LD_I(int adr){
    this.I = adr;
  }
  
  private void jump_V0(int adr){
    this.PC = adr + this.V_reg[0];
  }
  
  private void RND(int Vx, byte kk){
    this.V_reg[Vx] = byte( kk & byte(random(0,255)) );
  }
  
  private void DRW(int Vx, int Vy, int n){
    
    
    int x =  int(this.V_reg[Vx]) % 64;
    int y =  int(this.V_reg[Vy]) % 32;
    
    this.V_reg[15] = 0;
    
    for(int row = 0; row < n; row++){
      String bin = binary(this.memory[this.I+row]);
      
      int py = (y+row);
      
      if(py >= 32){
        return;
      }
      
      for(int col = 0; col < bin.length(); col++){
        int px = (x+col);
        
        if(px >= 64){
          continue;
        }
        
        boolean new_pix = (bin.charAt(col) == '1');
        boolean old_pix = this.frame_buffer[px][py]; 
        
        if(new_pix && old_pix){
          this.V_reg[15] = byte(1);
          this.frame_buffer[px][py] = false;
        }
        
        else if(!old_pix){
          this.frame_buffer[px][py] = new_pix;
        }
        
        
       
      }
      
      
    }
    
    
    
  }
  
  
  
  private void SKP(int Vx){
    if(keys[this.V_reg[Vx]]){this.PC += 2;}
   
  }
  
  private void SKNP(int Vx){
    if(!keys[this.V_reg[Vx]]){this.PC += 2;}
  }
 
  
  private void LD_DT(int Vx){
    this.V_reg[Vx] = byte(this.delay_timer);
  }
  
  boolean ke;
  private void wait(int Vx){
    
    if(ke){
       for(int k = 0; k < 16; k++){
          if(keys[k]){this.PC -= 2;return;}
          
          else{
            ke = false;
            this.V_reg[Vx] = byte(k); 
            return;
          }
       }
    }
    for(int k = 0; k < 16; k++){
      if(keys[k]){
       //this.V_reg[Vx] = byte(k);
       ke = true;
       return;
      }
    }
    
    this.PC -=2;
   
  }
  
  
  private void SET_DT(int Vx){
    this.delay_timer = this.V_reg[Vx];
  }
  
   private void SET_ST(int Vx){
    this.sound_timer = this.V_reg[Vx];
  }
  
  private void Add_I(int Vx){
    this.I += int(this.V_reg[Vx]);
  }
  
  private void LD_F(int Vx){
    this.I = 5 * int(this.V_reg[Vx]);
  }
  
  private void BCD(int Vx){
    int d = int(this.V_reg[Vx]);
    
    this.memory[this.I] =   byte(d/100);
    this.memory[this.I+1] = byte((d/10)%10);
    this.memory[this.I+2] = byte(d%10);
     
  }
  
  
  private void load_reg(int Vx){
     for(int i = this.I; i <= Vx+this.I; i++){
      this.memory[i] = byte(this.V_reg[i - this.I]);
      
    }
    
      this.I += Vx + 1;
    
  }
  
  private void read_reg(int Vx){
    for(int i = this.I; i <= Vx+this.I; i++){
      this.V_reg[i - this.I] = byte(this.memory[i]);
     
    }
    
     this.I += Vx + 1;
  }
  
  
    
    
  
  
  
  
  
  
  
  
 
}
