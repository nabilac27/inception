<?php

// ------------------------ POSTS PAGE ------------------------

$request_path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);

if (rtrim($request_path, '/') === '/posts') {
    require __DIR__ . '/page-posts.php';
    exit;
}

// ------------------------ HOME PAGE ------------------------

if (is_front_page()) {
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="<?php echo esc_url(get_stylesheet_uri()); ?>">
        <title>Inception</title>
        <?php wp_head(); ?>
    </head>

    <body>

    <!-- ------------------------ HEADER ------------------------ -->
<header class="header">
    <a href="/" class="logo">INCEPTION</a>

    <nav class="nav">
        <a href="/">Home</a>
        <a href="/posts/">Posts</a>
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

        <main class="main">
            <div class="hero">
                <p class="subtitle">42 SCHOOL · DOCKER PROJECT</p>
                <h1>Welcome to Inception</h1>
                <p class="description">
                    A simple WordPress website powered by
                    <a href="https://docs.docker.com/"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="docker-link">Docker</a>.
                </p>
                <div class="buttons">
                    <a href="/posts/" class="btn btn-primary">
                        Explore Posts →
                    </a>

                    <?php if (is_user_logged_in()) : ?>
                        <?php $current_user = wp_get_current_user(); ?>
                        <a href="/wp-admin/" class="btn btn-secondary">
                            You're logged in as <?php echo esc_html($current_user->user_login); ?>
                        </a>
                    <?php else : ?>
                        <a href="/wp-login.php" class="btn btn-secondary">
                            Log in ↗
                        </a>
                    <?php endif; ?>
                </div>
            </div>
        </main>


<!-- ------------------------ FOOTER ------------------------ -->

<footer class="footer">
    <p>© 2026 Nabila C. All rights reserved.</p>

    <p class="footer-links">
        <a href="https://nginx.org/" target="_blank" rel="noopener noreferrer">NGINX</a>
        ·
        <a href="https://wordpress.org/documentation/" target="_blank" rel="noopener noreferrer">WordPress</a>
        ·
        <a href="https://mariadb.com/docs" target="_blank" rel="noopener noreferrer">MariaDB</a>
    </p>
</footer>


        <?php wp_footer(); ?>
    </body>
    </html>
    <?php
    exit;
}

// ------------------------ DEFAULT WORDPRESS PAGES ------------------------

get_header();

if (have_posts()) {
    while (have_posts()) {
        the_post();
        the_content();
    }
}

get_footer();