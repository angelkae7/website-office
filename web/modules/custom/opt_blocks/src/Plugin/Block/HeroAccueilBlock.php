<?php

namespace Drupal\opt_blocks\Plugin\Block;

use Drupal\Core\Block\BlockBase;

/**
 * Fournit un bloc "Hero accueil".
 *
 * @Block(
 *   id = "hero_accueil_block",
 *   admin_label = @Translation("Hero Accueil"),
 *   category = @Translation("OPT-NC")
 * )
 */
class HeroAccueilBlock extends BlockBase {

  /**
   * {@inheritdoc}
   */
  public function build() {
    return [
      '#theme' => 'hero_accueil', // correspond au nom du template Twig
      '#title' => 'Vos démarches, vos besoins',
      '#subtitle' => 'L’OPT-NC vous accompagne au quotidien.',
      '#cta_1' => [
        'label' => 'Découvrir l’OPT-NC',
        'url' => '/nous-connaitre',
      ],
      '#cta_2' => [
        'label' => 'Voir les démarches',
        'url' => '/demarches',
      ],
    ];
  }
}
