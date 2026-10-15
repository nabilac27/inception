<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
<?php wp_body_open(); ?>

<!-- ------------------------ HEADER ------------------------ -->

<header class="header">
    <a href="<?php echo esc_url(home_url('/')); ?>" class="logo">
        INCEPTION
    </a>

    <nav class="nav">
        <a href="<?php echo esc_url(home_url('/')); ?>">Home</a>
        <a href="<?php echo esc_url(home_url('/posts/')); ?>">Posts</a>
        <a href="<?php echo esc_url(home_url('/bonus/')); ?>">Bonus</a>

        <?php if (is_user_logged_in()) : ?>
            <?php
                $user = wp_get_current_user();
                $is_admin = in_array('administrator', (array) $user->roles, true);
            ?>

            <div class="user-dropdown">
                <a href="<?php echo esc_url(admin_url()); ?>"
                   class="<?php echo $is_admin ? 'nav-admin' : 'nav-user'; ?>">
                    <?php echo esc_html($user->user_login); ?> ↗
                </a>

                <div class="dropdown-menu">
                    <a href="<?php echo esc_url(wp_logout_url(home_url('/'))); ?>">
                        Log out ↗
                    </a>
                </div>
            </div>

        <?php else : ?>
            <a href="<?php echo esc_url(wp_login_url()); ?>" class="nav-guest">
                Guest Mode
            </a>
        <?php endif; ?>
    </nav>
</header>