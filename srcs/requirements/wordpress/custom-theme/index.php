<?php

// ------------------------ DEFAULT WORDPRESS TEMPLATE ------------------------

get_header();

// ------------------------ CONTENT ------------------------

if (have_posts())
{
    while (have_posts())
    {
        the_post();
        the_content();
    }
}

// ------------------------ FOOTER ------------------------

get_footer();