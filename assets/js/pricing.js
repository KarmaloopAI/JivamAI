(function () {
  // FAQ accordion
  document.querySelectorAll('.faq-q').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var item = btn.closest('.faq-item');
      var wasOpen = item.classList.contains('open');
      document.querySelectorAll('.faq-item').forEach(function (i) {
        i.classList.remove('open');
      });
      if (!wasOpen) item.classList.add('open');
    });
  });

  // Billing toggle
  var annual = true;
  var toggle = document.getElementById('billingToggle');
  if (!toggle) return;

  toggle.addEventListener('click', function () {
    annual = !annual;
    toggle.classList.toggle('annual', annual);
    document.querySelectorAll('.amount[data-monthly]').forEach(function (el) {
      el.textContent = annual ? el.dataset.annual : el.dataset.monthly;
    });
  });
})();
