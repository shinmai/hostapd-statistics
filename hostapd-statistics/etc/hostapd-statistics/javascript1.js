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
//function refreshVnstati()
//{
//if (window.XMLHttpRequest)
//  {// code for IE7+, Firefox, Chrome, Opera, Safari
//  xmlhttp=new XMLHttpRequest();
//  }
//else
//  {// code for IE6, IE5
//  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
//  }
//xmlhttp.onreadystatechange=function()
//  {
//  if (xmlhttp.readyState==4 && xmlhttp.status==200)
//    {
//    document.getElementById("VnstatiHolder").innerHTML=xmlhttp.responseText;
//   }
//  }
//xmlhttp.open("GET","refreshvnstati",true);
//xmlhttp.send();
//setTimeout(refreshVnstati, 120000);
//}
//mediacontrol
function ajaxMedia(str)
{
if (window.XMLHttpRequest)
  {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp=new XMLHttpRequest();
  }
else
  {// code for IE6, IE5
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.open("GET",str,true);
xmlhttp.send();

}


</script>
