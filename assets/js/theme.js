(function () {
  var btn = document.getElementById('theme-toggle');
  if (!btn) return;

  function getTheme() {
    return document.documentElement.dataset.theme || 'light';
  }

  function setTheme(theme) {
    document.documentElement.dataset.theme = theme;
    localStorage.setItem('jivam-theme', theme);
  }

  btn.addEventListener('click', function () {
    setTheme(getTheme() === 'dark' ? 'light' : 'dark');
  });

  // Follow system preference only when user hasn't manually set a preference
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function (e) {
    if (!localStorage.getItem('jivam-theme')) {
      document.documentElement.dataset.theme = e.matches ? 'dark' : 'light';
    }
  });
})();
