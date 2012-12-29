var navLinks = document.getElementById('navigation').getElementsByTagName('a');
var sections = document.getElementById('content').getElementsByTagName('section');

function getOffset(elem) {
    var x = 0;
    var y = 0;
    while( elem && !isNaN( elem.offsetLeft ) && !isNaN( elem.offsetTop ) ) {
        x += elem.offsetLeft;
        y += elem.offsetTop;
        elem = elem.offsetParent;
    }
    return { top: y, left: x };
}

function getScroll() {
  var doc = document.documentElement, body = document.body;
  var x = (doc && doc.scrollLeft || body && body.scrollLeft || 0);
  var y = (doc && doc.scrollTop  || body && body.scrollTop  || 0);
  return { top: y, left: x };
}

function scrollToElement(elem, callback) {
  var offset        = getOffset(elem);
  var animTime      = 200;
  var animInterval  = 10;
  var steps         = animTime/animInterval;
  var scroll        = getScroll();
  var max           = document.documentElement.scrollHeight - window.innerHeight;
  var way           = offset.top - scroll.top;
  var step          = way / steps;
  var animation = setInterval(function() {
    scroll  = getScroll();
    if (steps) {
      window.scrollTo(0,scroll.top + step);
    } else {
      step = offset.top - scroll.top;
      window.scrollTo(0,scroll.top + step);
      clearInterval(animation);
      callback && callback.call(elem);
    }
    steps--;
  },animInterval);
}

for (var i=0; i < navLinks.length; i++) {
  navLinks[i].onclick = function(e) {
    e.preventDefault();
    var id = e.target.attributes.href.value.toString();
    for (var k=0; k < sections.length; k++) {
      if (sections[k].id == id.substr(1)) {
        scrollToElement(sections[k], function(elem) {
          window.location.hash = id;
        });
      }
    };
  }
};