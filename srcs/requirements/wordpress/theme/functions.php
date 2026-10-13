<?php

// ------------------------ WEBSITE STYLES ------------------------

function inception_styles()
{
    wp_enqueue_style(
        'inception-style',
        get_stylesheet_uri()
    );
}

add_action('wp_enqueue_scripts', 'inception_styles');


// ------------------------ LOGIN PAGE TITLE ------------------------

function inception_login_title()
{
    return 'INCEPTION';
}

function inception_login_url()
{
    return home_url('/');
}

add_filter('login_headertext', 'inception_login_title');
add_filter('login_headerurl', 'inception_login_url');


// ------------------------ LOGIN PAGE STYLES ------------------------

function inception_login_styles()
{
    wp_enqueue_style(
        'inception-login',
        get_stylesheet_uri()
    );
}

add_action('login_enqueue_scripts', 'inception_login_styles');
