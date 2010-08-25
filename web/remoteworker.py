#!/usr/bin/env python 
import serial,time,sys,util
from redis import Redis

class worker():
  def __init__(self,redis,log,misslimit,getserial):
    self.serial=None
    self.redis=redis
    self.misses=0
    self.getserial=getserial
    self.misslimit=misslimit
    self.log=log
    
  def handleItem(self,op):
    if self.serial is None:
      self.log.debug("opened serial port")
      self.serial= self.getserial();
      #todo: don't return multi line output, so don't have to wait on timeout
      time.sleep(1.5) #hang on for serial port to start up
      
    self.serial.write(op)
      
    self.log.debug("sent %s"%op)
    
  def work(self):
    while True:
      item=self.redis.blpop("arduino:remote-command",timeout=1);
      if item:
        self.misses=0
        self.handleItem(item[1]) #0=> key
      else:
        self.misses+=1
        if self.misses > self.misslimit and self.serial:
          self.serial.close()
          self.serial=None
          log.debug("closed serial port")

if __name__ =="__main__":
  log=util.getLogger('arduino_remote_worker')
  #set up redis
  rdb=Redis()
  
  #setup serial
  PORT="COM3"
  MISSLIMIT=10000000000
  if len(sys.argv) > 1 and sys.argv[1]=='fake':
    log.warn("using fake serial")
    getserial=lambda: util.fakeSerial(log)
  else:
    getserial=lambda: serial.Serial(port=PORT, baudrate=115200,timeout=2)
    
  while True:
    try:
      worker(rdb,log,MISSLIMIT,getserial).work()
    except KeyboardInterrupt:
      log.info("KeyboardInterrupt>>shutdown")
      break
    except:
      log.exception('exception> oh boy')