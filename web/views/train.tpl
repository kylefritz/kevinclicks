<html>
 <head>
  <title>Train</title>
  <script src="http://localhost:8080/static/jquery-1.4.2.min.js" type="text/javascript" />
  <script type="text/javascript">
	$(function(){
		$('a').click(function(e){
			e.preventDefault();
			$.get($(this).attr('href'));
		})
	});
  </script>
 </head>
 <body>
 <table>
  %for row in range(6):
	<tr>
	%for col in range(8):
		<td><a href="/op/r{{row}}{{col}}">{{row}}-{{col}}</a></td>
	%end
	</tr>
  %end
  </table>
  
  <a href="/op/dg0">green on</a>
  <br/>
  <a href="/op/dg1">green off</a>
  <br/>
  <a href="/op/dd">door</a>
  
 </body>
</html>