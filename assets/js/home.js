(function () {
  var tabs = document.querySelectorAll('.mode-tab');
  if (!tabs.length) return;

  tabs.forEach(function (tab, i) {
    tab.addEventListener('click', function () {
      tabs.forEach(function (t) { t.classList.remove('active'); });
      tab.classList.add('active');
    });
  });
})();
