
<?php
// ------------------------ SINGLE POST ------------------------
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php wp_title('|', true, 'right'); ?> Inception</title>
    <?php wp_head(); ?>
</head>

<body <?php body_class('inception-single-page'); ?>>
<?php wp_body_open(); ?>

<header class="header">
    <a href="<?php echo esc_url(home_url('/')); ?>" class="logo">INCEPTION</a>

    <nav class="nav">
        <a href="<?php echo esc_url(home_url('/')); ?>">Home</a>
        <a href="<?php echo esc_url(home_url('/posts/')); ?>">Posts</a>
        <a href="<?php echo esc_url(wp_login_url()); ?>">Log in</a>
        <a href="<?php echo esc_url(admin_url()); ?>" class="nav-admin">Admin ↗</a>
    </nav>
</header>

<main class="main posts-main">
    <section class="posts-container">

        <?php while (have_posts()) : the_post(); ?>

            <article class="post-card">
                <div class="post-meta">
                    <span><?php echo esc_html(get_the_date('F j, Y')); ?></span>
                    <span>·</span>
                    <span><?php echo esc_html(get_the_author()); ?></span>
                </div>

                <h1 class="post-title"><?php the_title(); ?></h1>

                <div class="post-content">
                    <?php the_content(); ?>
                </div>

                <div class="post-comments">
                    <?php comments_template(); ?>
                </div>
            </article>

        <?php endwhile; ?>

    </section>
</main>

<footer class="footer">
    <p>© 2026 Nabila C. All rights reserved.</p>
    <p>NGINX · WordPress · MariaDB</p>
</footer>

<?php wp_footer(); ?>
</body>
</html>
