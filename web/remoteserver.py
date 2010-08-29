#!/usr/bin/env python 

from bottle import send_file, redirect, abort, request, response, route, view,error
from redis import Redis
import util, json

KEY_MAPPING="arduino:keymapping"
KEY_POSITIONS="arduino:keypositions"
KEY_POSITION_FMT="arduino:keyposition:%s"
ARDUINO_COMMAND="arduino:remote-command"
LOG=util.getLogger('arduino_remote_server')

@route('/op/:op', method='POST')
@route('/op/:op/:repeat', method='POST')
def do_op(op,repeat='1'):
	r=Redis()
	try:
	  repeat=int(repeat)
	except ValueError:
	  repeat=1
	for _ in range(repeat):
	  r.rpush(ARDUINO_COMMAND,op)
	
	LOG.info("got %s, repeats %s"%(op,repeat))
	return 'OK: %s x %s'%(op,repeat)

@route('/static/:filename')
def static_file(filename):
	send_file(filename, root='static')

@route('/')
def home():
	return redirect('/remote')

@route('/remote', method='get')
@view('remote')
def remote():
	r=Redis()
	mappings=r.smembers(KEY_POSITIONS)
	keysOp=r.hgetall(KEY_MAPPING)
	allCommands=util.ALL_COMMANDS.split()
	return locals()

@route('/remote/train', method='get')
@view('train')
def remote_train():
	r=Redis()
	keysOp=r.hgetall(KEY_MAPPING)
	opKeys=dict()
	allCommands=util.ALL_COMMANDS.split()
	for k,v in keysOp.iteritems():
		if opKeys.has_key(v):
			opKeys[v]+=", %s"%k
		else:
			opKeys[v]=k
	return locals()

@route('/remote/train', method='POST')
def remote_train_update():
	r=Redis()
	r.hset(KEY_MAPPING,request.POST['key'].strip(),request.POST['op'].strip())
	for key in request.POST['unset'].split(','):
		r.hdel(KEY_MAPPING,key.strip())
	return 'ok'

@route('/remote/position', method='get')
@view('position')
def position():
	r=Redis()
	mappings=r.smembers(KEY_POSITIONS)
	keysOp=r.hgetall(KEY_MAPPING)
	allCommands=util.ALL_COMMANDS.split()
	return locals()
	
@route('/remote/position/:mapping', method='get')
def which_position(mapping):
	r=Redis()
	position=r.hgetall(KEY_POSITION_FMT%mapping)
	return json.dumps(position) #should be auto-json?
	
@route('/remote/position/:mapping', method='post')
def which_position(mapping):
	position=json.loads(request.POST['position'])
	r=Redis()
	r.hmset(KEY_POSITION_FMT%mapping,position)
	r.sadd(KEY_POSITIONS,mapping)
	return 'ok'



from bottle import request, response, abort

def auth_required(users, realm='Secure Area'):
    def decorator(func):
        def wrapper(*args, **kwargs):
            name, password = request.auth()
            if name not in users or users[name] != password:
                response.headers['WWW-Authenticate'] = 'Basic realm="%s"' % realm
                abort('401', 'Access Denied. You need to login first.')
            kwargs['user'] = name
            return func(*args, **kwargs)
        return wrapper
    return decorator

@route('/secure/area')
@auth_required(users={'Bob':'1234'})
def secure_area(user):
    print 'Hello %s' % user

# @error(404)
# def error404(error):
#     return 'Nothing here, sorry'

@error(401)
def error401(error):
    return 'login bastard'

#auth 
@route('/hello/cookie')
def cookie():
	name = request.COOKIES.get('name', 'Stranger')
	response.headers['Content-Type'] = 'text/plain'
	return 'Hello, %s' % name

	
@route('/wrong/url')
def wrong():
	redirect("/right/url")

@route('/restricted')
def restricted():
	abort(401, "Sorry, access denied.") 

class StripPathMiddleware(object):
  def __init__(self, app):
    self.app = app
  def __call__(self, e, h):
    e['PATH_INFO'] = e['PATH_INFO'].rstrip('/')
    return self.app(e,h)


if __name__=="__main__":
	import bottle
	app = bottle.app()
	myapp = StripPathMiddleware(app)
	bottle.debug(True)
	bottle.run(app=myapp,host='localhost', port=8080,reloader=True)