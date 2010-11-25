<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
<head>
	<!-- 
	don't know why but setting the doc-type screws up element sizing :(
	-->
	<meta http-equiv="Content-type" content="text/html; charset=utf-8">
  <title>Remote</title>
	<meta name="viewport" content="width=device-width, minimum-scale=1, maximum-scale=1">
	
	<link rel="icon" type="image/ico" href="/static/head-16.gif" />
	<link rel="apple-touch-icon" href="/static/head-114.png" />
	
  <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.3/themes/base/jquery-ui.css" type="text/css" media="all" /> 
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript" ></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js" type="text/javascript" ></script>
  <script type="text/javascript">
	$(function(){
		
		var loadPostion=function(){
			$.get('/positions',function(data){
			  dict=JSON.parse(data);
			  
			  //set space size
			  $('#space').height(dict['space-height']);
			  delete dict['space-height'];
        
        //get keys and positions
				var $sp=$('#commands').empty();
				for(key in dict){
				  var el=dict[key];
				  var li=$('<li/>').text(key)
				  .height(el.height)
				  .width(el.width)
				  .css('top',el.top)
				  .css('left',el.left)
				  .css('background',el.color);
				  $sp.append(li)
				}
				
				//wire action
				$('#commands li').click(function(){
				  $this=$(this);
				  var url='/key/'+$this.text()
				  console.log(url);
				  $.post(url)
    		});
    		
			});				
		};
		
		loadPostion();
		
	});
  </script>
	<style type="text/css">
		body{margin:0;background:black;font-family:arial;}
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
			border:1px solid white;
			background:white;
			-moz-border-radius:10px;
			-webkit-border-radius:10px;
			border-radius: 15px;
			position:absolute;
			-moz-user-select:none;
			-webkit-user-select:none;
		}
		#aux{
			width:300px;
		}
	</style>
 </head>
 <body>
	<div id="space">
		<ul id="commands">
		</ul>
	</div>
<hl/>
	<div id="aux">
		<a href="/remote/position">edit position</a>
	</div>
 </body>
</html>