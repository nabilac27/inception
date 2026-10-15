<?php

// ------------------------ BONUS PAGE ------------------------

get_header();
?>

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

<?php get_footer(); ?>