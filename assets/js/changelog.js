(function () {
  var entries = document.querySelectorAll('.cl-entry');
  var tocLinks = document.querySelectorAll('.toc-link');
  if (!entries.length || !tocLinks.length) return;

  var observer = new IntersectionObserver(function (observations) {
    observations.forEach(function (obs) {
      if (obs.isIntersecting) {
        var id = obs.target.id;
        tocLinks.forEach(function (link) {
          link.classList.toggle('current', link.getAttribute('href') === '#' + id);
        });
      }
    });
  }, { rootMargin: '-20% 0px -70% 0px' });

  entries.forEach(function (entry) { observer.observe(entry); });
})();
