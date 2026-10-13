<?php

function inception_styles()
{
    wp_enqueue_style(
        'inception-style',
        get_stylesheet_uri()
    );
}

add_action('wp_enqueue_scripts', 'inception_styles');