<?php
/**
 * Inception - Homepage
 */
?>

<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
<?php wp_body_open(); ?>

    <!-- HEADER -->
    <header class="header">
        <a href="<?php echo esc_url(home_url('/')); ?>" class="logo">
            INCEPTION
        </a>

        <nav class="nav">
            <a href="<?php echo esc_url(home_url('/')); ?>">Home</a>
            <a href="<?php echo esc_url(wp_login_url()); ?>">Log in</a>
            <a href="<?php echo esc_url(admin_url()); ?>" class="nav-admin">
                Admin ↗
            </a>
        </nav>
    </header>

    <!-- MAIN -->
    <main class="main">
        <div class="hero">
            <p class="subtitle">42 SCHOOL · DOCKER PROJECT</p>

            <h1>Welcome to Inception.</h1>

            <p class="description">
                A simple WordPress website powered by Docker.
            </p>

            <div class="buttons">
                <a href="<?php echo esc_url(wp_login_url()); ?>" class="btn btn-primary">
                    Log in →
                </a>

                <a href="<?php echo esc_url(admin_url()); ?>" class="btn btn-secondary">
                    Administrator ↗
                </a>
            </div>
        </div>
    </main>

    <!-- FOOTER -->
    <footer class="footer">
        <p>© <?php echo esc_html(date('Y')); ?> INCEPTION</p>
        <p>NGINX · WordPress · MariaDB</p>
    </footer>

    <?php wp_footer(); ?>
</body>
</html>
