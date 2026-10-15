
<?php

// ------------------------ THEME STYLES ------------------------

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
    return 'LOGIN';
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


// ------------------------ LOGIN REDIRECT ------------------------

function inception_login_redirect($redirect_to, $requested_redirect_to, $user)
{
    if ($user instanceof WP_User)
        return home_url('/');

    return $redirect_to;
}

add_filter('login_redirect', 'inception_login_redirect', 10, 3);

// ------------------------ LOGIN USERNAME LABEL ------------------------

function inception_login_username_label($translated, $text, $domain)
{
    if ($text === 'Username or Email Address' && $domain === 'default')
        return 'Username';

    return $translated;
}

add_filter('gettext', 'inception_login_username_label', 10, 3);

// ------------------------ HIDE REMEMBER ME ------------------------

function inception_hide_remember_me()
{
    echo '<style>
        .login form .forgetmenot {
            display: none !important;
        }
    </style>';
}

add_action('login_head', 'inception_hide_remember_me');

// ------------------------ HIDE LOST PASSWORD LINK ------------------------

function inception_hide_lost_password()
{
    echo '<style>
        .login #nav a[href*="lostpassword"],
        .login #nav a[href*="retrievepassword"] {
            display: none !important;
        }
    </style>';
}

add_action('login_head', 'inception_hide_lost_password');