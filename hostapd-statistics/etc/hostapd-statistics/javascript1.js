<script>
function refreshMainTable()
{
if (window.XMLHttpRequest)
  {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp=new XMLHttpRequest();
  }
else
  {// code for IE6, IE5
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
    {
    document.getElementById("tableHolder").innerHTML=xmlhttp.responseText;
    }
  }
xmlhttp.open("GET","stats/refreshtable",true);
xmlhttp.send();
setTimeout(refreshMainTable, 5000);
}
function refreshVnstati()
{
if (window.XMLHttpRequest)
  {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp2=new XMLHttpRequest();
  }
else
  {// code for IE6, IE5
  xmlhttp2=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp2.onreadystatechange=function()
  {
  if (xmlhttp2.readyState==4 && xmlhttp2.status==200)
    {
    document.getElementById("VnstatiHolder").innerHTML=xmlhttp2.responseText;
   }
  }
xmlhttp2.open("GET","stats/refreshvnstati",true);
xmlhttp2.send();
setTimeout(refreshVnstati, 120000);
}
refreshVnstati();
</script>
<script type="text/javascript">
  WebFontConfig = {
    google: { families: [ 'Varela+Round::latin' ] }
  };
  (function() {
    var wf = document.createElement('script');
    wf.src = ('https:' == document.location.protocol ? 'https' : 'http') +
      '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
    wf.type = 'text/javascript';
    wf.async = 'true';
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(wf, s);
  })(); </script>
