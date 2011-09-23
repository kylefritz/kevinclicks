<html>
 <head>
  <title>Train</title>
    <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.3/themes/base/jquery-ui.css" type="text/css" media="all" /> 
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript" ></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js" type="text/javascript" ></script>

  <script type="text/javascript">
	$(function(){
		$('a').click(function(e){
			e.preventDefault();
			$.post($(this).attr('href'));
		})
		$("#commands li").draggable({revert: true});
		$("#matrix td").droppable({
			drop: function(event, ui) {
				var key=ui.draggable.text();
				var cls='set-'+key;
				
				//clean up old ones
				$('.'+cls).removeClass('set').find('span').html('not set').removeClass(cls);
				
				var $this=$(this).addClass('set').addClass('set-'+key);
				
				var prev=$this.find('span').html()
				var $span=$this.find('span').html(key);
				$.post('/remote/train',{op:this.id,key:key,unset:prev});
			}
		});
		
		$('#send').button().click(function(){
			var val=$('#anycode').val();
			if(val!=null||val!=''){
				$.post('/op/'+val,function(){
					$('#result').show().delay(500).fadeOut();
				})
			}
		})
		
	});
  </script>
	<style type="text/css">
		#matrix,#commands{
			float:left;
			margin-right:6px;
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
		}
		#matrix td{
			padding:4px;
			margin:4px;
			width:60px;
			border:1px solid black;
			text-align:center;
		}
		#matrix td.set{
			background:#53894d;
		}
	</style>
 </head>
 <body>
	<div id="intro">
		<big>Train it</big> <a href="/op/dg0">green 0</a> |  <a href="/op/dg1">green 1</a> | <a href="/op/dd">door</a>

	</div>
<div id="matrix">
	<table >
	 %for row in range(6):
	<tr>
	%for col in range(8):
		%hashkey='r%s%s'%(row,col)
		%haskey=opKeys.has_key(hashkey)
		<td id="r{{row}}{{col}}" class="{{'set set-%s'%opKeys[hashkey] if haskey else ''}}"><a href="/op/r{{row}}{{col}}">{{row}}-{{col}}</a>
			<br><span>
				%if haskey:
					{{opKeys[hashkey]}}
				%else:
					not set
				%end
			</span>
		</td>
	%end
	</tr>
	 %end
	 </table>
	<br/>
	<input id="anycode" placeholder="send any code" />
	<span id="send">send</span>
	<span id="result" style="display:none;color:red">sent!</span>
	<br/>
	<small>p rc rc S (rc)+ \n</small>
	<br/>
	<small>rRC</small>
</div>

<ul id="commands">
%for cmd in allCommands:
	<li>{{cmd}}</li>
%end
</ul>


 </body>
</html>