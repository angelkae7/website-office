(function (Drupal, once) {
  Drupal.behaviors.navToggle = {
    attach: function (context) {
      once('nav-toggle', '#navToggle', context).forEach((btn) => {
        const nav = context.querySelector('#mainNav');
        if (!nav) return;
        btn.addEventListener('click', () => {
          const expanded = btn.getAttribute('aria-expanded') === 'true';
          btn.setAttribute('aria-expanded', String(!expanded));
          nav.classList.toggle('hidden');   // montre/masque en mobile
        });
      });
    }
  };
})(Drupal, once);
