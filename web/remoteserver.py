#!/usr/bin/env python 

from bottle import *
from redis import Redis
import util, json
from time import strftime,gmtime,time,sleep

KEY_MAPPING="arduino:keymapping"
KEY_POSITIONS="arduino:keypositions"
KEY_POSITION_FMT="arduino:keyposition:%s"
ARDUINO_COMMAND="arduino:remote-command"
LOG=util.getLogger('arduino_remote_server')
AUTH_COOKIE='remote-auth'
COOKIE_SECRET='laksdjalkdnqwoeiqwenjnlaksndlkadnlakmcmzc'
PASSWORD="ooja"

def auth_required():
    def decorator(func):
        def wrapper(*args, **kwargs):
            authd=request.get_cookie(AUTH_COOKIE,secret=COOKIE_SECRET)
            if authd !=PASSWORD:
              redirect('/login')
            return func(*args, **kwargs)
        return wrapper
    return decorator

def getRelativeCookieTime(days):
  return strftime("%a, %d-%b-%Y %H:%M:%S GMT", gmtime(days*24*60*60+time()))

from bottle import get, post, request

@get('/login')
def login_form():
    return '''<h1>Login!</h1>
              <form method="POST">
                <input name="password" placeholder="password" type="password" />
              </from>'''

@post('/login')
def login_submit():
    password = request.forms.get('password')
    if password==PASSWORD:
        response.set_cookie (secret=COOKIE_SECRET,key=AUTH_COOKIE, \
        value=password,path="/",expires=getRelativeCookieTime(60))
        redirect('/')
    else:
        return "<p>Nope! <a href='/login'>try again</a></p>"

@get('/logout')
def logout():
    response.set_cookie (secret=COOKIE_SECRET,key='remote-auth', \
    value="",path="/",expires=getRelativeCookieTime(-1))
    return "<p>You're logged out!</p>"


@post('/op/:op')
@post('/op/:op/:repeat')
@auth_required()
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

@get('/static/:filename')
def static_file(filename):
	send_file(filename, root='static')
	
@get('/favicon.ico')
def favicon():
	send_file("head-16.gif", root='static')

@route('/')
@auth_required()
def home():
	return redirect('/remote')

@route('/remote', method='get')
@view('remote')
@auth_required()
def remote():
	r=Redis()
	mappings=r.smembers(KEY_POSITIONS)
	keysOp=r.hgetall(KEY_MAPPING)
	allCommands=util.ALL_COMMANDS.split()
	return locals()

@route('/remote/train', method='get')
@view('train')
@auth_required()
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
@auth_required()
def remote_train_update():
	r=Redis()
	r.hset(KEY_MAPPING,request.POST['key'].strip(),request.POST['op'].strip())
	for key in request.POST['unset'].split(','):
		r.hdel(KEY_MAPPING,key.strip())
	return 'ok'

@route('/remote/position', method='get')
@view('position')
@auth_required()
def position():
	r=Redis()
	mappings=r.smembers(KEY_POSITIONS)
	keysOp=r.hgetall(KEY_MAPPING)
	allCommands=util.ALL_COMMANDS.split()
	return locals()
	
@route('/remote/position/:mapping', method='get')
@auth_required()
def which_position(mapping):
	r=Redis()
	position=r.hgetall(KEY_POSITION_FMT%mapping)
	return json.dumps(position) #should be auto-json?
	
@route('/remote/position/:mapping', method='post')
@auth_required()
def which_position(mapping):
	position=json.loads(request.POST['position'])
	r=Redis()
	r.hmset(KEY_POSITION_FMT%mapping,position)
	r.sadd(KEY_POSITIONS,mapping)
	return 'ok'


#use a key
@post('/key/:key')
def post_key(key):
	r=Redis()
	ops=r.hget(KEY_MAPPING,key)
	for op in ops.split(','):
		match=re.match('^pause(\d*\.?\d*)',op)
		if match:
			sleep(float(match.groups()[0]))
		else:
			cmd=r.hget(KEY_MAPPING,op)
			r.rpush(ARDUINO_COMMAND,cmd if cmd else op)
			sleep(.25)

	return 'ok'

#get positions
@get('/positions')
def get_positions():
	r=Redis()
	
	spositions=r.get("remote:positionsjson")
	if spositions:
		positions=json.loads(spositions)
	else:
		 positions={}
	
	keys=r.hkeys(KEY_MAPPING)
	
	for key in keys:
		if key not in positions.keys():
			positions[key]={'width':100,'height':15,'top':0,'left':300,'color':'#FFFFFF'}
			
	return json.dumps(positions)

#set positions
@post('/positions')
def post_positions():
	r=Redis()
	positions=r.set("remote:positionsjson",request.POST['position'])
	return 'OK'

#get mapping
@get('/mapping')
@view('mapping')
def get_mapping():
	r=Redis()
	mapping=json.dumps(r.hgetall(KEY_MAPPING)).replace("{","{\n").replace(", ",",\n").replace("}","\n}")
	return locals()
	
#set mapping
@post('/mapping')
def post_mapping():
	try:
		mapping=json.loads(request.POST['mapping'])
	except:
		return "NO DICE"
	
	r=Redis()
	r.delete(KEY_MAPPING)
	for k,v in mapping.items():
		r.hset(KEY_MAPPING,k,v)
	
	LOG.info(mapping)	
	return 'OK'

#get mapping
@get('/positionedit')
@view('positionedit')
def get_positionedit():
	r=Redis()
	positionedit=r.get("remote:positionsjson").replace("\n","").replace("\r","").replace("{","{\n").replace("}","\n}").replace(",\"",",\n\"")
	return locals()

#set mapping
@post('/positionedit')
def post_positionedit():
	try:
		mapping=json.loads(request.POST['positionedit'])
	except:
		return "NO DICE"

	r=Redis()
	r.set("remote:positionsjson",request.POST['positionedit'])

	return 'OK'

# @error(404)
# def error404(error):
#     return 'Nothing here, sorry'

@error(401)
def error401(error):
    return 'login bastard'

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