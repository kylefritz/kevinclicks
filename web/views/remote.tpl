<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
<head>
	<!-- 
	don't know why but setting the doc-type screws up element sizing :(
	-->
	<meta http-equiv="Content-type" content="text/html; charset=utf-8">
	<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.6;" />
  <title>Remote</title>
	<meta name="viewport" value="width=320;user-scalable=no" >
	
	<link rel="icon" type="image/ico" href="/static/head-16.gif" />
	<link rel="apple-touch-icon" href="/static/head-114.png" />
	
  <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.3/themes/base/jquery-ui.css" type="text/css" media="all" /> 
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript" ></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js" type="text/javascript" ></script>

  <script type="text/javascript">
	$(function(){
		
		var postA = function(a){ $.post(a.href); }
		
		$('#commands li a').click(function(e){
			e.preventDefault();
		});
		
		$('#commands li').click(function(e){
			var atag=$(this).find('a:eq(0)');
			if( atag.length==1){
				postA(atag.get(0));
			}
		});
		
		$cmd=$('.cmd').hide();
		$('#togglecommands').button().toggle(function(){$cmd.show();},function(){$cmd.hide();})
		
		var loadPostion=function(){
			$.get('/remote/position/'+$('select').val(),function(data){
				var dict=JSON.parse(data);
				var sp=$('#space').position();
				for(key in dict){
					var $i=$('#'+key);
					var vals=dict[key].split(',');
					//pop in reverse order
					$i.width(vals.pop());
					$i.height(vals.pop());
					$i.css('top',parseInt(vals.pop())+sp.top);
					$i.css('left',parseInt(vals.pop())+sp.left);
				}
			});
		};
		
		$('#load').button().click(loadPostion);
		if($('select').val()!=null)
			loadPostion();
		
	});
  </script>
	<style type="text/css">
		body{margin:0;}
		#space{
			width:300px;
			height:450px;
			margin-bottom:40px;
		}
		#commands{margin:0px;height:0px;padding:0;}
		#commands li{
			display:inline-block;
			width:60px;
			padding:4px;
			margin:4px;
			border:1px solid black;
			background:white;
			-moz-border-radius:10px;
			-webkit-border-radius:10px;
			border-radius: 15px;
			position:absolute;
		}
		#commands li.unset{
			background:red;
			opacity:.4;
		}
		#aux{
			width:300px;
		}
	</style>
 </head>
 <body>
	<div id="space">
		<ul id="commands">
		%for cmd in allCommands:
			%haskey=keysOp.has_key(cmd)
			<li id="{{cmd}}" class="{{'set' if haskey else 'unset'}}">
				%if haskey:
				%repeats= 3 if cmd.startswith('Vol') else 1
				<a href="{{'/op/%s/%s'%(keysOp[cmd],repeats)}}">{{cmd}} </a> <span class="cmd">{{ ' %s'%keysOp[cmd]}}</span>
				%else:
					{{cmd}}
				%end
			</li>
		%end
			<li id="g0"><a href="/op/dg0">green 0</a></li>
			<li id="g1"><a href="/op/dg1">green 1</a></li>
			<li id="d"><a href="/op/dd">door</a></li>	
		</ul>
	</div>

	<div id="aux">
		<select style="font-size:1.4em">
			%for mapping in mappings:
				<option>{{mapping}}</option>
			%end
		</select>
		<span id="load">load</span>
		<br/>	
		<span id="togglecommands">cmds</span>
		<br/>
		<a href="/remote/position">edit profiles</a>
	</div>
 </body>
</html>