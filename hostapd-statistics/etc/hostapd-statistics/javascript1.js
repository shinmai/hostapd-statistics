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
xmlhttp.open("GET","refreshtable",true);
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
xmlhttp2.open("GET","refreshvnstati",true);
xmlhttp2.send();
setTimeout(refreshVnstati, 120000);
}
refreshVnstati();
</script>
