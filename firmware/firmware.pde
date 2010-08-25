// we need fundamental FILE definitions and printf declarations
#include <stdio.h>

// create a FILE structure to reference our UART output function
static FILE uartout = {0} ;

// create a output function
// This works because Serial.write, although of type virtual, already exists.
static int uart_putchar (char c, FILE *stream)
{
    Serial.write(c) ;
    return 0 ;
}

const int MuxR=0;
const int MuxC=1;

const int inh[]={8,9};
const int a[]={2,5};
const int b[]={3,6};
const int c[]={4,7};

const int doorPin =  10;
const int greenOn =  11;
const int greenOff =  12;

void setup() {
  //all pins default to output
  
  //setupdoor => active low
  digitalWrite(doorPin, HIGH);
  
  //inhibit mux
  inhibitAll();
  
  //start serial port at 115200 bps
  Serial.begin(115200);
  //Enable printf => fill in the UART file descriptor with pointer to writer.
  fdev_setup_stream (&uartout, uart_putchar, NULL, _FDEV_SETUP_WRITE);

  //The uart is the standard output device STDOUT.
  stdout = &uartout ;
}

void loop() {
	char func =0;
	
    if (Serial.available() > 0) {
    // get incoming byte:
      func = Serial.read();
      if(func=='r'){
        /* Momentary Connect Row-Col */
        pressRowColumn();
      }
#if DEBUG	  
	  else if(func=='h'){
        /* HOLD */
        holdRowOrColumn();        
      }else if(func=='c'){
        /* CLEAR */
        inhibitAll();
        printf("Remote> clear\n");
      }
#endif
	  else if(func=='d'){
        /*device*/
        pressDevice();
      }else{
        printf("ERR: don't know function: %s\n",func);
      }
    }
}

#if DEBUG
void holdRowOrColumn(){
  while(Serial.available() < 2)
    true;//block till get what we need

  char m=Serial.read();
  char row[]="row";
  char col[]="col";
  char dev[]="dev";
  char * label;
  int mux;
  if(m=='r'){
      mux = MuxR;
      label= row;
  }else if(m=='c'){
      mux = MuxC;    
      label= col;
  }else{
      mux = MuxD;
      label= dev;
  }
  
  int which = parse(Serial.read());
  
  printf("Remote> hold %s: %d\n",label,which);
  setMuxCh(mux,which);
  setMuxInh(mux,false);
}
#endif

void pressDevice(){
  //0=g1,1=g2,2=b1,3=b2,4=d
  while(Serial.available() < 1)
    true;//block till get what we need  
  char which = Serial.read();
 
  if(which=='g'){
    while(Serial.available() < 1) true;
    
	int pin=Serial.read()=='1'?greenOn:greenOff;
	//green thing => active high
	digitalWrite(pin,HIGH);
	delay(1000);
	digitalWrite(pin,LOW);
    printf("OK: green %s\n",on?"on":"off");
  }else if(which=='d'){
    //openDoor => active low
	digitalWrite(doorPin,LOW);
	delay(1000);
	digitalWrite(doorPin,HIGH);
	printf("OK: door");
  }else{
    printf("ERR: don't know %c\n",which);
  }
}

void pressRowColumn(){
  while(Serial.available() < 2)
    true;//block till get what we need
  char cRow = Serial.read();
  char cCol = Serial.read();
  int iRow=parse(cRow);
  int iCol=parse(cCol);
  
#if DEBUG
  printf("(%c,%c)> row:%d col:%d\n\r",cRow,cCol,iRow,iCol);
#endif

  //press key
  if(iRow>5)
  {
    printf("ERROR: row %d not supported\n",iRow);
    return;    
  }
  
  inhibitAll();//just in case, inhibit all
  
  setMuxCh(MuxR,iRow);
  setMuxCh(MuxC,iCol);
  
  setMuxInh(MuxR,false);//mux 1 on
  setMuxInh(MuxC,false);//mux 2 on
    
  delay(40);//40ms down
    
  inhibitAll();
  
  if(iRow==5 && iCol!=4)
  {
    printf("WARN: row 5 probably doesn't support col %d\n",iCol);
    //return;
  }else {
	printf("OK: r%d c%d\n",iRow,iCol);
  }
}

int parse(char in){
  char zero='0';
  char A='A';
  char a='a';
  if(in >=a) //'a' -> 97
    return in-a;
  if(in>=A)//'A' -> 65
    return in-A;
    
  return in-zero;//'0' -> 48
}

void inhibitAll(){
  
  //shut all down
  setMuxInh(MuxR,true);
  setMuxInh(MuxC,true);
}

/*
0: [0, 0, 0, 0]
1: [0, 0, 0, 1]
2: [0, 0, 1, 0]
3: [0, 0, 1, 1]
4: [0, 1, 0, 0]
5: [0, 1, 0, 1]
6: [0, 1, 1, 0]
7: [0, 1, 1, 1]
8: [1, 0, 0, 0]
*/

void setMuxCh(int mux,int ch){
  int A=(ch>>0)%2;
  int B=(ch>>1)%2;
  int C=(ch>>2)%2;

#if DEBUG 
  printf("   ");
  if(mux==MuxR){
      printf("row");
  }else if(mux==MuxC){
      printf("col");
  }else{
      printf("dev");
  }

  printf(" [C,B,A]\n\r");
  printf("       [%d,%d,%d]\n\r",c[mux],b[mux],a[mux]);
  printf("       [%d,%d,%d]\n\r",C,B,A);
#endif
  
  digitalWrite(a[mux], A==1);
  digitalWrite(b[mux], B==1);
  digitalWrite(c[mux], C==1);
}

void setMuxInh(int mux,boolean inhibit){
    digitalWrite(inh[mux], inhibit);
}
