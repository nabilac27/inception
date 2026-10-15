
<?php
// ------------------------ GET PUBLISHED WORDPRESS POSTS ------------------------

$posts_query = new WP_Query(array(
    'post_type'      => 'post',
    'post_status'    => 'publish',
    'posts_per_page' => -1,
));
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Posts | Inception</title>
    <?php wp_head(); ?>
</head>

<body <?php body_class('inception-posts-page'); ?>>
<?php wp_body_open(); ?>


<!-- ------------------------ HEADER ------------------------ -->

<header class="header">
    <a href="<?php echo esc_url(home_url('/')); ?>" class="logo">
        INCEPTION
    </a>

    <nav class="nav">
        <a href="<?php echo esc_url(home_url('/')); ?>">Home</a>
        <a href="<?php echo esc_url(home_url('/posts/')); ?>" class="active">
            Posts
        </a>
        <a href="<?php echo esc_url(home_url('/bonus/')); ?>">
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

<main class="main posts-main">
    <section class="posts-container">

        <div class="posts-section-heading">
            <h1>Latest posts</h1>
            <span>
                <?php echo esc_html($posts_query->post_count); ?>
                <?php echo $posts_query->post_count === 1 ? 'POST' : 'POSTS'; ?>
            </span>
        </div>

        <?php if ($posts_query->have_posts()) : ?>

            <?php while ($posts_query->have_posts()) : $posts_query->the_post(); ?>

                <?php $post_id = get_the_ID(); ?>

                <article class="post-card">

                    <!-- POST DATE AND AUTHOR -->

                    <div class="post-meta">
                        <span>
                            <?php echo esc_html(get_the_date('F j, Y')); ?>
                        </span>
                        <span class="meta-dot">·</span>
                        <span>
                            <?php echo esc_html(get_the_author()); ?>
                        </span>
                    </div>

                    <!-- POST TITLE -->

                    <h2 class="post-title">
                        <a href="<?php echo esc_url(get_permalink()); ?>">
                            <?php the_title(); ?>
                        </a>
                    </h2>

                    <!-- POST CONTENT -->

                    <div class="post-content">
                        <?php the_content(); ?>
                    </div>

                    <!-- COMMENT COUNT -->

                    <div class="post-card-footer">
                        <span class="comment-count">
                            <?php
                            $comment_count = (int) get_comments_number($post_id);

                            echo esc_html(
                                $comment_count .
                                ($comment_count === 1 ? ' comment' : ' comments')
                            );
                            ?>
                        </span>
                    </div>

                    <!-- APPROVED COMMENTS ONLY -->

                    <div class="post-comments">

                        <?php
                        $post_comments = get_comments(array(
                            'post_id' => $post_id,
                            'status'  => 'approve',
                            'orderby' => 'comment_date_gmt',
                            'order'   => 'ASC',
                        ));
                        ?>

                        <?php if ($post_comments) : ?>

                            <h3>Comments</h3>

                            <ul class="comment-list">

                                <?php foreach ($post_comments as $comment) : ?>

                                    <li class="comment-item">

                                        <div class="comment-author">
                                            <?php
                                            echo esc_html($comment->comment_author);
                                            ?>

                                            <span class="comment-date">
                                                · <?php
                                                echo esc_html(
                                                    get_comment_date('F j, Y', $comment)
                                                );
                                                ?>
                                            </span>
                                        </div>

                                        <div class="comment-text">
                                            <?php
                                            echo wp_kses_post(
                                                apply_filters(
                                                    'comment_text',
                                                    $comment->comment_content,
                                                    $comment
                                                )
                                            );
                                            ?>
                                        </div>

                                    </li>

                                <?php endforeach; ?>

                            </ul>

                        <?php else : ?>

                            <p class="no-comments">No comments yet.</p>

                        <?php endif; ?>

                        <!-- COMMENT FORM FOR LOGGED-IN USERS -->

                        <?php if (is_user_logged_in() && comments_open($post_id)) : ?>

                            <div class="comment-form-container">

                                <?php
                                comment_form(array(
                                    'title_reply'          => 'Leave a comment',
                                    'label_submit'         => 'Post comment',
                                    'comment_notes_before' => '',
                                    'comment_notes_after'  => '',
                                    'logged_in_as'         => '',
                                    'cookies'              => false,
                                    'comment_field'        =>
                                        '<p class="comment-form-comment">' .
                                        '<label for="comment">Your comment</label>' .
                                        '<textarea id="comment" name="comment" ' .
                                        'rows="4" required></textarea>' .
                                        '</p>',
                                ), $post_id);
                                ?>

                            </div>

                        <?php endif; ?>

                    </div>

                </article>

            <?php endwhile; ?>

            <?php wp_reset_postdata(); ?>

        <?php else : ?>

            <div class="empty-posts">
                <h2>No posts published yet.</h2>
                <p>Your posts will appear here when you publish them.</p>
            </div>

        <?php endif; ?>

    </section>
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
