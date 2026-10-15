<?php get_header(); ?>

<!-- ------------------------ MAIN ------------------------ -->

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
            <a href="<?php echo esc_url(home_url('/posts/')); ?>"
               class="btn btn-primary">
                Explore Posts →
            </a>

            <?php if (is_user_logged_in()) : ?>
                <?php $user = wp_get_current_user(); ?>

                <a href="<?php echo esc_url(admin_url()); ?>"
                   class="btn btn-secondary">
                    You're logged in as <?php echo esc_html($user->user_login); ?>
                </a>
            <?php else : ?>
                <a href="<?php echo esc_url(wp_login_url()); ?>"
                   class="btn btn-secondary">
                    Log in ↗
                </a>
            <?php endif; ?>
        </div>
    </div>
</main>

<?php get_footer(); ?>