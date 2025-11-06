<?php

namespace Drupal\opt_blocks\Plugin\Block;

use Drupal\Core\Block\BlockBase;

/**
 * @Block(
 *   id = "opt_join_us",
 *   admin_label = @Translation("OPT — Rejoignez-nous"),
 *   category = @Translation("OPT")
 * )
 */
class JoinUsBlock extends BlockBase {

  public function build(): array {
    return [
      '#theme' => 'opt_join_us',
      '#title' => 'Rejoignez-nous',
      '#text'  => "Envie de contribuer aux services publics numériques en Nouvelle-Calédonie ?",
      '#cta'   => ['label' => 'Voir les offres', 'url' => '/recrutement'],
      '#attached' => ['library' => ['opt_theme/global-styles']],
    ];
  }
}
