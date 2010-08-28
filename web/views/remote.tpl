<html>
 <head>
  <title>Remote</title>
	<meta name="viewport" value="width = device-width, user-scalable = no" />
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
		#space,#matrix,#commands{
			float:left;
			margin-right:6px;
		}
		#space{
			width:300px;
			height:450px;
		}
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
			float:left;
		}
		#commands li.unset{
			background:red;
			opacity:.4;
		}
		#aux{
			clear:both;
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
				<a href="{{'/op/%s'%keysOp[cmd]}}">{{cmd}} </a> <span class="cmd">{{ ' %s'%keysOp[cmd]}}</span>
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
	</div>
 </body>
</html>