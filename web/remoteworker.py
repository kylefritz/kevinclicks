from redis import Redis
import serial
import time

PORT="COM3"
MISSLIMIT=10000000000

class worker():
	def __init__(self):
		self.serial=None
		self.redis=Redis()
		self.misses=0
		
	def handleItem(self,op):
		if self.serial is None:
			print "opened serial port"
			self.serial= serial.Serial(port=PORT, baudrate=9600,timeout=2)
			#todo: don't return multi line output, so don't have to wait on timeout
			time.sleep(1.5) #hang on for serial port to start up
			
		
		self.serial.write(op)
		print "sent %s"%op
		#for line in self.serial.readlines():
		#	print line
			
		
		self.redis.rpush("arduino:remote-command:sent",op);
		
		
	def work(self):
		while True:
			item=self.redis.blpop("arduino:remote-command",timeout=1);
			if item:
				self.misses=0
				self.handleItem(item[1]) #0=> key
			else:
				self.misses+=1
				if self.misses > MISSLIMIT and self.serial:
					self.serial.close()
					self.serial=None
					print "closed serial port"

if __name__ =="__main__":
	worker().work();