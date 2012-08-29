window.addEventListener("load",function(){
document.documentElement.className="js";
var a=document.querySelectorAll("p.block");
for(var i=0;i<a.length;i++){
    a[i].addEventListener("touchend",function(){
        var b=document.querySelector("[data-block='"+a[i].getAttribute("data-blockid")+"']");
        b.className=a[i].className=b.className=="expanded"?"collapsed":"expanded"
    },false)
}
},false)