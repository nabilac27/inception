
<?php
// ------------------------ BONUS PAGE ------------------------
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bonus | Inception</title>
    <?php wp_head(); ?>
</head>

<body <?php body_class('inception-bonus-page'); ?>>
<?php wp_body_open(); ?>

<!-- ------------------------ HEADER ------------------------ -->

<header class="header">
    <a href="<?php echo esc_url(home_url('/')); ?>" class="logo">
        INCEPTION
    </a>

    <nav class="nav">
        <a href="<?php echo esc_url(home_url('/')); ?>">
            Home
        </a>

        <a href="<?php echo esc_url(home_url('/posts/')); ?>">
            Posts
        </a>

        <a href="<?php echo esc_url(home_url('/bonus/')); ?>" class="active">
            Bonus
        </a>

        <?php if (is_user_logged_in()) : ?>

            <?php
                $user = wp_get_current_user();
                $is_admin = in_array(
                    'administrator',
                    (array) $user->roles,
                    true
                );
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

<!-- ------------------------ MAIN ------------------------ -->

<main class="main bonus-main">

    <section class="bonus-container">

        <p class="subtitle">42 SCHOOL · DOCKER PROJECT</p>

        <h1>Bonus for Inception</h1>

        <div class="bonus-grid">

            <!-- ------------------------ ADMINER ------------------------ -->

            <a href="<?php echo esc_url(home_url('/bonus-adminer/')); ?>"
               class="bonus-card">

                <span class="bonus-number">
                    01 / DATABASE MANAGEMENT
                </span>

                <h2>Adminer ↗</h2>

                <p>
                    A web-based database management tool for
                    accessing and managing MariaDB.
                </p>

            </a>

            <!-- ------------------------ STATIC WEBSITE ------------------------ -->

            <a href="<?php echo esc_url(home_url('/bonus-static-web/')); ?>"
               class="bonus-card">

                <span class="bonus-number">
                    02 / STATIC WEBSITE
                </span>

                <h2>Static Website ↗</h2>

                <p>
                    A static website served by NGINX using
                    HTML and CSS.
                </p>

            </a>

            <!-- ------------------------ REDIS ------------------------ -->

            <div class="bonus-card bonus-card-redis">

                <span class="bonus-number">
                    03 / OBJECT CACHING
                </span>

                <h2>Redis</h2>

                <p>
                    An in-memory caching service that improves
                    WordPress performance by caching frequently
                    accessed data.
                </p>

                <span class="bonus-note">
                    Internal Docker service · No web interface
                </span>

            </div>

        </div>

    </section>

</main>

<!-- ------------------------ FOOTER ------------------------ -->

<footer class="footer">
    <p>© 2026 Nabila C. All rights reserved.</p>

    <p class="footer-links">
        <a href="https://nginx.org/"
           target="_blank"
           rel="noopener noreferrer">
            NGINX
        </a>
        ·
        <a href="https://wordpress.org/documentation/"
           target="_blank"
           rel="noopener noreferrer">
            WordPress
        </a>
        ·
        <a href="https://mariadb.com/docs"
           target="_blank"
           rel="noopener noreferrer">
            MariaDB
        </a>
    </p>
</footer>

<?php wp_footer(); ?>

</body>
</html>
