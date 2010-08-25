#!/usr/bin/env python 

from bottle import send_file, redirect, abort, request, response, route, view, run
from redis import Redis
from datetime import datetime
import json
from commands import ALL_COMMANDS

KEY_MAPPING="arduino:keymapping"

@route('/op/:op', method='POST')
def do_op(op):
	r=Redis()
		#r.rpush("arduino:remote-command",json.dumps({'op':op,'push-time':datetime.now().isoformat()}))
	r.rpush("arduino:remote-command",op)
		
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
	allCommands=ALL_COMMANDS.split()
	return locals()
	
@route('/remote/train', method='get')
@view('train')
def remote_train():
	r=Redis()
	keysOp=r.hgetall(KEY_MAPPING)
	opKeys=dict()
	allCommands=ALL_COMMANDS.split()
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
	

@route('/hello/template/:names')
@view('hello')
def remote_trainer(names):
	names = names.split(',')
	return dict(title='Hello World', names=names)
	
	
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