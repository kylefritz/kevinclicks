<html>
 <head>
  <title>Remote</title>
  <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.3/themes/base/jquery-ui.css" type="text/css" media="all" /> 
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript" ></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js" type="text/javascript" ></script>
  <script src="/static/json2.min.js" type="text/javascript" ></script>

  <script type="text/javascript">
	$(function(){
		
		$('a').click(function(e){
			e.preventDefault();
			$.post($(this).attr('href'));
		})
		$cmd=$('.cmd').hide();
		$('#togglecommands').button().toggle(function(){$cmd.show();},function(){$cmd.hide();})
		
		$('#space').resizable({maxWidth: 300,minWidth: 300})
		
		$('#commands li').draggable(); //.resizable()
		$('#resize').button().toggle(
			function(){$('#commands li').resizable({ disabled: false });},
			function(){$('#commands li').resizable({ disabled: true });}
			);


		$savedlg=$('#namedlg').dialog({autoOpen: false, modal:true});
		var $savebtn=$('#namedlg span').button().click(function(){
			var positions={};
			$space=$('#space');
			var sp=$space.position();
			$('#commands li').each(function(){
				$this=$(this);
				var pos=$this.position();
				positions[this.id]= (pos.left-sp.left)+","+(pos.top-sp.top)+","+$this.height()+","+$this.width();
			})
			positions['space']=$space.height()+","+320;//only set height
			var name=$('#namedlg input').val();
			$.post('/remote/position/'+name,{position:JSON.stringify(positions)})
			$savedlg.dialog('close')
		});

		$('#savepositions').button().click(function(){
			if($('select').val()!=null)
				$('#namedlg input').val($('select').val());
			$savedlg.dialog('open');
			});
		
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
	body{margin:0;padding:0;}
		#space,#matrix,#commands{
			float:left;
			margin-right:6px;
		}
		#space{
			width:300px;
			height:450px;
			border:1px solid black;
			background:#DEF;
		}
		#commands{
			width:325px;
			margin:0;
			padding:0;
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
		}
		.ui-state-disabled{
			opacity:1;
		}
	</style>
 </head>
 <body>
	<div id="intro">
		<big>Position Keys</big> 
	</div>
	<div id="space">
		
	</div>

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
	<div style="clear:both;float:left">
		<span id="resize">toggle resize</span>
		<span id="togglecommands">toggle cmds</span>
		<span id="savepositions">save positions</span>
		<select style="font-size:1.4em">
			%for mapping in mappings:
				<option>{{mapping}}</option>
			%end
		</select>
		<span id="load">load</span>
	</div>
	
	<div id="namedlg" style="display:none" title="Name your position">
		<input value="ooja" />
		<span>save</span>
	</div>
	
 </body>
</html>