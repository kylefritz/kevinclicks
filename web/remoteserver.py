#!/usr/bin/env python 

from bottle import send_file, redirect, abort, request, response, route, view, run
from redis import Redis
import util, json

KEY_MAPPING="arduino:keymapping"
KEY_POSITIONS="arduino:keypositions"
KEY_POSITION_FMT="arduino:keyposition:%s"
ARDUINO_COMMAND="arduino:remote-command"
LOG=util.getLogger('arduino_remote_server')

@route('/op/:op', method='POST')
def do_op(op):
	r=Redis()
	r.rpush(ARDUINO_COMMAND,op)
	LOG.info("got %s"%op)
	return 'OK: %s'%op

@route('/static/:filename')
def static_file(filename):
	send_file(filename, root='static')

@route('/')
def home():
	return redirect('/remote/train')

@route('/remote', method='get')
@view('remote')
def remote():
	r=Redis()
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
	return json.dumps(position)
	
@route('/remote/position/:mapping', method='post')
def which_position(mapping):
	position=json.loads(request.POST['position'])
	r=Redis()
	r.hmset(KEY_POSITION_FMT%mapping,position)
	return 'ok'
	
	
	
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

import bottle
bottle.debug(True)
run(host='localhost', port=8080,reloader=True)