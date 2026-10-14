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
        <header class="header">
            <a href="/" class="logo">INCEPTION</a>

            <nav class="nav">
                <a href="/">Home</a>
                <a href="/posts/">Posts</a>

                <?php if (is_user_logged_in()) : ?>
                    <?php $current_user = wp_get_current_user(); ?>
                    <a href="/wp-admin/">
                        You're logged in as <?php echo esc_html($current_user->user_login); ?>
                    </a>
                <?php else : ?>
                    <a href="/wp-login.php">Log in</a>
                <?php endif; ?>

                <a href="/wp-admin/" class="nav-admin">Admin ↗</a>
            </nav>
        </header>

        <main class="main">
            <div class="hero">
                <p class="subtitle">42 SCHOOL · DOCKER PROJECT</p>
                <h1>Welcome to Inception</h1>
                <p class="description">
                    A simple WordPress website powered by Docker.
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

        <footer class="footer">
            <p>© 2026 Nabila C. All rights reserved.</p>
            <p>NGINX · WordPress · MariaDB</p>
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