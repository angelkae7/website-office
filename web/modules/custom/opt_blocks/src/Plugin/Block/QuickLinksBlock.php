<?php

namespace Drupal\opt_blocks\Plugin\Block;

use Drupal\Core\Block\BlockBase;

/**
 * @Block(
 *   id = "opt_quick_links",
 *   admin_label = @Translation("OPT — Accès rapides"),
 *   category = @Translation("OPT")
 * )
 */
class QuickLinksBlock extends BlockBase {

  public function build(): array {
    // Modifie ici les 6 tuiles (label + url + icône facultative).
    $links = [
      ['label' => 'Courrier & colis', 'url' => '/courrier-colis', 'icon' => '/themes/custom/opt_theme/images/ico-courrier.svg'],
      ['label' => 'Télécom',          'url' => '/telecom',        'icon' => '/themes/custom/opt_theme/images/ico-telecom.svg'],
      ['label' => 'Particuliers',     'url' => '/particuliers',   'icon' => '/themes/custom/opt_theme/images/ico-user.svg'],
      ['label' => 'Professionnels',   'url' => '/professionnels', 'icon' => '/themes/custom/opt_theme/images/ico-pro.svg'],
      ['label' => 'Agences',          'url' => '/agences',        'icon' => '/themes/custom/opt_theme/images/ico-agence.svg'],
      ['label' => 'Contact',          'url' => '/contact',        'icon' => '/themes/custom/opt_theme/images/ico-contact.svg'],
    ];

    return [
      '#theme' => 'opt_quick_links',
      '#links' => $links,
      '#attached' => ['library' => ['opt_theme/global-styles']],
    ];
  }
}
