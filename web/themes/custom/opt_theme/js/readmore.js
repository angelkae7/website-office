(function (Drupal, once) {
  Drupal.behaviors.readMoreToggle = {
    attach: function (context) {
      once('readmore-toggle', '.js-readmore-toggle', context).forEach((btn) => {
        const wrap = btn.closest('.p-card__content');
        const text = wrap ? wrap.querySelector('.js-readmore') : null;
        if (!text) return;
        btn.addEventListener('click', () => {
          const open = text.classList.toggle('is-expanded');
          btn.textContent = open ? 'Lire moins' : 'Lire la suite';
        });
      });
    }
  };
})(Drupal, once);
