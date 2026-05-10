(function () {
  var filterBtns = document.querySelectorAll('.filter-btn');
  var cards = document.querySelectorAll('.blog-listing-card');
  if (!filterBtns.length) return;

  filterBtns.forEach(function (btn) {
    btn.addEventListener('click', function () {
      filterBtns.forEach(function (b) { b.classList.remove('active'); });
      btn.classList.add('active');

      var cat = btn.dataset.category || 'all';
      cards.forEach(function (card) {
        if (cat === 'all' || card.dataset.category === cat) {
          card.classList.remove('hidden');
        } else {
          card.classList.add('hidden');
        }
      });
    });
  });
})();
