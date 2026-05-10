(function () {
  var nav = document.getElementById('main-nav');
  var hamburger = document.getElementById('nav-hamburger');
  if (!hamburger || !nav) return;

  hamburger.addEventListener('click', function () {
    var isOpen = nav.dataset.mobileOpen === 'true';
    nav.dataset.mobileOpen = isOpen ? 'false' : 'true';
  });

  // Close on overlay link click
  document.querySelectorAll('.nav-mobile-overlay a').forEach(function (link) {
    link.addEventListener('click', function () {
      nav.dataset.mobileOpen = 'false';
    });
  });
})();
